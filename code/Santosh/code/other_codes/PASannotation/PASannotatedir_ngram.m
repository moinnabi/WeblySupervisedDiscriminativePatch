function PASannotatedir_ngram 

try
    
objname = 'horse';
if ispc
    path = 'Z:';
else
    path = '/nfs/hn12/sdivvala/';
end

objngramdir = [path '/objectNgrams/results/object_ngram_data/' objname '/'];
PASdir = [path '/objectNgrams/results/object_ngramImg_finalData/'];
phrasenames = getPhraseNamesForObject(objname, objngramdir);

JPEGdir=[PASdir,'JPEGImages/'];
ANNdir=[PASdir,'Annotations/'];
ISETdir=[PASdir,'ImageSets/'];
ORGlabel='TBD';     %original label
DATstr='Google Ngram Image Database';

for f=1:numel(phrasenames)    
    disp(['DOING NGRAM ' phrasenames{f}]);
    
    % get image names
    %[ids_trn gt] = textread([ISETdir '/' phrasenames{f} '_train.txt'], '%s %d');
    %ids_trn = ids_trn(gt == 1);
    [ids_tst gt] = textread([ISETdir '/Main/' phrasenames{f} '_test.txt'], '%s %d');
    ids_tst = ids_tst(gt == 1);
    %ids = [ids_trn;ids_tst];
    ids = ids_tst;
    
    classnames={['PAS' 'baseobjectcategory_' objname]; ['PAS' phrasenames{f}]};
    
    for i=1:length(ids)
        annfile=[ANNdir,ids{i},'.txt'];
        if ~exist(annfile, 'file')
            clc;
            img=imread([JPEGdir,ids{i}, '.jpg']);
            fprintf('-- Now annotating %s, %s --\n',phrasenames{f}, ids{i});
            record=PASannotateimg_ngram(img,classnames);
            record.imgname=[ids{i} '.jpg'];
            record.database=DATstr;
            
            for j=1:length(record.objects),
                record.objects(j).orglabel=ORGlabel;
            end
            
            disp('if record and PASreadrecord(annfile) are same, then directly pass record to VOCwritexml!'); keyboard;
            %[path,name,ext]=fileparts(d(i).name);            
            comments={}; % Extra comments = array of cells (one per line)
            
            %{
            % commented on 22Jan13 (after realizing that writing to .txt and reading is redundant and directly rec can be passed to writing xml PASwriterecord(annfile,record,comments);
            annfilexml=[ANNdir,ids{i},'.xml'];
            convertTxtRecToXml(annfile, annfilexml);
            delete(annfile);
            %}                                    
            convertRecToXml(record, annfilexml);
                        
            %if exist(annfilexml,'file'), delete(annfilexml); end
            %if (~PAScmprecords(record,PASreadrecord(annfile)))
            %    PASerrmsg('Records do not match','');
            %end
        end
        
    end
end

catch
    disp(lasterr); keyboard;
end
