function [rec,prec,ap,tp_ret,ovp_ret] = VOCevaldet_wsup(VOCopts,id,cls,draw,postag)
% this script from VOCevaldet.m, except that it provides additional
% information about tp_ret (labels) and ovp_ret (overlap)


try
% load test set
if strcmp(postag, 'NOUN')
    [gtids,t]=textread(sprintf(VOCopts.imgsetpath,VOCopts.testset),'%s %d');
elseif strcmp(postag, 'VERB')
    [gtids,t]=textread(sprintf(VOCopts.action.imgsetpath,VOCopts.testset),'%s %d');
end

disp(' load ground truth objects');
%tic;
gt(length(gtids))=struct('BB',[],'diff',[],'det',[]);
parfor i=1:length(gtids)
    % display progress
    %if toc>1
    %    fprintf('%s: pr: load: %d/%d\n',cls,i,length(gtids));
    %    drawnow;
    %    tic;
    %end
    
    % read annotation
    rec=PASreadrecord(sprintf(VOCopts.annopath,gtids{i}));
    
    % extract objects of class
    if strcmp(postag, 'NOUN')
        clsinds=strmatch(cls,{rec.objects(:).class},'exact');
    elseif strcmp(postag, 'VERB')
        clsinds = []; %zeros(numel(rec.objects), 1);
        for kk=1:numel(rec.objects)
            if isfield(rec.objects(kk).actions, cls) && rec.objects(kk).actions.(cls) == 1
                clsinds = [clsinds; kk];
            end
        end
    end
    gt(i).BB=cat(1,rec.objects(clsinds).bbox)';
    gt(i).diff=[rec.objects(clsinds).difficult];
    gt(i).det=false(length(clsinds),1);
end

npos=0;
for i=1:length(gtids)
    npos=npos+sum(~gt(i).diff);
end

% load results
[ids,confidence,b1,b2,b3,b4]=textread(sprintf(VOCopts.detrespath,id,cls),'%s %f %f %f %f %f');
BB=[b1 b2 b3 b4]';

% sort detections by decreasing confidence
[sc,si]=sort(-confidence);
ids=ids(si);
BB=BB(:,si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
ovp=zeros(nd,1);

tic;
for d=1:nd
    % display progress
    if toc>1
        fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
        drawnow;
        tic;
    end
    
    % find ground truth image
    i=strmatch(ids{d},gtids,'exact');
    if isempty(i)
        error('unrecognized image "%s"',ids{d});
    elseif length(i)>1
        error('multiple image "%s"',ids{d});
    end

    % assign detection to ground truth object if any
    bb=BB(:,d);
    ovmax=-inf;
    for j=1:size(gt(i).BB,2)
        bbgt=gt(i).BB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 & ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax>=VOCopts.minoverlap
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
                gt(i).det(jmax)=true;
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
    ovp(d) = ovmax;
end

newInd(si) = 1:length(tp);
tp_ret = tp(newInd);
ovp_ret = ovp(newInd);

% compute precision/recall
fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/npos;
prec=tp./(fp+tp);

% compute average precision
ap=0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end

if draw
    % plot precision/recall
    plot(rec,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %s, subset: %s, AP = %.3f',cls,VOCopts.testset,ap));
end

catch
    disp(lasterr); keyboard;
end
