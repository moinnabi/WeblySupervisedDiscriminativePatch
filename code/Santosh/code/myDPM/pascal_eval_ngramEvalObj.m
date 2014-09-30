function pascal_eval_ngramEvalObj(cls, baseobjname, cachedir, testset, year, suffix, minolap, postag)
% Score detections using the PASCAL development kit.

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;

disp(['pascal_eval_ngramEvalObj(''' cls ''',''' baseobjname ''',''' cachedir ''',''' testset ''',''' year ''',''' suffix ''',' num2str(minolap) ',''' postag ''')' ]);

load([cachedir cls '_boxes_' testset '_' suffix], 'ds', 'ds_sum');
if ~exist('ds_sum', 'var'), ds_sum = ds; end

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

disp(['overlap is ' num2str(minolap)]);
VOCopts.minoverlap = minolap;    

fprefix = [cachedir cls '_pr_' testset '_' suffix '_' num2str(100*VOCopts.minoverlap)];

%ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
if strcmp(postag, 'NOUN')
    ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
elseif strcmp(postag, 'VERB')
    ids = textread(sprintf(VOCopts.action.imgsetpath, testset), '%s');
end

mymatlabpoolopen; 

% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, ['comp3_' suffix], cls), 'w');
for i = 1:length(ids);
    bbox = ds{i};
    for j = 1:size(bbox,1)
        fprintf(fid, '%s %f %d %d %d %d\n', ids{i}, bbox(j,end), round(bbox(j,1:4)));
    end
end
fclose(fid);

recall = [];
prec = [];
ap = 0;
ap_base = 0;
[labels, olap, recall_base, prec_base, labels_base, olap_base, imgids,scores, boxes] = deal([]);

do_eval = (str2num(year) <= 2007) | isAnnotationExists(VOCopts, postag);
if do_eval
    if str2num(year) == 2006
        %[recall, prec, ap] = VOCpr(VOCopts, ['comp3_' suffix], cls, true);
    else
        [imgids,scores,b1,b2,b3,b4]=textread(sprintf(VOCopts.detrespath,['comp3_' suffix],cls),'%s %f %f %f %f %f');
        boxes = [b1 b2 b3 b4];
        
        % Bug in VOCevaldet requires that tic has been called first
        tic;        
        [recall, prec, ap, labels, olap] = VOCevaldet_wsup(VOCopts, ['comp3_' suffix], cls, true, postag);
        labels (labels == 0) = -1;
        
        [recall_base, prec_base, ap_base, labels_base, olap_base] = VOCevaldet_ngramEvalObj(VOCopts, ['comp3_' suffix], cls, true, baseobjname, postag);
        labels_base (labels_base == 0) = -1;
    end
    
    % force plot limits
    ylim([0 1]);
    xlim([0 1]);
    
    print(gcf, '-djpeg', '-r0', [fprefix '.jpg']);
end

% save results
save([fprefix '.mat'], 'recall', 'prec', 'ap', 'labels', 'olap',...    
    'recall_base', 'prec_base', 'ap_base', 'labels_base', 'olap_base',...
    'imgids', 'scores', 'boxes'); 
fprintf('AP = %.4f , Base AP = %.4f\n', ap, ap_base);
%delete(sprintf(VOCopts.detrespath, ['comp3_' suffix], cls));

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end
