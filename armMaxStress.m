function [arm_sigma_max, r_max_stress] = armMaxStress(t_ring, D, b1, b2, rho, W, n, Omega, r_hub, k, T)
    %t_ring % radial thickness [m]
    %D % Diameter_wheel [m]
    %b1   % Spoke inner thickness [m]
    %b2 % Spoke outer thickness [m]
    %rho % density [kg/m3]
    %W % out of plane thickness [m]
    %n % amount of spoke, no n is one due to it being unbalanced!!
    %Omega % Rotational speed [rad/s]
    %r_hub - radius of the hub 
    %k - number of divisions of the arm, where we calculate stress
    %T - motor torque

    R_rim = (D-2*t_ring)/2; %Radius when spoke connects to the rim
    r = linspace(r_hub, R_rim, k); %discrete values of r along the arm lenght
    
    a = (b2-b1)/(R_rim - r_hub);
    b = a*(r - r_hub) +b1;
    Z = b.^2*W/6; %Section modulus of the arm (note its not the moment of inertia)
    
    % Calculate the spoke's own centrifugal force 
    C = b1 - a * r_hub; 
    F_spoke = rho * W * (Omega^2) * ( (C/2)*(R_rim^2 - r.^2) + (a/3)*(R_rim^3 - r.^3) );
    
    sigma_arm = zeros([1, length(r)]); %initilazing array for stress
    for i = 1:k
        Area_i = b(i) * W; 
        sigma_arm(i) = flywheelArmStress(rho, D/2, Omega, T, r(i), n, Z(i), Area_i, t_ring, W, F_spoke(i));
    end
    
    [arm_sigma_max, idx] = max(sigma_arm); %return max stress
    r_max_stress = r(idx); % Get the radius corresponding to the maximum stress
end