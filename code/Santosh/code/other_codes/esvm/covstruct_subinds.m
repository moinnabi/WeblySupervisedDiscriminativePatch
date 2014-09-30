function subinds = covstruct_subinds(covstruct_full, hg_size)
% Marginalize out a large feature covariance/mean into a smaller
% template.  The center [m n F] region of
% the larger [M N F] covariance matrix is taken.
%
% Inputs
%   covstruct_full: the covariance structure obtained form
%                   learnCovariance which contains an (mnF x mnF) 
%                   covariance matrix and an (mnF x 1) mean vector
%   hg_size:        the target template size
%
% Outputs
%   subinds:        the indices which can index covstruct (these
%                   integers range from 1 to mnF)
%
% Example Usage
% 1. Marginalize out an 8x4 covariance from a larger 12x12 covariance
% >> covstruct = learnCovariance(data_set,[12 12]);
% >> subinds = covstruct_subinds(covstruct,[8 4]);
% >> c = covstruct.c(subinds,subinds);
% >> mu = covstruct.mean(subinds);
%
% Tomasz Malisiewicz (tomasz@csail.mit.edu)

if nargin ~= 2
  error('Error(covstruct_subinds): needs two input arguments');
end

if ~isstruct(covstruct_full)
  error('Error(covstruct_subinds): input covariance not a struct');
end

if ~isnumeric(hg_size) || numel(hg_size) < 2
  error(['Error(covstruct_subinds): input hg_size must be numeric' ...
         ' and contain as least two elements']);
end

if hg_size(1) > covstruct_full.hg_size(1) || hg_size(2) > ...
      covstruct_full.hg_size(2) 
  error(['Error in covstruct_subinds: hg_size must be smaller than' ...
         ' or equal to covstrut_full.hg_size']);
end

hg_full = zeros(covstruct_full.hg_size(1), covstruct_full.hg_size(2), ...
                covstruct_full.hg_size(3));

%Center the new hg_size within the full covstruct full hg_size
offset = round((covstruct_full.hg_size(1:2) - hg_size(1:2))/2);

hg_full(offset(1) + (1:hg_size(1)),...
        offset(2) + (1:hg_size(2)),:) = 1;

subinds = find(hg_full);
