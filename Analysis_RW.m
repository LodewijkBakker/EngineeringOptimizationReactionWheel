
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

% gradient method 
% simplify so that t_ring does not form the boundary
step_size = 0.00001;
dx = 0.0001; % size of step for getting gradient
f_obj = @(b1, b2) objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable);
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

    % update b1 and b2
    b1 = b1 - step_size*dfdx1;
    b2 = b2 - step_size*dfdx2;

    disp(b1)
    disp(b2)
    disp(loops)
    loops = loops + 1;
end



% draw 
draw_reaction_wheel(t_ring, r_hub, D, b1, b2, W, n);

