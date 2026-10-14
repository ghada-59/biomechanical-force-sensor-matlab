"""Interactive companion simulation for the MATLAB force-sensor exercise.

This endpoint reproduces the documented signal-processing workflow in Python
for the browser UI; it does not execute MATLAB or connect to physical hardware.
"""
from __future__ import annotations

import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from scipy.signal import butter, filtfilt

app = FastAPI(title="Instrumentation Lab API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1:5173", "http://localhost:5173"],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


class SimulationSettings(BaseModel):
    noise_std_v: float = Field(default=0.015, ge=0.001, le=0.08)
    cutoff_hz: float = Field(default=10.0, ge=1.0, le=80.0)
    filter_order: int = Field(default=4, ge=2, le=8)


def _run(settings: SimulationSettings):
    fs = 1000
    duration = 10.0
    t = np.arange(0, duration, 1 / fs)
    force = np.zeros_like(t)

    mask = (t >= 1) & (t < 3)
    force[mask] = 20 + 80 * np.sin(np.pi * (t[mask] - 1) / 4) ** 2
    mask = (t >= 3) & (t < 5)
    force[mask] = 100 + 25 * np.sin(np.pi * (t[mask] - 3) / 2) ** 2
    mask = (t >= 5) & (t < 7)
    force[mask] = 100 * np.cos(np.pi * (t[mask] - 5) / 4) ** 2
    mask = (t >= 7) & (t < 9)
    force[mask] = 25 + 45 * np.sin(np.pi * (t[mask] - 7) / 2) ** 2
    force = np.maximum(force + 2 * np.sin(2 * np.pi * 1.2 * t), 0)

    true_slope, true_offset = 50.0, -5.0
    ideal_v = (force - true_offset) / true_slope
    rng = np.random.default_rng(42)
    raw_v = ideal_v + settings.noise_std_v * rng.normal(size=t.size)

    b, a = butter(settings.filter_order, settings.cutoff_hz / (fs / 2), btype="low")
    filtered_v = filtfilt(b, a, raw_v)

    calibration_force = np.asarray([0, 25, 50, 75, 100, 125], dtype=float)
    calibration_v = (calibration_force - true_offset) / true_slope + np.asarray(
        [0.000, 0.008, -0.006, 0.005, -0.004, 0.007]
    )
    slope, offset = np.polyfit(calibration_v, calibration_force, 1)
    fitted = slope * calibration_v + offset
    ss_res = float(np.sum((calibration_force - fitted) ** 2))
    ss_tot = float(np.sum((calibration_force - np.mean(calibration_force)) ** 2))
    r_squared = 1 - ss_res / ss_tot if ss_tot else 0.0

    estimated = np.maximum(slope * filtered_v + offset, 0)
    error = estimated - force
    rmse = float(np.sqrt(np.mean(error ** 2)))
    mean_force = float(np.mean(force))
    peak_idx = int(np.argmax(estimated))
    stride = 10

    return {
        "settings": {
            "sampling_frequency_hz": fs,
            "duration_s": duration,
            "noise_std_v": settings.noise_std_v,
            "cutoff_hz": settings.cutoff_hz,
            "filter_order": settings.filter_order,
        },
        "calibration": {
            "slope_n_per_v": float(slope),
            "offset_n": float(offset),
            "r_squared": float(r_squared),
        },
        "metrics": {
            "reference_peak_n": float(np.max(force)),
            "estimated_peak_n": float(estimated[peak_idx]),
            "peak_time_s": float(t[peak_idx]),
            "rmse_n": rmse,
            "relative_error_percent": float(rmse / mean_force * 100) if mean_force else 0.0,
        },
        "series": {
            "time_s": t[::stride].round(3).tolist(),
            "raw_voltage_v": raw_v[::stride].round(5).tolist(),
            "filtered_voltage_v": filtered_v[::stride].round(5).tolist(),
            "reference_force_n": force[::stride].round(3).tolist(),
            "estimated_force_n": estimated[::stride].round(3).tolist(),
            "tolerance_upper_n": (force[::stride] * 1.05).round(3).tolist(),
            "tolerance_lower_n": (force[::stride] * 0.95).clip(min=0).round(3).tolist(),
        },
        "note": "Synthetic data only. The browser companion is a Python implementation of the documented workflow, not a MATLAB runtime or physical sensor connection. These values are not real sensor specifications.",
    }


@app.get("/api/health")
def health():
    return {"status": "ok", "service": "Instrumentation Lab API"}


@app.post("/api/simulate")
def simulate(settings: SimulationSettings):
    try:
        return _run(settings)
    except Exception as exc:
        raise HTTPException(status_code=400, detail="Simulation failed: " + str(exc)) from exc
