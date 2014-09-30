function createNegativeImageSet(voc07dir, imgsetdir, objname)
% voc gives images for 20 classes only; i use the imagesets to access
% negative images for those classes (positives are from google); for doing
% new classes (apart form the 20), i simply use all images of voc as
% negatives

try

indir_info = [voc07dir '/ImageSets/Main/'];

suffixes = {'train', 'val', 'test', 'trainval'};
for f=1:length(suffixes)
    suffix = suffixes{f};
    if ~exist([indir_info '/' objname '_' suffix '.txt'], 'file')        % if not one of voc 20 classes
        if ~exist([imgsetdir '/' objname '_' suffix '.txt'], 'file')     % if not alread processed
            disp(['creating  ' objname '_' suffix '.txt']); 
            ids = textread([indir_info '/'  suffix '.txt'], '%s');
            fid = fopen([imgsetdir '/' objname '_' suffix '.txt'], 'w');
            for i=1:length(ids)
                fprintf(fid, '%s -1\n', ids{i});
            end
            fclose(fid);
        end
    end    
end

catch
    disp(lasterr); keyboard;
end
