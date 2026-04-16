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

    % its done seperately so each of these errors can be dealt with
    % individually
    if t_ring > D || t_ring <= 0
        disp(t_ring)
        disp("ring error")
        correct_geometry = false;
        return
    elseif L_spoke > D || L_spoke <= 0
        correct_geometry = false;
        return 
    elseif r_hub > D/2 || r_hub <= 0
        correct_geometry = false;
        return 
    elseif b1 > D || b1 <= 0
        correct_geometry = false;
        return
    elseif b2 > D || b2 <= 0
        correct_geometry = false;
        return
    end
  
    %L_spoke = D-t_ring - tan(pi/n)*2/b1; % actual L if joining is taken into account
   
    r_hub = b1/(2*tan(pi/n));
    L_spoke = D - t_ring - r_hub;

    end
%rules
% t_ring < D;
% L_spoke < D;
% r_hub < R;
% b1 & b2 < D; % probably allot smaller. 