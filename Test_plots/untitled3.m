% Flywheel Geometry Visualizer
clear; clc;

% --- Parameters (Regular Scale) ---
D = 0.200;          % 200 mm
t_rim = 0.015;      % 15 mm
n = 4;              % 4 spokes
b1 = 0.020;         % 20 mm (hub)
b2 = 0.01;         % 12 mm (rim)
r_hub = 0.020;      % 20 mm

% Calculations
R_out = D/2;
R_in = R_out - t_rim;
theta = linspace(0, 2*pi, 200);

figure('Color', 'w'); hold on;

% 1. Plot Rim
x_out = R_out * cos(theta); y_out = R_out * sin(theta);
x_in = R_in * cos(theta);   y_in = R_in * sin(theta);
fill([x_out, fliplr(x_in)], [y_out, fliplr(y_in)], [0.7 0.7 0.7], 'EdgeColor', 'k');

% 2. Plot Hub
x_h = r_hub * cos(theta); y_h = r_hub * sin(theta);
fill(x_h, y_h, [0.4 0.4 0.4], 'EdgeColor', 'k');

% 3. Plot Spokes
spoke_angles = linspace(0, 2*pi, n+1);
for i = 1:n
    phi = spoke_angles(i);
    
    % Corners of the trapezoidal spoke in local coordinates
    % (x is along the spoke, y is width)
    local_x = [r_hub, R_in, R_in, r_hub];
    local_y = [-b1/2, -b2/2, b2/2, b1/2];
    
    % Rotate to global coordinates
    global_x = local_x * cos(phi) - local_y * sin(phi);
    global_y = local_x * sin(phi) + local_y * cos(phi);
    
    fill(global_x, global_y, [0.7 0.7 0.7], 'EdgeColor', 'k');
end

% Formatting
axis equal; grid on;
xlabel('x [m]'); ylabel('y [m]');
title(sprintf('Flywheel Geometry (D=%dmm, n=%d, b1=%dmm, b2=%dmm)', D*1000, n, b1*1000, b2*1000));



