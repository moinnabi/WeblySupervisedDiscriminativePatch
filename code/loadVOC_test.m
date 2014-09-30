function [voc,ids] = loadVOC_test(voc_dir,year,val_test)

%Initial parameter
VOC_root = [voc_dir,'VOC',year,'/VOCdevkit'];
run([VOC_root '/VOCinit.m']);

%addpath([VOC_root '/VOCcode']);
%VOCinit; %set for 2007
%year = '2007';
% i =13; %horse
% cls=VOCopts.classes{i};


%Load Positive
  [ids,gt]=textread(sprintf(VOCopts.imgsetpath,val_test),'%s %d');
  voc    = [];
  dataid   = 0;
  for i = 1:length(ids);
      voc(i).im     = sprintf(VOCopts.imgpath, ids{i});
      voc(i).flip   = false;
      dataid = dataid +1;
      voc(i).dataid = dataid;    
  end