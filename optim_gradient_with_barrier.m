clear; clc; close all;

%Parameters of the flywheel
rho = 7850;             
W = 0.05;               
n = 3;                  
d_shaft = 0.05;  %b1 init    
Sy = 1170e6/2;          % Yield strenght with Safety factor of 2
r_hub = d_shaft / (2 * tan(pi/n));



t_rim_fixed = 0.015;    
D_fixed     = 0.400;    
Omega_fixed = 6000 * (2*pi/60); 


% Steepest ascent optimization loop parameters
x_init = [0.025, 0.025];   %initial point (Design variable vector [b1, b2]) 
step_size = 5e-5;   
x = x_init;
max_iter = 4000;
history_x = x;          
history_J = [];
h = 1e-6; % gradient step size
grad = zeros(1, 2);


for k = 1:max_iter
    J_now = penalized_objective_2D(x, rho, W, n, Sy, t_rim_fixed, D_fixed, Omega_fixed);
   
    if k > 100 && all(abs(diff(history_J(end-49:end))) < 1e-4) %Checking if there is still meaningful change in the objective
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

    sig_arm = armMaxStress(t_rim, D, b1, b2, rho, W, n, Omega, r_hub, 60, 1);

    %barrier func implementation
    mu = 1e-3;
    r1 = sig_arm / Sy;
    r2 = b1 / (0.2 * D);
    r3 = b2 / (0.2 * D);
    
    % Check if ratioswill result in a real ln
    if r1 < 1 && r2 < 1 && r3 < 1
        % Barrier functions
        B1 = mu * log(1 - r1);
        B2 = mu * log(1 - r2);
        B3 = mu * log(1 - r3);
        J_aug = norm_spec_e + B1 + B2 + B3;
    else
        % Infeasible state- assign a low constant value
        J_aug = -5; 
    end
end





%plots
%-------------------------------------------------------------------

% --- Generate Topographic Mesh ---
% --- Generate Topographic Mesh ---
res = 100; 
b1_grid = linspace(0.001, 0.03, res); 
b2_grid = linspace(0.001, 0.03, res);
[B1, B2] = meshgrid(b1_grid, b2_grid);
J_total_mesh = zeros(size(B1));

fprintf('Generating Topographic Mesh... ');
for i = 1:res
    for j = 1:res
        J_val = penalized_objective_2D([B1(i,j), B2(i,j)], rho, W, n, Sy, t_rim_fixed, D_fixed, Omega_fixed);
        % Clip for better Z-axis scaling (0 is fine, but -0.2 shows the "rounded" edge better)
        J_total_mesh(i,j) = max(J_val, 0); 
    end
end
fprintf('Done.\n');

% --- Plot Trajectories ---
figure('Color', 'w', 'Position', [100, 100, 1100, 750]);

% A. Draw Smooth Surface (surfc adds contours to the bottom)
s = surfc(B1*1000, B2*1000, J_total_mesh);
hold on;

% B. Add Contours to the Surface itself
% We use 25 levels to show the "crown" of the objective function
[~, h_cont] = contour3(B1*1000, B2*1000, J_total_mesh, 25);
h_cont.LineColor = [0.2 0.2 0.2]; % Dark grey lines
h_cont.LineWidth = 0.5;
h_cont.LineStyle = '-';

% --- Engineering Visual Refinement ---
s(1).EdgeColor = 'none';        
s(1).FaceColor = 'interp';      
s(1).FaceAlpha = 0.85;          


colormap(jet); 
cb = colorbar; ylabel(cb, 'J_{total} (Normalized)');

% C. Draw Trajectory Path (Increased offset to float above contours)
h_path = plot3(history_x(:,1)*1000, history_x(:,2)*1000, history_J + 0.01, ...
    'k-', 'LineWidth', 2.5); 

