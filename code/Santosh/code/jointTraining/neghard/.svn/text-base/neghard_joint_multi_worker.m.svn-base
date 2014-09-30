function neghard_joint_multi_worker(resdir)

try

load([resdir '/data.mat'], 'conf', 't', 'negiter', 'model', 'neg', 'maxsize', 'negpos', 'max_num_examples');

model.interval = conf.training.interval_bg;
numneg = length(neg);

%dmthresh = -1.002;
dmthresh = conf.threshs.joint_dmthresh;

%for i = 1:numneg    
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numneg); 
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end

    disp(['Doing ' num2str(f)]); 
    fname = [resdir '/output_' num2str(f) '.mat'];
    try
        load(fname, 'bs', 'trees');
        bs;
    catch        
        im = color(imreadx(neg(f)));
        pyra = featpyramid(im, model);
        %det_limit = ceil((max_num_examples - num_examples) / thisbatchsize);
        %[ds, bs, trees] = gdetect_joint(pyra, model, -1.002, det_limit);
        [ds, bs, trees] = gdetect_joint(pyra, model, dmthresh);
        save(fname, 'bs', 'trees');
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch
    disp(lasterr); keyboard;
end
