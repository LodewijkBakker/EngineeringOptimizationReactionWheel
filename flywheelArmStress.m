function sigma_arm_total = flywheelArmStress(rho, R_outer, Omega, T, r, n, Z, Area, t_ring, W, F_spoke)
    % Calculates the total combined stress at a specific point along a flywheel arm.
    %
    % Inputs:
    %   rho     - Density of the material [kg/m^3]
    %   R_outer - Outer radius of the flywheel rim [m]
    %   Omega   - Angular velocity [rad/s]
    %   T       - Maximum torque transmitted by the shaft [N-m]
    %   r       - Local radial position where stress is evaluated [m]
    %   n       - Total number of arms (spokes)
    %   Z       - Local section modulus of the arm at position r [m^3]
    %   Area    - Local cross-sectional area of the arm at position r [m^2]
    %   t_ring  - Radial thickness of the rim [m]
    %   W       - Out-of-plane thickness (width) of the flywheel [m]
    %   F_spoke - Centrifugal force of the spoke mass outboard of r [N]
    %
   
    % Outputs:
    %   sigma_arm_total - Combined tensile and bending stress [Pa]

    
    % --- 1. Geometry Constants
    R_mean = R_outer - t_ring/2;      % Radius to the center of the rim mass
    R_spoke_end = R_outer - t_ring;   % Radius where the spoke meets the rim

    % --- 2. Tensile Stress (Centrifugal)-
    % Each arm must "hold" its share of the rim's mass.
    % Mass of one rim segment = Volume_segment * rho
    V_rim_total = pi * (R_outer^2 - R_spoke_end^2) * W;
    M_seg = (V_rim_total * rho) / n;
    
  
    Force_centrifugal = M_seg * (Omega^2) * R_mean;

    %tensile stress from rim centrifugal force and spoke centrifugal force
    sigma_t = (Force_centrifugal + F_spoke) / Area;
       
    % --- 3. Bending Stress
    Force_torque = T / (n * R_spoke_end);
    

    % Lever arm is the distance from the rim junction back to point r
    Moment_arm = (R_spoke_end - r);
    M_bending = Force_torque * Moment_arm;
    
    % Stress = Moment / Section Modulus
    sigma_b = M_bending / Z;
    % --- 4. Total Combined Stress ---
    sigma_arm_total = sigma_t + sigma_b;
end