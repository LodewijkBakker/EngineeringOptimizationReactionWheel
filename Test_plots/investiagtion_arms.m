% Initial Problem Investigation: Regular Satellite Scale (200mm)
clear; clc;

% --- New Nominal Parameters ---
rho = 2700; 
D_nom = 0.20;       % 200 mm
t_nom = 0.015;      % 15 mm
W_nom = 0.030;      % 30 mm (Out of plane)
n_nom = 4;
Omega_nom = 6000 * (2*pi/60); 
T_nom = 1.0;        % 1.0 Nm Torque
b1_nom = 0.020;     % 20 mm
b2_nom = 0.010;     % 10 mm
r_hub = 0.020;      % 20 mm hub
k = 100;

% --- Define Wider Ranges for Scale ---
b1_vec = linspace(0.005, 0.040, 100);
b2_vec = linspace(0.005, 0.030, 100);
D_vec  = linspace(0.10, 0.40, 100);
t_vec  = linspace(0.005, 0.040, 100);
W_vec  = linspace(1000, 15000, 100) * (2*pi/60);
n_vec  = 2:12;

figure(1);

subplot(2,3,1); s = arrayfun(@(b) armMaxStress(t_nom, D_nom, b, b2_nom, rho, W_nom, n_nom, Omega_nom, r_hub, k, T_nom), b1_vec);
plot(b1_vec*1000, s/1e6, 'LineWidth', 1.5); xlabel('b1 [mm]'); ylabel('Max Spoke Stress [MPa]'); title('Variation with b1'); grid on;

subplot(2,3,2); s = arrayfun(@(b) armMaxStress(t_nom, D_nom, b1_nom, b, rho, W_nom, n_nom, Omega_nom, r_hub, k, T_nom), b2_vec);
plot(b2_vec*1000, s/1e6, 'LineWidth', 1.5); xlabel('b2 [mm]'); ylabel('Max Spoke Stress [MPa]'); title('Variation with b2'); grid on;

subplot(2,3,3); s = arrayfun(@(d) armMaxStress(t_nom, d, b1_nom, b2_nom, rho, W_nom, n_nom, Omega_nom, r_hub, k, T_nom), D_vec);
plot(D_vec*1000, s/1e6, 'LineWidth', 1.5); xlabel('D [mm]'); ylabel('Max Spoke Stress [MPa]]'); title('Variation with Diameter'); grid on;

subplot(2,3,4); s = arrayfun(@(t) armMaxStress(t, D_nom, b1_nom, b2_nom, rho, W_nom, n_nom, Omega_nom, r_hub, k, T_nom), t_vec);
plot(t_vec*1000, s/1e6, 'LineWidth', 1.5); xlabel('t [mm]'); ylabel('Max Spoke Stress [MPa]'); title('Variation with t_{rim}'); grid on;

subplot(2,3,5); s = arrayfun(@(w) armMaxStress(t_nom, D_nom, b1_nom, b2_nom, rho, W_nom, n_nom, w, r_hub, k, T_nom), W_vec);
plot(W_vec*60/(2*pi), s/1e6, 'LineWidth', 1.5); xlabel('Speed [RPM]'); ylabel('Max Spoke Stress [MPa]'); title('Variation with \omega'); grid on;

subplot(2,3,6); s = arrayfun(@(n) armMaxStress(t_nom, D_nom, b1_nom, b2_nom, rho, W_nom, n, Omega_nom, r_hub, k, T_nom), n_vec);
plot(n_vec, s/1e6, 'o-', 'LineWidth', 1.5); xlabel('n'); ylabel('Max Spoke Stress [MPa]'); title('Variation with n'); grid on;

sgtitle(['Nominal: D=200mm, \omega=6000RPM, T=1Nm']);


% 3D Visualization of Arm Stress vs. Spoke Widths
clear; clc;

% --- Parameters (Regular Scale) ---
rho = 2700; D = 0.20; t_rim = 0.015; n = 4;
W = 0.030; Omega = 6000 * (2*pi/60); T = 1.0;
r_hub = 0.020; k = 100;

% --- Create Meshgrid ---
b1_vec = linspace(0.005, 0.040, 40); % Hub width
b2_vec = linspace(0.005, 0.030, 40); % Rim width
[B1, B2] = meshgrid(b1_vec, b2_vec);
S_max = zeros(size(B1));

% --- Compute Surface ---
for i = 1:size(B1, 1)
    for j = 1:size(B1, 2)
        S_max(i,j) = armMaxStress(t_rim, D, B1(i,j), B2(i,j), rho, W, n, Omega, r_hub, k, T);
    end
