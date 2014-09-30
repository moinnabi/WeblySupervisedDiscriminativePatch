function [ap, prec, recall] = pascal_eval_ignoreBboxLabels(cls, cachedir, testset, year, suffix)
% ignores bboxes labels i.e., "horse" or "horse face"; just uses all bboxes
% in a test image as "horse" gtruth
% main change is VOCevaldet_detailed()

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
diary([cachedir '/diaryoutput_eval_ignoreBboxLabels_' testset '.txt']);
disp(['pascal_eval_ignoreBboxLabels(''' cls ''',''' cachedir ''',''' testset ''',''' year ''',''' suffix ''')' ]);

load([cachedir cls '_boxes_' testset '_' suffix], 'ds', 'ds_sum');
if ~exist('ds_sum', 'var'), ds_sum = ds; end

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, 'comp3', cls), 'w');
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
        [recall, prec, ap] = VOCpr(VOCopts, 'comp3', cls, true);
    else
        % Bug in VOCevaldet requires that tic has been called first
        tic;
        [recall, prec, ap, labels, olap] = VOCevaldet_ignoreBboxLabels(VOCopts, 'comp3', cls, false);
        labels (labels == 0) = -1;
    end        
end

% save results
save([cachedir cls '_prlabels_' testset '_' suffix], 'recall', 'prec', 'ap', ...
    'labels', 'olap');
fprintf('AP = %.4f \n', ap);

diary off;
catch
    disp(lasterr); keyboard;
end
