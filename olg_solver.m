function [residual, goods_market_residual, step, a, c] = olg_solver(parameters, Kguess, aguess)
    LAMBDAHH = 0.01;

    alpha = parameters.alpha;
    delta = parameters.delta;
    gZ = parameters.gZ;
    n = parameters.n;
    rho = parameters.rho;
    beta = parameters.beta;
    sigma = parameters.sigma;
    ell = parameters.ell;
    J = parameters.J;
    JRet = parameters.JRet;
    tau_k = parameters.tau_k;
    g = parameters.g;

    % Output matrices for optimal choices
    astart = 0;     % starting assets at age 0
    a = NaN(1,J);   % asset choice
    c = NaN(1,J);   % consumption choice

    % Impose stationary population
    N = (1+n).^(J:-1:1);
    N = N / sum(N);
    
    % Total labor force and employment rate as share of population
    L = ell * sum(N(1:JRet-1));
    emprate  = L/sum(N);
    
    % Factor prices from firms' first-order conditions
    r = alpha * Kguess.^(alpha-1) - delta;
    w = (1-alpha) * Kguess.^alpha;
    
    % Return on savings, net of capital tax
    R = (1 + r)*(1-tau_k);
   
    % Aggregate output 
    Y = Kguess^alpha;

    % Pension transfer and tax rate from public sector budget
    b   = rho * w * ell;
    tau_w = (b*sum(N(JRet:end)) + g*Y - tau_k*Kguess)/w*L;

    % Set one overall vector with disposable income
    y           = NaN(1,J);
    y(1:JRet-1) = (1-tau_w)*w*ell;
    y(JRet:end) = b;

    tol = 1e-6;
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
    
        acond = abs(a(1) - astart);
    
        % Update asset guess with fixed point iteration
        aguess = aguess - LAMBDAHH*(a(1) - astart);
    end
    
    % Aggregates
    K = sum(a.*N) ./ L;                                             % Capital market
    C = sum(c.*N) ./ L;                                             % Aggregate consumption
    Y = K^alpha;                                                    % Aggregate output
    I = ((1+n)*(1+gZ) - (1-delta))*K;                               % Gross capital investment
    G = g*Y + b*sum(N(JRet:end));                                   % Aggregate public spending

    % Goods market clearing
    goods_market_residual = abs(Y - C - I - G);
    
    residual = norm(Kguess - K, inf);
    step = K-Kguess;
end
