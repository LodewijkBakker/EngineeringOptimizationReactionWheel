
% --- Base Input Parameters ---
D = 2;              % 2m Diameter [m] (Note: 2m is huge, stresses will be high!)
t_ring = 0.2;      % 20cm ring thickness [m]
W = 0.08;           % 8cm out-of-plane thickness [m]
n = 10;              % 6 spokes
k = 1000;            % Number of points to check
b1 = 0.1;
b2 = 0.1;

%-- fixed parameters
rho = 7850;         % Steel density [kg/m3]
T = 1000;           % 1000 Nm Torque

% dynamic should be based on thickness spokes and such and such.
r_hub = 0.5;        % 50cm hub radius [m]

[correct_geometry, L_spoke] = dimension_constraints(t_ring, D, b1, b2, W, n);
r_hub = D - L_spoke - t_ring;
draw_reaction_wheel(t_ring, r_hub, D, b1, b2, W, n);