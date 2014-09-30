function [labels, olapval] = context_labelssep_wsup(cachedir, gtruthname, ds, train_set, train_year, cls, gtsubdir)

% copied from context_labels_wsup; saves labels per ngram but gtruth is
% gtruthname

% Get classification training labels for training the context rescoring
% classifier.
%   labels = context_labels(cls, ds, train_set, train_year)
%
% Return value
%   labels      Binary labels {-1,+1} for each detection in boxes
%
% Arguments
%   cls         Object class
%   ds          Detections
%   train_set   Training dataset
%   train_year  Training dataset year

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

if strcmp(train_set, 'val2')
    savecode = train_set;
elseif strcmp(train_set, 'val1')
    savecode = [gtsubdir train_set];
end

savename = [cachedir '/../' cls '/' cls '_context_labelsWolap_' savecode '_' train_year '_' gtruthname];
try
    disp(' loading');
    load(savename, 'labels', 'olapval');
catch
    disp(' constructing training labels (this will take a little while)...\n');
    if strcmp(train_set, 'val2')
    [gt, npos] = get_ground_truth(cachedir, gtruthname, train_set, train_year);
    elseif strcmp(train_set, 'val1')
    [gt, npos] = get_ground_truth_unsup(cachedir, gtruthname, train_set, train_year, gtsubdir);
    %[gt, npos] = get_ground_truth(cachedir, gtruthname, train_set, train_year);
    end
    [gtids, t] = textread(sprintf(VOCopts.imgsetpath, train_set),'%s %d');
    
    labels = cell(length(gtids),1);
    olapval = cell(length(gtids),1);
    
    L = 0;
    for i = 1:length(gtids)
        L = L + size(ds{i},1);
    end
    
    detections = zeros(L,7);
    I = 1;
    for i = 1:length(gtids)
        if ~isempty(ds{i})
            l = size(ds{i},1);
            % Detection scores
            detections(I:I+l-1,1) = ds{i}(:,end);
            % Detection windows
            detections(I:I+l-1,2:5) = ds{i}(:,1:4);
            % The image (i) the detections came from
            detections(I:I+l-1,6) = i;
            % The index in ds{i} for each detection
            detections(I:I+l-1,7) = 1:l;
            labels{i} = zeros(l,1);
            olapval{i} = zeros(l,1);
            I = I+l;
        else
            labels{i} = [];
            olapval{i} = [];
        end
    end
    
    [sc, si] = sort(-detections(:,1));
    ids = detections(si,6);
    idx = detections(si,7);
    BB = detections(si,2:5)';
    
    % Adapted from the VOCdevkit m-file VOCevaldet.m
    
    % assign detections to ground truth objects
    nd=length(si);
    for d=1:nd
        % find ground truth image
        i=ids(d);
        
        % assign detection to ground truth object if any
        bb=BB(:,d);
        ovmax=-inf;
        for j=1:size(gt(i).boxes,2)
            bbgt=gt(i).boxes(:,j);
            bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
            iw=bi(3)-bi(1)+1;
            ih=bi(4)-bi(2)+1;
            if iw>0 && ih>0
                % compute overlap as area of intersection / area of union
                ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                    (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                    iw*ih;
                ov=iw*ih/ua;
                if ov>ovmax
                    ovmax=ov;
                    jmax=j;
                end
            end
        end
        % assign detection as true positive/don't care/false positive
        olapval{i}(idx(d)) = ovmax;
        if ovmax>=VOCopts.minoverlap            
            if ~gt(i).diff(jmax)
                if ~gt(i).det(jmax)     % True positive                    
                    gt(i).det(jmax)=true;
                    labels{i}(idx(d)) = 1;                    
                else                    % false positive (multiple detection)                    
                    labels{i}(idx(d)) = -1;                    
                end
            else
                labels{i}(idx(d)) = 0;   % difficult                
            end
        else                            % false positive (low overlap)            
            labels{i}(idx(d)) = -1;                
        end
    end
    save(savename, 'labels', 'olapval');
    fprintf('done!\n');
end
