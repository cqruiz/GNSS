#!/usr/bin/env python3
from __future__ import annotations
import argparse
import os
from pathlib import Path
import zipfile
import tarfile
import gzip
import bz2
import lzma
import shutil
import sys

# Intento opcional de soporte 7z
try:
    import py7zr  # pip install py7zr
    HAS_PY7ZR = True
except Exception:
    HAS_PY7ZR = False

# Extensiones soportadas
TAR_EXTS = (".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tbz2", ".tar.xz", ".txz")
ZIP_EXTS = (".zip",)
SEVENZ_EXTS = (".7z",)
SINGLE_FILE_EXTS = (".gz", ".bz2", ".xz")  # Solo cuando NO son .tar.*

def _normalize_case_suffixes(name: str) -> str:
    """Normaliza a minúsculas solo para comparación por sufijos."""
    return name.lower()

def _is_tar_archive(p: Path) -> bool:
    name = _normalize_case_suffixes(p.name)
    return any(name.endswith(ext) for ext in TAR_EXTS)

def _is_zip_archive(p: Path) -> bool:
    return _normalize_case_suffixes(p.suffix) in ZIP_EXTS

def _is_7z_archive(p: Path) -> bool:
    return _normalize_case_suffixes(p.suffix) in SEVENZ_EXTS

def _is_single_file_compressed(p: Path) -> bool:
    """Detecta .gz/.bz2/.xz que NO sean .tar.*"""
    name = _normalize_case_suffixes(p.name)
    if any(name.endswith(ext) for ext in TAR_EXTS):
        return False
    return p.suffix.lower() in SINGLE_FILE_EXTS

def _base_name_without_archive_suffix(p: Path) -> str:
    """Quita el sufijo de archivo comprimido, considerando multi-extensiones (tar.gz, tgz, etc.)."""
    name = p.name
    lname = name.lower()
    # Ordenar por largo descendente para capturar .tar.gz antes que .gz
    for ext in sorted(TAR_EXTS + ZIP_EXTS + SEVENZ_EXTS, key=len, reverse=True):
        if lname.endswith(ext):
            return name[: -len(ext)]
    # Para .gz/.bz2/.xz simples, quita solo el último sufijo
    return p.stem

def _safe_join(base_dir: Path, target_path: str) -> Path:
    # Previene path traversal
    dest = (base_dir / target_path).resolve()
    if base_dir.resolve() not in dest.parents and dest != base_dir.resolve():
        raise RuntimeError(f"Extracción insegura detectada: {target_path}")
    return dest

def _safe_extract_tar(tar: tarfile.TarFile, path: Path) -> None:
    for member in tar.getmembers():
        _safe_join(path, member.name)  # valida
    tar.extractall(path)

def _safe_extract_zip(zf: zipfile.ZipFile, path: Path) -> None:
    for member in zf.namelist():
        _safe_join(path, member)
    zf.extractall(path)

