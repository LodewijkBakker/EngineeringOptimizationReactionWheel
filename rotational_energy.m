function [specific_rot_energy, rot_energy] = rotational_energy(t_ring,D,b1,b2,rho,W,L_spoke,n,Omega)

arguments (Input)
    t_ring % radial thickness [m]
    D % Diameter_wheel [m]
    b1   % Spoke inner thickness [m]
    b2 % Spoke outer thickness [m]
    rho % density [kg/m3]
    W % out of plane thickness [m]
    L_spoke % length of spoke
    n % amount of spoke, no n is one due to it being unbalanced!!
    Omega % Rotational speed [rad/s]
end

arguments (Output)
    specific_rot_energy
    rot_energy
end

% split into 2 parts, the ring, the spoke and perhaps an inner polygon

% the ring
M_ring = rho*W*0.25*pi*(D^2 - (D-t_ring)^2); % mass of ring
I_ring = 0.5*M_ring*(D^2 + (D-t_ring)^2);

% the spokes, assuming that it is possible to meet at one point
% b1 must therefore not be sufficiently thick if n spokes > 2
% important b1 can be smaller than b2 or even equal to it. 

t_base = max([b1, b2])-min([b1, b2]);  % iscoscoles triangular base width
z_hypotenuse= ((0.5*t_base)^2 + L_spoke ^2)^0.5; % hypotenuse of triangle part of spoke

M_spoke_rect = rho*L_spoke*min([b1, b2])*W;
M_spoke_triangle = rho*0.5*L_spoke*t_base*W;
M_spoke = M_spoke_triangle + M_spoke_rect;
I_spoke_rect = (1/12)*(M_spoke_rect)*(L_spoke^2  + min([b1, b2])^2); %  moment of inertia for the rectangular part around center of rectangle

I_spoke_triangle = 1/36 * M_spoke_triangle * (2*z_hypotenuse^2 + t_base^2);  % around center of triangle. Guaranteed to be in the middle of L_spoke
I_spoke = I_spoke_rect + I_spoke_triangle; % basically a split iscoscoles triangle and a square in the middle

% inner polygon
R_inner_polygon = b1/(2*sin(pi/n)); 
H_inner_polygon = b1/(2*tan(pi/n));
M_inner_polygon = rho*W*0.5*b1*H_inner_polygon;
I_inner_polygon = n*0.5*M_inner_polygon*R_inner_polygon^2*(1- 2/3 * sin(pi/n)^2);

I_total = I_ring + I_spoke*n + M_inner_polygon* (H_inner_polygon+0.5*L_spoke)^2  + I_inner_polygon;  % add parallel axis theorem for I rect
M_total = M_inner_polygon + M_spoke*n + M_ring;

rot_energy = 0.5*I_total*Omega^2; % in joules
specific_rot_energy = rot_energy / M_total;

end