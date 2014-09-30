function [emd_val, flow, exitflag] = emd(dist_mat, w1, w2)
% earth mover's distance - from Svetlana
% dist_mat: m x n matrix of pairwise distances
% w1: weights for the first distribution (m x 1 vector)
% w2: weights for the second distribution (n x 1 vector)

% make sure the smaller signature is the consumer
if sum(w1) < sum(w2)
    w_tmp = w1;
    w1 = w2;
    w2 = w_tmp;
    dist_mat = dist_mat';
end

m = size(w1, 1);
n = size(w2, 1);

% le constraints
A = zeros(m, m*n);
for i=1:m
    A(i, (i-1)*n+1:i*n) = 1;
end
b = w1;

% equality constraints
Aeq = eye(n,n);
Aeq = repmat(Aeq, 1, m);
beq = w2;

% bounds
lb = zeros(m*n, 1);
ub = []; %ones(m*n, 1) * Inf;

% linear coefficients for the objective function
coeffs = reshape(dist_mat', [m*n, 1]);

% solve linear program to get the flow coefficients
options = optimset('linprog');
options = optimset(options, 'MaxIter', 10000, 'LargeScale', 'on', 'Display', 'off');
[flow, f_val, exitflag] = linprog(coeffs, A, b, Aeq, beq, lb, ub, [], options);

% return earth mover's distance
emd_val = f_val / sum(flow);
