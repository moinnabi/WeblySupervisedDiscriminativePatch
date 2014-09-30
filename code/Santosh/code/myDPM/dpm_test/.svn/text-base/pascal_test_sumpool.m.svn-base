function pascal_test_sumpool(cachedir, cls, testset, year, suffix, modelname)
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

if nargin < 6
    modelname = '';
end

diary([cachedir '/diaryoutput_test_' testset '_' year '.txt']);
disp(['pascal_test_sumpool(''' cachedir ''',''' cls ''',''' testset ''',''' year ''',''' suffix ''',''' modelname ''');' ]);

disp('opening only 8 cores'); 
mymatlabpoolopen(8);

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
    load([cachedir '/' cls '_' modelname '.mat'], 'model');
    savename = [cachedir cls '_boxes_' testset '_' suffix '_' modelname];
end

% updated 11Jun13 (bad model components take too long; typically happens when degenerate ngram)
%model.thresh = min(conf.eval.max_thresh, model.thresh); 
if model.thresh < conf.eval.max_thresh
    disp('model threshold is lower than usual, probably corrupted!!');    
end
model.thresh = conf.eval.max_thresh;

model.interval = conf.eval.interval;

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% run detector in each image
try    
    load(savename);
catch  
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
    parfor i = 1:num_ids;
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
        [ds, bs] = imgdetect(im, model, model.thresh);
        if ~isempty(bs)
            unclipped_ds = ds(:,1:4);
            [ds, bs, rm] = clipboxes(im, ds, bs);
            unclipped_ds(rm,:) = [];
            
            % sumpooling
            ds_sum = ds;
            ds_sum = decodeDets(ds_sum);
            I = nms(ds_sum, 0.5);
            ds_sum = ds_sum(I,:);
            
            % NMS
            I = nms(ds, 0.5);
            ds = ds(I,:);
            bs = bs(I,:);
            unclipped_ds = unclipped_ds(I,:);
                        
            % Save detection windows in boxes
            ds_out{i} = ds(:,[1:4 end]);   
            ds_sumout{i} = ds_sum(:,[1:4 end]); % sumpooling
            
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
        else
            ds_out{i} = [];
            ds_sumout{i} = [];
            bs_out{i} = [];
        end        
    end
    th = toc(th);
    ds = ds_out;
    bs = bs_out;
    ds_sum = ds_sumout;
    save(savename, 'ds', 'bs', 'ds_sum', 'th');
    fprintf('Testing took %.4f seconds\n', th);
end

displayDetection_rankedMontages_v5(cls, testset, cachedir, year, suffix, modelname);

diary off;
catch
    disp(lasterr); keyboard;
end
