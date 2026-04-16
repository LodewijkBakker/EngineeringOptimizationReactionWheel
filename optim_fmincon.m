clear;
clc;


% Constant values
rho_const = 7850;  
W_const = 0.02;   
n_const = 8;  
T_nom = 1;

sigma_yield = 1170 *10^6; %yield strenghth of the material - 17-4 PH (H900)
T_nom = 0; %Nominal torque
k = 100; %arm stress divisions


% 2. Create the function handle
% We assume x = [t_ring, D, b1, b2, Omega]
f = @(x) -rotational_energy_new(x(1), x(2), x(3), x(4), rho_const, W_const, n_const, x(5));

%Bounds for optimization:
ub = [0.2, 1, 0.2, 0.2, 10000*2*pi/60];
lb = [0.001, 0.95, 0.01, 0.005, 1000*2*pi/60];


%g1 - Rim stress constraint
g1 = @(x) flywheelStressRim(rho_const, x(2), x(5), n_const, x(1)) - sigma_yield;

%g2 - Arm stress constrraint
g2 = @(x)  (armMaxStress(x(1), x(2), x(3), x(4), rho_const, W_const, n_const, x(5), x(3)/(2*tan(pi/n_const)), k, T_nom) - sigma_yield);

% g3: Spoke Length Safety (Ensures Rim Inner Radius > Hub Radius)
g3 = @(x) (x(3)/(2*tan(pi/n_const))) - (x(2)/2 - x(1)) + 0.005; % Spoke must be at least 5mm

% Combine into nonlcon
nonlcon = @(x) deal([g1(x); g2(x); g3(x)], []);


x0 = [0.01, 0.4, 0.03, 0.02, 3000 * 2*pi/60]; 
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');

[x_opt, J_opt] = fmincon(f, x0, [], [], [], [], lb, ub, nonlcon, options);



% Display the optimized parameters and their corresponding values
fprintf('Optimized Parameters:\n');
fprintf('t_ring: %.4f m\n', x_opt(1));
fprintf('D: %.4f m\n', x_opt(2));
fprintf('b1: %.4f m\n', x_opt(3));
fprintf('b2: %.4f m\n', x_opt(4));
fprintf('Omega: %.2f rad/s\n', x_opt(5));
fprintf('Objective Function Value: %.4f\n', -J_opt);

draw_reaction_wheel(x_opt(1), x_opt(2), x_opt(3), x_opt(4), W_const, n_const)