def extract_archive(archive_path: Path, overwrite: bool = False, delete_archive: bool = False) -> str:
    """
    Extrae un archivo comprimido:
      - zip / tar.* → carpeta con mismo nombre del archivo (sin extensión).
      - .gz/.bz2/.xz (no tar) → archivo descomprimido en mismo directorio.
    """
    archive_path = archive_path.resolve()
    if not archive_path.is_file():
        return f"[SKIP] No es archivo: {archive_path}"

    try:
        if _is_tar_archive(archive_path):
            out_dir = archive_path.with_name(_base_name_without_archive_suffix(archive_path))
            if out_dir.exists() and not overwrite:
                return f"[SKIP] Carpeta destino ya existe: {out_dir}"
            out_dir.mkdir(parents=True, exist_ok=True)
            with tarfile.open(archive_path, mode="r:*") as tf:
                _safe_extract_tar(tf, out_dir)
            msg = f"[OK] TAR extraído en: {out_dir}"

        elif _is_zip_archive(archive_path):
            out_dir = archive_path.with_name(_base_name_without_archive_suffix(archive_path))
            if out_dir.exists() and not overwrite:
                return f"[SKIP] Carpeta destino ya existe: {out_dir}"
            out_dir.mkdir(parents=True, exist_ok=True)
            with zipfile.ZipFile(archive_path, "r") as zf:
                _safe_extract_zip(zf, out_dir)
            msg = f"[OK] ZIP extraído en: {out_dir}"

        elif _is_7z_archive(archive_path):
            if not HAS_PY7ZR:
                return f"[WARN] .7z detectado pero 'py7zr' no está instalado: {archive_path}"
            out_dir = archive_path.with_name(_base_name_without_archive_suffix(archive_path))
            if out_dir.exists() and not overwrite:
                return f"[SKIP] Carpeta destino ya existe: {out_dir}"
            out_dir.mkdir(parents=True, exist_ok=True)
            with py7zr.SevenZipFile(archive_path, mode="r") as z:
                z.extractall(path=str(out_dir))
            msg = f"[OK] 7z extraído en: {out_dir}"

        elif _is_single_file_compressed(archive_path):
            # .gz/.bz2/.xz → un solo archivo descomprimido
            dest = archive_path.with_suffix("")  # quita último sufijo
            if dest.exists() and not overwrite:
                return f"[SKIP] Archivo destino ya existe: {dest}"

            if archive_path.suffix.lower() == ".gz":
                opener = gzip.open
            elif archive_path.suffix.lower() == ".bz2":
                opener = bz2.open
            elif archive_path.suffix.lower() == ".xz":
                opener = lzma.open
            else:
                return f"[SKIP] Formato no reconocido: {archive_path.suffix}"

            with opener(archive_path, "rb") as f_in, open(dest, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)
            msg = f"[OK] Archivo descomprimido: {dest}"

        else:
            return f"[SKIP] No es un archivo comprimido soportado: {archive_path.name}"

        if delete_archive:
            try:
                os.remove(archive_path)
                msg += " (origen eliminado)"
            except Exception as e:
                msg += f" (no se pudo eliminar origen: {e})"

        return msg

    except Exception as e:
        return f"[ERR] {archive_path.name}: {e}"

def decompress_all(root: Path, recursive: bool = True, overwrite: bool = False, delete_archive: bool = False) -> None:
    root = root.resolve()
    if not root.exists():
        print(f"[ERR] Ruta no existe: {root}", file=sys.stderr)
        return

    files: list[Path] = []
    if root.is_file():
        files = [root]
    else:
        it = root.rglob("*") if recursive else root.glob("*")
        files = [p for p in it if p.is_file()]

    # Procesar solo lo que parezcan archivos comprimidos
    targets: list[Path] = []
    for p in files:
        if _is_tar_archive(p) or _is_zip_archive(p) or _is_7z_archive(p) or _is_single_file_compressed(p):
            targets.append(p)

    if not targets:
        print("[INFO] No se encontraron archivos comprimidos.")
        return

    print(f"[INFO] Encontrados {len(targets)} archivo(s) comprimido(s).")
    for p in sorted(targets):
        print(extract_archive(p, overwrite=overwrite, delete_archive=delete_archive))

def parse_args():
    ap = argparse.ArgumentParser(
        description="Descomprime archivos (.zip, .tar.*, .gz/.bz2/.xz, .7z) en el mismo path con el mismo nombre."
    )
    ap.add_argument("path", type=str, help="Ruta a archivo o carpeta raíz.")
    ap.add_argument("--no-recursive", action="store_true", help="No buscar recursivamente en subcarpetas.")
    ap.add_argument("--overwrite", action="store_true", help="Sobrescribir si el destino ya existe.")
    ap.add_argument("--delete-archive", action="store_true", help="Eliminar el archivo comprimido después de extraer.")
    return ap.parse_args()

if __name__ == "__main__":
    args = parse_args()
    decompress_all(
        Path(args.path),
        recursive=not args.no_recursive,
        overwrite=args.overwrite,
        delete_archive=args.delete_archive,
    )


