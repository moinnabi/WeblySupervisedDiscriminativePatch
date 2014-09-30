function M_norm = normalize_rows(M)
% rescale each row to have mean 0 and norm 1
% from Svetlana

cols = size(M,2);
M_norm = M;
m_vec = mean(M_norm,2);
M_norm = M_norm - repmat(m_vec, 1, cols);
n_vec = sqrt(sum(M_norm.^2,2));
n_vec(find(n_vec<eps)) = 1;
M_norm = M_norm ./ repmat(n_vec, 1, cols);
