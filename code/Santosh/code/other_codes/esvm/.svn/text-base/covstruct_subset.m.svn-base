function covstruct = covstruct_subset(covstruct,hg_size)

subinds = covstruct_subinds(covstruct,hg_size);

covstruct.c = covstruct.c(subinds,subinds);
covstruct.mean = covstruct.mean(subinds);
if isfield(covstruct,'evecs')
  %NOTE: not sure we can just take subsets of eigenvectors, at
  %least I know the normalization won't be correct
  %covstruct.evecs = covstruct.evecs(subinds,1:length(subinds));
  %covstruct.evals = covstruct.evals(1:length(subinds));
  covstruct = rmfield(covstruct,'evecs');
  covstruct = rmfield(covstruct,'evals');
end
covstruct.hg_size = hg_size;
