function doExpertSel_test(cachedir, train_year, traindataset, testdataset, objname, phrasenames, suffix, test_year, numComp)

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = test_year;
conf = voc_config('pascal.year', test_year);
cachedir = conf.paths.model_dir;

disp(['doExpertSel_test(''' cachedir ''',''' train_year  ''',''' traindataset ''',''' testdataset ''',''' objname ''','' phrasenames  '',''' suffix ''',''' test_year ''',''' num2str(numComp) ''')' ]);

load([cachedir '/' objname '_ordering_' traindataset suffix '_' train_year '.mat'], 'phraseorder', 'phrasethreshs');
disp(length(phraseorder));

disp(' get boxes');
[ds_all, bs_all] = getBoxes_helper(cachedir, testdataset, test_year, phrasenames);

disp(['merge detections ']);
[ds, bs] = mergeBoxes_helper(numel(ds_all{1}), ds_all, bs_all);

doComp = numel(phrasenames)*numComp == numel(phraseorder);
if doComp
    disp(' updating with comp info');
    for i=1:numel(ds)        
        ds{i} = [ds{i}(:,1:end-1) (ds{i}(:,end-1)-1)*numComp+ds{i}(:,end-2) ds{i}(:, end)];
        %for j=1:size(ds{i},1), ds{i}(j,:) = [ds{i}(j,1:end-1) (ds{i}(j,end-1)-1)*numComp+ds{i}(j,end-2) ds{i}(j, end)]; end
    end
end    
ds_nonms = ds;
numids = numel(ds);

disp(' do expert selection');
ds = cell(numids,1);
OVTH = 0.15;                % min overlap threshold to discard overlapping detection (specific to expert selection)
for f=1:numids              % for each image
    myprintf(f, 100);
    ds_after = [];
    ds{f} = [];                         % initialize with null set
    for ii=1:size(phrasethreshs,2)        
        ngcnt = numel(phraseorder)*(size(phrasethreshs,2)-ii+1);        
        for c=phraseorder(:)'               % go in a predetermined order
            if ~isempty(ds_nonms{f})
                % get boxes belonging to this ngram and above the predetermined threshold
                thisinds = find(ds_nonms{f}(:,end-1) == c & ds_nonms{f}(:,end) >= phrasethreshs(c,ii));
                thisboxes = ds_nonms{f}(thisinds,:);
                if ~isempty(thisboxes)
                    thisboxes = applySigmoid(thisboxes, [], doComp); 
                    %thisboxes(:,end) = thisboxes(:,end) - (ii-1);
                    thisboxes(:,end) = thisboxes(:,end) + ngcnt;
                end
                ds{f} = [ds{f}; thisboxes];
                
                % remove the selected boxes
                ds_nonms{f}(thisinds,:) = [];
                
                % now for each selected box, find all overlapping boxes (across
                % all phrases) and discard them, so they are not picked in
                % subsequent steps
                for j=1:size(thisboxes,1)
                    ov = getBoxOverlap_pedroNMS2(thisboxes(j, [1 3 2 4]), ds_nonms{f}(:, [1 3 2 4]));
                    ds_after = [ds_after; ds_nonms{f}(ov>OVTH,:)];
                    ds_nonms{f}(ov > OVTH,:) = [];
                end
            end
            ngcnt = ngcnt - 1;
        end        
    end        
    % do nms for all the left over stuff you added at the end
    I = nms(ds_after, 0.75); 
    ds_after = ds_after(I, :);    
    ds{f} = [ds{f}; ds_after];        
    %%%%%%%%%%%%[blah, blah, I] = bboxNonMaxSuppression(ds{f}(:,1:4), ds{f}(:,end), 0.25);        
end
myprintfn;

save([cachedir '/' objname '_boxes_' testdataset '_' traindataset suffix '_' test_year '.mat'], 'ds');

catch
    disp(lasterr); keyboard;
end

function thisboxes = applySigmoid(thisboxes, sigparams, doComp)

if doComp
compid = thisboxes(:,end-3);
phraseid = thisboxes(:,end-2);
else
compid = thisboxes(:,end-2);
phraseid = thisboxes(:,end-1);
end

scores = thisboxes(:, end);

sigvals = zeros(numel(phraseid),2);
for i=1:numel(phraseid)
    %sigvals(i,:) = sigparams{phraseid(i)}(compid(i),:);
    sigvals(i,:) = [-1 0];
end

scores = 1./(1+exp(scores.*sigvals(:,1) + sigvals(:,2)));
thisboxes(:,end) = scores;
