% --- MATLAB Script: N-Sweep Optimization ---
clear; clc;

% Fixed parameters
rho_const = 7850; W_const = 0.02; omega_const = 6000*2*pi/60;
mass_budget = 10; sigma_yield = 1170e6 * 0.5; T_nom = 0; k = 100;
L_spoke_min = 0.01;

% Preallocate results: [n, E_rot, t_ring, D, b1, b2, mass]
n_values = 3:10;
results = zeros(length(n_values), 7);

% Optimization options
options = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp', ...
    'FiniteDifferenceStepSize', 1e-4, 'FiniteDifferenceType', 'central');

for i = 1:length(n_values)
    n_curr = n_values(i);
    
    % Re-define handles for the current n
    f = @(x) -overal_energy(x, rho_const, W_const, n_curr, omega_const);
    
    nonlcon = @(x) deal([...
        (flywheelStressRim(rho_const, x(2), omega_const, n_curr, x(1)) - sigma_yield)/sigma_yield; % g1
        (armMaxStress(x(1), x(2), x(3), x(4), rho_const, W_const, n_curr, omega_const, x(3)/(2*tan(pi/n_curr)), k, T_nom) - sigma_yield)/sigma_yield; % g2
        ( (x(3)/(2*tan(pi/n_curr))) - (x(2)/2 - x(1)) + L_spoke_min ) / L_spoke_min; % g3
        x(1) - (0.9 * x(2)/2); % g4
        x(3) - 2*tan(pi/n_curr)*(x(2)/2 - x(1)) + 0.0001; % g5
        x(4) - 2*tan(pi/n_curr)*(x(2)/2 - x(1)) + 0.0001; % g6
        (get_third_output(x, rho_const, W_const, n_curr, omega_const) - mass_budget)/mass_budget % g7
    ], []);

    % Run optimization
    x0 = [0.01, 0.5, 0.015, 0.015];
    lb = [0.002, 0.1, 0.005, 0.005]; ub = [0.1, 0.5, 0.3, 0.3];
    [x_opt, J_opt] = fmincon(f, x0, [], [], [], [], lb, ub, nonlcon, options);
    
    % Record: [n, Energy, t_ring, D, b1, b2, Mass]
    [~, ~, m_final] = rotational_energy_new(x_opt(1), x_opt(2), x_opt(3), x_opt(4), ...
                                            rho_const, W_const, n_curr, omega_const);
    results(i, :) = [n_curr, -J_opt, x_opt(1)*1000, x_opt(2)*1000, x_opt(3)*1000, x_opt(4)*1000, m_final];
end

% --- Compilation for Report ---
T_results = array2table(results, 'VariableNames', {'n', 'Energy', 't_ring_mm', 'D_mm', 'b1_mm', 'b2_mm', 'Mass_kg'});
disp(T_results);

% Plot the trade-off
figure('Color', 'w');
yyaxis left; plot(n_values, results(:,2)/1000, 'b-s', 'LineWidth', 1.5); ylabel('Rotational Energy [kJ]');
yyaxis right; plot(n_values, results(:,5), 'r-o', 'LineWidth', 1.5); ylabel('Spoke end thickness b2 [mm]');
grid on; xlabel('Number of Spokes (n)'); title('N-Sweep: Energy and Spoke thickness');


function out2 = overal_energy(x, rho_const, W_const, n_const, omega_const)
    [~, out2, ~] = rotational_energy_new(x(1), x(2), x(3), x(4), ...
                                        rho_const, W_const, n_const, omega_const);
end

function out = get_third_output(x, rho_const, W_const, n_const, omega_const)
    [~, ~, out] = rotational_energy_new(x(1), x(2), x(3), x(4), ...
                                        rho_const, W_const, n_const, omega_const);
end


% --- Plot all optimized flywheel geometries in one figure (mm) ---
figure('Color','w','Name','Optimized Flywheel Geometries');

n_cases = size(results,1);
ncols = 4;
nrows = ceil(n_cases/ncols);

lim = max(results(:,4))/2 * 1.1;   % max radius from D [mm]

for i = 1:n_cases
    n_curr = results(i,1);
    E_curr = results(i,2)/1000;   % Energy [kJ]
    t_ring = results(i,3);        % mm
    D      = results(i,4);        % mm
    b1     = results(i,5);        % mm
    b2     = results(i,6);        % mm

    R_outer = D/2;
    R_inner = R_outer - t_ring;
    r_hub   = b1/(2*tan(pi/n_curr));   % mm

    theta = linspace(0,2*pi,300);

    subplot(nrows,ncols,i); hold on; axis equal off;

    % Ring
    x_ring = [R_outer*cos(theta), fliplr(R_inner*cos(theta))];
    y_ring = [R_outer*sin(theta), fliplr(R_inner*sin(theta))];
    fill(x_ring, y_ring, [0.75 0.75 0.75], 'EdgeColor', 'k', 'LineWidth', 0.8);

    % Hub
    fill(r_hub*cos(theta), r_hub*sin(theta), [0.30 0.30 0.30], ...
         'EdgeColor', 'k', 'LineWidth', 0.8);

    % Spokes
    for j = 1:n_curr
        angle = 2*pi*(j-1)/n_curr;

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

        fill([p1(1) p2(1) p3(1) p4(1)], ...
             [p1(2) p2(2) p3(2) p4(2)], ...
             [0.2 0.2 0.8], 'EdgeColor', 'k', 'LineWidth', 0.8);
    end

    xlim([-lim lim]);
    ylim([-lim lim]);

    title(sprintf('n = %d, E = %.3f kJ', n_curr, E_curr), 'FontSize', 11);
end