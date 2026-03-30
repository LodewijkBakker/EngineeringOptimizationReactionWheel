function [sigma_t, sigma_b, sigma_total] = flywheelStress(rho, R, omega, n, t)

    % Calculate
    % Inputs:
    %   rho - Density of material (kg/m^3)
    %   R - Mean radius of flywheel (m)
    %   omega - Angular speed (rad/s)
    %   n - Number of arms
    %   t  - Thickness of the rim (m)
    %
    % Outputs:
    %   sigma_t  - Hoop (tensile) stress (Pa)
    %   sigma_b  - Bending stress due to arm restraint (Pa)
    %   sigma_total - Total combined stress (Pa)

    %Hoop Stress
    sigma_t = rho * (R^2) * (omega^2);

    %Calculate Bending Stress
    sigma_b = (19.74 * rho * (omega^2) * (R^3)) / ((n^2) * t);

    % 3. Calculate Total Stress
    sigma_total = sigma_t + sigma_b;
end