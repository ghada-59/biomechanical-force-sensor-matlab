# Biomechanical Force Sensor Signal Processing & Calibration — MATLAB

A simulation-based biomedical instrumentation project that explores how a force-sensor signal can be filtered, calibrated, and evaluated in MATLAB.

> **Scope:** this is a software and signal-processing exercise using synthetic data. It does not read from a physical sensor, control medical equipment, or demonstrate clinically validated measurement performance.

## Workflow

1. Generate a reproducible synthetic biomechanical force profile.
2. Convert the force profile into simulated sensor voltage using a known linear relationship.
3. Add Gaussian measurement noise to the voltage signal.
4. Apply a fourth-order low-pass Butterworth filter using zero-phase filtering.
5. Estimate the force-to-voltage calibration relationship with linear regression.
6. Convert filtered voltage back to estimated force and compare it with the synthetic reference.
7. Calculate calibration R², peak force, RMSE, and relative error, then visualize the raw, filtered, reference, and estimated signals.

## Main parameters

- Sampling frequency: 1,000 Hz
- Simulation duration: 10 seconds
- Butterworth cutoff frequency: 10 Hz
- Filter order: 4
- Calibration model: Force = slope × Voltage + offset
- Random seed: 42, for repeatable simulated noise

## Example simulation results

The following values were obtained from the seeded simulation:

| Metric | Example result |
| --- | ---: |
| Calibration slope | 49.9695 N/V |
| Calibration offset | -5.0421 N |
| Calibration R² | 1.0000 |
| Reference peak force | 123.43 N |
| Estimated peak force | 123.27 N |
| Estimated peak time | 4.089 s |
| RMSE | 0.8478 N |
| Relative error reported by the script | 1.57% |

These results describe this synthetic experiment only. The near-perfect calibration R² is not evidence of real-world sensor accuracy, and the RMSE is not a validated measurement specification.

## Run

1. Open `main.m` in MATLAB.
2. Run the script.
3. Review the command-window metrics and the generated figure.

The script uses `butter` and `filtfilt` from MATLAB's Signal Processing Toolbox.

## Limitations

- The force signal and sensor voltage are simulated.
- The calibration points are synthetic and derived from a predefined linear sensor model with small imposed variations.
- No real hardware, patient data, or clinical workflow is involved.
- The model does not assess sensor drift, physical mounting, environmental effects, or hardware-specific noise.

## Project type

**Academic / practice project.** This repository demonstrates MATLAB programming, digital filtering, linear calibration, error metrics, and signal visualization in a biomedical-engineering context.
