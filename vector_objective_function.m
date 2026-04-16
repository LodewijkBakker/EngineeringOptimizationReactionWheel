function objective_value = vector_objective_function(b, t_ring, D, rho, W, n, k, T, max_tensile_stress_allowable)
    b1 = b(1);
    b2 = b(2);

    objective_value = objective_function_RW(t_ring, D, b1, b2, rho, W, n, k, T, max_tensile_stress_allowable);
end