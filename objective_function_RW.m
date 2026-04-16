function [specific_rot_energy] = objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable)

    [~, L_spoke, r_hub] = dimension_constraints(t_ring, D, b1, b2, W, n);
    
    % the stresses should both be monotone increasing, which means that 
    f = @(Omega) max_stress_zeroed(t_ring, D, b1, b2, rho, W, n, Omega, r_hub, k, T, max_tensile_stress_allowable);
    omega_max = fzero(f, [1, 10000]);

    [specific_rot_energy, ~] = rotational_energy(t_ring,D,b1,b2,rho,W,L_spoke,n,omega_max);

end