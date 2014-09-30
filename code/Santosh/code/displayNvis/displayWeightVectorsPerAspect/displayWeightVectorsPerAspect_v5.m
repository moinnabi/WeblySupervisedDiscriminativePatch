function displayWeightVectorsPerAspect_v5(objname, outdir)
%multimachine_warp('displayWeightVectorsPerAspect_v5', 20, resdir, 2)

try
disp(['displayWeightVectorsPerAspect_v5(''' objname ''',''' outdir ''')' ]);

resdir = [outdir filesep 'display/']; mymkdir(resdir);

if 0
% when part "model" is saved    
disp('writing final model');
finmodelname = [outdir '/' objname '_parts.mat'];
if exist(finmodelname, 'file')
    savename = [resdir '/weightVector_parts.jpg'];
    if ~exist(savename, 'file')
        clear allimw alliml
        load(finmodelname, 'model');        
        for i=1:numel(model.rules{model.start})
            allimw{i} = color(myvisualizeHOG(model.filters(i).w));
            alliml{i} = num2str(i);
            imwrite(allimw{i}, [resdir '/weightVector_parts_' num2str(i) '.jpg']);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [4500 3000 3]);
        imwrite(mim, savename);
        
        % write part filters
        try
        %pdispim = myvisualizemodel(model);
        [pdispim, pmim] = myvisualizemodel_v5(model);
        imwrite(pdispim, [resdir '/weightVectorWithParts_parts.jpg']);
        for i=1:numel(pmim)
            imwrite(pmim{i}, [resdir '/weightVectorWithParts_parts_' num2str(i) '.jpg']);
        end
        end
    end
end
end

disp('writing joint model');
finmodelname = [outdir '/' objname '_joint.mat'];
if exist(finmodelname, 'file')
    savename = [resdir '/weightVector_joint.jpg'];
    if ~exist(savename, 'file')
        clear allimw alliml
        try load(finmodelname, 'model'); model;
        catch load(finmodelname, 'models'); model = model_merge(models); end
        [~, ~, ~, ~, cmps] = fv_model_args(model);
        for i=1:numel(model.rules{model.start})
            myprintf(i,10);
            thisw = reshape(model.blocks(cmps{i}(1)).w, model.blocks(cmps{i}(1)).shape);
            allimw{i} = color(myvisualizeHOG(thisw));
            alliml{i} = num2str(i);
            imwrite(allimw{i}, [resdir '/weightVector_joint_' num2str(i, '%03d') '.jpg']);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [4500 3000 3]);
        imwrite(mim, savename);
        
        % write part filters
        try
        %pdispim = myvisualizemodel(model);
        [pdispim, pmim] = myvisualizemodel_v5(model);
        imwrite(pdispim, [resdir '/weightVectorWithParts_joint.jpg']);
        for i=1:numel(pmim)
            myprintf(i,10);
            imwrite(pmim{i}, [resdir '/weightVectorWithParts_joint_' num2str(i, '%03d') '.jpg']);
        end
        end
    end
end

disp('writing parts model');
finmodelname = [outdir '/' objname '_parts.mat'];
if exist(finmodelname, 'file')
    savename = [resdir '/weightVector_parts.jpg'];
    if ~exist(savename, 'file')
        clear allimw alliml
        try load(finmodelname, 'model'); model;
        catch load(finmodelname, 'models'); model = model_merge(models); end
        [~, ~, ~, ~, cmps] = fv_model_args(model);
        for i=1:numel(model.rules{model.start})
            thisw = reshape(model.blocks(cmps{i}(1)).w, model.blocks(cmps{i}(1)).shape);
            allimw{i} = color(myvisualizeHOG(thisw));
            alliml{i} = num2str(i);
            imwrite(allimw{i}, [resdir '/weightVector_parts_' num2str(i) '.jpg']);
        end
        mim = montage_list_w_text2(allimw, alliml, 2, [], [], [4500 3000 3]);
        imwrite(mim, savename);
        
        % write part filters
        try
        %pdispim = myvisualizemodel(model);
        [pdispim, pmim] = myvisualizemodel_v5(model);
        imwrite(pdispim, [resdir '/weightVectorWithParts_parts.jpg']);
        for i=1:numel(pmim)
            imwrite(pmim{i}, [resdir '/weightVectorWithParts_parts_' num2str(i) '.jpg']);
        end
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
        [~, ~, ~, ~, cmps] = fv_model_args(model);
        for i=1:numel(model.rules{model.start})
            thisw = reshape(model.blocks(cmps{i}(1)).w, model.blocks(cmps{i}(1)).shape);
            allimw{i} = color(myvisualizeHOG(thisw));
            alliml{i} = num2str(i);
            imwrite(allimw{i}, [resdir '/weightVector_mix_' num2str(i) '.jpg']);
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
        [~, ~, ~, ~, cmps] = fv_model_args(model);
        for k=1:numel(model.rules{model.start})            
            %allimw{k} = color(visualizeHOG(models{k}.filters(1).w));
            thisw = reshape(model.blocks(cmps{k}(1)).w, model.blocks(cmps{k}(1)).shape);
            allimw{k} = color(myvisualizeHOG(thisw));
            alliml{k} = num2str(k);
            %mim{k} = montage_list_w_text2(allimw, alliml, 2, [], [], [500 1000 3], [1 kclus]);
            imwrite(allimw{k}, [resdir '/weightVector_random_' num2str(k) '.jpg']);
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
