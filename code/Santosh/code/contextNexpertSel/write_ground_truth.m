function diffids = write_ground_truth(cachedir, cls, basecls, dataset, year)

try
conf = voc_config('pascal.year', year, 'paths.model_dir', cachedir);
VOCopts = conf.pascal.VOCopts;

gtsubdir = 'p33tn';
diffThresh = 0.33;

% load box information for 'val1'
load([cachedir '/' cls '_boxes_' dataset '_' year], 'ds', 'bs');
ids = textread(sprintf(conf.pascal.VOCopts.imgsetpath, dataset), '%s');
if numel(ids) ~= numel(ds), disp('error'); keyboard; end

% get pos img ids for this class
[thisids, gt] = textread(sprintf(conf.pascal.VOCopts.clsimgsetpath, cls, 'train'), '%s %d');
thisposids = thisids(gt == 1);
thisinds = logical(doStringMatch(ids, thisposids)); % get box info for pos ids
ds = ds(thisinds);
ids = ids(thisinds);

% get the top box for each pos img
numele = numel(ds);
bbox = zeros(numele, 5);
diffic = zeros(numele, 1);
for i=1:numele
    bbox(i,:) = ds{i}(1,:);
end

% mark as difficult
minThresh = 0.25;
load([cachedir '/' cls '_prpos_' dataset '_' year '.mat'], 'ap');
if ap > minThresh        % good class    
    [~, sind] = sort(bbox(:,5), 'descend');        
    diffones = sind(floor(numele*diffThresh)+1:end);  % pick top 75% as pos, rest as difficult
    diffic(diffones) = 1;   % just ignore the bottom ranked ones
else                    % bad class
    diffic(:) = 1;          % ignore all of them
end

if nargout > 0
    diffids = ids(logical(diffic));
    return;
end

mymkdir([myStrtokEnd(conf.pascal.VOCopts.annopath,'/') '/' gtsubdir '/']);
% write box info to .xml file
for i=1:numele    
    myPASwriteRecordWrapper(VOCopts, cls, basecls, ids{i}, bbox(i,:), diffic(i), gtsubdir);    
end

catch
    disp(lasterr); keyboard;
end
