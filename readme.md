# GNSS Dataset — User Manual

> **Scope.** This manual explains how to organize your data, run the **post-processing** pipeline, and generate **plots** (skyplot, C/N₀ over time, Doppler over time, and PVT trajectory with hAcc/vAcc) from **u-blox UBX** logs exported as **JSON**. It also details what each processed output contains, what each **UBX message** means, and how to read a real **RXM-RAWX** file.

---

## Table of Contents

* [1. Requirements & Environment](#1-requirements--environment)
* [2. Folder Structure](#2-folder-structure)
* [3. Scripts & Purpose](#3-scripts--purpose)
* [4. Step-by-Step Execution](#4-step-by-step-execution)
* [5. Processed Outputs: Content & Uses](#5-processed-outputs-content--uses)
* [6. UBX Messages (What they are / Why they matter)](#6-ubx-messages-what-they-are--why-they-matter)
* [7. What “raw data” means in the paper](#7-what-raw-data-means-in-the-paper)
* [8. Anatomy of an RXM-RAWX (real file)](#8-anatomy-of-an-rxm-rawx-real-file)
* [9. Glossary](#9-glossary)
* [Useful Commands (summary)](#useful-commands-summary)

---
## Dataset
* If you want to download the dataset please go to these repositories. 

  - GNSS Dataset (with Interference and Spoofing) Part I (https://data.mendeley.com/datasets/ccdgjcfvn5/1)
  - GNSS Dataset (with Interference and Spoofing) Part II (https://data.mendeley.com/datasets/h43s4d4zfn/1)
  - GNSS Dataset (with Interference and Spoofing) Part III (https://data.mendeley.com/datasets/nxk9r22wd6/1)

* Original Papper:

  - GNSS interference and spoofing dataset (https://www.sciencedirect.com/science/article/pii/S2352340924002713?ref=pdf_download&fr=RR-2&rr=90ca5490ce63eda7)

* To download U Center program

  - U Center: https://www.u-blox.com/en/product/u-center

* Hardware:
  
  - Go to hardware folder


## 1. Requirements & Environment

* **Python** 3.8+
* Packages: `numpy` (required) and `matplotlib` (for charts)
* (Recommended) **Conda** environment:

  ```bash
  conda create -n gnss python=3.10 -y
  conda activate gnss
  pip install numpy matplotlib
  ```

---

## 2. Folder Structure

### 2.1 Raw inputs → Processed outputs

```
GNSS_dataset/
├─ Raw_data/
│  └─ <day>/                 # e.g., 12
│     └─ <hour>/             # 0..23
│        ├─ RXM-RAWX/        # ~3600 JSON/hour (1 Hz)
│        ├─ NAV-PVT/
│        ├─ NAV-POSECEF/
│        ├─ NAV-CLOCK/
│        └─ NAV-DOP/
└─ Processed data/
   └─ <day>/
      ├─ observation<hour>.json
      ├─ satelliteInfomation<hour>.json
      └─ pvtSolution<hour>.json
```

> Respect capitalization/spaces (e.g., `Processed data/` vs `processed data/`). Each **hour** needs its subfolders and JSONs.

---

## 3. Scripts & Purpose

* **`read_raw_data.py`** – Verifies raw files per `<day>/<hour>/<UBX-TYPE>/`.
* **`extract_process_data.py`** – Produces per-hour:

  1. `observationHH.json`  ← **RXM-RAWX** (per-signal measurements)
  2. `satelliteInfomationHH.json` ← **NAV-SAT** (per-SV status)
  3. `pvtSolutionHH.json`  ← **NAV-PVT/POSECEF/CLOCK/DOP** (PVT + clock + DOP).
* **`read_processed_data.py`** – Quick viewer of processed outputs.
* **`graphics.py`** – Skyplot, C/N₀(t) & Doppler(t) for **used** SVs, PVT trajectory + hAcc/vAcc(t), all aligned by `recordTime`.

---

## 4. Step-by-Step Execution

### 4.1 Activate environment

```bash
conda activate gnss
pip install numpy matplotlib
```

### 4.2 (Optional) Inspect raw inputs

```bash
python read_raw_data.py
```

### 4.3 Post-process

Set `my_days` / `my_hours` inside `extract_process_data.py` and run:

```bash
python extract_process_data.py
```

Outputs (e.g., day 12, hour 14):

```
Processed data/12/observation14.json
Processed data/12/satelliteInfomation14.json
Processed data/12/pvtSolution14.json
```

### 4.4 Plot

(WSL example)

```bash
python3 graphics.py --base "../GNSS_Processing/GNSS_dataset/Processed data/12" --hour 14 --save
```

`--base` → folder holding the three JSONs for that hour; `--hour` → matches file suffix `HH`; `--save` → writes PNGs.

---

## 5. Processed Outputs: Content & Uses

### 5.1 `observation<hour>.json` (from **RXM-RAWX**)

* **Content:** 1 Hz time series per constellation/band (`G1/G2`, `E1/E2`, `B1/B2`, `Q1/Q2`, `R1/R2`): `cn0_*` (dB-Hz), `prMes_*` (m), `cpMes_*` (cycles), `doMes_*` (Hz), STDs (`prStd_*`, `cpStd_*`, `doStd_*`), and `VS*` with SVID column order.
* **Use:** Per-SV time analysis (C/N₀, Doppler, phase slips, lock loss), PPP/RTK/RINEX, RF fingerprinting features.

### 5.2 `satelliteInfomation<hour>.json` (from **NAV-SAT**)

* **Content:** `svId_*`, `svUsed_*` (used in solution), `cno_*`, `elev_*`, `azim_*`, `prRes_*`, `qualityInd_*`, `health_*`, `recordTime`, `numSvs`.
* **Use:** Skyplot, which SVs are used and their quality, multipath/interference diagnosis, alignment with `observation`.

### 5.3 `pvtSolution<hour>.json` (from **NAV-PVT/POSECEF/CLOCK/DOP**)

* **Content:** PVT (`lon/lat/height/hMSL`, `velN/E/D`, `gSpeed`, `headMot`, `hAcc/vAcc/sAcc`, `numSV`, `nano`), ECEF (`ecefX/Y/Z`), Clock (`clkB`, `clkD`, `tAcc`, `fAcc`), DOPs (`g/p/t/v/h/n/e`).
* **Use:** Trajectory (LLA/ECEF), kinematics, accuracy/DOP, clock stability/bias.

---

## 6. UBX Messages (What they are / Why they matter)

* **MON-SPAN (UBX-MON-SPAN):** 

   RF spectrum snapshot (FFT bin power, bandwidth, jamming/CW indicators, AGC). Use: noise/interference/jamming diagnosis.


* **NAV-CLOCK (UBX-NAV-CLOCK)** 

   Clock solution (bias ns, drift ns/s, timeAcc/freqAcc). Use: pseudorange correction, oscillator stability.

* **NAV-DOP (UBX-NAV-DOP)** 

   Dilution of Precision (GDOP, PDOP, TDOP, VDOP, HDOP, NDOP, EDOP). Use: geometry quality.

* **NAV-POSECEF (UBX-NAV-POSECEF)** 

   Position in ECEF (X/Y/Z cm, pAcc). Use: ECEF-frame integrations.

* **NAV-PVT (UBX-NAV-PVT)**

   Position-Velocity-Time (fixType, lat/lon, heights, velocities, heading, accuracies, numSV, flags). Use: ready-to-use nav solution.


* **NAV-SAT (UBX-NAV-SAT)** 

   Per-SV status (system, ID, C/N₀, elevation, azimuth, tracking/quality, used-in-solution, health).

* **RXM-RAWX (UBX-RXM-RAWX)**

   Raw measurements per channel (pseudorange, carrier phase, Doppler, C/N₀, signal IDs, locktime, flags; plus rcvTow/week, leap seconds). Use: RINEX/PPP/RTK, bias estimation, research, RF fingerprinting.

---

## 7. What “raw data” means in the paper

“Raw data” are the **original u-blox UBX logs**, stored as **hourly JSONs**: **MON-SPAN, NAV-CLOCK, NAV-DOP, NAV-POSECEF, NAV-PVT, NAV-SAT, RXM-RAWX**. The authors derive **processed** files regrouped **by satellite–time** from those logs. These are **not** baseband I/Q traces; **RXM-RAWX** provides receiver-level code/phase/Doppler/C/N₀ measurements, not IQ.

---

## 8. Anatomy of an RXM-RAWX (real file)

File: **`2023-09-12 00-00-00.json`**

### 8.1 Epoch header

* `start_time`: **2023-09-12 00:00:00**
* `rcvTow`: **144017.008** s (GPS time)
* `week`: **2279**
* `leapS`: **18**  / `leapSec`: **1**
* `numMeas`: **50**

### 8.2 Per-measurement structure “i” (i = 1..numMeas)

`gnssId_i` (0=GPS,1=SBAS,2=GAL,3=BDS,4=IMES,5=QZSS,6=GLO), `svId_i`, `sigId_i` (chip-dependent; e.g., GPS 0=L1 C/A, 3=L2C), `freqId_i` (GLO only), `prMes_i` (m), `cpMes_i` (cycles), `doMes_i` (Hz), `cno_i` (dB-Hz), `locktime_i` (ms), `prStd_i/cpStd_i/doStd_i`, `prValid_i/cpValid_i`, `halfCyc_i/subHalfCyc_i`.

### 8.3 Numerical examples (from this file)

* **i=1**: GPS PRN 7, `prMes=24516297.33 m`, `cpMes=1.2883397426e8 cycles`, `doMes=2324.89 Hz`, `cno=31 dB-Hz`, `locktime=57000 ms`, `prStd=6`, `cpStd=9`, `doStd=9`, `prValid=1`, `cpValid=1`, `halfCyc=1`, `subHalfCyc=1`.
* **i=2**: Galileo 21, `prMes=27221056.36 m`, `cpMes=1.4304762285e8 cycles`, `doMes=-859.46 Hz`, `cno=43 dB-Hz`, `locktime=64500 ms`, `prStd=3`, `cpStd=1`, `doStd=6`, `prValid=1`, `cpValid=1`, `halfCyc=1`, `subHalfCyc=0`.

---

## 9. Glossary

* **GNSS**: Global Navigation Satellite System (GPS, GLONASS, Galileo, BeiDou, QZSS, SBAS, IMES).
* **SV / SVID / PRN**: Space Vehicle (satellite). SVID/PRN is the satellite identifier within its constellation.
* **Nsv**: Number of satellites represented in a 1×Nsv row (width of matrices such as `cn0_G1[t]`).
* **numSvs / numSV / numMeas**: In NAV-SAT = reported SVs; in NAV-PVT = SVs used in the solution; in RXM-RAWX = measurement count (may be ≥ satellites due to multi-band).
* **C/N₀ (dB-Hz)**: Carrier-to-noise density ratio; higher → better tracking.
* **PVT**: Position-Velocity-Time solution (lat/lon/height, velocities, time).
* **DOP (GDOP/PDOP/HDOP/VDOP/TDOP/NDOP/EDOP)**: Geometry-driven error amplification; higher → worse precision.
* **ECEF / ENU / LLA**: Earth-Centered Earth-Fixed; East-North-Up local frame; Latitude-Longitude-Altitude.
* **hMSL vs height**: Height above mean sea level vs ellipsoidal height.
* **rcvTow / week**: Receiver time-of-week (s) and GPS week index at the epoch.
* **leapS / leapSec**: Leap seconds handled by the receiver.
* **prMes / cpMes / doMes**: Pseudorange (m), carrier phase (cycles), Doppler (Hz).
* **locktime**: Milliseconds since lock acquisition on the signal.
* **prStd / cpStd / doStd**: Encoded uncertainty estimates (smaller ≈ better).
* **prValid / cpValid**: Validity flags for code and phase measurements.
* **halfCyc / subHalfCyc**: Half-cycle indicators for phase; `subHalfCyc=1` means the receiver compensated ½ cycle in `cpMes`.
* **sigId / freqId**: Signal ID (band/modulation); GLONASS frequency channel index.
* **VS***: List giving SVID column order for the 1×Nsv rows in `observation`.
* **svUsed**: Flag indicating a satellite was used in the PVT solution.
* **Skyplot**: Polar plot of satellites (radius = 90°−elevation, angle = azimuth).
* **PPP / RTK / RINEX**: Precise Point Positioning; Real-Time Kinematic; standard format for GNSS observations.
* **AGC**: Automatic Gain Control (relevant in MON-SPAN/jamming diagnostics).
* **clkB / clkD / tAcc / fAcc**: Clock bias (ns), drift (ns/s), time accuracy, frequency accuracy.
* **gSpeed / headMot**: Ground speed and heading of motion from NAV-PVT.
* **health / qualityInd / prRes**: Satellite health, tracking quality index, pseudorange residual (NAV-SAT).
* **Multipath / CW / Jamming**: Reflections causing errors; continuous-wave interference; intentional interference.
* **Cycle slip**: Sudden carrier-phase jump (loss/reacquisition or severe dynamics).

---

## Useful Commands (summary)

```bash
# Activate environment
conda activate gnss

# Check raw inputs
python read_raw_data.py

# Post-process (set days/hours in the script)
python extract_process_data.py

# Plot (WSL; adjust --base and --hour)
python3 graphics.py --base "../GNSS_dataset/Processed data/12" --hour 14 --save
```
