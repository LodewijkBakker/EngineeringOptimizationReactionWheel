%% 3D Augmented Objective Landscape: Mesh Grid Topography
clear; clc; close all;

% --- 1. Material & Fixed Geometry Parameters ---
rho = 7850;             
W = 0.05;               
n = 5;                  
d_shaft = 0.05;         
Sy = 1170e6/4;          % Safety factor of 4 applied
r_hub = d_shaft / (2 * tan(pi/n));

t_rim_fixed = 0.015;    
D_fixed     = 0.400;    
Omega_fixed = 6000 * (2*pi/60); 

% --- 2. Compute the Augmented Landscape (J_total) ---
res = 50; % Reduced slightly for better grid-line spacing
b1_grid = linspace(0.005, 0.045, res);
b2_grid = linspace(0.005, 0.045, res);
[B1, B2] = meshgrid(b1_grid, b2_grid);
J_total_mesh = zeros(size(B1));

fprintf('Generating Topographic Mesh... ');
for i = 1:res
    for j = 1:res
        x_temp = [B1(i,j), B2(i,j)];
        J_val = penalized_objective_2D(x_temp, rho, W, n, d_shaft, Sy, t_rim_fixed, D_fixed, Omega_fixed);
        J_total_mesh(i,j) = max(J_val, -2000); 
    end
end
fprintf('Done.\n');

% --- 3. DIY Optimization Loop ---
x = [0.040, 0.040];     
step_size = 5e-5;   
max_iter = 2500;
history_x = x;          
history_J = [];         

for k = 1:max_iter
    J_now = penalized_objective_2D(x, rho, W, n, d_shaft, Sy, t_rim_fixed, D_fixed, Omega_fixed);
    history_J = [history_J; J_now];
    h = 1e-6; grad = zeros(1, 2);
    for i = 1:2
        xn = x; xn(i) = xn(i) + h;
        J_nudge = penalized_objective_2D(xn, rho, W, n, d_shaft, Sy, t_rim_fixed, D_fixed, Omega_fixed);
        grad(i) = (J_nudge - J_now) / h;
    end
    direction = grad / norm(grad);
    x = x + (step_size * direction);
    history_x = [history_x; x];
end
J_final = penalized_objective_2D(x, rho, W, n, d_shaft, Sy, t_rim_fixed, D_fixed, Omega_fixed);
history_J = [history_J; J_final];

%% --- 4. Plotting the Results (Mesh Style) ---
figure('Color', 'w', 'Position', [100, 100, 1100, 750]);

% A. Draw the Mesh Grid
% meshc adds a contour plot to the bottom for better depth perception
s = meshc(B1*1000, B2*1000, J_total_mesh);

% --- TOPOGRAPHY INSPECTION SETTINGS ---
s(1).EdgeColor = 'interp';    % Colors the lines based on height
s(1).FaceColor = [0.97 0.97 0.97]; % Light gray faces for hidden-line removal
s(1).LineWidth = 0.5;
colormap(jet); 
cb = colorbar; ylabel(cb, 'J_{total}');
hold on;

% B. Draw the Trajectory Path
% Plotted slightly thicker for the mesh background
plot3(history_x(:,1)*1000, history_x(:,2)*1000, history_J + 40, ...
    'k-o', 'LineWidth', 2, 'MarkerSize', 4, 'MarkerFaceColor', 'w');

% C. Start and End Markers
plot3(history_x(1,1)*1000, history_x(1,2)*1000, history_J(1) + 80, ...
    'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g'); 
plot3(x(1)*1000, x(2)*1000, history_J(end) + 80, ...
    'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); 

% D. Aesthetics
grid on;
view(145, 35); 
xlabel('b1 (Hub) [mm]', 'FontWeight', 'bold');
ylabel('b2 (Rim) [mm]', 'FontWeight', 'bold');
zlabel('J_{total}', 'FontWeight', 'bold');
title(['Mesh Topography: J_{total} Optimization Trajectory (Sy = ', num2str(Sy/1e6), ' MPa)']);

legend([s(1)], {'Augmented Objective Mesh'}, 'Location', 'NorthWest');

%% --- 5. Supporting Penalty Function ---
function J_aug = penalized_objective_2D(x, rho, W, n, d_shaft, Sy, t_rim, D, Omega)
    b1 = x(1); b2 = x(2);
    r_hub = d_shaft / (2 * tan(pi/n));
    L_spoke = (D/2 - t_rim) - r_hub;
    [spec_e, ~] = rotational_energy_new(t_rim, D, b1, b2, rho, W, L_spoke, n, Omega);
    sig_arm = armMaxStress(t_rim, D, b1, b2, rho, W, n, Omega, r_hub, 60, 0);
    P = 2000 * exp(40 * (sig_arm/Sy - 1));
    J_aug = spec_e - P;
end