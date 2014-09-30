function cluster_label = bottom_up_clustering(dist_mat, cluster_dist_thresh)
% dist_mat should be in symmetric form 
% important parameter: cost_flag
% from Svetlana
cost_flag = 3; % 1: min, 2: max, 3: avg

dist_mat = dist_mat + diag(ones(size(dist_mat,1),1) * Inf);

n = size(dist_mat,1);
max_iters = n;

% initially, put each point in its own cluster
cluster_label = (1:n)';
cluster_size = ones(n,1);
num_merged = 0;

% find minimum distance
[min_dist, i_merge, j_merge] = min2(dist_mat);

% while there are still things to merge
%while (num_merged < (n - 1)) & (min_dist < cluster_dist_thresh)
for i=1:max_iters
     if min_dist > cluster_dist_thresh
         break;
     end
%      fprintf( '**** Iteration %i, dist: %f, merging %d and %d, sizes %d and %d\n', ...
%          num_merged+1, min_dist, i_merge, j_merge, cluster_size(i_merge), cluster_size(j_merge));
    
   % update cluster_label
    cluster_label(find(cluster_label == j_merge)) = i_merge;
    num_merged = num_merged + 1;    
    ci = cluster_size(i_merge);
    cj = cluster_size(j_merge);
    cluster_size(i_merge) = cluster_size(i_merge) + cluster_size(j_merge);
    cluster_size(j_merge) = 0;
    
    % update between-cluster correlations
    if cost_flag == 1 % min
        dist_mat(:,i_merge) = min(dist_mat(:,i_merge), dist_mat(:,j_merge));
    elseif cost_flag == 2 % max
        dist_mat(:,i_merge) = max(dist_mat(:,i_merge), dist_mat(:,j_merge));
    else % avg
        n1 = cluster_size * ci;
        n2 = cluster_size * cj;
        n3 = n1 + n2;
        n3(find(n3==0)) = 1;
        dist_mat(:,i_merge) = (dist_mat(:, i_merge) .* n1 + dist_mat(:, j_merge) .* n2) ./ n3;
    end
    dist_mat(i_merge,:) = dist_mat(:, i_merge)';
    dist_mat(i_merge,i_merge) = Inf;
    
    dist_mat(j_merge,:) = Inf;
    dist_mat(:,j_merge) = Inf;
    [min_dist, i_merge, j_merge] = min2(dist_mat);
end
