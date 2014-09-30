function displayWeightVectorsPerAspect_v4(objname, outdir)
%multimachine_warp('displayWeightVectorsPerAspect', 20, resdir, 2)

try
disp(['displayWeightVectorsPerAspect(''' objname ''',''' outdir ''')' ]);

resdir = [outdir filesep 'display/']; mymkdir(resdir);

%load([outdir '/' objname '_lrsplit1.mat'], 'models');   
%kclus = numel(models);
%clear models;

disp('writing final model');
finmodelname = [outdir '/' objname '_final.mat'];
if exist(finmodelname, 'file')
    savename = [resdir '/weightVector_final.jpg'];
    if ~exist(savename, 'file')
        clear allimw alliml
        load(finmodelname, 'model');        
        for i=1:numel(model.rules{model.start})
            allimw{i} = color(visualizeHOG(model.filters(i).w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [4500 3000 3]);
        imwrite(mim, savename);
        
        % write part filters
        try
        pdispim = myvisualizemodel(model);
        imwrite(pdispim, [resdir '/weightVectorWithParts_final.jpg']);
        end
    end
end

disp('writing mix model');
partmodelname = [outdir '/' objname '_mix.mat'];
if exist(partmodelname, 'file')
    savename = [resdir '/weightVector_mix.jpg'];
    if ~exist(savename, 'file')
        % root filters        
        clear allimw alliml
        load(partmodelname, 'model');
        for i=1:numel(model.rules{model.start})
            allimw{i} = color(visualizeHOG(model.filters(i).w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [4500 3000 3]);
        imwrite(mim, savename);        
    end
end

disp('writing random model');
randmodelname = [outdir '/' objname '_lrsplit1.mat'];
if exist(randmodelname, 'file')
    savename = [resdir '/weightVector_random.jpg'];
    if ~exist(savename, 'file')
        %load(randmodelname, 'models');
        load(randmodelname, 'model');
        clear mim;
        clear allimw alliml
        for k=1:numel(model.rules{model.start})            
            %allimw{k} = color(visualizeHOG(models{k}.filters(1).w));
            allimw{k} = color(visualizeHOG(model.filters(i).w));
            alliml{k} = num2str(k);
            %mim{k} = montage_list_w_text2(allimw, alliml, 2, [], [], [500 1000 3], [1 kclus]);
        end
        %mimg = [mim{1}; mim{2}; mim{3}];        
        %mimg = cat(1,mim{:});
        mimg = montage_list_w_text2(allimw, alliml, 2, [], [], [4500 3000 3]);
        imwrite(mimg, savename);
    end
end

catch
    disp(lasterr); keyboard;
end
