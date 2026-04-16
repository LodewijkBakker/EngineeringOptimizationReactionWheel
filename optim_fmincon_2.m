clear;
clc;


% Constant values
rho_const = 7850;  
W_const = 0.02;   
n_const = 6;  
omega_const = 6000*2*pi/60;
mass_budget = 25;

sigma_yield = 1170 *10^6 * 0.5; %yield strenghth of the material - 17-4 PH (H900)
T_nom = 1; %Nominal torque
k = 100; %arm stress divisions


% 2. Create the function handle
% We assume x = [t_ring, D, b1, b2]
f = @(x) -rotational_energy_new(x(1), x(2), x(3), x(4), rho_const, W_const, n_const, omega_const);

%Bounds for optimization:
ub = [0.5, 2, 2, 2];
lb = [0.002, 0.1, 0.01, 0.001];


%g1 - Rim stress constraint
g1 = @(x) (flywheelStressRim(rho_const, x(2), omega_const, n_const, x(1)) - sigma_yield)/sigma_yield;

%g2 - Arm stress constrraint
g2 = @(x)  (armMaxStress(x(1), x(2), x(3), x(4), rho_const, W_const, n_const, omega_const, x(3)/(2*tan(pi/n_const)), k, T_nom) - sigma_yield)/sigma_yield;

% g3: Spoke Length constraint
L_spoke_min = 0.01;% Minimum length of spoke constraint
g3 = @(x) ( (x(3)/(2*tan(pi/n_const))) - (x(2)/2 - x(1)) + L_spoke_min ) / L_spoke_min; 

% g4 Rim thickness constraint (t_ring <= 50% of Radius)
g4 = @(x) x(1) - (0.9 * x(2)/2); 

% g5 maximum of b1
g5 = @(x) x(3) - 2*tan(pi/n_const)*(x(2)/2 - x(1)) + 0.0001;

% g6 maximum of b2
g6 = @(x) x(4) - 2*tan(pi/n_const)*(x(2)/2 - x(1)) + 0.0001;

% g7: MASS BUDGET 
g7 = @(x) (get_third_output(x, rho_const, W_const, n_const, omega_const) - mass_budget)/mass_budget;

function out = get_third_output(x, rho_const, W_const, n_const, omega_const)
    [~, out] = rotational_energy_new(x(1), x(2), x(3), x(4), ...
                                        rho_const, W_const, n_const, omega_const);
end

% Combine into nonlcon
nonlcon = @(x) deal([g1(x); g2(x); g3(x); g4(x); g5(x); g6(x); g7(x);], []);


x0 = [0.01, 0.4, 0.03, 0.02]; 
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');

[x_opt, J_opt] = fmincon(f, x0, [], [], [], [], lb, ub, nonlcon, options);



% Display the optimized parameters and their corresponding values
fprintf('Optimized Parameters:\n');
fprintf('t_ring: %.4f m\n', x_opt(1));
fprintf('D: %.4f m\n', x_opt(2));
fprintf('b1: %.4f m\n', x_opt(3));
fprintf('b2: %.4f m\n', x_opt(4));
fprintf('Omega: %.2f rad/s\n', omega_const);
fprintf('Objective Function Value: %.4f\n', -J_opt);


% --- Evaluate Constraints at the Optimum ---
[c_final, ~] = nonlcon(x_opt);

fprintf('\n--- Constraint Activity Check ---\n');
fprintf('g1 (Rim Stress):   %10.2f Pa (Slack: %10.2f)\n', c_final(1) + sigma_yield, -c_final(1));
fprintf('g2 (Arm Stress):   %10.2f Pa (Slack: %10.2f)\n', c_final(2) + sigma_yield, -c_final(2));
fprintf('g3 (Spoke Length): %10.4f m  (Slack: %10.4f)\n', c_final(3), -c_final(3));
fprintf('g4 (Rim/Radius):   %10.4f     (Slack: %10.4f)\n', c_final(4), -c_final(4));
fprintf('g5 (B1):   %10.4f     (Slack: %10.4f)\n', c_final(5), -c_final(5));
fprintf('g6 (B2):   %10.4f     (Slack: %10.4f)\n', c_final(6), -c_final(6));
mass_budget_final = g7(x_opt);
fprintf('g7 (Mass Budget) %.4f kg (Slack: %.4f)\n', mass_budget_final, -mass_budget_final);



draw_reaction_wheel(x_opt(1), x_opt(2), x_opt(3), x_opt(4), W_const, n_const)

