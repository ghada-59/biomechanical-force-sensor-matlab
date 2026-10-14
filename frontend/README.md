# Instrumentation Lab — React interface

This optional React/Vite frontend is a browser workspace for a Python companion implementation of the MATLAB script's documented synthetic force-sensor workflow. It does not execute MATLAB.

## Setup

Install dependencies from the repository root:

~~~bash
python -m pip install -r requirements-react-api.txt
~~~

Start the API in terminal 1:

~~~bash
python -m uvicorn simulation_api:app --reload --host 127.0.0.1 --port 8000
~~~

In terminal 2:

~~~bash
cd frontend
npm install
npm run dev
~~~

Open the local URL printed by Vite, normally http://127.0.0.1:5173/.

## Workflow

Adjust the simulated noise, Butterworth cutoff frequency and filter order, then run the workflow to inspect raw/filtered voltage, reference/estimated force, calibration coefficients, R², peak force and RMSE. A text report can be exported from the current run.

## Scope and reproducibility

All data are synthetic. The companion API is implemented in Python with SciPy to make the workflow interactive in the browser; it is not the MATLAB runtime and its seeded noise will not match MATLAB's RNG sample-for-sample. No physical sensor is connected and these values are not real-world sensor specifications.
