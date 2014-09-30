function [ap,tp] = pascal_eval(voc_dir,cls, ds, testset, testyear, suffix)

VOC_root = [voc_dir,'VOC',testyear,'/VOCdevkit'];
addpath([VOC_root '/VOCcode']);
run([VOC_root '/VOCinit.m']);

%testyear = '2007';

cachedir = [VOC_root,'/results/VOC2007/Main/'];

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, suffix, cls), 'w');
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

do_eval = (str2num(testyear) <= 2007) | ~strcmp(testset, 'test');
if do_eval
    try
        %load('data/scores_all_rescored.mat','scores_all_rescored');  
        load(['../data/result/pr_',suffix,'.mat'],'recall','prec','tp');
    catch
    
        if str2num(testyear) == 2006
            [recall, prec, ap] = VOCpr(VOCopts, suffix, cls, false);
        else
        % Bug in VOCevaldet requires that tic has been called first
            tic;
            [recall, prec, tp] = VOCevaldet(VOCopts, suffix, cls, false);
        end
        
        save(['../data/result/pr_',suffix,'.mat'],'recall','prec','tp');
    end
    
    %compute AP
    ap=0;
    for t=0:0.1:1
        p=max(prec(recall>=t));
        if isempty(p)
            p=0;
        end
        ap=ap+p/11;
    end
    
    %draw the PR curve
    plot(recall,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %s, subset: %s, AP = %.3f',cls,VOCopts.testset,ap));
        
    % force plot limits
    ylim([0 1]);
    xlim([0 1]);

    print(gcf, '-djpeg', '-r0', [cachedir cls '_pr_' testset '_' suffix '.jpg']);

end

% save results
%save([cachedir cls '_pr_' testset '_' suffix], 'recall', 'prec', 'ap');