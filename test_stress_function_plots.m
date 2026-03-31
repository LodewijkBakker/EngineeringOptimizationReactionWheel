%% Flywheel Arm & Rim Stress - Parametric Sweep
clear; clc; close all;

% --- Base Input Parameters ---
D = 2;              % 2m Diameter [m] (Note: 2m is huge, stresses will be high!)
t_ring = 0.2;      % 5cm ring thickness [m]
W = 0.08;           % 8cm out-of-plane thickness [m]
rho = 7850;         % Steel density [kg/m3]
n = 10;              % 6 spokes
r_hub = 0.5;        % 50cm hub radius [m]
T = 1000;           % 1000 Nm Torque
k = 1000;            % Number of points to check

%% STUDY 1: Sensitivity to Centrifugal Force (RPM)
b1_fixed = 0.04; 
b2_fixed = 0.05;
RPM_vec = linspace(1000, 15000, 50); % Sweep from 1k to 15k RPM
Omega_vec = (RPM_vec * 2 * pi) / 60;

max_sigma_arm_RPM = zeros(1, length(RPM_vec));

% 1. Calculate Arm Stress in a loop
for i = 1:length(RPM_vec)
    max_sigma_arm_RPM(i) = armMaxStress(t_ring, D, b1_fixed, b2_fixed, rho, W, n, Omega_vec(i), r_hub, k, T);
end

% 2. Calculate Rim Stress (Vectorized call)
[sigma_rim_RPM, ~, ~] = flywheelStressRim(rho, D, Omega_vec, n, t_ring);

figure(1); hold on; grid on;
plot(RPM_vec, max_sigma_arm_RPM / 1e6, 'b-', 'LineWidth', 2, 'DisplayName', 'Max Arm Stress');
plot(RPM_vec, sigma_rim_RPM / 1e6, 'r--', 'LineWidth', 2, 'DisplayName', 'Max Rim Stress');
xlabel('Rotational Speed [RPM]');
ylabel('Stress [MPa]');
title(sprintf('Stress vs RPM (b1=%.2fm, b2=%.2fm)', b1_fixed, b2_fixed));
legend('Location', 'northwest');

%% STUDY 2: Sensitivity to Dimensions (b1 and b2)
RPM_fixed = 10000;
Omega_fixed = (RPM_fixed * 2 * pi) / 60;
b1_vec = linspace(0.02, 0.10, 50); % Sweep hub width from 2cm to 10cm
b2_test_vals = [0.02, 0.05, 0.08]; % Test 3 different rim widths

figure(2); hold on; grid on;
colors = {'r', 'g', 'b'};

% 1. Calculate Rim Stress (Constant for this study)
[sigma_rim_fixed, ~, ~] = flywheelStressRim(rho, D, Omega_fixed, n, t_ring);

for j = 1:length(b2_test_vals)
    b2_current = b2_test_vals(j);
    max_sigma_b = zeros(1, length(b1_vec));
    
    for i = 1:length(b1_vec)
        max_sigma_b(i) = armMaxStress(t_ring, D, b1_vec(i), b2_current, rho, W, n, Omega_fixed, r_hub, k, T);
    end
    
    plot(b1_vec, max_sigma_b / 1e6, 'Color', colors{j}, 'LineWidth', 2, ...
         'DisplayName', sprintf('Arm Stress (b2 = %.2f m)', b2_current));
end

% Add the Rim Stress as a baseline comparison
yline(sigma_rim_fixed / 1e6, 'k--', 'LineWidth', 2, 'DisplayName', 'Rim Stress Threshold');

xlabel('Hub Width b1 [m]');
ylabel('Max Stress [MPa]');
title(sprintf('Stress vs b1 at %d RPM', RPM_fixed));
legend('Location', 'northeast');


%% STUDY 3: Sensitivity to Rim-Side Width (b2)
figure(3); hold on; grid on;
b2_vec = linspace(0.01, 0.10, 50); % Sweep rim width from 1cm to 10cm
b1_test_vals = [0.03, 0.06, 0.09]; % Test 3 different hub widths
colors = {'r', 'g', 'b'};

for j = 1:length(b1_test_vals)
    b1_current = b1_test_vals(j);
    max_sigma_b2 = zeros(1, length(b2_vec));
    
    for i = 1:length(b2_vec)
        max_sigma_b2(i) = armMaxStress(t_ring, D, b1_current, b2_vec(i), rho, W, n, Omega_fixed, r_hub, k, T);
    end
    
    plot(b2_vec, max_sigma_b2 / 1e6, 'Color', colors{j}, 'LineWidth', 2, ...
         'DisplayName', sprintf('Arm Stress (b1 = %.2f m)', b1_current));
end

% Add the Rim Stress baseline
yline(sigma_rim_fixed / 1e6, 'k--', 'LineWidth', 2, 'DisplayName', 'Rim Stress Threshold');
xlabel('Rim-Side Width b2 [m]');
ylabel('Max Stress [MPa]');
title(sprintf('Stress vs b2 at %d RPM', RPM_fixed));
legend('Location', 'best');


%% STUDY 4: Sensitivity to Number of Spokes (n)
figure(4); hold on; grid on;
n_vec = 3:12; % Evaluate between 3 and 12 spokes
max_sigma_arm_n = zeros(1, length(n_vec));
sigma_rim_n = zeros(1, length(n_vec));

for i = 1:length(n_vec)
    % Calculate for both Arm and Rim, since 'n' affects both heavily
    max_sigma_arm_n(i) = armMaxStress(t_ring, D, b1_fixed, b2_fixed, rho, W, n_vec(i), Omega_fixed, r_hub, k, T);
    [sigma_rim_n(i), ~, ~] = flywheelStressRim(rho, D, Omega_fixed, n_vec(i), t_ring);
end

plot(n_vec, max_sigma_arm_n / 1e6, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'DisplayName', 'Max Arm Stress');
plot(n_vec, sigma_rim_n / 1e6, 'r--s', 'LineWidth', 2, 'MarkerFaceColor', 'r', 'DisplayName', 'Max Rim Stress');
xlabel('Number of Spokes (n)');
ylabel('Max Stress [MPa]');
title(sprintf('Stress vs Number of Spokes at %d RPM', RPM_fixed));
legend('Location', 'northeast');
xticks(n_vec); % Force integer ticks on the x-axis


%% STUDY 5: 3D Surface Map of Spoke Taper (b1 vs b2)
figure(5);
% Create a 30x30 grid of b1 and b2 combinations
[B1, B2] = meshgrid(linspace(0.02, 0.10, 30), linspace(0.02, 0.10, 30));
Max_Sigma_Surf = zeros(size(B1));

% Calculate stress for every combination
for r_idx = 1:size(B1, 1)
    for c_idx = 1:size(B1, 2)
        Max_Sigma_Surf(r_idx, c_idx) = armMaxStress(t_ring, D, B1(r_idx, c_idx), B2(r_idx, c_idx), rho, W, n, Omega_fixed, r_hub, k, T);
    end
end

% Plot the 3D surface
surf(B1, B2, Max_Sigma_Surf / 1e6, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
colormap jet; 
cb = colorbar;
cb.Label.String = 'Max Arm Stress [MPa]';
xlabel('Hub Width b1 [m]');
ylabel('Rim Width b2 [m]');
zlabel('Max Arm Stress [MPa]');
title(sprintf('Arm Stress Taper Optimization (%d RPM)', RPM_fixed));
view(135, 30); % Set a nice default 3D viewing angle