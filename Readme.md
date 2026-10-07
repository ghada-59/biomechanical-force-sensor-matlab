# Biomechanical Force Sensor Signal Processing & Calibration — MATLAB

## Overview

This project is a MATLAB-based simulation of a biomechanical force sensor measurement pipeline.

The objective is to demonstrate a complete signal-processing workflow, from a simulated sensor output to calibrated force estimation and peak-force detection.

The project focuses on fundamental biomedical engineering concepts including:

* Sensor signal acquisition simulation
* Measurement noise
* Low-pass signal filtering
* Sensor calibration
* Linear regression
* Force estimation
* Peak-force detection
* Quantitative error evaluation

> **Note:** This is a simulation-based engineering project. It does not use a physical force sensor or patient data.

---

## Engineering Pipeline

```text
Simulated biomechanical force
            ↓
      Sensor model
            ↓
     Voltage signal (V)
            ↓
      Measurement noise
            ↓
   Butterworth low-pass filter
            ↓
     Filtered voltage
            ↓
        Calibration
            ↓
   Estimated force (N)
            ↓
     Peak-force detection
            ↓
     Error evaluation
```

---

## Project Workflow

### 1. Biomechanical Force Simulation

A time-dependent force profile is generated to represent a simplified biomechanical event.

The simulated signal contains:

* Force increase
* Main force peak
* Force release
* Secondary force event
* Small signal variations

The reference force is expressed in Newtons (N).

### 2. Force Sensor Simulation

The simulated sensor converts force into voltage using a linear sensor model:

```text
Force (N) = sensitivity × Voltage (V) + offset
```

The simulation uses:

* Sensor sensitivity: approximately 50 N/V
* Sensor offset: approximately -5 N

Measurement noise is then added to reproduce realistic sensor-signal imperfections.

### 3. Signal Filtering

The noisy voltage signal is processed using a fourth-order Butterworth low-pass filter.

**Parameters:**

| Parameter          |                Value |
| ------------------ | -------------------: |
| Sampling frequency |              1000 Hz |
| Filter type        | Butterworth low-pass |
| Filter order       |                    4 |
| Cutoff frequency   |                10 Hz |

Zero-phase filtering (`filtfilt`) is used to avoid introducing a visible phase shift in the simulated signal.

### 4. Sensor Calibration

Known calibration force points are used to estimate the voltage-to-force relationship.

Calibration points:

```text
0 N
25 N
50 N
75 N
100 N
125 N
```

A first-order polynomial regression is then used to obtain the calibration slope and offset.

The calibration quality is evaluated using the coefficient of determination (R²).

### 5. Force Estimation

The filtered sensor voltage is converted back into force using the **calculated calibration coefficients**.

This separates the calibration stage from the original simulated sensor parameters.

### 6. Peak Force Detection

The maximum estimated force is automatically detected.

The corresponding time point is also reported.

### 7. Performance Evaluation

The estimated force is compared with the simulated reference force.

The project calculates:

* RMSE (Root Mean Square Error)
* Relative error
* Reference peak force
* Estimated peak force
* Peak-force timing
* Calibration R²

---

## Results

Example results obtained from the current simulation:

| Metric               |      Result |
| -------------------- | ----------: |
| Calibration slope    | 49.9695 N/V |
| Calibration offset   |   -5.0421 N |
| Calibration R²       |      1.0000 |
| Reference peak force |    123.43 N |
| Estimated peak force |    123.27 N |
| Peak time            |     4.089 s |
| RMSE                 |    0.8478 N |
| Relative error       |       1.57% |

The estimated peak force is very close to the simulated reference peak, while the overall RMSE remains below 1 N for this simulation.

> These results describe the behavior of the simulated pipeline and should not be interpreted as validation of a physical medical sensor.

---

## Visualization

The MATLAB script generates two plots:

### 1. Raw vs Filtered Sensor Signal

The first plot compares the noisy sensor voltage with the filtered voltage.

This illustrates the effect of low-pass filtering on measurement noise.

### 2. Calibrated Force Estimation

The second plot compares:

* Reference force
* Estimated force
* ±5% tolerance boundaries
* Detected peak force

This provides a visual assessment of the calibration and estimation process.

---

## Technologies

* MATLAB
* Signal Processing
* Butterworth Filtering
* Linear Regression
* Sensor Calibration
* Biomedical Instrumentation
* Data Visualization

---

## Repository Structure

```text
biomechanical-force-sensor-matlab/
│
├── main.m
└── README.md
```

---

## How to Run

### Requirements

* MATLAB

No external dataset is required because the signal is generated directly by the MATLAB script.

### Run the project

Open `main.m` in MATLAB and execute:

```matlab
main
```

The script will:

1. Generate the simulated sensor signal
2. Add measurement noise
3. Filter the signal
4. Perform sensor calibration
5. Estimate the force
6. Detect the peak force
7. Calculate performance metrics
8. Generate the two analysis figures

---