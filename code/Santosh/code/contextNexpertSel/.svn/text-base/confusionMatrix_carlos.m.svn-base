function confusionMatrix_carlos

try
objname = 'horse';
basedir = '/projects/grail/santosh/objectNgrams/';
resultsdir_nfs = fullfile(basedir, 'results');
objngramdir = [resultsdir_nfs '/object_ngram_data/' objname '/'];
imgannodir = [resultsdir_nfs '/object_ngramImg_finalData/'];
codedir = 'kmeans_6';
savedir = [resultsdir_nfs '/display/'];
ngimgModeldir_obj = [resultsdir_nfs '/ngramGImg_models/' objname '/' codedir '/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);
testset = 'test1';
year = '9990';
suffix = year;

%numObjects=[157 136 237 166 228 68  414 192 310 69 55 239  146 135 2172
%183 78 77 83 136]; % VOC 2008 val data stats
numClasses = numel(phrasenames);

compileCode_v2('pascal_eval_ngramEvalNgram', 0);

cm_noC = zeros(numClasses,numClasses+3);
cm_WithC = zeros(numClasses,numClasses+3);
% without context
for i =1:numClasses
    disp(['Processing ' phrasenames{i}]);
    [labels, ov, scores] = deal([]);
    [tmplabels, tmpov, tmpscores] = deal([]);
            
    cachedir = [ngimgModeldir_obj '/' phrasenames{i} '/'];     
    for j=1:numClasses
        fprintf('%d ',j);        
        fname = [cachedir '/pr/' phrasenames{i} '_pr_' phrasenames{j} '_' testset '_' suffix '.mat'];
        %if ~exist(fname, 'file')
        try
            tmp = load(fname, 'scores', 'labels_base', 'olap_base');
            tmpscores(:,j) = tmp.scores;
            tmplabels(:,j) = tmp.labels_base;
            tmpov(:,j) = tmp.olap_base;
        catch
            %result = evaluateResult(rec, result, phrasenames{j}, false);
            pascal_eval_ngramEvalNgram(phrasenames{i}, phrasenames{j}, cachedir, testset, year, suffix);
            %multimachine_grail(['pascal_eval_ngramEvalNgram ' phrasenames{i} ' ' phrasenames{j} ' ' cachedir ' ' testset ' ' year ' ' suffix], 1, cachedir, 1, [], 1, 0, 0);
        end        
    end
    fprintf('\n');
    disp('wiating for jobs to finish');
    while ~exist(fname, 'file'), pause(10); end
    
    if 0
    for j=1:numClasses
        fprintf('%d ',j);        
        fname = [cachedir '/pr/' phrasenames{i} '_pr_' phrasenames{j} '_' testset '_' suffix '.mat'];
        tmp = load(fname, 'scores', 'labels_base', 'olap_base');        
        scores(:,j) = tmp.scores; 
        labels(:,j) = tmp.labels_base;
        ov(:,j) = tmp.olap_base;
    end
    fprintf('\n');
        
    %load([cachedir phrasenames{i} '_gt_anno_' testset '_' suffix], 'npos');
    [~, numObjects] = get_ground_truth(cachedir, phrasenames{i}, testset, year);
    
    [~, sind] = sort(scores, 'descend');
    labels = labels(sind,:);
    ov = ov(sind,:);
    %for k = 1:numObjects(i)/2 %size(labels,1)   % you want to look at only top few dets
    for k = 1:numObjects/2
        myprintf(k, 10);
        trueLab = find(labels(k,:) == 1);
        if isempty(trueLab)             % all are -1
            if max(ov(k,:)) > 0.5       % multiple detection
                cm_noC(i,numClasses+1) = cm_noC(i,numClasses+1)+1;
            elseif max(ov(k,:)) > 0.25  % poor localization
                cm_noC(i,numClasses+2) = cm_noC(i,numClasses+2)+1;
            else                        % background
                cm_noC(i,numClasses+3) = cm_noC(i,numClasses+3)+1;
            end
        elseif length(trueLab) == 1     % correct det
            cm_noC(i,trueLab) = cm_noC(i,trueLab)+1;
        elseif length(trueLab) > 1
            if find(trueLab == i)
                cm_noC(i,i) = cm_noC(i,i)+1;
            else
                cm_noC(i,trueLab(1)) = cm_noC(i,trueLab(1))+1;
            end
        end
    end
    cm_noC(i,:) = cm_noC(i,:)/sum(cm_noC(i,:));
    fprintf('\n');
    end
end
clear labels ov scores;
save([savedir '/confusionMatrix.mat'], 'cm_noC');

disp('check results'); keyboard;


%{
% with context
for i =1:20
    labels = []; ov = []; scores = [];
    disp(['Processing ' VOCopts.classes{i}]);
    load([resdir '/detectionWithContextNseg/valseg/' VOCopts.classes{i} '/objsegresults2_' VOCopts.classes{i}]);
    result = obj.result3;
    for j=1:20
        fprintf('%d ',j);
        result = evaluateResult(rec, result, VOCopts.classes{j}, false);
        scores(:,j) = cat(1,result.scores);
        labels(:,j) = cat(1,result.labels);
        ov(:,j) = cat(1,result.ov);
        %roc = computeROC(cat(1, result.scores), cat(1, result.labels));
        %roc.r = roc.r * sum([result.nfound]) / sum([result.npos]);
        %cm_withC(i,j) = averagePrecision(roc, (0:0.1:1));
    end
    [sval sind] = sort(scores, 'descend');
    labels = labels(sind,:);
    ov = ov(sind,:);
    for k = 1:numObjects(i)/2  %size(labels,1)
        trueLab = find(labels(k,:) == 1);
        if length(trueLab) == 0 % all are -1
            if max(ov(k,:)) > 0.5
                cm_WithC(i,21) = cm_WithC(i,21)+1;
            elseif max(ov(k,:)) > 0.25
                cm_WithC(i,22) = cm_WithC(i,22)+1;
            else
                cm_WithC(i,23) = cm_WithC(i,23)+1;
            end
        elseif length(trueLab) == 1
            cm_WithC(i,trueLab) = cm_WithC(i,trueLab)+1;
        elseif length(trueLab) > 1
            if find(trueLab == i)
                cm_WithC(i,i) = cm_WithC(i,i)+1;
            else
                cm_WithC(i,trueLab(1)) = cm_WithC(i,trueLab(1))+1;
            end
        end
    end
    cm_WithC(i,:) = cm_WithC(i,:)/sum(cm_WithC(i,:));
    fprintf('\n');
end
%}

catch
    disp(lasterror); keyboard;
end
