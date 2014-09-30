function pascal_eval_calib_wsup(cls, baseobjname, cachedir, testset, year, suffix)

% 5Dec12: I have now modified the logic such that now testset is set to val1 i.e., the
% "testset" is appropriately changed rather than modifying the code; so
% now "ids" is directly loaded as .txt file

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
diary([cachedir '/diaryoutput_eval_calib_' testset '.txt']);
disp(['pascal_eval_calib_wsup(''' cls ''',''' baseobjname ''',''' cachedir ''',''' testset ''',''' year ''',''' suffix ''')' ]);

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
%ids = getImgIdsForCalib(VOCopts, cls); % commented 5Dec12

%load([cachedir cls '_boxes_calib_' suffix], 'ds');
load([cachedir cls '_boxes_' testset '_' suffix], 'ds');

% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, 'comp5', cls), 'w');
for i = 1:length(ids);
    bbox = ds{i};
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
        [recall, prec, ap, tp, fp, ov] = VOCevaldet_calib_wsup(VOCopts, 'comp5', cls, baseobjname, false);        
    end
end

% DO_CALIBRATION
[ids,confidence,b1,b2,b3,b4]=textread(sprintf(VOCopts.detrespath,'comp5',cls),'%s %f %f %f %f %f');
bboxes = [b1 b2 b3 b4];
labels = tp;
labels(labels == 0) = -1;
ovp = ov;

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
end

numToConsider = 750;
[sval sind] = sort(confidence, 'descend');
numToUse = min(length(confidence), numToConsider);
confidence = confidence(sind(1:numToUse));
labels = labels(sind(1:numToUse));
ovp = ovp(sind(1:numToUse));
ids = ids(sind(1:numToUse));

%[A, B, err] = getProbabilisticOutputParams_overlap(confidence, ovp);
[A, B, err] = getProbabilisticOutputParams_unregularized(confidence, labels);
if A>0 || ...                 % A can never be positive!!
        length(find(ovp > VOCopts.minoverlap)) < 1 % kill a cluster if it is not firing on any instnace
    A=-1000; B=1000;
end
sigAB = [A B];
disp(['sigAB ' num2str(sigAB)]);

DISP = 1;
if DISP
    clf;  hold on   % changed 22Dec10
    scatter(confidence, ovp, 'k.');                % overlap
    labels(labels == -1) = 0;
    scatter(confidence, labels, 'r.');            % labels
    domn = [min(confidence):0.001:max(confidence)];
    sigcurvplot = 1 ./ (1+exp(A*domn+B));
    plot(domn, sigcurvplot ,'b');    
end

% save results
save([cachedir '/' cls '_calibParams_' testset '.mat'], 'sigAB', 'confidence', 'ids', 'labels', 'ovp');
if DISP, saveas(gcf, [cachedir '/display/sigABplot_' testset '.jpg']); end
fprintf('AP = %.4f \n', ap);
delete(sprintf(VOCopts.detrespath, 'comp5', cls));

diary off;
catch
    disp(lasterr); keyboard;
end
