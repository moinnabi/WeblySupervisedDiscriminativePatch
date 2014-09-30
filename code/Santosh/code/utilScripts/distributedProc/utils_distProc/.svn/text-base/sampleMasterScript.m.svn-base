function sampleMasterScript(DO_MODE)
% this script automates running the whole process

basedir = '';
DO_KMEANS = 1;
DO_BASE = 1;

OVERWRITE = 1;    
if OVERWRITE, disp('overwrite is 1'); end  

resultsdir = fullfile(basedir, 'results_lustre', 'uoctti_models', 'release3_retrained', VOCresdir);
resultsdir_baikal = fullfile(basedir, 'results', 'uoctti_models', 'release3_retrained', VOCresdir);

numProcs_trn = 3;  
numImgs = 4952; numMachs_tst = 100;
procid_trn = 'LATENT_TRAINING';  
procid_tst = 'LATENT_TESTING'; 
myClasses = VOCoptsClasses;

for i = 1:20
    objname = myClasses{i};     
    disp(['Doing ' objname]);
                                   
    if DO_KMEANS
    numclust = 15;
    disp(['Doing Kmeans ' num2str(numclust) ' ' objname]);
    outdir = fullfile(resultsdir, objname, [objname '_kmeans_' num2str(numclust) '/']); mymkdir(outdir);
    outdir_baikal = fullfile(resultsdir_baikal, objname, [objname '_kmeans_' num2str(numclust) '/']); mymkdir(outdir);
    if DO_MODE == 1 & ~exist([outdir filesep objname '_final.mat'], 'file')
        multimachine_warp_depfun(['mypascal_train_kmeans(''' objname ''',' num2str(numclust) ' , ''' outdir ''' )' ], 1, outdir, 1, procid_trn, numProcs_trn, 0, OVERWRITE);
    elseif DO_MODE == 3 & exist([outdir filesep objname '_final.mat'], 'file') & ~exist([outdir_test filesep 'results' filesep 'results.mat'], 'file')
        multimachine_warp_depfun(['objectDetection(''' objname ''',''' outdir ''')'], numImgs, outdir, numMachs_tst, procid_tst, [], [], OVERWRITE);
        multimachine_warp_depfun(['getDetectionResults(''' objname ''',''' outdir ''')' ], 1, outdir, 1, procid_tst);
    elseif DO_MODE == 4 & exist([outdir_test filesep 'results' filesep 'results.mat'], 'file')
        multimachine_warp_depfun(['displayDetection(''' objname ''',''' outdir ''')' ], 1, outdir, 1, procid_tst, 3, 0);
    elseif DO_MODE == 5 & exist([outdir_test filesep 'results' filesep 'results.mat'], 'file')
        dispdir = [outdir_baikal '/display/']; mymkdir(dispdir);
        if exist([outdir '/display/'], 'dir'), copyfile([outdir '/display'], dispdir); end
    end     
    end
    
    if DO_BASE
    numclust = 3;
    disp(['Doing Base ' num2str(numclust) ' ' objname]);
    outdir = fullfile(resultsdir, objname, [objname '_base_' num2str(numclust) '/']); mymkdir(outdir);
    outdir_baikal = fullfile(resultsdir_baikal, objname, [objname '_base_' num2str(numclust) '/']); mymkdir(outdir);
    if DO_MODE == 1 & ~exist([outdir filesep objname '_final.mat'], 'file')
        multimachine_warp_depfun(['mypascal_train(''' objname ''',' num2str(numclust) ' , ''' outdir ''' )' ], 1, outdir, 1, procid_trn, numProcs_trn, 0, OVERWRITE);
    elseif DO_MODE == 3 & exist([outdir filesep objname '_final.mat'], 'file') & ~exist([outdir_test filesep 'results' filesep 'results.mat'], 'file')
        multimachine_warp_depfun(['objectDetection(''' objname ''',''' outdir ''')'], numImgs, outdir, numMachs_tst, procid_tst, [], [], OVERWRITE);
        multimachine_warp_depfun(['getDetectionResults(''' objname ''',''' outdir ''')' ], 1, outdir, 1, procid_tst);
    elseif DO_MODE == 4 & exist([outdir_test filesep 'results' filesep 'results.mat'], 'file')
        multimachine_warp_depfun(['displayDetection(''' objname ''',''' outdir ''')' ], 1, outdir, 1, procid_tst, 3, 0);
    elseif DO_MODE == 5 & exist([outdir_test filesep 'results' filesep 'results.mat'], 'file')
        dispdir = [outdir_baikal '/display/']; mymkdir(dispdir);
        if exist([outdir '/display/'], 'dir'), copyfile([outdir '/display'], dispdir); end
    end     
    end        
end
datestr(now)