end

% --- Plotting ---
figure('Color', 'w');
surf(B1*1000, B2*1000, S_max/1e6, 'EdgeColor', 'none');
colormap(jet); colorbar;
view(-135, 30); % Adjust angle for better perspective
xlabel('b1 (Hub Width) [mm]');
ylabel('b2 (Rim Width) [mm]');
zlabel('Max Arm Stress [MPa]');
title('3D Stress Landscape: Interaction of Spoke Widths');
grid on;

% High-Visibility Topological Visualization of Arm Stress
clear; clc;

% --- Parameters (Regular Satellite Scale: 200mm) ---
rho = 2700; D = 0.20; t_rim = 0.015; n = 4;
W = 0.030; Omega = 6000 * (2*pi/60); T = 1.0;
r_hub = 0.020; k = 100;

% --- Create a Fine Mesh for a Smooth Topology ---
% A higher resolution grid makes the shape much more defined.
grid_res = 60; 
b1_vec = linspace(0.005, 0.040, grid_res); 
b2_vec = linspace(0.005, 0.030, grid_res); 
[B1, B2] = meshgrid(b1_vec, b2_vec);
S_max = zeros(size(B1));

% --- Compute the Landscape ---
fprintf('Computing topological landscape... ');
for i = 1:size(B1, 1)
    for j = 1:size(B1, 2)
        S_max(i,j) = armMaxStress(t_rim, D, B1(i,j), B2(i,j), rho, W, n, Omega, r_hub, k, T);
    end
end
fprintf('Done.\n');

% High-Visibility Arm Stress Topology
clear; clc;

% --- Parameters (Regular Satellite Scale) ---
rho = 2700; D = 0.20; t_rim = 0.015; n = 4;
W = 0.030; Omega = 6000 * (2*pi/60); T = 1.0;
r_hub = 0.020; k = 100;

% --- Create a Fine Mesh ---
res = 50; % Higher resolution for smoother "knees"
b1_vec = linspace(0.005, 0.040, res); 
b2_vec = linspace(0.005, 0.030, res); 
[B1, B2] = meshgrid(b1_vec, b2_vec);
S_max = zeros(size(B1));

for i = 1:size(B1, 1)
    for j = 1:size(B1, 2)
        S_max(i,j) = armMaxStress(t_rim, D, B1(i,j), B2(i,j), rho, W, n, Omega, r_hub, k, T);
    end
end



% Topological Visualization: Faceted Mesh (No Shading)
clear; clc;

% --- Parameters (Regular Satellite Scale) ---
rho = 2700; D = 0.20; t_rim = 0.015; n = 4;
W = 0.030; Omega = 6000 * (2*pi/60); T = 1.0;
r_hub = 0.020; k = 100;

% --- Create a Discrete Mesh ---
% We use a slightly lower resolution (30-35) so the facets are visible
res = 35; 
b1_vec = linspace(0.005, 0.040, res); 
b2_vec = linspace(0.005, 0.030, res); 
[B1, B2] = meshgrid(b1_vec, b2_vec);
S_max = zeros(size(B1));

for i = 1:size(B1, 1)
    for j = 1:size(B1, 2)
        S_max(i,j) = armMaxStress(t_rim, D, B1(i,j), B2(i,j), rho, W, n, Omega, r_hub, k, T);
    end
end

% --- Plotting: Discrete Facets ---
figure('Color', 'w', 'Position', [100, 100, 900, 650]);

% surfc adds the 2D contour map to the floor
h = surfc(B1*1000, B2*1000, S_max/1e6);

% --- The "No Shading" Magic ---
shading faceted; % Discrete solid colors for each cell
set(h(1), 'EdgeColor', [0.1 0.1 0.1], 'LineWidth', 0.3); % Sharp black edges
set(h(2), 'LineWidth', 1.1); % Thicker floor contours for reference

% --- Aesthetics ---
colormap(jet); % High contrast colors
cb = colorbar;
ylabel(cb, 'Max Arm Stress [MPa]', 'FontSize', 11);

% View angle to see the "valley" and the "plateau" clearly
view(-135, 30); 

xlabel('b1 (Hub Width) [mm]', 'FontWeight', 'bold');
ylabel('b2 (Rim Width) [mm]', 'FontWeight', 'bold');
zlabel('Stress [MPa]', 'FontWeight', 'bold');
title('Structural Topology: Faceted Stress Landscape', 'FontSize', 12);
grid on;