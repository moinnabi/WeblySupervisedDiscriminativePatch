function ds = pascal_test_calib_wsup(cachedir, cls, testset, year, suffix)

% 5Dec12: The main update here is getting "ids" via getImgIdsForCalib(); 

% I have now modified the logic such that now testset is set to val1 i.e., the
% "testset" is appropriately changed rather than modifying the code; so
% this script is no longer useful and pascal_test or pascal_test_sumpool
% could be directly used

try    

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
diary([cachedir '/diaryoutput_calib_' testset '.txt']);
disp(['pascal_test_calib_wsup(''' cachedir ''',''' cls ''',''' testset ''',''' year ''',''' suffix ''')' ]);

mymatlabpoolopen;

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
VOCopts  = conf.pascal.VOCopts;
cachedir = conf.paths.model_dir;
%cls = model.class;

% copied from pascal.m
load([cachedir '/' cls '_final.mat'], 'model');
model.thresh = min(conf.eval.max_thresh, model.thresh);
model.interval = conf.eval.interval;
%disp('reduce the threshold a bit -- isnt threshold already reduced at test time to encourage high recall?'); 
%disp('keeping same settings as at test time'); 

%ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
ids = getImgIdsForCalib(VOCopts, cls);

% run detector in each image
try
    load([cachedir cls '_boxes_calib_' suffix]);
catch  
    % parfor gets confused if we use VOCopt
    opts = VOCopts;
    num_ids = length(ids);
    ds_out = cell(1, num_ids);
    bs_out = cell(1, num_ids);    
    th = tic();
    parfor i = 1:num_ids;
        fprintf('%s: testing: %s %s, %d/%d\n', cls, testset, year, ...
            i, num_ids);
        im = imread(sprintf(opts.imgpath, ids{i}));
        [ds, bs] = imgdetect(im, model, model.thresh);
        if ~isempty(bs)
            unclipped_ds = ds(:,1:4);
            [ds, bs, rm] = clipboxes(im, ds, bs);
            unclipped_ds(rm,:) = [];
            
            % NMS
            I = nms(ds, 0.5);
            ds = ds(I,:);
            bs = bs(I,:);
            unclipped_ds = unclipped_ds(I,:);
                        
            % Save detection windows in boxes
            ds_out{i} = ds(:,[1:4 end]);
            
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
            bs_out{i} = [];
        end
    end
    th = toc(th);
    ds = ds_out;
    bs = bs_out;    
    save([cachedir cls '_boxes_calib_' suffix], 'ds', 'bs', 'th');
    fprintf('Testing took %.4f seconds\n', th);
end

diary off;
catch
    disp(lasterr); keyboard;
end
