function [v, i, j] = max2(M)
% from Svetlana

[v_row, i_row] = max(M);
[v, j] = max(v_row);
i = i_row(j);
