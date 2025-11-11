#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GNSS Mini Workflow
==================
Generates three kinds of plots from "processed" JSON files produced by
extract_process_data.py:
  (a) Skyplot (azimuth/elevation) for the selected hour.
  (b) C/N0(t) and Doppler(t) time series for satellites *used* in the solution.
  (c) PVT trajectory and accuracy (hAcc, vAcc) vs time.

USAGE (Windows example):
    python gnss_mini_workflow.py --base "GNSS_dataset\\Processed data\\12" --hour 14

USAGE (Linux/macOS example):
    python gnss_mini_workflow.py --base "GNSS_dataset/Processed data/12" --hour 14

Dependencies:
    pip install numpy matplotlib

Notes:
 - The script is defensive about field names and shapes. It tries to work with the
   JSON structure described in your project.
 - Each chart is built in its own figure (no subplots), and no specific colors are set.
"""

import os, json, math, argparse, glob
from datetime import datetime
from typing import Dict, List, Tuple, Optional

import numpy as np
import matplotlib.pyplot as plt


# ----------------------------- IO utilities -----------------------------

def load_json(path: str) -> Dict:
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def find_hour_from_filename(fname: str) -> Optional[int]:
    """
    Extract the <hour> from filenames like 'observation14.json', 'pvtSolution07.json', etc.
    Returns None if pattern not found.
    """
    base = os.path.basename(fname)
    for i in range(0, 24):
        token = f"{i:02d}" if f"{i:02d}" in base else str(i)
        # We need to ensure the token is the trailing numeric in the stem
        # Simplify: try both
        if base.endswith(f"{i}.json") or base.endswith(f"{i:02d}.json"):
            return i
    # Fallback: parse any trailing digits before '.json'
    stem = os.path.splitext(base)[0]
    digits = ''.join([c for c in stem if c.isdigit()])
    if digits.isdigit():
        try:
            val = int(digits[-2:]) if len(digits) >= 2 else int(digits)
            if 0 <= val <= 23:
                return val
        except:
            pass
    return None

def list_available_hours(base_dir: str) -> List[int]:
    hours = set()
    for patt in ["observation*.json", "pvtSolution*.json", "satelliteInfomation*.json"]:
        for f in glob.glob(os.path.join(base_dir, patt)):
            h = find_hour_from_filename(f)
            if h is not None:
                hours.add(h)
    return sorted(hours)


# ----------------------------- Helpers -----------------------------

CONST_KEYS = {
    "G": "GPS",
    "E": "GAL",
    "B": "BDS",
    "Q": "QZSS",
    "R": "GLO",
}

def safe_get(d: Dict, key: str, default=None):
    return d[key] if key in d else default

def to_datetime_list(timestr_list: List[str]) -> List[datetime]:
    out = []
    for s in timestr_list:
        # Expected like "2023-09-12 14-00-00" (sometimes with colons). Be flexible.
        if isinstance(s, (int, float)):
            # If timestamp as seconds
            out.append(datetime.fromtimestamp(s))
            continue
        s2 = s.replace('-',':',2) if (' ' in s and '-' in s) else s  # keep date dashes; only first two '-' after space maybe colons
        s2 = s2.replace('T',' ').replace('/', '-')
        # Try multiple formats
        for fmt in ("%Y-%m-%d %H-%M-%S", "%Y-%m-%d %H:%M:%S", "%Y/%m/%d %H:%M:%S", "%Y-%m-%d %H-%M-%S.%f", "%Y-%m-%d %H:%M:%S.%f"):
            try:
                out.append(datetime.strptime(s2, fmt))
                break
            except Exception:
                pass
        else:
            # last resort: return as-is with now()
            out.append(datetime.now())
    return out

def ensure_TxN(list_of_rows: List[List[float]]) -> np.ndarray:
    """Convert list-of-rows to numpy array [T, N] (or [T] if scalars)."""
    if not isinstance(list_of_rows, list):
        return np.array([])
    if len(list_of_rows) == 0:
        return np.zeros((0,0))
    # Some JSONs may store 1xN rows; some may store scalars.
    if isinstance(list_of_rows[0], list):
        return np.array([np.array(r, dtype=float) for r in list_of_rows], dtype=float)
    else:
        # 1D time series → shape [T, 1]
        return np.array(list_of_rows, dtype=float).reshape(-1, 1)

def sanitize(arr: np.ndarray) -> np.ndarray:
    """Replace sentinel values like 0.11 with NaN, keep zeros as zeros."""
    if arr.size == 0:
        return arr
    out = arr.copy()
    out[np.isclose(out, 0.11, atol=1e-9)] = np.nan
    return out

def get_used_svids_per_const(sat_info: Dict, t_idx: int) -> Dict[str, List[int]]:
    """
    For a given time index, return dict like:
        {'G': [3,7,19], 'E': [5,12], ...}
    where values are svIds with svUsed == 1.
    """
    used = {}
    for c in CONST_KEYS.keys():
        svId_key = f"svId_{c}"
        used_key = f"svUsed_{c}"
        svIds_row = safe_get(sat_info, svId_key, [])
        used_row  = safe_get(sat_info, used_key, [])
        if isinstance(svIds_row, list) and len(svIds_row) > t_idx:
            svIds_t = svIds_row[t_idx]
            used_t  = used_row[t_idx] if (isinstance(used_row, list) and len(used_row) > t_idx) else []
            if isinstance(svIds_t, list) and isinstance(used_t, list):
                used_list = [int(sv) for sv, u in zip(svIds_t, used_t) if (u == 1 or u == True)]
                if used_list:
                    used[c] = used_list
    return used

def guess_vs_map(obs: Dict, const_char: str, t_idx: int, fallback_sv_list: List[int]) -> List[int]:
    """
    Try to recover the mapping SVID -> column index for observation arrays.
    Priority:
      1) VS list inside observation JSON (e.g., 'VSG','VSE','VSB','VSQ','VSR')
      2) svId_* list from satelliteInfomation (fallback_sv_list)
    Returns a list of SVIDs in the same order as columns (length = N columns for *_G1 arrays at t_idx).
    """
    # Try variants: 'VS' + c, 'VS_'+c
    for key in (f"VS{const_char}", f"VS_{const_char}"):
        vs = safe_get(obs, key, None)
        if isinstance(vs, list):
            # If list is [T] of [list of svIds], pick time t_idx if nested
            if len(vs) > 0 and isinstance(vs[0], list):
                if t_idx < len(vs):
                    return [int(x) for x in vs[t_idx]]
            else:
                # single list
                return [int(x) for x in vs]
    # Fallback: use list from sat info (already per time)
    return list(fallback_sv_list)

def pick_top_k_used(sat_info: Dict, k: int = 4) -> List[Tuple[str, int]]:
    """
    Select top-k (constellation, svid) pairs most frequently 'used' across time.
    """
    counts = {}
    T = len(safe_get(sat_info, 'recordTime', []))
    for t in range(T):
        used = get_used_svids_per_const(sat_info, t)
        for c, svids in used.items():
            for s in svids:
                counts[(c, s)] = counts.get((c, s), 0) + 1
    ranked = sorted(counts.items(), key=lambda kv: kv[1], reverse=True)
    return [pair for pair, _ in ranked[:k]]

def first_available_key(d: Dict, keys: List[str]):
    for k in keys:
        if k in d:
            return k
    return None


# ----------------------------- Plotters -----------------------------

def plot_skyplot(sat_info: Dict, hour: int, out_png: Optional[str] = None):
    """
    Build a skyplot for the *last epoch* of the specified hour.
    Uses 'azim_*' and 'elev_*' arrays.
    """
    times = safe_get(sat_info, 'recordTime', [])
    if not isinstance(times, list) or len(times) == 0:
        print("[skyplot] No recordTime found; skipping.")
        return
    T = len(times)
    t_idx = T - 1  # last epoch

    az_all = []
    el_all = []
    for c in CONST_KEYS.keys():
        az_key = f"azim_{c}"
        el_key = f"elev_{c}"
        az = safe_get(sat_info, az_key, [])
        el = safe_get(sat_info, el_key, [])
        if isinstance(az, list) and len(az) > t_idx and isinstance(az[t_idx], list):
            az_row = np.array(az[t_idx], dtype=float)
            el_row = np.array(el[t_idx], dtype=float) if (isinstance(el, list) and len(el) > t_idx and isinstance(el[t_idx], list)) else np.array([])
            if el_row.size == az_row.size and el_row.size > 0:
                az_all.append(az_row)
                el_all.append(el_row)
    if len(az_all) == 0:
        print("[skyplot] No azim/elev rows found; skipping.")
        return
    az_arr = np.concatenate(az_all)
    el_arr = np.concatenate(el_all)

    # Convert to radians; skyplot radius = 90 - elev (0 at zenith)
    theta = np.deg2rad(az_arr)
    r = 90.0 - el_arr

    fig = plt.figure()
    ax = plt.subplot(111, projection='polar')
    ax.set_theta_zero_location('N')  # 0 deg at North
    ax.set_theta_direction(-1)       # clockwise
    ax.set_rlim(0, 90)
    ax.set_title(f"Skyplot (hour={hour:02d})")
    ax.scatter(theta, r, s=20)  # default colors/markers
    if out_png:
        fig.savefig(out_png, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_cno_time(obs: Dict, sat_info: Dict, hour: int, out_png: Optional[str] = None):
    """
    Plot C/N0 over time for the top-k 'used' satellites.
    Prefer CN0 from observation (per band G1/E1 as default). If mapping is
    ambiguous, fallback to CN0 series from satelliteInfomation.
    """
    times = safe_get(sat_info, 'recordTime', [])
    if not isinstance(times, list) or len(times) == 0:
        print("[C/N0] No recordTime found; skipping.")
        return
    t_dt = to_datetime_list(times)
    T = len(t_dt)

    # Top-k used across time
    top = pick_top_k_used(sat_info, k=4)
    if not top:
        print("[C/N0] No 'used' satellites found; skipping.")
        return

    # Candidate observation CN0 keys by band preference (L1/E1 as default)
    cn0_keys_by_const = {
        'G': ['cn0_G1', 'cn0_G2'],
        'E': ['cn0_E1', 'cn0_E2'],
        'B': ['cn0_B1', 'cn0_B2'],
        'Q': ['cn0_Q1', 'cn0_Q2'],
        'R': ['cn0_R1', 'cn0_R2'],
    }

    # Fallback sat-info CN0 keys
    cn0_satinfo_keys = {
        'G': 'cno_G',
        'E': 'cno_E',
        'B': 'cno_B',
        'Q': 'cno_Q',
        'R': 'cno_R',
    }

    fig = plt.figure()
    plt.title(f"C/N0 vs time (hour={hour:02d}) - used SVs")
    for c, svid in top:
        # 1) Try observation mapping
        series = np.full((T,), np.nan)
        preferred = cn0_keys_by_const.get(c, [])
        obs_key = first_available_key(obs, preferred) if preferred else None
        if obs_key is not None:
            arr = ensure_TxN(safe_get(obs, obs_key, []))
            arr = sanitize(arr)
            # Build mapping per time step
            for t in range(T):
                # Candidate mapping list (VS) or fallback to sat-info SVID ordering
                svIds_row = safe_get(sat_info, f"svId_{c}", [])
                svIds_list = svIds_row[t] if (isinstance(svIds_row, list) and len(svIds_row) > t) else []
                map_list = guess_vs_map(obs, c, t, svIds_list)
                if arr.shape[0] > t and len(map_list) == arr.shape[1]:
                    if svid in map_list:
                        j = map_list.index(svid)
                        series[t] = arr[t, j]
        # 2) Fallback to sat-info CN0 if still all-NaN
        if np.all(np.isnan(series)):
            key = cn0_satinfo_keys.get(c, None)
            vals = safe_get(sat_info, key, [])
            if isinstance(vals, list) and len(vals) == T:
                for t in range(T):
                    svIds_list = safe_get(sat_info, f"svId_{c}", [])
                    svIds_t = svIds_list[t] if (isinstance(svIds_list, list) and len(svIds_list) > t) else []
                    cno_t = vals[t] if (isinstance(vals[t], list)) else []
                    if isinstance(cno_t, list) and len(cno_t) == len(svIds_t):
                        for sv, cn in zip(svIds_t, cno_t):
                            if int(sv) == int(svid):
                                series[t] = float(cn)
                                break
        # Plot if anything valid
        if not np.all(np.isnan(series)):
            plt.plot(t_dt, series, label=f"{c}{svid}")
    plt.xlabel("Time")
    plt.ylabel("C/N0 (dB-Hz)")
    plt.legend()
    if out_png:
        fig.savefig(out_png, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_doppler_time(obs: Dict, sat_info: Dict, hour: int, out_png: Optional[str] = None):
    """
    Plot Doppler over time for the same top-k 'used' satellites, using observation doMes_*.
    """
    times = safe_get(sat_info, 'recordTime', [])
    if not isinstance(times, list) or len(times) == 0:
        print("[Doppler] No recordTime found; skipping.")
        return
    t_dt = to_datetime_list(times)
    T = len(t_dt)

    top = pick_top_k_used(sat_info, k=4)
    if not top:
        print("[Doppler] No 'used' satellites found; skipping.")
        return

    do_keys_by_const = {
        'G': ['doMes_G1', 'doMes_G2'],
        'E': ['doMes_E1', 'doMes_E2'],
        'B': ['doMes_B1', 'doMes_B2'],
        'Q': ['doMes_Q1', 'doMes_Q2'],
        'R': ['doMes_R1', 'doMes_R2'],
    }

    fig = plt.figure()
    plt.title(f"Doppler vs time (hour={hour:02d}) - used SVs")
    for c, svid in top:
        series = np.full((T,), np.nan)
        preferred = do_keys_by_const.get(c, [])
        obs_key = first_available_key(obs, preferred) if preferred else None
        if obs_key is not None:
            arr = ensure_TxN(safe_get(obs, obs_key, []))
            arr = sanitize(arr)
            for t in range(T):
                svIds_row = safe_get(sat_info, f"svId_{c}", [])
                svIds_list = svIds_row[t] if (isinstance(svIds_row, list) and len(svIds_row) > t) else []
                map_list = guess_vs_map(obs, c, t, svIds_list)
                if arr.shape[0] > t and len(map_list) == arr.shape[1]:
                    if svid in map_list:
                        j = map_list.index(svid)
                        series[t] = arr[t, j]
        if not np.all(np.isnan(series)):
            plt.plot(t_dt, series, label=f"{c}{svid}")
    plt.xlabel("Time")
    plt.ylabel("Doppler (Hz)")
    plt.legend()
    if out_png:
        fig.savefig(out_png, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_pvt_and_accuracy(pvt: Dict, hour: int, out_png_traj: Optional[str] = None, out_png_acc: Optional[str] = None):
    """
    Plot (1) trajectory in lon-lat and (2) horizontal/vertical accuracy vs time.
    """
    times = safe_get(pvt, 'recordTime', [])
    if not isinstance(times, list) or len(times) == 0:
        print("[PVT] No recordTime found; skipping.")
        return
    t_dt = to_datetime_list(times)

    lon = np.array(safe_get(pvt, 'lon', []), dtype=float)
    lat = np.array(safe_get(pvt, 'lat', []), dtype=float)
    hAcc = np.array(safe_get(pvt, 'hAcc', []), dtype=float)
    vAcc = np.array(safe_get(pvt, 'vAcc', []), dtype=float)

    # (1) Trajectory
    fig1 = plt.figure()
    plt.title(f"PVT trajectory (hour={hour:02d})")
    if lon.size and lat.size:
        plt.plot(lon, lat, marker='.', linestyle='-')
        plt.xlabel("Longitude (deg)")
        plt.ylabel("Latitude (deg)")
        plt.axis('equal')
    else:
        plt.text(0.5, 0.5, "No lon/lat data", ha='center', va='center')
    if out_png_traj:
        fig1.savefig(out_png_traj, bbox_inches="tight")
    plt.show()
    plt.close(fig1)

    # (2) Accuracy bars vs time
    fig2 = plt.figure()
    plt.title(f"Accuracy vs time (hour={hour:02d})")
    if hAcc.size:
        plt.plot(t_dt, hAcc, label='hAcc (m)')
    if vAcc.size:
        plt.plot(t_dt, vAcc, label='vAcc (m)')
    plt.xlabel("Time")
    plt.ylabel("Accuracy (m)")
    plt.legend()
    if out_png_acc:
        fig2.savefig(out_png_acc, bbox_inches="tight")
    plt.show()
    plt.close(fig2)


# ----------------------------- Main -----------------------------

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True, help="Base directory containing processed JSONs, e.g., 'GNSS_dataset\\Processed data\\12'")
    parser.add_argument("--hour", type=int, default=None, help="Hour to process (0-23). If omitted, the script will try to pick one automatically.")
    parser.add_argument("--save", action="store_true", help="If set, saves PNGs in the base directory.")
    args = parser.parse_args()

    base = args.base
    if not os.path.isdir(base):
        raise SystemExit(f"[ERR] Base directory not found: {base}")

    # Resolve hour
    hour = args.hour
    if hour is None:
        hours = list_available_hours(base)
        if not hours:
            raise SystemExit("[ERR] No observation/pvtSolution/satelliteInfomation JSONs found in base directory.")
        hour = hours[-1]
        print(f"[INFO] No --hour given. Using detected hour: {hour:02d}")

    def path_of(name: str) -> str:
        return os.path.join(base, f"{name}{hour}.json")

    obs_path = path_of("observation")
    pvt_path = path_of("pvtSolution")
    sat_path = path_of("satelliteInfomation")

    for p in (obs_path, pvt_path, sat_path):
        if not os.path.isfile(p):
            raise SystemExit(f"[ERR] Missing file: {p}")

    print(f"[INFO] Loading:\n  - {obs_path}\n  - {sat_path}\n  - {pvt_path}")
    obs = load_json(obs_path)
    sat = load_json(sat_path)
    pvt = load_json(pvt_path)

    # Produce plots
    out_dir = base if args.save else None
    sky_png = os.path.join(out_dir, f"skyplot_{hour:02d}.png") if out_dir else None
    cno_png = os.path.join(out_dir, f"cno_{hour:02d}.png") if out_dir else None
    do_png  = os.path.join(out_dir, f"doppler_{hour:02d}.png") if out_dir else None
    traj_png= os.path.join(out_dir, f"trajectory_{hour:02d}.png") if out_dir else None
    acc_png = os.path.join(out_dir, f"accuracy_{hour:02d}.png") if out_dir else None

    plot_skyplot(sat, hour, out_png=sky_png)
    plot_cno_time(obs, sat, hour, out_png=cno_png)
    plot_doppler_time(obs, sat, hour, out_png=do_png)
    plot_pvt_and_accuracy(pvt, hour, out_png_traj=traj_png, out_png_acc=acc_png)

    print("[DONE] Plots generated.")

if __name__ == "__main__":
    main()
