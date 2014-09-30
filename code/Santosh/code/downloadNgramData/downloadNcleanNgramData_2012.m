function downloadNcleanNgramData_2012(ngramtype, outdir) 

try

if isdeployed, ngramtype = str2num(ngramtype); end
numNgramFiles = ngramGoogFileInfo(ngramtype);

if exist('/data', 'dir')
    tmpdirname = '/data/';      % tmp dirname on local machine (not /tmp but /data on grail machines)
elseif exist('/scratch', 'dir')
    tmpdirname = '/scratch/';
end

googDataUrl = 'http://storage.googleapis.com/books/ngrams/books/';

resdir = outdir;
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numNgramFiles);
for f = list_of_ims    %0:numNgramFiles
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
    
    %fcode = getfcode_forzerogram(f);
    fcode = getfcode_forngram(ngramtype, f);
    filename = ['googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' fcode];
    savename = [outdir '/' filename];    
    savename_tmp = [tmpdirname '/out_' filename];
    if ~exist(savename, 'file')
        disp(['Processing file ' num2str(f) '/' num2str(numNgramFiles)]);
        disp(savename);
        
        %zipfilename = [indir '/' filename '.gz'];
        zipfilename = [tmpdirname '/zip_' filename '.gz'];
        %if ~exist(zipfilename, 'file')
            if exist(zipfilename, 'file'), system(['rm ' zipfilename]); end
            u=[googDataUrl filename '.gz'];
            system(['wget -O ' zipfilename ' ' u]);
        %end
        
        unzipfileprefix = [tmpdirname '/' filename];
        %if ~exist([unzipfileprefix 'aa'], 'file')   % check if file has not already been unzipped
            disp(' unzipping');
            system(['rm ' unzipfileprefix '*']);
            system(['gunzip -c ' zipfilename ' | split -C 1G - ' unzipfileprefix]);
            % gunzip unzips the file; split splits it into 1G chunks wiht
            % suffixes as 'aa','ab', and so on
        %end
         
        if exist(savename_tmp, 'file'), system(['rm ' savename_tmp]); end
        fid = fopen(savename_tmp, 'w');
          
        flist = mydir([unzipfileprefix '*'],1);
        for i=1:numel(flist)    % for each of the split file
            myprintf(i, 10);
            
            disp(' getting data');
            unzipfilename = flist{i};
            [~, ngstrings] = system(['cat ' unzipfilename ' | cut -f 1']);      % first field is string (ngram)
            [~, ngcnts] = system(['cat ' unzipfilename ' | cut -f 3']);         % thrid field is the ngram count
            
            ngstrings = regexp(ngstrings, '\n', 'split');
            ngcnts = regexp(ngcnts, '\n', 'split');
            
            ngstrings(cellfun('isempty', ngstrings)) = [];
            ngcnts(cellfun('isempty', ngcnts)) = [];
            if length(ngstrings) ~= length(ngcnts), disp('dim mismatch'); keyboard; end
            
            disp(' converting counts to mat');
            ngcnts_mat = sscanf(CStr2String(ngcnts, '*'), '%f*');
            ngcnts_mat = ngcnts_mat';
            
            disp(' do unique');
            [ngstrings_uniq, ~, ib] = unique(ngstrings);
            
            disp(' add similar items ');
            ngcnts_uniq = accumarray(ib(:), ngcnts_mat(:));
            
            disp(' write to file');
            for j = 1:length(ngstrings_uniq);
                fprintf(fid, '%s %d\n', ngstrings_uniq{j}, ngcnts_uniq(j));
            end
        end
        myprintfn;
        
        fclose(fid);
        
        disp(' copying processed file to results driectory');
        movefile(savename_tmp, savename);
        
        %if exist(zipfilename, 'file')
            disp(' deleting zip & unziped file');
            system(['rm ' zipfilename ' &']);
            system(['rm ' unzipfileprefix '*' ' &']);
        %end
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done']);
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch
    disp(lasterr); keyboard;
end
