%% Biomechanical Force Sensor Signal Processing & Calibration
% MATLAB portfolio mini-project
% Simulation-based biomedical instrumentation workflow.
%
% Pipeline:
% Simulated force -> Sensor voltage -> Noise -> Filtering
% -> Calibration -> Force estimation -> Performance evaluation

clc;
clear;
close all;

%% 1. Simulation Parameters

Fs = 1000;              % Sampling frequency (Hz)
duration_s = 10;        % Signal duration (s)
fc = 10;                % Low-pass cutoff frequency (Hz)
filter_order = 4;       % Butterworth filter order

rng(42);                % Reproducible random noise

t = (0:1/Fs:duration_s-1/Fs)';

%% 2. Simulate a Biomechanical Force Signal

% Create a smooth, non-negative biomechanical force profile.
% The signal contains force increase, peak, release and small variations.

force_reference_N = zeros(size(t));

% Force increase
idx1 = t >= 1 & t < 3;
force_reference_N(idx1) = 20 + 80 * ...
    sin(pi * (t(idx1)-1) / 4).^2;

% Main force peak
idx2 = t >= 3 & t < 5;
force_reference_N(idx2) = 100 + 25 * ...
    sin(pi * (t(idx2)-3) / 2).^2;

% Force release
idx3 = t >= 5 & t < 7;
force_reference_N(idx3) = 100 * ...
    cos(pi * (t(idx3)-5) / 4).^2;

% Small secondary force event
idx4 = t >= 7 & t < 9;
force_reference_N(idx4) = 25 + 45 * ...
    sin(pi * (t(idx4)-7) / 2).^2;

% Add a small low-frequency variation
force_reference_N = force_reference_N + ...
    2 * sin(2*pi*1.2*t);

% Force cannot be negative
force_reference_N = max(force_reference_N, 0);

%% 3. Simulate the Force Sensor

% True sensor relationship:
%
% Force (N) = a_true * Voltage (V) + b_true

a_true = 50;            % True sensor sensitivity (N/V)
b_true = -5;            % True sensor offset (N)

% Convert reference force to ideal sensor voltage
voltage_ideal_V = (force_reference_N - b_true) / a_true;

% Add measurement noise
noise_std_V = 0.015;    % Sensor noise standard deviation (V)

voltage_raw_V = voltage_ideal_V + ...
    noise_std_V * randn(size(voltage_ideal_V));

%% 4. Low-Pass Butterworth Filtering

% A low-pass filter reduces high-frequency measurement noise.
% filtfilt performs zero-phase filtering and therefore avoids
% introducing a visible phase shift in the signal.

[b, a] = butter(filter_order, fc/(Fs/2), 'low');

voltage_filtered_V = filtfilt(b, a, voltage_raw_V);

%% 5. Sensor Calibration

% Known calibration force points
calibration_force_N = [0 25 50 75 100 125]';

% Corresponding measured voltages with small measurement variations
calibration_voltage_V = ...
    (calibration_force_N - b_true) / a_true + ...
    [0.000; 0.008; -0.006; 0.005; -0.004; 0.007];

% Linear regression:
% Force = slope * Voltage + offset

calibration_coefficients = polyfit( ...
    calibration_voltage_V, ...
    calibration_force_N, ...
    1);

calibration_slope = calibration_coefficients(1);
calibration_offset = calibration_coefficients(2);

% Predicted calibration force
calibration_force_predicted_N = polyval( ...
    calibration_coefficients, ...
    calibration_voltage_V);

% Calculate R-squared
SS_res = sum((calibration_force_N - ...
    calibration_force_predicted_N).^2);

SS_tot = sum((calibration_force_N - ...
    mean(calibration_force_N)).^2);

R_squared = 1 - SS_res / SS_tot;

%% 6. Convert Filtered Voltage to Estimated Force

% IMPORTANT:
% The estimated force uses the calculated calibration coefficients,
% not the original true sensor coefficients.

force_estimated_N = calibration_slope * ...
    voltage_filtered_V + calibration_offset;

