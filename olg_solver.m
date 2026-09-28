residual = olg_solver(parameters, Kguess, LAMBDAHH = 0.01)

% Factor prices from firms' first-order conditions
r = alpha * Kguess.^(alpha-1) - delta;
w = (1-alpha) * Kguess.^alpha;

% Return on savings, net of capital tax
R = (1 + r)*(1-tau_k);

% Pension transfer and tax rate from public sector budget
b   = rho * w * ell;
tau_w = (b*sum(N(JRet:end)) + g*Y - tau_k*Kguess)/w*L;

% Set one overall vector with disposable income
y           = NaN(1,J);
y(1:JRet-1) = (1-tau_w)*w*ell;
y(JRet:end) = b;

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

    acond = abs(a(1) - astart);

    % Update asset guess with fixed point iteration
    aguess = aguess - LAMBDAHH*(a(1) - astart);

end

% Goods market clearing condition
K      = sum(a.*N) ./ L;                                               % Capital market
C      = sum(c.*N) ./ L;                                               % Aggregate consumption
I      = ((1+n)*(1+gZ) - (1-delta))*K;                                 % Gross capital investment
Y      = K^alpha;                                                      % Aggregate output
goods_market_residual = abs(Y - C - I);                                % Residual

residual = norm(Kguess - K, inf);

end
