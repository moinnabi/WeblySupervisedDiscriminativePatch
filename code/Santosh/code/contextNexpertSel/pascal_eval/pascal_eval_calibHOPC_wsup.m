function pascal_eval_calibHOPC_wsup(cls, gtruthname, cachedir, testset, year, suffix)

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
%diary([cachedir '/diaryoutput_eval_calibHOPC_' testset '.txt']);
disp(['pascal_eval_calibHOPC_wsup(''' cls ''',''' gtruthname ''',''' cachedir ''',''' testset ''',''' year ''',''' suffix ''')' ]);

load([cachedir cls '_boxes_' testset '_' suffix], 'ds', 'bs');

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

%{
% see 5Dec12 commnets in pascal_eval_calibHO_wsup.m
hoinds = textread(sprintf(VOCopts.imgsetpath, 'hoinds'), '%d');

load([cachedir cls '_boxes_test_' suffix], 'ds', 'bs');
ds = ds(hoinds);
bs = bs(hoinds);

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
ids = ids(hoinds);
%}

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
load([cachedir cls '_final.mat'], 'model');

if numel(ids) ~= numel(ds), disp('length mismatch'); keyboard; end

IGNOREBADONES = 1;
if IGNOREBADONES
    gtsubdir = 'p33tn';
    gt = get_ground_truth_unsup(cachedir, gtruthname, testset, year, gtsubdir);    
    thisinds = [];
    for i=1:numel(gt)
        if isempty(gt(i).diff) || ~gt(i).diff
            thisinds = [thisinds; i];
        end
    end    
else
    gtsubdir = '';
    thisinds = 1:numel(ids);
end
ds = ds(thisinds);
bs = bs(thisinds);
ids = ids(thisinds);

% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, 'comp5', cls), 'w');
comps = cell(numel(ids),1);
for i = 1:length(ids);
    bbox = ds{i};
    if ~isempty(bs{i}) 
        comps{i} = bs{i}(:,end-1); 
    end
    for j = 1:size(bbox,1)
        fprintf(fid, '%s %f %d %d %d %d\n', ids{i}, bbox(j,end), bbox(j,1:4));
    end
end
fclose(fid);

recall = [];
prec = [];
ap = 0;

%do_eval = (str2num(year) <= 2007) | ~strcmp(testset, 'test');
do_eval = (str2num(year) <= 2007) | isAnnotationExists(VOCopts);
if do_eval
    if str2num(year) == 2006
        [recall, prec, ap] = VOCpr(VOCopts, 'comp5', cls, true);
    else
        % Bug in VOCevaldet requires that tic has been called first
        tic;
        %[recall, prec, ap, tp, fp, ovp] = VOCevaldet_calibHO_wsup(VOCopts, 'comp5', cls, gtruthname, false);
        %labels = tp;
        %labels(labels == 0) = -1;        
        [recall, prec, ap, labels, ovp] = VOCevaldet_ngramEvalObj(VOCopts, 'comp5', cls, true, gtruthname, cachedir);        
        labels (labels == 0) = -1;
    end
end

% DO_CALIBRATION
[ids,confidence,b1,b2,b3,b4]=textread(sprintf(VOCopts.detrespath,'comp5',cls),'%s %f %f %f %f %f');
bboxes = [b1 b2 b3 b4];
compinfo = cat(1, comps{:});
if length(compinfo) ~= length(ovp), disp('error, lengths dont match'); keyboard; end

% pick subset of images in case you are fitting sigmoid for a ngram detector to its own gtruth
if strcmp(cls, gtruthname)
    disp(' doing string match');
    [thisids, ~] = textread(sprintf(VOCopts.clsimgsetpath, gtruthname, 'test'), '%s %d');
    thisinds = logical(doStringMatch(ids, thisids));    
    
    confidence = confidence(thisinds,:);
    ids = ids(thisinds,:);
    bboxes = bboxes(thisinds, :);
    compinfo = compinfo(thisinds, :);
    labels = labels(thisinds,:);
    ovp = ovp(thisinds,:);
end
    
%{
%disp('check if any postprocessing is needed e.g., picking just one det per image, dealing with small tp in big images, etc'); keyboard;
POST = 0;
if POST     %% post-process the labels        
    ignoreInds = find(ov >= 0.2 & ov < 0.5);
    labels(ignoreInds) = 0;     % if ov \in [0.2 0.5], then set label as 0    
    goodOvButNegInds = find(ov > 0.5 & labels == -1);  % since doing global evaluateResult
    labels(goodOvButNegInds) = 0;   % if ov >0.5 but labels == -1, then ignore
    
    nonZeroInds = find(labels ~= 0);
    confidence = confidence(nonZeroInds);
    labels = labels(nonZeroInds);
    ovp = ovp(nonZeroInds);
    ids = ids(nonZeroInds);
    compinfo = compinfo(nonZeroInds);
end
%}
    
numToConsider = 750;
DISP = 1;

numcomps = numel(model.rules{model.start});
sigAB = zeros(numcomps, 2);
spx = 2; spy = ceil(numcomps/spx); clf;
for i= 1:numcomps    
    disp(['sigmoid '  num2str(i)]);
    this_compinds = find(compinfo == i);
    if ~isempty(this_compinds)
        this_confidence = confidence(this_compinds);
        this_labels = labels(this_compinds);
        this_ovp = ovp(this_compinds);
        this_ids = ids(this_compinds);
        
        [sval sind] = sort(this_confidence, 'descend');
        numToUse = min(length(this_confidence), numToConsider);
        this_confidence = this_confidence(sind(1:numToUse));
        this_labels = this_labels(sind(1:numToUse));
        this_ovp = this_ovp(sind(1:numToUse));
        this_ids = this_ids(sind(1:numToUse));
        
        %[A, B, err] = getProbabilisticOutputParams_overlap(confidence, ovp);
        [A, B, err] = getProbabilisticOutputParams_unregularized(this_confidence, this_labels);
        if A>0 || ...                 % A can never be positive!!
                length(find(this_ovp > VOCopts.minoverlap)) < 1 % kill a cluster if it is not firing on any instnace
            A=-1000; B=1000;
        end
        sigAB(i,:) = [A B];
                
        if DISP
            subplot(spx,spy,i);  hold on   % changed 22Dec10
            scatter(this_confidence, this_ovp, 'k.');                % overlap
            this_labels(this_labels == -1) = 0;
            scatter(this_confidence, this_labels, 'r.');            % labels
            domn = [min(this_confidence):0.001:max(this_confidence)];
            sigcurvplot = 1 ./ (1+exp(A*domn+B));
            plot(domn, sigcurvplot ,'b');
            title(i);
        end
    else
        sigAB(i,:) = [-1000 1000];
    end    
end

% save results
save([cachedir '/' cls '_calibParamsHOPC_' gtsubdir testset '_' gtruthname '.mat'], 'sigAB', 'confidence', 'ids', 'labels', 'ovp');
if DISP, saveas(gcf, [cachedir '/display/sigABplotHO_' gtsubdir testset '_' gtruthname '.jpg']); end
fprintf('AP = %.4f \n', ap);
delete(sprintf(VOCopts.detrespath, 'comp5', cls));

%diary off;

catch
    disp(lasterr); keyboard;
end
