
% --- Base Input Parameters ---
D = 0.3;              % 0.3m Diameter [m] (Note: 2m is huge, stresses will be high!)
t_ring = 0.02;      % 2cm ring thickness [m]
W = 0.02;           % 2cm out-of-plane thickness [m]
n = 5;              % 6 spokes
k = 1000;            % Number of points to check

b1 = 0.02;
b2 = 0.02;


%-- fixed parameters
rho = 2780;         % Steel density [kg/m3]
T = 1;           % 10 Nm Torque
max_tensile_stress_allowable = 289e6;  % yield strength

objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable)

%
draw_reaction_wheel(t_ring, r_hub, D, b1, b2, W, n);


% gradient method 