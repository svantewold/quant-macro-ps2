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
parameters.alpha    = 0.30;                                                           % Capital share
parameters.delta    = 0.05;                                                           % Depreciation rate
parameters.gZ       = 0.01;                                                           % TFP growth rate
parameters.n        = 0.01;                                                           % Population growth rate
parameters.rho      = 0.4;                                                            % Pension replacement rate
parameters.beta     = 1.011;                                                           % Discount factor
parameters.sigma    = 2;                                                              % CRRA
parameters.ell      = 0.3;                                                            % Labour supply
parameters.J        = 60;                                                             % Maximum age
parameters.JRet     = 46;                                                             % Retirement age
parameters.tau_k = 0.15;

% Impose stationary population with total size equal to 1
N        = (1+n).^(J:-1:1);                                                % Stationary population
N        = N / sum(N);                                                     % Normalize to 1

% Labour force = total households younger than 46 * ell
L        = ell * sum(N(1:JRet-1));                                         % Total labour force
emprate  = L/sum(N);                                                       % Total labour force as share of population

% Set technical parameters
MAXITER   = 100;                                                           % Max number of root-finding iterations
TOLERANCE = 1e-6;                                                          % Root-finding tolerance level
LAMBDA    = 0.5;                                                           % FP iteration dampening: equilibrium

% Output matrices for optimal choices
astart   = 0;                                                              % Starting assets at age 0
a        = NaN(1,J);                                                       % Asset choice
c        = NaN(1,J);                                                       % Consumption choice

% ======================================================================= %
%  SOLVE MODEL                                                            %
% ======================================================================= %

% Print iteration header
fprintf('Solving the model with replacement rate = %3.2g\n',rho)
fprintf('%9s %8s %14s\n','Iteration', 'K', 'Norm of f(K)');

% Initial guess for capital intensity
% K/Y=3 and alpha=0.3 -> Ktilde approximately 5
Kguess = 5;

% Run fixed-point iteration
for iter = 1:maxiter
    [residual, goods_market_residual] = olg_solver(parameters, Kguess);
   
    % Evaluate convergence
    if residual < TOLERANCE
        break
    else
        Kguess  = Kguess  + LAMBDA*(K - Kguess);
    end
end



% Finally, print an exit message to give us an idea of what is going on
if Kcond < tol && residY < tol
    fprintf('Model solved: norm of f(K) is smaller than the tolerance level and the goods market clears.\n\n');
elseif Kcond < tol
    fprintf('Possible solution: norm of f(K) smaller than the tolerance level but the goods market does not clear.\n\n');
else
    fprintf('No solution found: iteration limit reached.\n\n');
end



% Plot life-cycle profiles
figure
hold on
    plot(19+(1:J), a, 'linewidth', 1.5)
    plot(19+(1:J), c, 'linewidth', 1.5)
    ylim([0 2.5])
    legend('Assets','Consumption','location','northwest')
    title('Shooting method equilibrium')
    xlabel('Age')
    grid on
hold off
