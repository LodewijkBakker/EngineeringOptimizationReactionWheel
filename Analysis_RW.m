
% --- Base Input Parameters ---
D = 0.3;              % 0.3m Diameter [m] (Note: 2m is huge, stresses will be high!)
t_ring = 0.05;      % 2cm ring thickness [m]
W = 0.02;           % 2cm out-of-plane thickness [m]
n = 5;              % 6 spokes
k = 1000;            % Number of points to check

b1 = 0.03;
b2 = 0.03;


%-- fixed parameters
rho = 2780;         % Steel density [kg/m3]
T = 1;           % 10 Nm Torque
max_tensile_stress_allowable = 289e6;  % yield strength


objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable)

% gradient method 
% simplify so that t_ring does not form the boundary
step_size = 1e-6;
dx = 0.01; % size of step for getting gradient
f_obj = @(b1, b2) objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable);

% graph results across 
b1_vals = linspace(0.001, 0.05, 50);
b2_vals = linspace(0.001, 0.05, 50);
[b1_vis, b2_vis] = meshgrid(b1_vals, b2_vals);
z = arrayfun(f_obj, b1_vis, b2_vis);
surf(b1_vis, b2_vis, z)
xlabel('b1');
ylabel('b2');
zlabel('specific angular momentum [J/kg]');
title('Objective Function Surface Plot');
colorbar


convergence_norm = 1e-5;  % minimum difference between result to accept results
convergence_res = -1;
loops = 0;
max_loops = 10;
prev_res = -1;  % previous result to calculate convergence with

while loops < max_loops && convergence_res < convergence_norm
    f_obj_nom = f_obj(b1, b2);

    % get gradients
    f_obj_x1 = f_obj(b1+dx, b2);
    f_obj_x2 = f_obj(b1, b2+dx);
    dfdx1 = (f_obj_x1 - f_obj_nom)/dx;
    dfdx2 = (f_obj_x2 - f_obj_nom)/dx;
    disp(dfdx1)
    disp(dfdx2)

    % update b1 and b2
    b1 = b1 + step_size*dfdx1;
    b2 = b2 + step_size*dfdx2;

    disp(string(b1) + " b1 updated")
    disp(string(b2) + " b2 updated")

    loops = loops + 1;
    disp(loops)
    convergence_res = abs(f_obj_nom- prev_res);
    prev_res = f_obj_nom;
end



% draw 
draw_reaction_wheel(t_ring, D, b1, b2, W, n);

