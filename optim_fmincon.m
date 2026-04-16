clear;
clc;


% Constant values
rho_const     = 7850;  
W_const       = 0.05;   
L_spoke_const = 0.2;   
n_const       = 5;      

% 2. Create the function handle
% We assume x = [t_ring, D, b1, b2, Omega]
% This maps x(1) to t_ring, x(2) to D, etc.
f = @(x) -rotational_energy_new(x(1), x(2), x(3), x(4), rho_const, W_const, L_spoke_const, ...
                                      n_const, x(5));


x_test = [0.01, 0.5, 0.02, 0.02, 6000, 0]; 

%Define constraints
sigma_yield = 1170 *10^6; %yield strenghth of the material - 17-4 PH (H900)
T_nom = 0; %Nominal torque
k = 100; %arm stress divisions


%g1 - Rim stress constraint
g1 = @(x) flywheelStressRim(rho_const, x(2), x(5), n_const, x(1)) - sigma_yield;

%g2 - Arm stress constrraint
g2 = @(x)  (armMaxStress(x(1), x(2), x(3), x(4), rho_const, W_const, n_const, x(5), x(2)/(2*tan(pi/n_const)), k, T_nom) - sigma_yield);

nonlcon = @(x) [g1(x), g2(x)];


% Define the optimization problem
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
x0 = x_test; % Initial guess