% Force cannot be negative
force_estimated_N = max(force_estimated_N, 0);

%% 7. Performance Evaluation

% Calculate estimation error
error_N = force_estimated_N - force_reference_N;

% Root Mean Square Error
RMSE_N = sqrt(mean(error_N.^2));

% Mean reference force
mean_reference_force_N = mean(force_reference_N);

% Relative error
relative_error_percent = ...
    (RMSE_N / mean_reference_force_N) * 100;

%% 8. Peak Force Detection

[peak_force_N, peak_index] = max(force_estimated_N);

peak_time_s = t(peak_index);

reference_peak_force_N = max(force_reference_N);

%% 9. Tolerance Region

% Define a transparent +/-5% tolerance around the reference force.
tolerance_percent = 5;

tolerance_upper_N = force_reference_N * ...
    (1 + tolerance_percent/100);

tolerance_lower_N = max( ...
    force_reference_N * ...
    (1 - tolerance_percent/100), 0);

%% 10. Display Technical Results

fprintf('\n');
fprintf('=============================================\n');
fprintf(' BIOMECHANICAL FORCE SENSOR ANALYSIS\n');
fprintf('=============================================\n');

fprintf('Sampling frequency : %.0f Hz\n', Fs);
fprintf('Filter cutoff      : %.1f Hz\n', fc);
fprintf('Filter order       : %d\n', filter_order);

fprintf('\n');
fprintf('Calibration slope  : %.4f N/V\n', ...
    calibration_slope);

fprintf('Calibration offset : %.4f N\n', ...
    calibration_offset);

fprintf('Calibration R^2     : %.4f\n', ...
    R_squared);

fprintf('\n');
fprintf('Reference Peak     : %.2f N\n', ...
    reference_peak_force_N);

fprintf('Estimated Peak     : %.2f N\n', ...
    peak_force_N);

fprintf('Peak Time          : %.3f s\n', ...
    peak_time_s);

fprintf('\n');
fprintf('RMSE               : %.4f N\n', ...
    RMSE_N);

fprintf('Relative Error     : %.2f %%\n', ...
    relative_error_percent);

fprintf('=============================================\n');

%% 11. Visualization

figure('Name', ...
    'Biomechanical Force Sensor Analysis', ...
    'NumberTitle', 'off');

% -------- Subplot 1: Raw vs Filtered Voltage --------

subplot(2,1,1);

plot(t, voltage_raw_V, ...
    'LineWidth', 0.8);

hold on;

plot(t, voltage_filtered_V, ...
    'LineWidth', 1.5);

xlabel('Time (s)');
ylabel('Sensor Output (V)');

title('Raw vs Filtered Biomechanical Force Sensor Signal');

legend('Raw Sensor Signal', ...
    'Filtered Sensor Signal', ...
    'Location', 'best');

grid on;

xlim([0 duration_s]);

% -------- Subplot 2: Calibrated Force --------

subplot(2,1,2);

plot(t, force_reference_N, ...
    'LineWidth', 1.3);

hold on;

plot(t, force_estimated_N, ...
    'LineWidth', 1.5);

% Tolerance boundaries
plot(t, tolerance_upper_N, ...
    '--', 'LineWidth', 0.8);

plot(t, tolerance_lower_N, ...
    '--', 'LineWidth', 0.8);

% Peak force marker
plot(peak_time_s, peak_force_N, ...
    'o', 'MarkerSize', 8, ...
    'LineWidth', 1.5);

% Peak force annotation
text(peak_time_s, peak_force_N, ...
    sprintf('  Peak = %.2f N', peak_force_N), ...
    'VerticalAlignment', 'bottom');

xlabel('Time (s)');
ylabel('Force (N)');

title('Calibrated Force Estimation');

legend('Reference Force', ...
    'Estimated Force', ...
    '+5% / -5% Tolerance', ...
    '', ...
    'Peak Force', ...
    'Location', 'best');

grid on;

xlim([0 duration_s]);

%% End of Script