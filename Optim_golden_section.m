
clear; clc;

% Initial parameters of the flywheel
t_nom = 0.020; D_nom = 0.418; b1_nom = 0.030; rho = 7850;
W_nom = 0.020; n_nom = 5; r_hub = 0.050/(2*tan(pi/n_nom));
T_nom = 1; Omega_nom = 6000 * 2*pi/60; k = 100;

% Make the function only variable with b2
f = @(b2) armMaxStress(t_nom, D_nom, b1_nom, b2, rho, W_nom, n_nom, Omega_nom, r_hub, k, T_nom);

% Parameters of the Golden Section method
a_init = 0.005; b_init = 0.050; %initial segment
tol = 1e-5; %tolerance for the final segment
phi = (sqrt(5) - 1)/2; %golden ratio constant

iter = 0;
history = []; 


a = a_init; b = b_init;
d = phi*(b - a); %initial segment, and points inside
x1 = b - d;
x2 = a + d;
f1 = f(x1); f2 = f(x2);

while abs(b - a) > tol && iter < 30 % Limit max no. iterations
    iter = iter + 1;
    history = [history; iter, a, b, x1, x2, f1, f2];
    
    if f1 < f2 %Search in left part of the segment
        b = x2;
        x2 = x1;
        f2 = f1;

        d  = phi * (b - a);
        x1 = b - d;
        f1 = f(x1); 
    else %Search in right part of the segment
        a = x1;
        x1 = x2;
        f1 = f2;
        d = phi*(b - a);
        x2 = a + d;
        f2 = f(x2);

    end
end

b2_opt = (a + b) / 2; % Optimal b2 value found at the end of the iterations
[sigma_min, r_max_stress] = f(b2_opt)

%Plot the optimization process
figure('Color', 'w', 'Position', [100 100 1000 800]);

% Plot sweep of the b2 values
subplot(2,1,1); hold on;
b2_sweep = linspace(a_init, b_init, 1000);
s_sweep = arrayfun(@(x) f(x), b2_sweep);
plot(b2_sweep*1000, s_sweep/1e6, 'k', 'LineWidth', 1.5, 'DisplayName', 'Stress Curve');

colors = jet(size(history,1));
for i = 1:size(history,1)
    plot(history(i,4)*1000, history(i,6)/1e6, 'd', 'Color', colors(i,:), 'MarkerSize', 5, 'MarkerFaceColor', colors(i,:));
    plot(history(i,5)*1000, history(i,7)/1e6, 'd', 'Color', colors(i,:), 'MarkerSize', 5, 'MarkerFaceColor', colors(i,:));
end
xlabel('b2 [mm]'); ylabel('Stress [MPa]'); grid on;
title('Golden Section Evaluation History (x markers)');

% Plot segments over time
subplot(2,1,2); hold on;
for i = 1:size(history,1)
    line([history(i,2)*1000, history(i,3)*1000], [i, i], 'Color', colors(i,:), 'LineWidth', 4);
    plot(history(i,4)*1000, i, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k');
    plot(history(i,5)*1000, i, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k');
end
set(gca, 'YDir', 'reverse');
xlabel('b2 [mm]'); ylabel('Iteration Number');
title('Search Interval Reduction (Segments)');
grid on; colormap(jet); cb = colorbar; ylabel(cb, 'Progress');

% Create a side-by-side comparison figure
figure('Color', 'w', 'Position', [100 100 1200 600]);




draw_reaction_wheel(t_nom, r_hub, D_nom, b1_nom, 0.04, W_nom, n_nom);
draw_reaction_wheel(t_nom, r_hub, D_nom, b1_nom, b2_opt, W_nom, n_nom);



