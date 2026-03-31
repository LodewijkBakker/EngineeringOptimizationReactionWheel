function [ sigma_total, sigma_t, sigma_b] = flywheelStressRim(rho, D, Omega, n, t_ring)
    
    %conversion from design variables to local formulas
    R = (D-t_ring)/2;
    

    % Calculate flywheel rim stress (assumes rectangular crosssection!)
    % Inputs:
    %   rho - Density of material (kg/m^3)
    %   R - Mean radius of flywheel (m)
    %   omega - Angular speed (rad/s)
    %   n - Number of arms
    %   t_ring  - Thickness of the rim (m)
    %
    % Outputs:
    %   sigma_t  - Hoop (tensile) stress (Pa)
    %   sigma_b  - Bending stress due to arm restraint (Pa)
    %   sigma_total - Total combined stress (Pa)

    % Hoop Stress
    sigma_t = rho * (R^2) * (Omega.^2);

    % Calculate Bending Stress
    sigma_b = (19.74 * rho * (Omega.^2) * (R^3)) / ((n^2) * t_ring);

    % Calculate Total Stress
    sigma_total = sigma_t + sigma_b;
end