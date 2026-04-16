function [specific_rot_energy] = objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable)

    [~, ~, r_hub] = dimension_constraints(t_ring, D, b1, b2, W, n);

    omega_start = 10; % Initial guess for fzero
    f = @(Omega) max_stress_zeroed(t_ring, D, b1, b2, rho, W, n, Omega, r_hub, k, T, max_tensile_stress_allowable);
    omega_max = fzero(f, omega_start);

    [specific_rot_energy, ~] = rotational_energy(t_ring,D,b1,b2,rho,W,n,omega_max);


end