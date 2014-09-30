function [ap, prec, recall] = pascal_eval_box_wsup(cls, cachedir, testset, year, suffix)
% from pascal_eval_wsup
% checks if each gtruth has any detection that ovlaps > 0.5 with it

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
disp(['pascal_eval_box_wsup(''' cls ''',''' cachedir ''',''' testset ''',''' year ''',''' suffix ''')' ]);

load([cachedir cls '_topboxesnonms_' testset '_' suffix], 'ds', 'ds_sum');
if ~exist('ds_sum', 'var'), ds_sum = ds; end

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

%disp('reducing the gtruh overlap?'); keyboard;
%VOCopts.minoverlap = 0.25;

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

disp(' write out detections in PASCAL format and score');
fid = fopen(sprintf(VOCopts.detrespath, 'comp3', cls), 'w');
for i = 1:length(ids);
    bbox = ds{i};
    for j = 1:size(bbox,1)
        fprintf(fid, '%s %f %d %d %d %d\n', ids{i}, bbox(j,end), bbox(j,1:4));
    end
end
fclose(fid);

%{
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
%}

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
        [recall, prec, ap, labels, olap, gt] = VOCevaldet_box_wsup(VOCopts, 'comp3', cls, true);
        labels (labels == 0) = -1;
    end
    
    % force plot limits
    ylim([0 1]);
    xlim([0 1]);
    
    print(gcf, '-djpeg', '-r0', [cachedir cls '_prbox_' testset '_' suffix '.jpg']);
end

disp(' compute gttruth statistic');    
cnt = 0;
fnd = 0;
for f=1:numel(gt)
    if ~isempty(gt(f).det)
        for j=1:length(gt(f).det)
            fnd = fnd + gt(f).det(j);
            cnt = cnt+1;
        end
    end
end
pcntfnd = fnd/cnt;

disp('here'); keyboard;

% save results
save([cachedir cls '_prbox_' testset '_' suffix], 'recall', 'prec', 'ap', 'labels', 'olap', 'gt', 'pcntfnd'); %, ...
fprintf('AP = %.4f \n', ap); 
delete(sprintf(VOCopts.detrespath, 'comp3', cls));

diary off;
catch
    disp(lasterr); keyboard;
end
