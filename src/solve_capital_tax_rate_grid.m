% Set model parameters
parameters.alpha = 0.3845;                                      % Capital share
parameters.delta = 0.0371;                                      % Depreciation rate
parameters.gZ    = 0.0103;                                      % TFP growth rate
parameters.n     = 0.0107;                                      % Population growth rate
parameters.rho   = 0.4;                                         % Pension replacement rate
parameters.beta  = 1.011;                                       % Discount factor
parameters.sigma = 2;                                           % CRRA
parameters.ell   = 0.3;                                         % Labour supply
parameters.J     = 60;                                          % Maximum age
parameters.JRet  = 46;                                          % Retirement age
parameters.g     = 0.2;                                         % Public spending share of output

% Set technical parameters
MAXITERATIONS = 300;
TOLERANCE     = 1e-6;  % convergence criterium
LAMBDA        = 0.5;   % fixed point iteration dampening factor
LAMBDAHH      = 0.01;  % fixed point iteration dampening factor for solving household problem

tau_k_grid = linspace(0,1,1000); % Capital tax rates grid

% Initial guess for capital intensity
Kguess = 5;

% Output matrices
residuals = NaN(1,1000);
goods_market_residuals = NaN(1,1000);

labor_tax_rate = NaN(1,1000);
govt_cap_tax_revenue = NaN(1,1000);
welfare_sum = NaN(1,1000);

% Solving the model over the grid with dampened fixed point iteration
for i = 1:1000
    parameters.tau_k = tau_k_grid(i);

    for iter = 1:MAXITERATIONS
        % Initial asset guesses used in household optimization
        if iter == 1
            aguess = 1;
        else
            aguess = a(end);
        end
        % Call the solver function
        [residual, goods_market_residual, step, a, c, tau_w, r] = olg_solver(parameters, Kguess, aguess, LAMBDAHH);
    
        % Evaluate convergence
        if residual < TOLERANCE
            break
        else
            Kguess = Kguess + LAMBDA*step;
        end
    end
    % Collect residual and goods market residual
    residuals(i) = residual;
    goods_market_residuals(i) = goods_market_residual;
    
    % Collect endogenous labor income tax rate and gov't capital tax revenue
    tau_w_solutions(i) = tau_w;
    govt_cap_tax_revenue(i) = r*parameters.tau_k*Kguess;
   
    % Calculate household welfare
    welfare = NaN(1,60);
    for j = 1:parameters.J
        welfare(j) = parameters.beta^(j-1)*((((1+parameters.gZ)^(j-1))*c(j))^(1-parameters.sigma)-1)/(1-parameters.sigma);
    end

    welfare_sum(i) = sum(welfare);
end

% Confirm convergence and goods market clearing
if max(residuals) < TOLERANCE && max(goods_market_residuals) < TOLERANCE
    disp("Solutions found, and goods market clearing confirmed!");
elseif max(residuals) < TOLERANCE
    disp("Possible solutions found, but goods market clearing could not be confirmed.");
end

% Export results for plotting
results = table(tau_k_grid', tau_w_solutions', govt_cap_tax_revenue', welfare_sum',VariableNames = ["cap_tax_rate" "lab_tax_rate" "govt_cap_tax_revenue" "welfare"]);
writetable(results, "data/cap_tax_rate_grid.csv");
