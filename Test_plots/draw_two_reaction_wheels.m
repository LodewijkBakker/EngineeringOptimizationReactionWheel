function draw_two_reaction_wheels(params1, params2)
% params = [t_ring, D, b1, b2, W, n]

    figure('Color','w');

    ax1 = subplot(1,2,1);
    draw_reaction_wheel_ax(ax1, params1(1), params1(2), params1(3), params1(4), params1(5), params1(6));
    title(ax1, 'Initial flywheel');

    ax2 = subplot(1,2,2);
    draw_reaction_wheel_ax(ax2, params2(1), params2(2), params2(3), params2(4), params2(5), params2(6));
    title(ax2, 'Optimized flywheel');
end