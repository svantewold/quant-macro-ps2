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
parameters.alpha    = 0.3845;                                      % Capital share
parameters.delta    = 0.0371;                                      % Depreciation rate
parameters.gZ       = 0.0103;                                      % TFP growth rate
parameters.n        = 0.0107;                                      % Population growth rate
parameters.rho      = 0.4;                                         % Pension replacement rate
parameters.beta     = 1.011;                                       % Discount factor
parameters.sigma    = 2;                                           % CRRA
parameters.ell      = 0.3;                                         % Labour supply
parameters.J        = 60;                                          % Maximum age
parameters.JRet     = 46;                                          % Retirement age
parameters.g = 0.2;

% Set technical parameters
MAXITERATIONS = 200;
TOLERANCE = 1e-6;
LAMBDA    = 0.5;

% SOLVE MODEL

tau_k_grid = linspace(0,1,1000); % Capital tax rates grid

% Initial guess for capital intensity
Kguess = 5;
residuals = NaN(1,1000);

for i = 2:1000
    parameters.tau_k = tau_k_grid(i);

    for iter = 1:MAXITERATIONS
        if iter == 1
            aguess = 1;
        else
            aguess = a(end);
        end
    
        [residual, goods_market_residual, step, a, c] = olg_solver(parameters, Kguess, aguess);
    
        % Evaluate convergence
        if residual < TOLERANCE
            break
        else
            Kguess = Kguess + LAMBDA*step;
        end
    end

    residuals(i) = residual;
    cap_intensity(i) = Kguess;
end

if max(abs(residuals)) < TOLERANCE
    disp("Solutions found!");
else
    disp("Solutions not found");
end

[max, id] = max(cap_intensity);
fprintf("%20s %26s\n", "Max. capital intensity", "Optimal capital tax rate");
fprintf("%22.3f %26.3f\n", max, tau_k_grid(id));
