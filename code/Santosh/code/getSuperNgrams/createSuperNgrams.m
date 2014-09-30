function createSuperNgrams(inpfname, outfname, rawgoogimgdir_obj)

try    

disp(['createSuperNgrams(''' inpfname ''',''' outfname ''',''' rawgoogimgdir_obj ''')']);

conf = voc_config('paths.model_dir', 'blah');
maxNumImagesInSuperNgram = conf.threshs.maxNumImagesInSuperNgram;

tmp = load(inpfname, 'phrasenames', 'simNodes');
phrasenames = tmp.phrasenames;
simNodes = tmp.simNodes; 
numcls = numel(phrasenames);

mymatlabpoolopen;

disp('softlinking images');
%k = 1;
parfor i=1:numcls  
    myprintf(i,10); 
    %myprintf(k, 10);    
    %if k <= numNgramsToPick
        this_numNgCnt = length(simNodes{i});
        if this_numNgCnt > 1 
            %k = k+ 1;
            sname = [phrasenames{simNodes{i}(1)} '_super'];            
            outdirname = [rawgoogimgdir_obj '/' sname]; myrmdir(outdirname); mymkdir(outdirname);   %create image folder
            ids = cell(this_numNgCnt,1);
            totImgs = 0;            
            for j=1:this_numNgCnt
                indirname = [rawgoogimgdir_obj '/' phrasenames{simNodes{i}(j)}];
                ids{j} = mydir([indirname '/*.jpg']);
                totImgs = totImgs + numel(ids{j});
            end 
            if totImgs > maxNumImagesInSuperNgram                
                % dont do random selection; use google ranking to pick
                for j=1:this_numNgCnt                
                    indirname = [rawgoogimgdir_obj '/' phrasenames{simNodes{i}(j)}];
                    numToSelectPerNgram = min(round(maxNumImagesInSuperNgram/this_numNgCnt), numel(ids{j}));
                    for kk=1:numToSelectPerNgram
                        [a b]=system(['ln -s ' indirname '/' ids{j}{kk} ' ' outdirname '/' phrasenames{simNodes{i}(j)} '_' ids{j}{kk}]);
                    end
                end
            else
                for j=1:this_numNgCnt                
                    indirname = [rawgoogimgdir_obj '/' phrasenames{simNodes{i}(j)}];
                    for kk=1:numel(ids{j})  
                        [a b]=system(['ln -s ' indirname '/' ids{j}{kk} ' ' outdirname '/' phrasenames{simNodes{i}(j)} '_' ids{j}{kk}]);
                    end
                end
            end                            
        end 
    %end
end
myprintfn;

disp('writing new ngram names to file'); 
fid = fopen(outfname, 'w');
for i=1:numcls
    myprintf(i,10);
    this_numNgCnt = length(simNodes{i});
    if this_numNgCnt > 1
        sname = [phrasenames{simNodes{i}(1)} '_super'];
        fprintf(fid, '%s\n', sname);        
    elseif this_numNgCnt == 1
        fprintf(fid, '%s\n', phrasenames{simNodes{i}(1)});
    end
end
fclose(fid);
myprintfn;

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end

%{
ids = mydir([rawgoogimgdir_obj '/images/' sname '/*.jpg'], 1);                        
if length(ids) > maxNumImagesInSuperNgram
    %disp(' subsampling since more than 1000 images');
    tids = randperm(length(ids));
    selInds = tids(maxNumImagesInSuperNgram+1:end);
    idsToDel = ids(selInds);
    for j=1:length(idsToDel)
        [a b] = system(['rm ' idsToDel{j}]);
    end
end
%}

