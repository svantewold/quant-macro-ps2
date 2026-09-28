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
alpha    = 0.30;                                                           % Capital share
delta    = 0.05;                                                           % Depreciation rate
gZ       = 0.01;                                                           % TFP growth rate
n        = 0.01;                                                           % Population growth rate
rho      = 0.4;                                                            % Pension replacement rate
beta     = 1.011;                                                           % Discount factor
sigma    = 2;                                                              % CRRA
ell      = 0.3;                                                            % Labour supply
J        = 60;                                                             % Maximum age
JRet     = 46;                                                             % Retirement age

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
LAMBDAHH  = 0.01;

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
    
    % Factor prices from firms' first-order conditions
    r = alpha * Kguess.^(alpha-1) - delta;
    w = (1-alpha) * Kguess.^alpha;
    
    % Return on savings
    R = 1 + r;
    
    % Pension transfer and tax rate from public sector budget
    b   = rho * w * ell;
    tau = b*sum(N(JRet:end)) / (w*L);
    
    % Set one overall vector with disposable income
    y           = NaN(1,J);
    y(1:JRet-1) = (1-tau)*w*ell;
    y(JRet:end) = b;
    
    
    % Initial guess for household problem
    % Note: use last iteration's solution if possible (faster convergence)
    if iter == 1
        aguess = 1;
    else
        aguess = a(end);
    end
    
    % Run shooting algorithm
    acond  = inf;
    while acond > tol
        
        % Final-age assets from guess
        a(end) = aguess;
        
        % Consumption from budget constraint (given that savings = 0)
        c(end) = R*a(end) + y(end);
        
        % Now loop over remaining cohorts
        for j = J-1:-1:1
            
            % Consumption from Euler equation
            c(j) = (beta*R).^(-1/sigma) .* (1+gZ) .* c(j+1);
            
            % Assets from budget constraint
            a(j) = (c(j) + (1+gZ)*a(j+1) - y(j)) / R;
            
        end
        
        % Check distance from astart for age-0 assets
        acond = abs(a(1) - astart);
        
        % Update asset guess with fixed point iteration
        aguess = aguess - lambdahh*(a(1) - astart);
        
    end
    
    
    % Market clearing conditions
    K      = sum(a.*N) ./ L;                                               % Capital market
    C      = sum(c.*N) ./ L;                                               % Aggregate consumption
    I      = ((1+n)*(1+gZ) - (1-delta))*K;                                 % Gross capital investment
    Y      = K^alpha;                                                      % Aggregate output
    residY = abs(Y - C - I);                                               % Goods market residual (zero by Walras law)
    
    
    % Iteration condition
    Kcond  = norm(Kguess-K, inf);
    
    % Print iteration output so we keep track of what is happening
    fprintf('%5i\t %9.6g %14.6g\n',iter,Kguess,Kcond);
    
    % Evaluate convergence
    if Kcond < tol
        break
    else
        Kguess  = Kguess  + lambda*(K  - Kguess);
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
