%   
%   FULLMODEL_SHOOTING computes the full general equilibrium OLG model with
%   many generations and a a pension system, in which the household problem
%   is solved with the shooting method.
%   
%   The code assumes a stationary population distribution with 1 percent
%   population growht per year in which households live with certainty
%   until an age of 79 (model age 60) and retire at age 65 (model age 46).
%   The population size is normalized to 1. TFP grows by 1 percent per
%   year; the capital share is 0.3; the capital depreciation rate is 5
%   percent; the social security replacement rate 40 percent; and
%   households have a discount factor and CRRA parameter equal to 0.98
%   and 2, respectively.
%   
%   Author: Markus Pettersson, Stockholm University.
%   
% -------------------------------------------------------------------------

% Set parameters
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
TOLERANCE     = 1e-6;
LAMBDA        = 0.5;
LAMBDAHH      = 0.01;

tau_k_grid = linspace(0,1,1000); % Capital tax rates grid

% Initial guess for capital intensity
Kguess = 5;

% Output matrices
residuals = NaN(1,1000);
goods_market_residuals = NaN(1,1000);

labor_tax_rate = NaN(1,1000);
govt_cap_tax_revenue = NaN(1,1000);

for i = 1:1000
    parameters.tau_k = tau_k_grid(i);

    for iter = 1:MAXITERATIONS
        if iter == 1
            aguess = 1;
        else
            aguess = a(end);
        end

        [residual, goods_market_residual, step, a, tau_w, r] = olg_solver(parameters, Kguess, aguess, LAMBDAHH);
    
        % Evaluate convergence
        if residual < TOLERANCE
            break
        else
            Kguess = Kguess + LAMBDA*step;
        end
    end

    residuals(i) = residual;
    goods_market_residuals(i) = goods_market_residual;

    tau_w_solutions(i) = tau_w;
    govt_cap_tax_revenue(i) = r*parameters.tau_k*Kguess;
end

% Confirm convergence and goods market clearing
if max(residuals) < TOLERANCE && max(goods_market_residuals) < TOLERANCE
    disp("Solutions found, and goods market clearing confirmed!");
elseif max(residuals) < TOLERANCE
    disp("Possible solutions found, but goods market clearing could not be confirmed.");
end

results = table(tau_k_grid', tau_w_solutions', govt_cap_tax_revenue', VariableNames = ["cap_tax_rate" "lab_tax_rate" "govt_cap_tax_revenue"]);
writetable(results, "data/processed/cap_tax_rate_grid.csv");
