% Comparison of Energy Models: Initial vs. Refined
clear; clc;

% --- Parameters ---
rho = 7850;         % Steel
t_ring = 0.020;     % 20 mm
b1 = 0.030; b2 = 0.030; W = 0.020; n = 3;
Omega = 6000 * (2*pi/60);
d_shaft = 0.050;
r_hub = d_shaft / (2 * tan(pi/n));

% --- Data Generation ---
D_vec = linspace(0.15, 0.50, 50); % Sweep from 150mm to 500mm
E_old = zeros(size(D_vec)); S_old = zeros(size(D_vec));
E_new = zeros(size(D_vec)); S_new = zeros(size(D_vec));

for i = 1:length(D_vec)
    D = D_vec(i);
    L_spoke = (D/2 - t_ring) - r_hub;
    
    [S_old(i), E_old(i)] = rotational_energy(t_ring, D, b1, b2, rho, W, L_spoke, n, Omega);
    [S_new(i), E_new(i)] = rotational_energy_new(t_ring, D, b1, b2, rho, W, L_spoke, n, Omega);
end

% --- Plotting ---
figure('Color', 'w', 'Position', [100, 100, 1100, 500]);

% 1. Total Energy Comparison
subplot(1,2,1);
plot(D_vec*1000, E_old/1000, 'r--', 'LineWidth', 1.8); hold on;
plot(D_vec*1000, E_new/1000, 'b-', 'LineWidth', 1.8);
xlabel('Diameter [mm]'); ylabel('Total Energy [kJ]');
title('Total Rotational Energy Verification');
legend('Initial Model (Uncorrected)', 'Refined Model (Corrected)', 'Location', 'NorthWest');
grid on;

% 2. Specific Energy Comparison
subplot(1,2,2);
plot(D_vec*1000, S_old, 'r--', 'LineWidth', 1.8); hold on;
plot(D_vec*1000, S_new, 'b-', 'LineWidth', 1.8);
xlabel('Diameter [mm]'); ylabel('Specific Energy [J/kg]');
title('Specific Energy Verification');
legend('Initial Model (Uncorrected)', 'Refined Model (Corrected)', 'Location', 'NorthWest');
grid on;

sgtitle('Structural Model Verification: Correcting Radius-Diameter Inertia Scaling');