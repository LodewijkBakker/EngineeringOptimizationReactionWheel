function [objective_value] = objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable)

    [specific_rot_energy, ~] = max_energy_for_setup(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable);
    objective_value = specific_rot_energy;
end