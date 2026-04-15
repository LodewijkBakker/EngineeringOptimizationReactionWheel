% Initial Problem Investigation: Multi-Baseline Comparison
clear; clc;

% --- Core Parameters ---
rho = 2700; D_nom = 0.20; t_nom = 0.015; W_nom = 0.030;
n_nom = 4; T_nom = 1.0; b1_nom = 0.020; b2_nom = 0.010;
r_hub = 0.020; k = 100;

% --- Baselines to Compare (Different Speeds) ---
Omega_list = [4000, 6000, 8000] * (2*pi/60); 
colors = {'#0072BD', '#D95319', '#EDB120'}; % Blue, Orange, Yellow
labels = {'4000 RPM', '6000 RPM', '8000 RPM'};

% --- Define Ranges ---
b1_vec = linspace(0.005, 0.040, 50);
b2_vec = linspace(0.005, 0.030, 50);
D_vec  = linspace(0.10, 0.40, 50);
t_vec  = linspace(0.005, 0.040, 50);
W_vec  = linspace(1000, 12000, 50) * (2*pi/60);
n_vec  = 2:12;

figure('Color', 'w', 'Position', [100, 100, 1100, 750]);

for i = 1:3
    O = Omega_list(i);
    
    subplot(2,3,1); hold on;
    s = arrayfun(@(b) armMaxStress(t_nom, D_nom, b, b2_nom, rho, W_nom, n_nom, O, r_hub, k, T_nom), b1_vec);
    plot(b1_vec*1000, s/1e6, 'Color', colors{i}, 'LineWidth', 1.5);
    title('Variation with b1'); xlabel('b1 [mm]'); ylabel('Stress [MPa]'); grid on;

    subplot(2,3,2); hold on;
    s = arrayfun(@(b) armMaxStress(t_nom, D_nom, b1_nom, b, rho, W_nom, n_nom, O, r_hub, k, T_nom), b2_vec);
    plot(b2_vec*1000, s/1e6, 'Color', colors{i}, 'LineWidth', 1.5);
    title('Variation with b2'); xlabel('b2 [mm]'); grid on;

    subplot(2,3,3); hold on;
    s = arrayfun(@(d) armMaxStress(t_nom, d, b1_nom, b2_nom, rho, W_nom, n_nom, O, r_hub, k, T_nom), D_vec);
    plot(D_vec*1000, s/1e6, 'Color', colors{i}, 'LineWidth', 1.5);
    title('Variation with Diameter'); xlabel('D [mm]'); grid on;

    subplot(2,3,4); hold on;
    s = arrayfun(@(t) armMaxStress(t, D_nom, b1_nom, b2_nom, rho, W_nom, n_nom, O, r_hub, k, T_nom), t_vec);
    plot(t_vec*1000, s/1e6, 'Color', colors{i}, 'LineWidth', 1.5);
    title('Variation with t_{rim}'); xlabel('t [mm]'); ylabel('Stress [MPa]'); grid on;

    subplot(2,3,5); hold on;
    s = arrayfun(@(w) armMaxStress(t_nom, D_nom, b1_nom, b2_nom, rho, W_nom, n_nom, w, r_hub, k, T_nom), W_vec);
    if i == 2, plot(W_vec*60/(2*pi), s/1e6, 'k', 'LineWidth', 1.5); end
    title('Variation with \omega'); xlabel('RPM'); grid on;

    subplot(2,3,6); hold on;
    s = arrayfun(@(n) armMaxStress(t_nom, D_nom, b1_nom, b2_nom, rho, W_nom, n, O, r_hub, k, T_nom), n_vec);
    plot(n_vec, s/1e6, 'o-', 'Color', colors{i}, 'LineWidth', 1.2);
    title('Variation with n'); xlabel('n'); grid on;
end

% Construct descriptive title
title_str = sprintf('Arm Stress Sensitivity | Nominal: D=%dmm, t=%dmm, W=%dmm, b1=%dmm, b2=%dmm, n=%d, T=%0.1fNm', ...
    D_nom*1000, t_nom*1000, W_nom*1000, b1_nom*1000, b2_nom*1000, n_nom, T_nom);
sgtitle(title_str, 'FontSize', 12, 'FontWeight', 'bold');

% Single legend for the whole figure
lgd = legend(subplot(2,3,6), labels, 'Orientation', 'horizontal');
lgd.Position = [0.4, 0.02, 0.2, 0.03]; % Bottom center