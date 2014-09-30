function pascal_test_sumpool_selectedComps(cachedir, cls, testset, year, suffix, modelname, objname)
% Compute bounding boxes in a test set.
%   ds = pascal_test(model, testset, year, suffix)
%
% Return value
%   ds      Detection clipped to the image boundary. Cells are index by image
%           in the order of the PASCAL ImageSet file for the testset.
%           Each cell contains a matrix who's rows are detections. Each
%           detection specifies a clipped subpixel bounding box and its score.
% Arguments
%   model   Model to test
%   testset Dataset to test the model on (e.g., 'val', 'test')
%   year    Dataset year to test the model on  (e.g., '2007', '2011')
%   suffix  Results are saved to a file named:
%           [model.class '_boxes_' testset '_' suffix]
%
%   We also save the bounding boxes of each filter (include root filters)
%   and the unclipped detection window in ds

try    

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;

diary([cachedir '/diaryoutput_testselectedComps_' testset '_' year '.txt']);
disp(['pascal_test_sumpool_selectedComps(''' cachedir ''',''' cls ''',''' testset ''',''' year ''',''' suffix ''',''' modelname ''',''' objname ''');' ]);

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
VOCopts  = conf.pascal.VOCopts;
cachedir = conf.paths.model_dir;

% copied from pascal.m
if isempty(modelname)   % if modelname = 'final', leave it empty
    disp('loading final (parts) model');
    load([cachedir '/' cls '_final.mat'], 'model');
    savename = [cachedir cls '_boxes_' testset '_' suffix];
else
    disp('loading non-final (no parts/mix/joint) model');
    tmp = load([cachedir '/' cls '_' modelname '.mat'], 'model');    
    model = tmp.model;
    savename = [cachedir cls '_boxes_' testset '_' suffix '_' modelname];
    
    %{
    % prepare model    
    tmp = load([cachedir '/' cls '_lrsplit1.mat'], 'models');
    models = tmp.models;
    % update lrsplit models with latest weights from _mix model, so that parts are well initialized
    for i = 1:numel(models)
        % bias
        bl_lhs = models{i}.rules{models{i}.start}(1).offset.blocklabel;
        bl_rhs = model.rules{model.start}(i).offset.blocklabel;
        if numel(models{i}.blocks(bl_lhs).w) ~= numel(model.blocks(bl_rhs).w), disp('error here'); keyboard; end
        models{i}.blocks(bl_lhs).w = model.blocks(bl_rhs).w;
        
        % filter (dsk: not sure how to index into filter, for now "-1" is a hack)
        bl_lhs = models{i}.rules{models{i}.start}(1).offset.blocklabel-1;
        bl_rhs = model.rules{model.start}(i).offset.blocklabel-1;
        if numel(models{i}.blocks(bl_lhs).w) ~= numel(model.blocks(bl_rhs).w), disp('error here'); keyboard; end
        models{i}.blocks(bl_lhs).w = model.blocks(bl_rhs).w;
    end    
    %}
    
    tmp = load([cachedir '/' cls '_' modelname '_goodInfo.mat'], 'goodcomps');
    goodcomps = tmp.goodcomps;
    disp([num2str(length(find(goodcomps==1))) '/' num2str(numel(model.rules{model.start})) ' good components']);
        
end

% updated 11Jun13 (bad model components take too long; typically happens when degenerate ngram)
%model.thresh = min(conf.eval.max_thresh, model.thresh); 
if model.thresh < conf.eval.max_thresh
    disp('model threshold is lower than usual, probably corrupted!!');    
end
model.thresh = conf.eval.max_thresh;

model.interval = conf.eval.interval;

ids = textread([VOCopts.imgsetpath(1:end-6) '/baseobjectcategory_' objname '_val2.txt'], '%s');
tmp = load([VOCopts.imgsetpath(1:end-6) '/baseobjectcategory_' objname '_val2_validCompIds.mat'], 'validids');
validids = tmp.validids;
if numel(ids) ~= numel(validids), disp('length mismatch'); keyboard; end

if length(find(goodcomps==1)) == 0
    disp('no valid components, so saving dummy results and quitting');    
    ds = cell(1, length(ids));
    bs = ds;
    [ds_sum, th] = deal([]);
    save(savename, 'ds', 'bs', 'ds_sum', 'th');
    diary off;
    return;
end

% run detector in each image
try
    load(savename);
catch  
    disp('opening only 8 cores');
    mymatlabpoolopen(8);

    % parfor gets confused if we use VOCopt
    opts = VOCopts;
    if exist('/home/ubuntu/JPEGImages/','dir')  % for aws
        disp('updating image path /home/ubuntu/JPEGImages');
        opts.imgpath = '/home/ubuntu/JPEGImages/%s.jpg'; 
    end
    num_ids = length(ids);
    ds_out = cell(1, num_ids);
    bs_out = cell(1, num_ids);
    ds_sumout = cell(1, num_ids);   % sumpooling
    th = tic();
    %for i = 1:num_ids
    parfor i = 1:num_ids
        fprintf('%s: testing: %s %s, %d/%d\n', cls, testset, year, ...
            i, num_ids);
        if strcmp('inriaperson', cls)
            % INRIA uses a mixutre of PNGs and JPGs, so we need to use the annotation
            % to locate the image.  The annotation is not generally available for PASCAL
            % test data (e.g., 2009 test), so this method can fail for PASCAL.
            rec = PASreadrecord(sprintf(opts.annopath, ids{i}));
            im = imread([opts.datadir rec.imgname]);
        else
            im = imread(sprintf(opts.imgpath, ids{i}));
        end
        
        if validids(i) == 1            
            %[ds, bs] = imgdetect(im, model, model.thresh);
            %{
            % running 6 comps together is same speed as running 1 comp (without parts)
            tic; ds = imgdetect(im, model, model.thresh); toc;
            tic; ds2 = imgdetect2_tmp(im, models, model, model.thresh, goodcomps); toc;
            tic; ds3 = imgdetect2(im, models, model, model.thresh, goodcomps); toc;
            disp(sum(ds2(:)-ds3(:)));
            %}            
            %ds = imgdetect2(im, models, model, model.thresh, goodcomps);
            % this snippet gives fewer detections than imgdetect2 as it
            % does inbuilt nms; but note that snippet is being done to
            % speed up things (which it is not actually) and originally you
            % would have run it
            ds = [];
            [ds2, bs2] = imgdetect(im, model, model.thresh);             
            if ~isempty(ds2)
                for kk=1:length(goodcomps)  %% pick relevant comps
                    if goodcomps(kk) == 1
                        thisCompBoxIds = find(bs2(:,end-1) == kk);
                        ds = [ds; ds2(thisCompBoxIds, 1:4) kk*ones(length(thisCompBoxIds),1) ds2(thisCompBoxIds,end)];
                    end
                end
            end
        else
            ds = [];
        end
        
        if ~isempty(ds)
            ds = clipboxes(im, ds);
            
            % NMS
            I = nms(ds, 0.5);
            ds = ds(I,:);
                        
            % Save detection windows in boxes
            %ds_out{i} = ds(:,[1:4 end]);
            ds_out{i} = ds;
            
            %{
            % Save filter boxes in parts
            if model.type == model_types.MixStar
                % Use the structure of a mixture of star models
                % (with a fixed number of parts) to reduce the
                % size of the bounding box matrix
                bs = reduceboxes(model, bs);
                bs_out{i} = bs;
            else
                % We cannot apply reduceboxes to a general grammar model
                % Record unclipped detection window and all filter boxes
                bs_out{i} = cat(2, unclipped_ds, bs);
            end
            %}
        else
            ds_out{i} = [];
            %ds_sumout{i} = [];
            %bs_out{i} = [];
        end        
    end
    th = toc(th);
    ds = ds_out;
    bs = ds; %bs_out;    
    ds_sum = []; %ds_sumout;
    save(savename, 'ds', 'bs', 'ds_sum', 'th');
    fprintf('Testing took %.4f seconds\n', th);
end

%displayDetection_rankedMontages_v5(cls, testset, cachedir, year, suffix, modelname);
try matlabpool('close', 'force'); end
diary off;
catch
    disp(lasterr); keyboard;
end
