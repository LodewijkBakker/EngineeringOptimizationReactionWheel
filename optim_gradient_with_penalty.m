clear; clc; close all;

%Parameters of the flywheel
rho = 7850;             
W = 0.05;               
n = 5;                  
d_shaft = 0.05;  %b1 init    
Sy = 1170e6/2;          % Yield strenght with Safety factor of 2
r_hub = d_shaft / (2 * tan(pi/n));


t_rim_fixed = 0.015;    
D_fixed     = 0.400;    
Omega_fixed = 6000 * (2*pi/60); 


% Steepest ascent optimization loop parameters
x = [0.025, 0.025];   %initial point (Design variable vector [b1, b2]) 
step_size = 5e-5;   
max_iter = 4000;
history_x = x;          
history_J = [];
h = 1e-6; % gradient step size
grad = zeros(1, 2);

for k = 1:max_iter
    J_now = penalized_objective_2D(x, rho, W, n, Sy, t_rim_fixed, D_fixed, Omega_fixed);
   
    if k > 1 && abs(J_now - history_J(end)) < 1e-4 %Checking if there is still meaningful change in the objective
        fprintf('Optimization Stalled (Converged) at iteration %d\n', k);
        break;
    end

    history_J = [history_J; J_now];
    

    for i = 1:2 %Loop over all design variables (directions)
        xn = x;
        xn(i) = xn(i) + h;
        J_nudge = penalized_objective_2D(xn, rho, W, n, Sy, t_rim_fixed, D_fixed, Omega_fixed);
        grad(i) = (J_nudge - J_now) / h; %calculate gradient for design variable
    end
    
    gnorm = norm(grad);
    if gnorm < 1e-6  % Terminate if an extremum is found
        fprintf('Peak reached at iteration %d\n', k);
        break; 
    end
    direction = grad / gnorm;
    current_step = step_size * (1 - k*0.995/(max_iter)); % decrease the step size, with each iteration, but not smaller than 0.5% of the original step size
    x = x + (current_step * direction); %calculate the direction vector, and move there with step size
    history_x = [history_x; x];
end


J_final = penalized_objective_2D(x, rho, W, n, Sy, t_rim_fixed, D_fixed, Omega_fixed);
history_J = [history_J; J_final]; %save trajectory


%Objective function with penalty included
function J_aug = penalized_objective_2D(x, rho, W, n, Sy, t_rim, D, Omega)
    b1 = x(1); b2 = x(2);
    r_hub = x(1) / (2 * tan(pi/n));
    [spec_e, ~, ~] = rotational_energy_new(t_rim, D, b1, b2, rho, W, n, Omega); %get specific rotational energy
    norm_spec_e = spec_e / (1/16 * D^2*Omega^2); %normalizing the spec_e, by rotational energy of a solid disk 

    sig_arm = armMaxStress(t_rim, D, b1, b2, rho, W, n, Omega, r_hub, 60, 0);

    scale = 0.5; 
    sharpness = 20; 

    P1 = scale * exp(sharpness * (sig_arm/Sy - 1)); %Penalty function - exponential growth, when sig_arm hits specified Sy
    P2 = scale * exp(sharpness * (x(1)/(0.2*D) - 1)); % Penalty for b1 > D/2
    P3 = scale * exp(sharpness * (x(2)/(0.2*D) - 1)); % Penalty for b2 > D/2
    J_aug = norm_spec_e - P1 - P2 - P3; % Modified objectife function
end





%plots
%-------------------------------------------------------------------

% --- Generate Topographic Mesh ---
res = 100; 
b1_grid = linspace(0.001, 0.2, res); % Increased range slightly to see the peak
b2_grid = linspace(0.001, 0.2, res);
[B1, B2] = meshgrid(b1_grid, b2_grid);
J_total_mesh = zeros(size(B1));

fprintf('Generating Topographic Mesh... ');
for i = 1:res
    for j = 1:res
        J_val = penalized_objective_2D([B1(i,j), B2(i,j)], rho, W, n, Sy, t_rim_fixed, D_fixed, Omega_fixed);
        % Clip very low penalty values to -0.2 for better Z-axis scaling
        J_total_mesh(i,j) = max(J_val, -3); 
    end
end
fprintf('Done.\n');

% --- Plot Trajectories ---
figure('Color', 'w', 'Position', [100, 100, 1100, 750]);

% A. Draw Mesh (meshc adds contour lines to the bottom)
s = meshc(B1*1000, B2*1000, J_total_mesh);
s(1).EdgeColor = 'interp';    
s(1).FaceColor = [0.97 0.97 0.97]; 
s(1).FaceAlpha = 0.7;
colormap(jet); 
cb = colorbar; ylabel(cb, 'J_{total} (Normalized)');
hold on;

% B. Draw Trajectory Path (Offset reduced to 0.05 for normalized scale)
h_path = plot3(history_x(:,1)*1000, history_x(:,2)*1000, history_J + 0.001, ...
    'k-o', 'LineWidth', 1.5, 'MarkerSize', 3, 'MarkerFaceColor', 'w');

% C. Start and End Markers (Offset reduced to 0.1 for normalized scale)
h_start = plot3(history_x(1,1)*1000, history_x(1,2)*1000, history_J(1) + 0.01, ...
    'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g'); 
h_end = plot3(x(1)*1000, x(2)*1000, history_J(end) + 0.01, ...
    'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k'); 

% D. Aesthetics
grid on;
view(145, 35); 
xlabel('b1 (Hub) [mm]', 'FontWeight', 'bold');
ylabel('b2 (Rim) [mm]', 'FontWeight', 'bold');
zlabel('J_{total} (Normalized)', 'FontWeight', 'bold');
title(['Optimization Trajectory (Sy = ', num2str(Sy/1e6), ' MPa)']);

legend([s(1), h_path, h_start, h_end], ...
    {'Objective Mesh', 'Search Path', 'Start', 'Optimum'}, 'Location', 'NorthWest');