% D. Start and End Markers
h_start = plot3(history_x(1,1)*1000, history_x(1,2)*1000, history_J(1) + 0.02, ...
    'go', 'MarkerSize', 8, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k'); 
h_end = plot3(x(1)*1000, x(2)*1000, history_J(end) + 0.02, ...
    'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k'); 

% E. Aesthetics
grid on;
view(145, 35); 
xlabel('b1 (Hub) [mm]', 'FontWeight', 'bold');
ylabel('b2 (Rim) [mm]', 'FontWeight', 'bold');
zlabel('J_{total} (Normalized)', 'FontWeight', 'bold');
title(['Optimization Trajectory with Surface Contours (Sy = ', num2str(Sy/1e6), ' MPa)']);
view(200, 30);

legend([s(1), h_cont, h_path, h_start, h_end], ...
    {'Objective Surface', 'Topographic Contours', 'Search Path', 'Start', 'Optimum'}, ...
    'Location', 'NorthWest');


% --- 1. Extract Stats for Initial Design ---
[spec_e_init, ~, M_init] = rotational_energy_new(t_rim_fixed, D_fixed, x_init(1), x_init(2), rho, W, n, Omega_fixed);
sig_init = armMaxStress(t_rim_fixed, D_fixed, x_init(1), x_init(2), rho, W, n, Omega_fixed, x_init(1)/(2*tan(pi/n)), 60, 1);
J_init = spec_e_init / (1/16 * D_fixed^2 * Omega_fixed^2);

% --- 2. Extract Stats for Optimized Design ---
[spec_e_final, ~, M_final] = rotational_energy_new(t_rim_fixed, D_fixed, x(1), x(2), rho, W, n, Omega_fixed);
sig_final = armMaxStress(t_rim_fixed, D_fixed, x(1), x(2), rho, W, n, Omega_fixed, x(1)/(2*tan(pi/n)), 60, 1);
J_final_raw = spec_e_final / (1/16 * D_fixed^2 * Omega_fixed^2);

% --- 3. Pack Data ---
% params = [t_ring, D, b1, b2, W, n]
params1 = [t_rim_fixed, D_fixed, x_init(1), x_init(2), W, n];
stats1  = [M_init, J_init, sig_init];

params2 = [t_rim_fixed, D_fixed, x(1), x(2), W, n];
stats2  = [M_final, J_final_raw, sig_final];

% --- 4. Call Drawing Function ---
draw_two_reaction_wheels_augmented(params1, stats1, params2, stats2);


function draw_two_reaction_wheels_augmented(params1, stats1, params2, stats2)
    figure('Color','w', 'Position', [100, 100, 1300, 650]);
    
    % --- Initial Subplot ---
    ax1 = subplot(1,2,1);
    draw_reaction_wheel_ax(ax1, params1(1), params1(2), params1(3), params1(4), params1(5), params1(6));
    title(ax1, 'Initial Design (Baseline)', 'FontSize', 14, 'FontWeight', 'bold');
    add_stats_table(ax1, params1, stats1, 'Initial');

    % --- Optimized Subplot ---
    ax2 = subplot(1,2,2);
    draw_reaction_wheel_ax(ax2, params2(1), params2(2), params2(3), params2(4), params2(5), params2(6));
    title(ax2, 'Optimized Design (Stress-Limited)', 'FontSize', 14, 'FontWeight', 'bold');
    add_stats_table(ax2, params2, stats2, 'Optimized');
    
    % Synchronize views for comparison
    linkprop([ax1, ax2], {'View', 'XLim', 'YLim', 'ZLim'});
    view(ax1, 135, 30);
end

function add_stats_table(ax, p, s, label)
    % Formatting strings
    % Uses LaTeX for precise engineering symbols
    str = {['\bf{', label, ' Design Metrics}'], ...
           ['$b_1 = ', num2str(p(3)*1000, '%.1f'), '$ mm'], ...
           ['$b_2 = ', num2str(p(4)*1000, '%.1f'), '$ mm'], ...
           ['Mass: ', num2str(s(1), '%.2f'), ' kg'], ...
           ['Efficiency $J$: ', num2str(s(2), '%.2f')], ...
           ['$\sigma_{max}: ', num2str(s(3)/1e6, '%.0f'), '$ MPa']};
    
    % Using 'normalized' units turns the text into a 2D overlay (0 to 1 scale)
    % [0.05, 0.85] places it in the top-left corner of the subplot area
    text(ax, 0.05, 0.82, str, 'Units', 'normalized', ...
        'Interpreter', 'latex', 'FontSize', 10, ...
        'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 1, ...
        'BackgroundColor', [1 1 1 0.9], 'Margin', 5);
end



% --- Convergence Analysis Plot ---
figure('Color', 'w', 'Name', 'Optimization Convergence', 'Position', [100, 100, 1000, 800]);

% 1. Objective Function Convergence
subplot(3,1,1);
plot(0:length(history_J)-1, history_J, 'b', 'LineWidth', 2);
grid on; ylabel('J_{aug} (Normalized)');
title('Objective Function Convergence');
set(gca, 'FontSize', 10);
ylim([1 2])

% 2. Design Variable Evolution
subplot(3,1,2);
plot(0:size(history_x,1)-1, history_x(:,1)*1000, 'r', 'LineWidth', 1.5, 'DisplayName', 'b1 (Hub)');
hold on;
plot(0:size(history_x,1)-1, history_x(:,2)*1000, 'g', 'LineWidth', 1.5, 'DisplayName', 'b2 (Rim)');
grid on; ylabel('Width [mm]');
legend('Location', 'best');
title('Design Variable Evolution');

% 3. Stress Evolution
% Re-calculate stress history for plotting
stress_history = zeros(size(history_x,1), 1);
for i = 1:size(history_x,1)
    bx = history_x(i,:);
    rh = bx(1) / (2 * tan(pi/n));
    stress_history(i) = armMaxStress(t_rim_fixed, D_fixed, bx(1), bx(2), rho, W, n, Omega_fixed, rh, 60, 1);
end

subplot(3,1,3);
plot(0:length(stress_history)-1, stress_history/1e6, 'm', 'LineWidth', 2);
hold on;
yline(Sy/1e6, 'k--', 'Allowable Stress (S_y)', 'LineWidth', 1.5);
grid on; ylabel('Max Arm Stress [MPa]');
xlabel('Iteration');
title('Constraint (Stress) Evolution');