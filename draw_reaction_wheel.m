function draw_reaction_wheel_3D(t_ring, D, b1, b2, W, n)
    arguments (Input)

        t_ring % radial thickness [m]
        D % Diameter_wheel [m]
        b1   % Spoke inner thickness [m]
        b2 % Spoke outer thickness [m]
        W % out of plane thickness [m]
        n % amount of spoke, no n is one due to it being unbalanced!!
    end

    [~, L_spoke, r_hub] = dimension_constraints(t_ring, D, b1, b2, W, n);
    %r_hub = D-L_spoke;

    R_outer = D/2;
    R_inner = R_outer - t_ring;

    figure; hold on; axis equal;
    view(3);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('3D Reaction Wheel');

    theta = linspace(0, 2*pi, 100);

    %% === Z levels (extrusion) ===
    z_top = W/2;
    z_bot = -W/2;

    %% === RING (outer cylinder - inner cylinder) ===
    % Outer surface
    [Xo, Zo] = meshgrid(R_outer*cos(theta), [z_bot z_top]);
    [Yo, ~]  = meshgrid(R_outer*sin(theta), [z_bot z_top]);
    surf(Xo, Yo, Zo, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');

    % Inner surface (hole)
    [Xi, Zi] = meshgrid(R_inner*cos(theta), [z_bot z_top]);
    [Yi, ~]  = meshgrid(R_inner*sin(theta), [z_bot z_top]);
    surf(Xi, Yi, Zi, 'FaceColor', [1 1 1], 'EdgeColor', 'none');

    %% === HUB (solid cylinder) ===
    [Xh, Zh] = meshgrid(r_hub*cos(theta), [z_bot z_top]);
    [Yh, ~]  = meshgrid(r_hub*sin(theta), [z_bot z_top]);
    surf(Xh, Yh, Zh, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none');

    % Top + bottom caps of hub
    fill3(r_hub*cos(theta), r_hub*sin(theta), z_top*ones(size(theta)), [0.3 0.3 0.3]);
    fill3(r_hub*cos(theta), r_hub*sin(theta), z_bot*ones(size(theta)), [0.3 0.3 0.3]);

    %% === RING CAPS (top & bottom) ===
    fill3([R_outer*cos(theta) fliplr(R_inner*cos(theta))], ...
          [R_outer*sin(theta) fliplr(R_inner*sin(theta))], ...
          z_top*ones(1, 2*length(theta)), ...
          [0.7 0.7 0.7]);

    fill3([R_outer*cos(theta) fliplr(R_inner*cos(theta))], ...
          [R_outer*sin(theta) fliplr(R_inner*sin(theta))], ...
          z_bot*ones(1, 2*length(theta)), ...
          [0.7 0.7 0.7]);

    %% === SPOKE(S) ===
    for i = 1:n
        angle = 2*pi*(i-1)/n;

        r_start = r_hub;
        r_end   = R_inner;

        % 2D trapezoid points
        p1 = [r_start*cos(angle) - (b1/2)*sin(angle), ...
              r_start*sin(angle) + (b1/2)*cos(angle)];

        p2 = [r_start*cos(angle) + (b1/2)*sin(angle), ...
              r_start*sin(angle) - (b1/2)*cos(angle)];

        p3 = [r_end*cos(angle) + (b2/2)*sin(angle), ...
              r_end*sin(angle) - (b2/2)*cos(angle)];

        p4 = [r_end*cos(angle) - (b2/2)*sin(angle), ...
              r_end*sin(angle) + (b2/2)*cos(angle)];

        % Top face
        fill3([p1(1) p2(1) p3(1) p4(1)], ...
              [p1(2) p2(2) p3(2) p4(2)], ...
              z_top*ones(1,4), [0.2 0.2 0.8]);

        % Bottom face
        fill3([p1(1) p2(1) p3(1) p4(1)], ...
              [p1(2) p2(2) p3(2) p4(2)], ...
              z_bot*ones(1,4), [0.2 0.2 0.8]);

        % Side walls
        verts = [p1; p2; p3; p4];
        for k = 1:4
            k2 = mod(k,4)+1;
            fill3([verts(k,1) verts(k2,1) verts(k2,1) verts(k,1)], ...
                  [verts(k,2) verts(k2,2) verts(k2,2) verts(k,2)], ...
                  [z_top z_top z_bot z_bot], ...
                  [0.2 0.2 0.8]);
        end
    end

    %% === Visual tweaks ===
    camlight;
    lighting gouraud;
    grid on;
end