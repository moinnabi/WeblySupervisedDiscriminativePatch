function [ap, prec, recall] = pascal_eval(cls, cachedir, testset, year, suffix)
% Score detections using the PASCAL development kit.
%   [ap, prec, recall] = pascal_eval(cls, ds, testset, suffix)
%
% Return values
%   ap        Average precision score
%   prec      Precision at each detection sorted from high to low confidence
%   recall    Recall at each detection sorted from high to low confidence
%
% Arguments
%   cls       Object class to evaluate
%   ds        Detection windows returned by pascal_test.m
%   testset   Test set to evaluate against (e.g., 'val', 'test')
%   year      Test set year to use  (e.g., '2007', '2011')
%   suffix    Results are saved to a file named:
%             [cls '_pr_' testset '_' suffix]
try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
diary([cachedir '/diaryoutput_eval_' testset '.txt']);
disp(['pascal_eval(''' cls ''',''' cachedir ''',''' testset ''',''' year ''',''' suffix ''')' ]);
 
load([cachedir cls '_boxes_' testset '_' suffix], 'ds', 'ds_sum');
if ~exist('ds_sum', 'var'), ds_sum = ds; end

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

%%%%%
disp('doing overlap 25%');   
VOCopts.minoverlap = 0.25; 
%savename_prefix = [cachedir cls '_pr_' testset '_' suffix];
savename_prefix = [cachedir cls '_pr_' testset '_' suffix '_25'];
%%%%%%%

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

% sumpooling
% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, 'comp3sum', cls), 'w');
for i = 1:length(ids);
    bbox = ds_sum{i};
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
        [recall, prec, ap] = VOCevaldet(VOCopts, 'comp3', cls, true);
        [recall_sum, prec_sum, ap_sum] = deal(0);
        %[recall_sum, prec_sum, ap_sum] = VOCevaldet(VOCopts, 'comp3sum', cls, true);    % sumpooling
    end
    
    % force plot limits
    ylim([0 1]);
    xlim([0 1]);
    
    print(gcf, '-djpeg', '-r0', [savename_prefix '.jpg']);
end

% save results
save([savename_prefix '.mat'], 'recall', 'prec', 'ap', ...
    'recall_sum', 'prec_sum', 'ap_sum');
fprintf('AP = %.4f \n', ap);
delete(sprintf(VOCopts.detrespath, 'comp3', cls));
delete(sprintf(VOCopts.detrespath, 'comp3sum', cls));

diary off;
catch
    disp(lasterr); keyboard;
end
