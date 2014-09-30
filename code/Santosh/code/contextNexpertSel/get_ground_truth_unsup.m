function [gt, npos] = get_ground_truth_unsup(cachedir, cls, dataset, year, subdir)
% Load and cache ground-truth annontation data.
% Most of this code is borrowed from the PASCAL devkit.

conf = voc_config('pascal.year', year, 'paths.model_dir', cachedir);
VOCopts  = conf.pascal.VOCopts;
VOCyear  = conf.pascal.year;

try
    load([cachedir cls '_gt_anno_' dataset '_' [subdir VOCyear]]);
catch
    % load ground truth objects
    [gtids, tgt] = textread(sprintf(VOCopts.imgsetpath,[dataset '_withLabels']),'%s %d');        
    
    npos = 0;
    for i = 1:length(gtids)
        % display progress
        tic_toc_print('%s: loading ground truth: %d/%d\n',cls,i,length(gtids));
        
        % read annotation
        if tgt(i) == -1        
        rec = PASreadrecord(sprintf(VOCopts.annopath,gtids{i}));
        elseif tgt(i) == 1
        rec = PASreadrecord(sprintf(VOCopts.annopath, [subdir '/' gtids{i}]));
        end
        
        % extract objects of class
        clsinds = strmatch(cls,{rec.objects(:).class},'exact');
        gt(i).boxes = cat(1,rec.objects(clsinds).bbox)';
        gt(i).diff = [rec.objects(clsinds).difficult];
        gt(i).det = false(length(clsinds),1);
        npos = npos+sum(~gt(i).diff);
    end    
    save([cachedir cls '_gt_anno_' dataset '_' [subdir VOCyear]], 'gt', 'npos');
end
