function displayAnnotations_v5(VOCyear, testset)
%multimachine_warp_depfun(['displayAnnotations_v5(''' VOCyear ''',''' testset ''')'], 10000, resdir, 10, [], 2, 0, 1);

try
cachedir = 'blah';    
VOCinit;

gtsubdir = '75percent';
imgdir = [VOCopts.datadir '/' VOCyear '/JPEGImages/'];
outdir = [VOCopts.datadir '/' VOCyear '/JPEGImages_annotated/' gtsubdir '/']; mymkdir(outdir);
resdir = outdir;

% load image set
[ids,gt]=textread([imgdir '/../ImageSets/Main/' testset '.txt'],'%s %d'); 
%ids = mydir([imgdir '/*.jpg']);

mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(length(ids));
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
    disp(['Processing image ' num2str(f)]);
       
    savename = [outdir '/' ids{f} '.mat'];    
    if ~exist(savename, 'file')
        
        if exist([imgdir '/../Annotations/' gtsubdir '/' strtok(ids{f},'.') '.xml'], 'file')
            % read annotation
            %rec=PASreadrecord(sprintf(VOCopts.annopath,ids{f}));
            rec=PASreadrecord([imgdir '/../Annotations/' gtsubdir '/' strtok(ids{f},'.') '.xml']);
        else
            continue;
        end
    
    % read image
    I=imread([imgdir '/' strtok(ids{f},'.') '.jpg']);

    clf;
    imagesc(I);
    hold on;
    for j=1:length(rec.objects)
        bb=rec.objects(j).bbox;
        lbl=rec.objects(j).class;
        lbl = [num2str(j) lbl];
        if rec.objects(j).difficult
            ls='r'; % "difficult": red
        else
            ls='g'; % not "difficult": green
        end
        if rec.objects(j).truncated
            lbl=[lbl 'T'];
        end
        if isfield(rec.objects(j), 'occluded') && rec.objects(j).occluded
            lbl=[lbl 'O'];
        end
        plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),ls,'linewidth',2);
        text(bb(1),bb(2),lbl,'color','k','backgroundcolor',ls(1),...
            'verticalalignment','top','horizontalalignment','left','fontsize',8);
        
        for k=1:length(rec.objects(j).part)
            bb=rec.objects(j).part(k).bbox;
            plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),[ls ':'],'linewidth',2);
            text(bb(1),bb(2),rec.objects(j).part(k).class,'color','k','backgroundcolor',ls(1),...
                'verticalalignment','top','horizontalalignment','left','fontsize',8);
        end
    end
    hold off;
    axis image off;
    
    mysaveas([outdir '/' strtok(ids{f},'.') '.jpg']);
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch
    disp(lasterr); keyboard;
end
