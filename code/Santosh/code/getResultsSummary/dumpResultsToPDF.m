function dumpResultsToPDF(objname, pdfdir, pdfname, supNgFname, fname_imgcl_sprNg, baseobjdir, disptestFname, n_perngram)

%try   
    
if exist(pdfname, 'file'), delete(pdfname); end
%diary(pdfname);

fid = fopen(pdfname, 'w');

fprintf(fid, '\\documentclass[10pt,letterpaper]{article}\n');
fprintf(fid, '\\usepackage{graphicx}\n');
fprintf(fid, '\\usepackage{geometry}\n');  
%fprintf(fid, '\\usepackage{times}\n');  
%fprintf(fid, '\\usepackage{epsfig}\n');  
  
%fprintf(fid, '\\setbeamertemplate{caption}{\\insertcaption}\n'); 
 
fprintf(fid, '\n');
fprintf(fid, '\\date{}\n');    
fprintf(fid, '\\begin{document}\n');
fprintf(fid, '\n');
fprintf(fid, ['\\title{' upper(objname) '}\n']);
fprintf(fid, '\n');
fprintf(fid, '\\maketitle\n');
fprintf(fid, '\n');

disp('printing list of ngrams');
fprintf(fid, ['\\section{ List of (Super) Ngrams }\n']);
%fprintf(fid, ['\label{sec:' objname '}']);
fprintf(fid, '\n');


load(supNgFname, 'phrasenames', 'simNodes');
for f=1:numel(phrasenames)
    phrasenames{f} = strrep(phrasenames{f}, '_', ' ');
end

fprintf(fid, ['\\begin{enumerate}\n']);
for i=1:numel(phrasenames)
    if length(simNodes{i}) >= 1
        fprintf(fid, '\\item '); 
        for j=1:length(simNodes{i})
            fprintf(fid, '%s, ', phrasenames{simNodes{i}(j)});            
        end
        fprintf(fid, '\n');
    end
end
fprintf(fid, ['\\end{enumerate}\n']);
fprintf(fid, '\\clearpage\n');
fprintf(fid, '\n\n\n');


disp('printing selected comps');
fprintf(fid, ['\\section{ Selected Components }\n']);
%fprintf(fid, ['\label{sec:' objname '}']);
fprintf(fid, '\n');
phrasenames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg); 
phrasenames_disp = [];
for f=1:numel(phrasenames)
    phrasenames_disp{f} = strrep(phrasenames{f}, '_', ' ');
end
[imgnames, ngname, ngothernames] = deal([]);
compind=0;
for c = 1:numel(phrasenames)    
    cachedir = [baseobjdir '/../' phrasenames{c}];
    load([cachedir '/' phrasenames{c} '_mix_goodInfo2'], 'selcomps', 'selcompsInfo');    
    for j=1:n_perngram
        if selcomps(j) == 1
            compind=compind+1;
            imgnames{compind} = [cachedir '/display/montage3x3_' num2str(j,'%02d') '.jpg'];
            ngname{compind} = [phrasenames_disp{c} ' ' num2str(j)];             
            for kk=1:size(selcompsInfo{j},1)
                ngothernames{compind}{kk} = [phrasenames_disp{selcompsInfo{j}(kk,1)} ' ' num2str(selcompsInfo{j}(kk,2))]; 
            end             
        end  
    end
end

