function [specific_rot_energy, rot_energy, M_total] = rotational_energy_new(t_ring, D, b1, b2, rho, W, n, Omega)
    % --- 1. Geometric Dependency Calculation ---
    Ro = D/2;                       % Outer Radius
    Ri = Ro - t_ring;               % Inner Rim Radius (Spoke Endpoint)
    
    % Radius of Inscribed Circle (Apothem) of the Hub Polygon
    % This is the "flat" face where the spoke starts.
    Rh = b1 / (2 * tan(pi/n));      % Hub Apothem (Spoke Startpoint)
    
    % Calculate L_spoke internally
    L_spoke = Ri - Rh;
    
    % Physical Sanity Check: If spokes have negative length, return 0
    if L_spoke <= 0
        rot_energy = 0;
        return;
    end

    % --- 2. The Ring (Rim) ---
    Vol_ring = pi * (Ro^2 - Ri^2) * W;
    M_ring = rho * Vol_ring;
    I_ring = 0.5 * M_ring * (Ro^2 + Ri^2);
    
    % --- 3. The Spokes (Trapezoid) ---
    % Area of the trapezoid face
    Area_spoke = L_spoke * (b1 + b2) / 2;
    M_spoke = rho * Area_spoke * W;
    
    % Distance from wheel center to the Spoke Centroid
    % Centroid of trapezoid from the b1 side (hub side)
    y_bar = (L_spoke/3) * ((b1 + 2*b2) / (b1 + b2));
    d_spoke = Rh + y_bar; 
    
    % Local Inertia of the spoke about its own centroid
    % (Approximated as a rectangular block of average width for local rotation)
    b_avg = (b1 + b2) / 2;
    I_spoke_local = (1/12) * M_spoke * (L_spoke^2 + b_avg^2);
    
    % Total Spoke Inertia using Parallel Axis Theorem
    I_spokes_total = n * (I_spoke_local + M_spoke * d_spoke^2);
    
    % --- 4. The Hub (Inner Polygon) ---
    % A regular polygon is made of n triangles
    Area_hub = n * (0.5 * b1 * Rh);
    M_hub = rho * Area_hub * W;
    
    % Inertia of a regular polygon about its center
    R_circum = b1 / (2 * sin(pi/n)); % Radius of circumscribed circle
    I_hub = 0.5 * M_hub * R_circum^2 * (1 - (2/3) * sin(pi/n)^2);
    
    % --- 5. Final Outputs ---
    M_total = M_ring + (n * M_spoke) + M_hub;
    I_total = I_ring + I_spokes_total + I_hub;
    
    rot_energy = 0.5 * I_total * Omega^2;
    specific_rot_energy = rot_energy / M_total;
end