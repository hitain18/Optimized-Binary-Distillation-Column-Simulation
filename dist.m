% Binary Distillation Column Simulation using McCabe-Thiele Method
% System: Benzene-Toluene (Ideal Mixture)

clear; clc; clf;

fprintf('--- Starting Distillation Simulation ---\n');

% --- 1. Define Feed, Target, and Plant Parameters ---
alpha = 2.5;              % Relative volatility (Benzene-Toluene)
xF = 0.5;                 % Feed mole fraction (50%)
xD_target = 0.95;         % TARGET: 95% Separation Efficiency 
xB = 0.05;                % Bottoms waste fraction (5%)
q = 1.0;                  % Saturated liquid feed
tray_efficiency = 0.75;   % NEW: Real-world tray efficiency (75%)

% --- 2. DYNAMIC CALCULATION: Minimum Reflux Ratio (R_min) ---
y_vle_at_feed = (alpha * xF) / (1 + (alpha - 1) * xF); 
slope_min = (xD_target - y_vle_at_feed) / (xD_target - xF);
R_min = slope_min / (1 - slope_min);
R_actual = 1.5 * R_min; 

fprintf('Target Purity: %d%%\n', xD_target * 100);
fprintf('Calculated Minimum Reflux (R_min): %.3f\n', R_min);
fprintf('Selected Operating Reflux (1.5 * R_min): %.3f\n\n', R_actual);

% --- 3. Generate VLE Curve ---
x_vle = linspace(0, 1, 100);
y_vle = (alpha .* x_vle) ./ (1 + (alpha - 1) .* x_vle);

% --- 4. Calculate Operating Lines ---
% Rectifying Section
x_rect = linspace(xF, xD_target, 50);
y_rect = (R_actual / (R_actual + 1)) .* x_rect + (xD_target / (R_actual + 1));

% Intersection point
x_int = xF;
y_int = (R_actual / (R_actual + 1)) * x_int + (xD_target / (R_actual + 1));

% Stripping Section
x_strip = linspace(xB, x_int, 50);
slope_strip = (y_int - xB) / (x_int - xB);
y_strip = slope_strip .* (x_strip - xB) + xB;

% --- 5. Stepwise Stage Construction ---
stages_x = xD_target;
stages_y = xD_target;
current_x = xD_target;
current_y = xD_target;
stage_count = 0;
optimal_feed_stage = 0; 

while current_x > xB
    % Horizontal step (Equilibrium)
    current_x = current_y / (alpha - current_y * (alpha - 1));
    stages_x = [stages_x, current_x];
    stages_y = [stages_y, current_y];
    
    stage_count = stage_count + 1;
    
    % Vertical step (Operating lines) & Feed Tray Logic
    if current_x > xF
        current_y = (R_actual / (R_actual + 1)) * current_x + (xD_target / (R_actual + 1));
    else
        if optimal_feed_stage == 0
            optimal_feed_stage = stage_count;
        end
        current_y = slope_strip * (current_x - xB) + xB;
    end
    
    stages_x = [stages_x, current_x];
    stages_y = [stages_y, current_y];
end

% NEW: Calculate Actual Physical Trays needed based on efficiency
actual_physical_trays = ceil(stage_count / tray_efficiency);

fprintf('--- Simulation Results ---\n');
fprintf('Theoretical Stages Required: %d\n', stage_count);
fprintf('Actual Physical Trays to Build (at 75%% efficiency): %d\n', actual_physical_trays);
fprintf('Optimal Feed Location: Physical Tray %d\n', ceil(optimal_feed_stage / tray_efficiency));
fprintf('----------------------------------------\n');

% --- 6. Plotting ---
figure(1);
hold on;
plot(x_vle, y_vle, 'b-', 'LineWidth', 1.5, 'DisplayName', 'VLE Curve');
plot([0 1], [0 1], 'k--', 'DisplayName', '45° Line');
plot(x_rect, y_rect, 'g-', 'LineWidth', 1.5, 'DisplayName', 'Rectifying Line');
plot(x_strip, y_strip, 'm-', 'LineWidth', 1.5, 'DisplayName', 'Stripping Line');
plot([xF xF], [xF y_int], 'r--', 'LineWidth', 1.5, 'DisplayName', 'q-line (Feed)');
plot(stages_x, stages_y, 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('Theoretical Stages (%d)', stage_count));
plot(stages_x(optimal_feed_stage*2), stages_y(optimal_feed_stage*2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'y', 'DisplayName', 'Theoretical Feed Stage');

title('Optimized Distillation Design (95% Separation)');
xlabel('Liquid Mole Fraction (x)');
ylabel('Vapor Mole Fraction (y)');
axis([0 1 0 1]);
grid on;
legend('Location', 'northwest');
hold off;

% --- 7. Generate Dataset and Export to CSV (Analytics Ready) ---
Tray_Number = (0:stage_count)';
Liquid_Fraction_x = stages_x(1:2:end)';
Vapor_Fraction_y = stages_y(1:2:end)';

% NEW: Dynamic Tagging for SQL/Power BI analysis
Column_Section = cell(stage_count + 1, 1);
for i = 1:length(Column_Section)
    if i == 1
        Column_Section{i} = 'Condenser';
    elseif i <= optimal_feed_stage
        Column_Section{i} = 'Rectifying';
    else
        Column_Section{i} = 'Stripping';
    end
end

% Create a structured table
StageData = table(Tray_Number, Column_Section, Liquid_Fraction_x, Vapor_Fraction_y);

% Export to CSV
writetable(StageData, 'Distillation_Stage_Compositions.csv');
fprintf('Success: Analytics-ready dataset exported to "Distillation_Stage_Compositions.csv"\n');