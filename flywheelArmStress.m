function [sigma_t1, sigma_b1, sigma_arm_total] = flywheelArmStress(rho, R, omega, T, r, n, Z)

    %Calculates stresses in the flywheel arms (note - stress calculated only at base). 
    %
    % Inputs:
    %   rho  - Density (kg/m^3)
    %   R  - Mean radius of rim (m)
    %   omega - Angular speed (rad/s)
    %   T - Max torque transmitted (N-m)
    %   r - Radius of the hub (m)
    %   n - Number of arms
    %   Z - Section modulus of arm (m^3)


    % Tensile stress due to centrifugal force
    v = R * omega;
    sigma_t1 = (3/4) * rho * v^2;

    % Bending stress due to torque transmitted
    sigma_b1 = (T * (R - r)) / (R * n * Z);


    % Total Stress in the arms
    sigma_arm_total = sigma_t1 + sigma_b1;

end