for f=1:3:3*floor(compind/3) 
    fprintf(fid, '\\begin{figure*}[ht]\n');
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\begin{center}\n');
    fprintf(fid, '\\begin{tabular}{ccc}\n');
    %fprintf(fid, ['\includegraphics[height=0.45\textheight]{' resdir '/clusters_val2/' imlist{i} '} \\']);
    %fprintf(fid, ['\includegraphics[height=0.3\textheight,width=0.3\linewidth]{' imgnames{f} '} \ \ \ & \ \ \ ']);
    fprintf(fid, ['\\includegraphics[width=0.3\\linewidth]{' imgnames{f} '}']);   
    fprintf(fid, ' \\ \\ \\ & \\ \\ \\ \n');   
    fprintf(fid, ['\\includegraphics[width=0.3\\linewidth]{' imgnames{f+1} '}']);
    fprintf(fid, ' \\ \\ \\ & \\ \\ \\ \n');
    fprintf(fid, ['\\includegraphics[width=0.3\\linewidth]{' imgnames{f+2} '}']);
    fprintf(fid, ' \\\\ \n');
    fprintf(fid, '%s ', ngname{f} );
    fprintf(fid, ' & ');
    fprintf(fid, '%s ', ngname{f+1});
    fprintf(fid, ' & ');
    fprintf(fid, '%s ', ngname{f+2});
    fprintf(fid, ' \\\\ \n');
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\\end{center}\n');    
    fprintf(fid, '\\caption{');
    for currf=f:f+2
        if numel(ngothernames{currf})>1
            fprintf(fid, ' {\\bf %s merges with} ', ngothernames{currf}{1});
            for kk=2:numel(ngothernames{currf})
                fprintf(fid, '%s, ', ngothernames{currf}{kk});
            end             
            fprintf(fid, ';');   
        end
    end
    fprintf(fid, '}\n');
         
    %fprintf(fid, '\label{fig:lr_vs_kmeans}');    
    fprintf(fid, '\\end{figure*}\n');
    
    %{
    currf = f;
    if numel(ngothernames{currf})>1
        fprintf(fid, ['\begin{itemize}']);
        fprintf(fid, '\\item %s: ', ngname{currf});
        for kk=1:numel(ngothernames{currf})
            fprintf(fid, '%s, ', ngothernames{currf}{kk});
        end
        fprintf(fid, '\n');
        fprintf(fid, ['\end{itemize}']);
    end    
    currf = f+1; 
    if numel(ngothernames{currf})>1
        fprintf(fid, ['\begin{itemize}']);
        fprintf(fid, '\\item %s: ', ngname{currf});
        for kk=1:numel(ngothernames{currf})
            fprintf(fid, '%s, ', ngothernames{currf}{kk});
        end
        fprintf(fid, '\n');
        fprintf(fid, ['\end{itemize}']);
    end
    currf = f+2;
    if numel(ngothernames{currf})>1
        fprintf(fid, ['\begin{itemize}']); 
        fprintf(fid, '\\item %s: ', ngname{currf});
        for kk=1:numel(ngothernames{currf})
            fprintf(fid, '%s, ', ngothernames{currf}{kk});
        end
        fprintf(fid, '\n');
        fprintf(fid, ['\end{itemize}']);
    end
    %}
    
    fprintf(fid, '\n');
        
    if rem(f+2,30) == 0
        fprintf(fid, '\\clearpage\n');
    end          
end
fprintf(fid, '\\clearpage\n');
fprintf(fid, '\n\n\n');

if ~isempty(disptestFname) && exist(disptestFname, 'file')
    disp('printing top 50 dets');
    test_imgname = disptestFname; %[disptestdir '/all_test_2007_joint_101-200.jpg'];    
    %fprintf(fid, ['\section{ Top 50 detections }']);
    %fprintf(fid, ['\label{sec:' objname '}']);
    fprintf(fid, '\\begin{figure*}[ht]\n');   
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\begin{center}\n');
    fprintf(fid, ['\\includegraphics[width=\\linewidth]{' test_imgname '}\n']);
    fprintf(fid, '\\end{center}\n');
    fprintf(fid, ['\\caption{Top 50 detections} \n']);
    fprintf(fid, '\\end{figure*}\n');  
    fprintf(fid, '\n\n\n');
end   


fprintf(fid, '\\end{document}\n');

fclose(fid);
  
currdir=pwd;
cd(pdfdir);   
system(['pdflatex ' pdfname ]);
system(['pdflatex ' pdfname ]);
cd(currdir);
  
%catch
%    disp(lasterr); keyboard;
%end
