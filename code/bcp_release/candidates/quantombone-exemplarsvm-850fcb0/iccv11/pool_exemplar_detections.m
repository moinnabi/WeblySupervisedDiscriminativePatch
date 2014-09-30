function final = pool_exemplar_detections(dataset_params, models, grid, M)
%% Perform detection box post-processing and pool detection boxes
%(which will then be ready to go into the PASCAL evaluation code)
% If there are overlap scores associated with boxes, then they are
% also kept track of propertly, even after NMS.
%
% Tomasz Malisiewicz (tomasz@cmu.edu)

%REMOVE FIRINGS ON SELF-IMAGE (these create artificially high
%scores when evaluating on the training set, but no need to set
%this on the testing set as we don't train on testing data)
REMOVE_SELF = 0;

if REMOVE_SELF == 1
  curids = cellfun2(@(x)x.curid,models);
end

cls = models{1}.cls;

excurids = cellfun2(@(x)x.curid,models);
bboxes = cell(1,length(grid));
maxos = cell(1,length(grid));

fprintf(1,'Loading bboxes\n');
curcls = find(ismember(dataset_params.classes,models{1}.cls));

for i = 1:length(grid)  
  curid = grid{i}.curid;
  bboxes{i} = grid{i}.bboxes;
  if size(bboxes{i},1) == 0
    continue
  end
  
  if length(grid{i}.extras)>0 && isfield(grid{i}.extras,'maxos')
    maxos{i} = grid{i}.extras.maxos;
    maxos{i}(grid{i}.extras.maxclass~=curcls) = 0;
  end
  
  if REMOVE_SELF == 1
    exes = bboxes{i}(:,6);
    excurids = curids(exes);
    badex = find(ismember(excurids,{curid}));
    bboxes{i}(badex,:) = [];
    
    if length(grid{i}.extras)>0 && isfield(grid{i}.extras,'maxos')
      if length(maxos{i})>0
        maxos{i}(badex) = [];
      end
    end
  end
end

% perform within-exemplar NMS
% NOTE: this is already done during detection time
if 0 
  fprintf(1,'applying exemplar nms\n');
  for i = 1:length(bboxes)
    if size(bboxes{i},1) > 0
      bboxes{i}(:,5) = 1:size(bboxes{i},1);
      bboxes{i} = nms_within_exemplars(bboxes{i},.5);
      if length(grid{i}.extras)>0 && isfield(grid{i}.extras,'os')
        maxos{i} = maxos{i}(bboxes{i}(:,5));
      end
    end
  end
end

%Perform score rescaling
%1. no scaling
%2. platt's calibration (sigmoid scaling)
%3. raw score + 1

raw_boxes = bboxes;

if exist('M','var') && length(M)>0 && isfield(M,'betas')
  for i = 1:length(bboxes)
    %if neighbor thresh is defined, then we are in M-mode boosting
    if isfield(M,'neighbor_thresh')
      calib_boxes = bboxes{i};
      calib_boxes(:,end) = calib_boxes(:,end)+1;
    else
      calib_boxes = calibrate_boxes(bboxes{i},M.betas); 
    end
    oks = find(calib_boxes(:,end) > dataset_params.params.calibration_threshold);
    calib_boxes = calib_boxes(oks,:);
    bboxes{i} = calib_boxes;
  end
end

if exist('M','var') && length(M)>0 && isfield(M,'neighbor_thresh')
  fprintf(1,'Applying M-boosting:\n');
  tic
  for i = 1:length(bboxes)
    fprintf(1,'.');
    [xraw,nbrlist{i}] = get_box_features(bboxes{i},length(models), ...
                                                M.neighbor_thresh);
    r2 = apply_boost_M(xraw,bboxes{i},M);
    bboxes{i}(:,end) = r2;
  end
  toc
end

os_thresh = .3;
fprintf(1, 'Applying Competitive NMS OS threshold=%.3f\n',os_thresh);
for i = 1:length(bboxes)
  if size(bboxes{i},1) > 0
    bboxes{i}(:,5) = 1:size(bboxes{i},1);
    bboxes{i} = nms(bboxes{i},os_thresh);
    if length(grid{i}.extras)>0 && isfield(grid{i}.extras,'maxos')
      maxos{i} = maxos{i}(bboxes{i}(:,5));
    end
    if exist('nbrlist','var')
      nbrlist{i} = nbrlist{i}(bboxes{i}(:,5));
    end
    bboxes{i}(:,5) = 1:size(bboxes{i},1);
  end
end

if 0
if exist('M','var') && length(M)>0 && isfield(M,'betas')

  fprintf(1,'Propagating scores onto raw detections\n');
  %% propagate scores onto raw boxes
  for i = 1:length(bboxes)
    calib_boxes = calibrate_boxes(raw_boxes{i},M.betas);
    beta_scores = calib_boxes(:,end);
    
    osmat = getosmatrix_bb(bboxes{i},raw_boxes{i});
    for j = 1:size(osmat,1)
      curscores = (osmat(j,:)>.5) .* beta_scores';
      [aa,bb] = max(curscores);
      bboxes{i}(j,:) = raw_boxes{i}(bb,:);
      bboxes{i}(j,end) = aa;
    end
    
    % new_scores = beta_scores;
    % for j = 1:length(nbrlist{i})
    %   new_scores(nbrlist{i}{j}) = max(new_scores(nbrlist{i}{j}),...
    %                                   beta_scores(nbrlist{i}{j}).*...
    %                                   bboxes{i}(nbrlist{i}{j},end));
    % end
    % bboxes{i}(:,end) = new_scores;
  end
end
end

% Clip boxes to image dimensions since VOC testing annotation
% always fall within the image
unclipped_boxes = bboxes;
for i = 1:length(bboxes)
  bboxes{i} = clip_to_image(bboxes{i},grid{i}.imbb);
end

final_boxes = bboxes;

% return unclipped boxes for transfers
final.unclipped_boxes = unclipped_boxes;
final.final_boxes = final_boxes;
final.final_maxos = maxos;

%Create a string which summarizes the pooling type
calib_string = '';
if exist('M','var') && length(M)>0 && isfield(M,'betas')
   calib_string = '-calibrated';
end

if exist('M','var') && length(M)>0 && isfield(M,'betas') && isfield(M,'w')
  calib_string = [calib_string '-M'];
end

final.calib_string = calib_string;

%NOTE: is this necessary anymore?
final.imbb = cellfun2(@(x)x.imbb,grid);
