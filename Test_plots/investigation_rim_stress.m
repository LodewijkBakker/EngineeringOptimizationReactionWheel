% Initial Problem Investigation: Rim Stress Behavior with Nominal Parameters
clear; clc;

% Baseline Aluminum CubeSat Reaction Wheel Parameters
rho = 2700;      % Aluminum [kg/m^3]
D_nom = 0.05;    % 50 mm Diameter
RPM_nom = 6000;  % 6000 RPM 
Omega_nom = RPM_nom * (2*pi/60); 
n_nom = 4;       % 4 spokes
t_nom = 0.005;   % 5 mm thickness

% Define ranges for parameter sweeps
D_vec = linspace(0.02, 0.10, 100); 
W_vec = linspace(500, 15000, 100) * (2*pi/60); 
n_vec = 2:12;
t_vec = linspace(0.001, 0.015, 100);

figure(1);

% 1. Stress vs Diameter (D)
subplot(2,2,1);
R_d = (D_vec - t_nom)/2;
sig_t = rho * (R_d.^2) * (Omega_nom^2);
sig_b = (19.74 * rho * (Omega_nom^2) * (R_d.^3)) ./ ((n_nom^2) * t_nom);
plot(D_vec*1000, (sig_t + sig_b)/1e6, 'LineWidth', 1.5);
xlabel('D [mm]'); ylabel('Rim Stress [MPa]');
title('Variation with Diameter'); grid on;

% 2. Stress vs Rotational Speed (Omega)
subplot(2,2,2);
R_nom = (D_nom - t_nom)/2;
sig_t = rho * (R_nom^2) * (W_vec.^2);
sig_b = (19.74 * rho * (W_vec.^2) * (R_nom^3)) ./ ((n_nom^2) * t_nom);
plot(W_vec * 60 / (2*pi), (sig_t + sig_b)/1e6, 'LineWidth', 1.5);
xlabel('Speed [RPM]'); ylabel('Rim Stress [MPa]');
title('Variation with Speed'); grid on;

% 3. Stress vs Number of Spokes (n)
subplot(2,2,3);
R_nom = (D_nom - t_nom)/2;
sig_t = rho * (R_nom^2) * (Omega_nom^2);
sig_b = (19.74 * rho * (Omega_nom^2) * (R_nom^3)) ./ ((n_vec.^2) * t_nom);
plot(n_vec, (sig_t + sig_b)/1e6, 'o-', 'LineWidth', 1.5);
xlabel('n'); ylabel('Rim Stress [MPa]');
title('Variation with Spoke Count'); grid on;

% 4. Stress vs Rim Thickness (t_ring)
subplot(2,2,4);
R_t = (D_nom - t_vec)/2;
sig_t = rho * (R_t.^2) * (Omega_nom^2);
sig_b = (19.74 * rho * (Omega_nom^2) * (R_t.^3)) ./ ((n_nom^2) .* t_vec);
plot(t_vec*1000, (sig_t + sig_b)/1e6, 'LineWidth', 1.5);
xlabel('t [mm]'); ylabel('Rim Stress [MPa]');
title('Variation with Rim Thickness'); grid on;

% --- Main Title with Nominal Parameters ---
sgtitle(['Nominal: D = ', num2str(D_nom*1000), 'mm, ', ...
         num2str(RPM_nom), ' RPM, n = ', num2str(n_nom), ...
         ', t = ', num2str(t_nom*1000), 'mm, \rho = ', num2str(rho), 'kg/m^3']);


% Initial Investigation: Feasible Region (D vs Omega)
D_grid = linspace(0.02, 0.1, 50);
Omega_grid = linspace(500, 15000/2, 50) * (2*pi/60);
[DD, OO] = meshgrid(D_grid, Omega_grid);

% Calculate Energy and Stress for the whole grid
% Simplified Energy: E = 0.5 * J * Omega^2 (Just for visualization)
% Simplified J approx: Mass_rim * R^2
Energy = 0.5 * (rho * pi * DD .* t_nom .* (DD-t_nom)) .* (DD/2).^2 .* OO.^2;
[Stress, ~, ~] = flywheelStressRim(rho, DD, OO, n_nom, t_nom);

figure(2);
[C, h] = contour(D_grid*1000, Omega_grid*60/(2*pi), Energy, 15);
clabel(C, h); hold on;
% Draw the Stress Limit (assuming 150 MPa for Aluminum)
contour(D_grid*1000, Omega_grid*60/(2*pi), Stress/1e6, [150 150], 'r', 'LineWidth', 3);
xlabel('Diameter [mm]'); ylabel('Speed [RPM]');
title('Objective (Energy) and Rim Stress Constraint');
legend('Energy Contours', 'Stress Limit (150 MPa)'); grid on;

