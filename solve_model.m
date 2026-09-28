%   
%   FULLMODEL_SHOOTING computes the full general equilibrium OLG model with
%   many generations and a a pension system, in which the household problem
%   is solved with the shooting method.
%   
%   The code assumes a stationary population distribution with 1 percent
%   population growth per year in which households live with certainty
%   until an age of 79 (model age 60) and retire at age 65 (model age 46).
%   The population size is normalized to 1. TFP grows by 1.03 percent per
%   year; the capital share is 0.3845; the capital depreciation rate is 
%   3.71 percent; the social security replacement rate 40 percent; and
%   households have a discount factor and CRRA parameter equal to 1.011 
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
parameters.tau_k = 0.1;
parameters.g = 0.2;

% Set technical parameters
MAXITERATIONS = 200;
TOLERANCE = 1e-6;
LAMBDA    = 0.5;

% ======================================================================= %
%  SOLVE MODEL                                                            %
% ======================================================================= %

% Print iteration header
fprintf('Solving the model with replacement rate = %3.2g\n',parameters.rho)
fprintf('%9s %8s %14s\n','Iteration', 'K', 'Norm of f(K)');

% Initial guess for capital intensity
% K/Y=3 and alpha=0.3 -> Ktilde approximately 5
Kguess = 5;

% Run fixed-point iteration
for iter = 1:MAXITERATIONS
    if iter == 1
        aguess = 1;
    else
        aguess = a(end);
    end

    [residual, goods_market_residual, step, a, c] = olg_solver(parameters, Kguess, aguess);
    fprintf('%9f %8f %14f\n', iter, Kguess, residual);

    % Evaluate convergence
    if residual < TOLERANCE
        break
    else
        Kguess  = Kguess  + LAMBDA*step;
    end
end

% Print an exit message to give us an idea of what is going on
if residual < TOLERANCE && goods_market_residual < TOLERANCE 
    fprintf('Model solved: norm of f(K) is smaller than the tolerance level and the goods market clears.\n\n');
elseif residual < TOLERANCE
    fprintf('Possible solution: norm of f(K) smaller than the tolerance level but the goods market does not clear.\n\n');
else
    fprintf('No solution found: iteration limit reached.\n\n');
end

% Plot life-cycle profiles
figure
hold on
    plot(19+(1:parameters.J), a, 'linewidth', 1.5)
    plot(19+(1:parameters.J), c, 'linewidth', 1.5)
    ylim([0 2.5])
    legend('Assets','Consumption','location','northwest')
    title('Shooting method equilibrium')
    xlabel('Age')
    grid on
hold off
