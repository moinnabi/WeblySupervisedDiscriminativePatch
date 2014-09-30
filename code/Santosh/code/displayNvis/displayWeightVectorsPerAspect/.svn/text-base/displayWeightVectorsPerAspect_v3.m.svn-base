function displayWeightVectorsPerAspect_v3(objname, outdir)
%multimachine_warp('displayWeightVectorsPerAspect', 20, resdir, 2)

try

resdir = [outdir filesep 'display/']; mymkdir(resdir);

disp(['Processing Class ' objname]);

load([outdir '/' objname '_random.mat'], 'models');   
kclus = numel(models{1}.rootfilters);
clear models;

disp('writing final model');
finmodelname = [outdir '/' objname '_final.mat'];
if exist(finmodelname, 'file')
    savename = [resdir '/weightVector_final.jpg'];
    if ~exist(savename, 'file')
        clear allimw alliml
        load(finmodelname, 'model');
        for i=1:numel(model.rootfilters)
            allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3], [3 kclus]);
        imwrite(mim, savename);
        
        % write part filters
        if length(model.components{1}.parts) > 0
            pdispim = myvisualizemodel(model);
            imwrite(pdispim, [resdir '/weightVectorWithParts_final.jpg']);
        end
    end
end

disp('writing parts model');
partmodelname = [outdir '/' objname '_parts.mat'];
if exist(partmodelname, 'file') %& length(model.components{1}.parts) > 0 
    savename = [resdir '/weightVector_parts.jpg'];
    if ~exist(savename, 'file')
        % root filters        
        clear allimw alliml
        load(partmodelname, 'model');
        for i=1:numel(model.rootfilters)
            allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3]);
        imwrite(mim, savename);
        
        % write part filters
        if length(model.components{1}.parts) > 0
            pdispim = myvisualizemodel(model);
            imwrite(pdispim, [resdir '/weightVectorWithParts_parts.jpg']);
        end
    end
end

disp('writing hard model');
harmodelname = [outdir '/' objname '_hard.mat'];
if exist(harmodelname, 'file')
    savename = [resdir '/weightVector_hard.jpg'];
    if ~exist(savename, 'file')
        clear allimw alliml
        load(harmodelname, 'model');
        for i=1:numel(model.rootfilters)
            allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3], [3 kclus]);
        imwrite(mim, savename);        
    end
end

disp('writing random model');
randmodelname = [outdir '/' objname '_random.mat'];
if exist(randmodelname, 'file')
    savename = [resdir '/weightVector_random.jpg'];
    if ~exist(savename, 'file')
        load(randmodelname, 'models');
        clear mim;
        for k=1:numel(models)
            clear allimw alliml
            for i=1:numel(models{k}.rootfilters)
                allimw{i} = color(visualizeHOG(models{k}.rootfilters{i}.w));
                alliml{i} = num2str(i);
            end
            mim{k} = montage_list_w_text2(allimw, alliml, 2, [], [], [500 1000 3], [1 kclus]);
        end
        %mimg = [mim{1}; mim{2}; mim{3}];
        mimg = cat(1,mim{:});
        imwrite(mimg, savename);
    end
end

catch
    disp(lasterr); keyboard;
end
