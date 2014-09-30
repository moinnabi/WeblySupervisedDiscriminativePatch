function small=down_sample_variable(big, rowvec, colvec)
% function small=down_sample(big,nr,nc)
% averaging over non-overlapping spatial blocks

% this function is taken from gistGabor.m script
% do not change this. it will affect the gist computation scripts

nc = length(colvec);
nr = length(rowvec);

%cols=fix(linspace(0,size(big,2),nc+1));
%rows=fix(linspace(0,size(big,1),nr+1));
cols=fix(linspace_variable(0,size(big,2),colvec));
rows=fix(linspace_variable(0,size(big,1),rowvec));
small = zeros(nr, nc, size(big,3));
%selinds = zeros(nr*nc, 4); kk=0;
for r=1:nr
    for c=1:nc
        %selinds(kk+1,:) = [rows(r)+1 rows(r+1) cols(c)+1 cols(c+1)]; kk=kk+1;
        v = big(rows(r)+1:rows(r+1), cols(c)+1:cols(c+1), :);
        %v = mean(mean(v,1),2);        
        % the following takes care of the problem when there are bunch of
        % vectors you want to average from and few of them are zeros. The
        % zero ones should not be counted when you are computing the mean
        v = reshape(v, [size(v,1)*size(v,2) size(v,3)]);
        zsuminds = find(sum(v,2) == 0);        
        v(zsuminds, :) = [];        
        if ~isempty(v)
            v = mean(v,1);
            small(r,c,:) = v(:);
        end
    end
end

