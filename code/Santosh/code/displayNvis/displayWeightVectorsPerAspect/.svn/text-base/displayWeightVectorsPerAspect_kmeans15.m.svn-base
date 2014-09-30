function displayWeightVectorsPerAspect_kmeans15(objname, outdir)

try

outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);

disp(['Processing Class ' objname]);

disp('writing final model');
finmodelname = [outdir '/' objname '_final.mat'];
if exist(finmodelname, 'file')
    savename = [resdir '/weightVector_final.jpg'];
    if ~exist(savename, 'file')        
        disp('root filters');
        clear allimw alliml
        load(finmodelname, 'model');
        for i=1:numel(model.rootfilters)
            allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3]);
        imwrite(mim, savename);
        
        disp('part filters');
        if length(model.components{1}.parts) > 0
            pdispim = myvisualizemodel(model);
            imwrite(pdispim, [resdir '/weightVectorWithParts_final.jpg']);
        end
        
        disp('child filters');
        if isfield(model, 'childfilters') & length(model.childfilters) > 0
            for i=1:numel(model.childfilters)
                hogim = color(visualizeHOG(model.childfilters{i}.w));
                callimw{i} = hogim;
                calliml{i} = num2str(i);
            end
            mim = montage_list_w_text2(callimw, calliml, 2, [], [], [3000 2000 3]);
            imwrite(mim, [resdir '/weightVectorWithChild_final.jpg']);
        end
    end
end

disp('writing parts model');
harmodelname = [outdir '/' objname '_parts.mat'];
if exist(harmodelname, 'file')      %length(model.components{1}.parts) > 0 & 
    savename = [resdir '/weightVector_parts.jpg'];
    if ~exist(savename, 'file')
        disp('root filters');
        clear allimw alliml
        load(harmodelname, 'model');
        for i=1:numel(model.rootfilters)
            allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3]);
        imwrite(mim, savename);
        
        disp('part filters');
        if length(model.components{1}.parts) > 0
            pdispim = myvisualizemodel(model);
            imwrite(pdispim, [resdir '/weightVectorWithParts_parts.jpg']);
        end
        
        disp('child filters');
        if isfield(model, 'childfilters') & length(model.childfilters) > 0
            for i=1:numel(model.childfilters)
                hogim = color(visualizeHOG(model.childfilters{i}.w));
                callimw{i} = [hogim ones(size(hogim,1), 10, size(hogim,3)) ...
                    imresize(allimw{i}, [size(hogim, 1) size(hogim, 2)])];
                calliml{i} = num2str(i);
            end
            mim = montage_list_w_text2(callimw, calliml, 2, [], [], [3000 2000 3]);
            imwrite(mim, [resdir '/weightVectorWithChild_parts.jpg']);
        end
    end
end

disp('writing hard model');
harmodelname = [outdir '/' objname '_hard.mat'];
if exist(harmodelname, 'file')
    savename = [resdir '/weightVector_hard.jpg'];
    if ~exist(savename, 'file')
        disp('root filters');
        clear allimw alliml
        load(harmodelname, 'model');
        for i=1:numel(model.rootfilters)
            allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
            alliml{i} = num2str(i);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3]);
        imwrite(mim, savename);
        
        disp('child filters');
        if isfield(model, 'childfilters') & length(model.childfilters) > 0
            for i=1:numel(model.childfilters)
                hogim = color(visualizeHOG(model.childfilters{i}.w));
                callimw{i} = [hogim ones(size(hogim,1), 10, size(hogim,3)) ...
                    imresize(allimw{i}, [size(hogim, 1) size(hogim, 2)])];
                calliml{i} = num2str(i);
            end
            mim = montage_list_w_text2(callimw, calliml, 2, [], [], [3000 2000 3]);
            imwrite(mim, [resdir '/weightVectorWithChild_hard.jpg']);
        end
    end
end

disp('writing random model');
randmodelname = [outdir '/' objname '_random.mat'];
if exist(randmodelname, 'file')
    savename = [resdir '/weightVector_random.jpg'];
    if ~exist(savename, 'file')
        disp('root filters');
        load(randmodelname, 'models');
        clear mim;
        for k=1:numel(models)
            clear allimw alliml
            for i=1:numel(models{k}.rootfilters)
                allimw{i} = color(visualizeHOG(models{k}.rootfilters{i}.w));
                alliml{i} = num2str(i);
                
                models{k} = myaddlevel(models{k}, i, 1);
                hogim = color(visualizeHOG(models{k}.childfilters{1}.w));
                callimw{i} = [hogim ones(size(hogim,1), 10, size(hogim,3)) ...
                    imresize(allimw{i}, [size(hogim, 1) size(hogim, 2)])];
            end
            mim{k} = montage_list_w_text2(allimw, alliml, 2, [], [], [500 1000 3]);
            cmim{k} = montage_list_w_text2(callimw, alliml, 2, [], [], [3000 2000 3]);
        end        
        mimg = cat(1,mim{:});
        cmimg = cat(1,cmim{:});
        imwrite(mimg, savename);
        imwrite(cmimg, [resdir '/weightVectorWithChild_random.jpg']);
    end
end

catch
    disp(lasterr); keyboard;
end
