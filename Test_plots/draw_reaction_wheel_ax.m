function draw_reaction_wheel_ax(ax, t_ring, D, b1, b2, W, n)

    arguments
        ax
        t_ring
        D
        b1
        b2
        W
        n
    end

    [~, ~, r_hub] = dimension_constraints(t_ring, D, b1, b2, W, n);

    R_outer = D/2;
    R_inner = R_outer - t_ring;

    axes(ax);
    hold(ax, 'on');
    axis(ax, 'equal');
    view(ax, 3);
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    zlabel(ax, 'Z');
    grid(ax, 'on');

    theta = linspace(0, 2*pi, 100);

    % Z levels
    z_top = W/2;
    z_bot = -W/2;

    %% === RING ===
    [Xo, Zo] = meshgrid(R_outer*cos(theta), [z_bot z_top]);
    [Yo, ~]  = meshgrid(R_outer*sin(theta), [z_bot z_top]);
    surf(ax, Xo, Yo, Zo, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');

    [Xi, Zi] = meshgrid(R_inner*cos(theta), [z_bot z_top]);
    [Yi, ~]  = meshgrid(R_inner*sin(theta), [z_bot z_top]);
    surf(ax, Xi, Yi, Zi, 'FaceColor', [1 1 1], 'EdgeColor', 'none');

    %% === HUB ===
    [Xh, Zh] = meshgrid(r_hub*cos(theta), [z_bot z_top]);
    [Yh, ~]  = meshgrid(r_hub*sin(theta), [z_bot z_top]);
    surf(ax, Xh, Yh, Zh, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none');

    fill3(ax, r_hub*cos(theta), r_hub*sin(theta), z_top*ones(size(theta)), [0.3 0.3 0.3]);
    fill3(ax, r_hub*cos(theta), r_hub*sin(theta), z_bot*ones(size(theta)), [0.3 0.3 0.3]);

    %% === RING CAPS ===
    fill3(ax, [R_outer*cos(theta) fliplr(R_inner*cos(theta))], ...
              [R_outer*sin(theta) fliplr(R_inner*sin(theta))], ...
              z_top*ones(1, 2*length(theta)), ...
              [0.7 0.7 0.7]);

    fill3(ax, [R_outer*cos(theta) fliplr(R_inner*cos(theta))], ...
              [R_outer*sin(theta) fliplr(R_inner*sin(theta))], ...
              z_bot*ones(1, 2*length(theta)), ...
              [0.7 0.7 0.7]);

    %% === SPOKES ===
    for i = 1:n
        angle = 2*pi*(i-1)/n;

        r_start = r_hub;
        r_end   = R_inner;

        p1 = [r_start*cos(angle) - (b1/2)*sin(angle), ...
              r_start*sin(angle) + (b1/2)*cos(angle)];

        p2 = [r_start*cos(angle) + (b1/2)*sin(angle), ...
              r_start*sin(angle) - (b1/2)*cos(angle)];

        p3 = [r_end*cos(angle)   + (b2/2)*sin(angle), ...
              r_end*sin(angle)   - (b2/2)*cos(angle)];

        p4 = [r_end*cos(angle)   - (b2/2)*sin(angle), ...
              r_end*sin(angle)   + (b2/2)*cos(angle)];

        % Top face
        fill3(ax, [p1(1) p2(1) p3(1) p4(1)], ...
                  [p1(2) p2(2) p3(2) p4(2)], ...
                  z_top*ones(1,4), [0.2 0.2 0.8]);

        % Bottom face
        fill3(ax, [p1(1) p2(1) p3(1) p4(1)], ...
                  [p1(2) p2(2) p3(2) p4(2)], ...
                  z_bot*ones(1,4), [0.2 0.2 0.8]);

        % Side walls
        verts = [p1; p2; p3; p4];
        for k = 1:4
            k2 = mod(k,4)+1;
            fill3(ax, [verts(k,1) verts(k2,1) verts(k2,1) verts(k,1)], ...
                      [verts(k,2) verts(k2,2) verts(k2,2) verts(k,2)], ...
                      [z_top z_top z_bot z_bot], ...
                      [0.2 0.2 0.8]);
        end
    end

    camlight(ax);
    lighting(ax, 'gouraud');
end