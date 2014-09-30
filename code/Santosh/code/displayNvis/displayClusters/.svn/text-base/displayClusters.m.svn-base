function displayClusters(objname, outdir, VOCyear)

% use for preparing CVPR'11/ICCV'12 suppl material, I think

try
outdir_test = outdir;    
outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/clusters/']; mymkdir(resdir);
numToDisplay = 100;

%% load ALLLL the stuff you need here
disp(['Processing Class ' objname]);
%rmodel=load([outdir filesep objname '_random.mat'], 'models', 'model');
hmodel=load([outdir filesep objname '_hard.mat'], 'model');
load([outdir '/' objname '_train'], 'pos');
load([outdir filesep objname '_hard_info'], 'sigAB', 'posclusinds', 'pos_cell', 'posscores');

%disp('load test pr curve');
%roca = load([outdir_test filesep 'results' filesep 'results_perComp.mat'], 'roc_comp');
disp('load val pr curve & sigmoid curve');
valfname = [outdir filesep 'valresults_perComp.mat'];
if exist(valfname, 'file')
    tmp = load(valfname, 'roc_comp', 'mimg_sigplot', 'result_comp');
    roca.roc_comp = tmp.roc_comp;
    mimg_sigplot = tmp.mimg_sigplot;
    base_result.result_comp = tmp.result_comp;
else
    [roca.roc_comp, mimg_sigplot, base_result.result_comp] = loadValPRCurveNsigmoid(outdir, VOCyear, objname);
    roc_comp = roca.roc_comp;
    result_comp = base_result.result_comp;
    save(valfname, 'roc_comp', 'mimg_sigplot', 'result_comp');
end

[mim_pr, mimg_pr, ap_percomp] = printPlotPerComp_func(roca);
[sval sind] = sort(ap_percomp, 'descend');   % sort based on ap_percomp

if ~exist([resdir '/' num2str(length(hmodel.model.thresh)) 'valrank_' num2str(sind(length(hmodel.model.thresh))) '.jpg'], 'file')
    
    disp('load training instances');
    thispos = pos_cell{3};
    for i=1:length(thispos)     % fill empty pos(i) cells
        if isempty(thispos(i).im), thispos(i) = pos(i); end
    end
    if ~isempty(sigAB{3})
        modelthresh = [1 ./ (1+exp(sigAB{3}(:,1).*hmodel.model.thresh(:)+sigAB{3}(:,2)))];    % include 0 for '0' cluster
    else
        modelthresh = hmodel.model.thresh(:);
    end
    [mim_train mimg_train] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
        (posclusinds{3}, posclusinds{2}, thispos, posscores{3}, hmodel.model, 10, modelthresh);
    if numel(mimg_train) == length(hmodel.model.thresh)+1
        mimg_train = mimg_train(2:end);
        %mlab_train = mlab_train(2:end);
    end
    
    disp('load model vector');
    finmodelname = [outdir '/' objname '_final.mat'];
    clear mimg_model mlab_model
    load(finmodelname, 'model');
    for i=1:numel(model.rootfilters)
        mimg_model{i} = color(visualizeHOG(model.rootfilters{i}.w));
        mlab_model{i} = num2str(i);
    end
    mim_model = montage_list_w_text2(mimg_model, mlab_model, 2, [], [], [1500 1000 3]);
    
    disp('load mean image ');
    try
        for i=1:length(model.rootfilters)
            mimg_mean{i} = imread([outdir '/display/average_perComp_100_' num2str(i) '.jpg']);            
        end
    catch
        thispos = pos_cell{3};
        for i=1:length(thispos)     % fill empty pos(i) cells
            if isempty(thispos(i).im), thispos(i) = pos(i); end
        end
        [mim_mean mimg_mean mlab_mean] = displayAverageImgPerAspect_kmeans_overIt_func...
            (posclusinds{3}, thispos, posscores{3}, hmodel.model, 100);
    end
    for i=1:length(mimg_mean)   % resize mean img to model vector size
        mimg_mean{i} = imresize(mimg_mean{i}, [size(mimg_model{i},1)/2 size(mimg_model{i},2)]);
    end
    
    %disp('load test top 10 detections');
    %mimg_test = displayDetection_rankedMontages_perComp_func(objname, VOCyear, outdir_test, 10);
    disp('load val top 10 detections'); 
    mimg_test = displayDetection_rankedMontages_perComp_func_v2(objname, VOCyear, base_result, 10);
    
    %disp('load sigmoid curve'); keyboard;
    
    disp('save all stuff to files');
    for i=1:length(mimg_train)
        myprintf(i);
        mtmp{1} = mimg_train{sind(i)};
        mtmp{2} = uint8(mimg_mean{sind(i)});
        mtmp{3} = mimg_model{sind(i)};
        mtmp{4} = mimg_sigplot{sind(i)};
        mtmp{5} = mimg_pr{sind(i)};
        mtmp{6} = mimg_test{sind(i)};
        mtmp2 = montage_list(mtmp, 2, [0 0 0], [5000 5000 3],  [2 3]);
        
        imwrite(mtmp2, [resdir '/' num2str(i) 'valrank_' num2str(sind(i)) '.jpg']);
    end
    
end

catch
    disp(lasterr); keyboard;
end


%%%%%
    %mtmp{1} = uint8(mimg_mean{sind(i)});
    %mtmp{2} = mimg_model{sind(i)};
    %mtmp{3} = mimg_pr{sind(i)};
    %mtmp2 = montage_list(mtmp, 2, [0 0 0], [],  [3 1]);    
    
    %mtmp3{1} = mimg_train{sind(i)};
    %mtmp3{2} = mtmp2;
    %mtmp3{3} = mimg_test{sind(i)};
    %mtmp4 = montage_list(mtmp3, 2, [0 0 0], [5000 5000 3],  [3 1]);    
    
