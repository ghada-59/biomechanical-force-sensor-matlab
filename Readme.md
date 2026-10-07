# Biomechanical Force Sensor Signal Processing & Calibration — MATLAB

## Overview

This repository contains a compact MATLAB simulation of a biomechanical force-sensor processing pipeline.

The project demonstrates how a sensor-oriented measurement workflow can transform a noisy voltage signal into a calibrated force estimate and extract a peak-force measurement.

**Scope:** simulation only. No physical sensor, patient data, or clinical validation is involved.

## Engineering Workflow

    Reference force profile
            ↓
    Simulated force sensor
            ↓
    Voltage signal + measurement noise
            ↓
    4th-order Butterworth low-pass filter
            ↓
    Filtered sensor signal
            ↓
    Linear sensor calibration
            ↓
    Estimated force (N)
            ↓
    Peak-force detection
            ↓
    Quantitative evaluation

## What the Project Demonstrates

- Sensor-output simulation in volts (V)
- Reproducible measurement-noise generation
- Low-pass signal conditioning
- Butterworth filtering with zero-phase filtering
- Linear sensor calibration using first-order regression
- Conversion from voltage to force (N)
- Peak-force detection
- RMSE-based estimation error evaluation
- Visualization of raw/filtered signals and force estimation

## Processing Details

### 1. Force-profile simulation

A simplified time-varying force profile is generated with a main peak, release phase, secondary event, and small low-frequency variation.

The signal is synthetic and is used as a reference for evaluating the processing pipeline.

### 2. Sensor model

The reference force is converted to an ideal sensor voltage using a linear model:

    Force (N) = sensitivity × Voltage (V) + offset

The simulated sensor uses a nominal sensitivity of **50 N/V** and an offset of **-5 N**.

Gaussian measurement noise is then added to the voltage signal.

### 3. Signal conditioning

The noisy voltage is processed with a **4th-order Butterworth low-pass filter**.

| Parameter | Value |
|---|---:|
| Sampling frequency | 1000 Hz |
| Cutoff frequency | 10 Hz |
| Filter order | 4 |
| Filtering method | Zero-phase filtering |

### 4. Calibration

Six known force points are used for a first-order voltage-to-force calibration:

    0, 25, 50, 75, 100, 125 N

The calibration coefficients are estimated with a first-order polynomial fit, and the fit quality is reported using R².

**Important:** R² measures the fit to the calibration points used to estimate the calibration line. It is not an independent validation score.

### 5. Force estimation and peak detection

The filtered voltage is converted to estimated force using the **calculated calibration coefficients**. The maximum estimated force and its corresponding time are then detected automatically.

### 6. Error evaluation

The project reports:

- Calibration slope and offset
- Calibration R²
- Reference peak force
- Estimated peak force
- Peak-force time
- RMSE in Newtons
- RMSE normalized by the mean reference force

The last metric is reported as:

    Normalized RMSE (%) = RMSE / mean(reference force) × 100

## Results

Results from the reproducible simulation (random seed = 42):

| Metric | Result |
|---|---:|
| Calibration slope | 49.9695 N/V |
| Calibration offset | -5.0421 N |
| Calibration R² | 1.0000 |
| Reference peak | 123.43 N |
| Estimated peak | 123.27 N |
| Peak time | 4.089 s |
| RMSE | 0.8478 N |
| Normalized RMSE | 1.57% |

The estimated peak differs from the simulated reference peak by approximately **0.16 N (0.13%)**.

These results describe the behavior of the simulated pipeline only; they do **not** represent accuracy of a physical or medical device.

## Visualization

The generated figure contains two panels:

1. **Raw vs filtered sensor voltage** — shows the effect of low-pass filtering on measurement noise.
2. **Calibrated force estimation** — compares reference and estimated force, displays ±5% tolerance boundaries, and marks the detected peak.

![Biomechanical force sensor analysis](results/Biomechanical%20Force%20Sensor%20Analysis.png)

## How to Run

### Requirements

- MATLAB
- **Signal Processing Toolbox** for Butterworth filtering

No external dataset is required.

### Run

Open main.m in MATLAB and execute:

    main

The script generates the analysis figure and prints the numerical results in the MATLAB Command Window.

## Repository Structure

    biomechanical-force-sensor-matlab/
    ├── main.m
    ├── README.md
    └── results/
        └── Biomechanical Force Sensor Analysis.png

## Why This Project

This mini-project was created to practice a complete biomedical instrumentation workflow:

**sensor signal → signal conditioning → calibration → force estimation → measurement evaluation**

It complements medical-imaging and biomedical-AI projects by demonstrating a different engineering skill set: **sensor data processing and quantitative measurement analysis in MATLAB**.

## Limitations and Possible Extensions

This project is intentionally small and simulation-based. Possible next steps include:

- Replacing the synthetic signal with recorded sensor data
- Adding independent calibration and validation datasets
- Comparing different filtering strategies
- Quantifying peak-force error separately from overall RMSE
- Testing robustness across different noise levels
- Exporting processed measurements for further analysis

## Author

**Ghada Boughrara**  
Biomedical Engineering Student — ESPITA, Tunisia
