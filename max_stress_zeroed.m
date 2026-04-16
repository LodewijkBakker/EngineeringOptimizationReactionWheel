
function [sigma_zeroed] = max_stress_zeroed(t_ring, D, b1, b2, rho, W, n, Omega, r_hub, k, T, max_tensile_stress_allowable)
    % returns the maximum stress min the max allowable so that root can be
    % found. 

    [arm_sigma_max, ~] = armMaxStress(t_ring, D, b1, b2, rho, W, n, Omega, r_hub, k, T);
    [sigma_total, ~, ~] = flywheelStressRim(rho, D, Omega, n, t_ring);
    % max stress
    max_stress = max([arm_sigma_max, sigma_total]);
    sigma_zeroed = max_stress - max_tensile_stress_allowable;


end