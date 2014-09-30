function [ds, bs, trees] = gdetect_joint(pyra, model, thresh, max_num)

% used by neghard_joint

if nargin < 4
  max_num = inf;
end

model = gdetect_dp(pyra, model);

%{
rules = model.rules{s};
score = rules(1).score;

for r = rules(2:end)    
    for i = 1:length(r.score)
        score{i} = max(score{i}, r.score{i});
    end
end
model.symbols(s).score = score;
%}

stsymb=model.start;
rules = model.rules{stsymb};
[ds_tmp, bs_tmp, trees_tmp] = deal(cell(numel(model.rules{stsymb}),1));
k=1;
%[ds, bs, trees] = deal([]);
for r = rules(1:end)    
    model.symbols(stsymb).score = r.score;
    [ds_tmp{k}, bs_tmp{k}, trees_tmp{k}] = gdetect_parse(model, pyra, thresh, max_num);
    %{
    ds = [ds; ds_tmp{k}];
    bs = [bs; bs_tmp{k}];
    trees = [trees; trees_tmp{k}];
    %}
    k=k+1;
end

ds = cat(1,ds_tmp{:});
bs = cat(1,bs_tmp{:});
trees = cat(1,trees_tmp{:});

%{

model = gdetect_dp(pyra, model);
[ds, bs, trees] = gdetect_parse(model, pyra, thresh, max_num);

%}