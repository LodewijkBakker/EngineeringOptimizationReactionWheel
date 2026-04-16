function [correct_geometry, L_spoke, r_hub] = dimension_constraints(t_ring, D, b1, b2, W, n)
    arguments (Input)
        t_ring % radial thickness [m]
        D % Diameter_wheel [m]
        b1   % Spoke inner thickness [m]
        b2 % Spoke outer thickness [m]
        W % out of plane thickness [m]
        n % amount of spoke, no n is one due to it being unbalanced!!
    end
    arguments (Output)
        correct_geometry
        L_spoke
        r_hub
    end

    correct_geometry = true;
    L_spoke = NaN;
    r_hub = NaN;

    % bounds

    % if all the polyong point are the ring this would be the width of a 
    % face
    max_b = 2*tan(pi/n)*(D/2 - t_ring);
    % its done seperately so each of these errors can be dealt with
    % individually
    if t_ring > D || t_ring <= 0
        disp(t_ring)
        disp("ring error")
        correct_geometry = false;
        return
    elseif L_spoke > D || L_spoke <= 0
        correct_geometry = false;
         disp("L_spoke error")
        return 
    elseif r_hub > D/2 || r_hub <= 0
        correct_geometry = false;
        disp("r_hub error")
        return 
    elseif b1 > D || b1 <= 0 || b1 > max_b
        disp("b1 error")
        correct_geometry = false;
        return
    elseif b2 > D || b2 <= 0 || b2 > max_b
        disp(b2)
        disp("b2 error")
        correct_geometry = false;
        return
    end
 
    r_hub = b1/(2*tan(pi/n));
    L_spoke = D/2 - t_ring - r_hub;

    end
