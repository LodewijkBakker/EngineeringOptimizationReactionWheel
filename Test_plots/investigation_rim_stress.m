% Initial Problem Investigation: Multi-Baseline Rim Stress
clear; clc;

% --- New Nominal Parameters (Regular Scale) ---
rho = 2700; 
D_nom = 0.20;       % 200 mm
t_nom = 0.015;      % 15 mm
n_nom = 4;
RPM_nom = 6000;
Omega_nom = RPM_nom * (2*pi/60);

% --- Baselines to Compare ---
Omega_list = [4000, 6000, 8000] * (2*pi/60); 
colors = {'#0072BD', '#D95319', '#EDB120'}; % Blue, Orange, Yellow
labels = {'4000 RPM', '6000 RPM', '8000 RPM'};

% --- Define Ranges ---
D_vec = linspace(0.10, 0.40, 100); 
W_vec = linspace(1000, 15000, 100) * (2*pi/60); 
n_vec = 2:12;
t_vec = linspace(0.005, 0.030, 100);

figure('Color', 'w', 'Position', [100, 100, 1000, 700]);

for i = 1:3
    O = Omega_list(i);
    
    % 1. Stress vs Diameter (D)
    subplot(2,2,1); hold on;
    R_d = (D_vec - t_nom)/2;
    sig_t = rho * (R_d.^2) * (O^2);
    sig_b = (19.74 * rho * (O^2) * (R_d.^3)) ./ ((n_nom^2) * t_nom);
    plot(D_vec*1000, (sig_t + sig_b)/1e6, 'Color', colors{i}, 'LineWidth', 1.5);
    title('Variation with Diameter'); xlabel('D [mm]'); ylabel('Rim Stress [MPa]'); grid on;

    % 2. Stress vs Rotational Speed (Omega)
    subplot(2,2,2); hold on;
    R_nom = (D_nom - t_nom)/2;
    sig_t = rho * (R_nom^2) * (W_vec.^2);
    sig_b = (19.74 * rho * (W_vec.^2) * (R_nom^3)) ./ ((n_nom^2) * t_nom);
    if i == 2, plot(W_vec * 60 / (2*pi), (sig_t + sig_b)/1e6, 'k', 'LineWidth', 1.5); end
    title('Variation with Speed'); xlabel('RPM'); grid on;

    % 3. Stress vs Number of Spokes (n)
    subplot(2,2,3); hold on;
    sig_t = rho * (R_nom^2) * (O^2);
    sig_b = (19.74 * rho * (O^2) * (R_nom^3)) ./ ((n_vec.^2) * t_nom);
    plot(n_vec, (sig_t + sig_b)/1e6, 'o-', 'Color', colors{i}, 'LineWidth', 1.2);
    title('Variation with Spoke Count'); xlabel('n'); ylabel('Rim Stress [MPa]'); grid on;

    % 4. Stress vs Rim Thickness (t_ring)
    subplot(2,2,4); hold on;
    R_t = (D_nom - t_vec)/2;
    sig_t = rho * (R_t.^2) * (O^2);
    sig_b = (19.74 * rho * (O^2) * (R_t.^3)) ./ ((n_nom^2) .* t_vec);
    plot(t_vec*1000, (sig_t + sig_b)/1e6, 'Color', colors{i}, 'LineWidth', 1.5);
    title('Variation with Rim Thickness'); xlabel('t [mm]'); grid on;
end

% Construct title
title_str = sprintf('Rim Stress Sensitivity | Nominal: D=%dmm, t=%dmm, n=%d, \\rho=%dkg/m^3', ...
    D_nom*1000, t_nom*1000, n_nom, rho);
sgtitle(title_str, 'FontSize', 12, 'FontWeight', 'bold');

lgd = legend(subplot(2,2,4), labels, 'Orientation', 'horizontal');
lgd.Position = [0.4, 0.02, 0.2, 0.03];

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

