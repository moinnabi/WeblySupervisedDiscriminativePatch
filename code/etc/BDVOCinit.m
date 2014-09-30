clear VOCopts

% dataset
%
% Note for experienced users: the VOC2008/9 test sets are subsets
% of the VOC2010 test set. You don't need to do anything special
% to submit results for VOC2008/9.

VOCopts.dataset= VOCYEAR;

% get devkit directory with forward slashes
%devkitroot=strrep(fileparts(fileparts(mfilename('fullpath'))),'\','/');
devkitroot = PASCALDIR;

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir=[devkitroot];

% change this path to a writable directory for your results
VOCopts.resdir=[devkitroot 'results/' VOCopts.dataset '/'];

% change this path to a writable local directory for the example code
VOCopts.localdir=[devkitroot 'local/' VOCopts.dataset '/'];

% initialize the training set

%VOCopts.trainset='train'; % use train for development
 VOCopts.trainset='train'; % use train+val for final challenge

% initialize the test set

if(~exist('testset', 'var'))
   VOCopts.testset='val'; % use validation data for development test set
else
    VOCopts.testset=testset; %'test'; % use test set for final challenge
end

% initialize main challenge paths

%Santosh_result;
VOCopts.annopath=[Santosh_result VOCopts.dataset '/Annotations/%s.xml'];
VOCopts.imgpath=[Santosh_result VOCopts.dataset '/JPEGImages/%s.jpg'];
VOCopts.imgsetpath=[Santosh_result VOCopts.dataset '/ImageSets/Main/portrait_horse_super_%s.txt'];
VOCopts.clsimgsetpath=[Santosh_result VOCopts.dataset '/ImageSets/Main/portrait_horse_super_%s_%s.txt'];
% VOCopts.imgsetpath='/homes/grail/moinnabi/datasets/PASCALVOC/VOC9990/VOCdevkit/VOC9990/ImageSets/horse/portrait_horse_super_%s.txt';
% VOCopts.clsimgsetpath='/homes/grail/moinnabi/datasets/PASCALVOC/VOC9990/VOCdevkit/VOC9990/ImageSets/horse/portrait_horse_super_%s_%s.txt';
    
VOCopts.clsrespath=[VOCopts.resdir 'portrait_horse_super/%s_cls_' VOCopts.testset '_%s.txt'];
VOCopts.detrespath=[VOCopts.resdir 'portrait_horse_super/%s_det_' VOCopts.testset '_%s.txt'];

% initialize segmentation task paths

% VOCopts.seg.clsimgpath=[VOCopts.datadir VOCopts.dataset '/SegmentationClass/%s.png'];
% VOCopts.seg.instimgpath=[VOCopts.datadir VOCopts.dataset '/SegmentationObject/%s.png'];
% 
% VOCopts.seg.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Segmentation/%s.txt'];
% 
% VOCopts.seg.clsresdir=[VOCopts.resdir 'Segmentation/%s_%s_cls'];
% VOCopts.seg.instresdir=[VOCopts.resdir 'Segmentation/%s_%s_inst'];
% VOCopts.seg.clsrespath=[VOCopts.seg.clsresdir '/%s.png'];
% VOCopts.seg.instrespath=[VOCopts.seg.instresdir '/%s.png'];
% 
% % initialize layout task paths
% 
% VOCopts.layout.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Layout/%s.txt'];
% VOCopts.layout.respath=[VOCopts.resdir 'Layout/%s_layout_' VOCopts.testset '.xml'];
% 
% % initialize action task paths
% 
% VOCopts.action.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Action/%s.txt'];
% VOCopts.action.clsimgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Action/%s_%s.txt'];
% VOCopts.action.respath=[VOCopts.resdir 'Action/%s_action_' VOCopts.testset '_%s.txt'];

% initialize the VOC challenge options

% classes

VOCopts.classes={...
    'portrait_horse_super'
    'negative'};

VOCopts.nclasses=length(VOCopts.classes);	

% poses

VOCopts.poses={...
    'Unspecified'
    'Left'
    'Right'
    'Frontal'
    'Rear'};

VOCopts.nposes=length(VOCopts.poses);

% layout parts

% VOCopts.parts={...
%     'head'
%     'hand'
%     'foot'};    
% 
% VOCopts.nparts=length(VOCopts.parts);
% 
% VOCopts.maxparts=[1 2 2];   % max of each of above parts
% 
% % actions
% 
% VOCopts.actions={...    
%     'phoning'
%     'playinginstrument'
%     'reading'
%     'ridingbike'
%     'ridinghorse'
%     'running'
%     'takingphoto'
%     'usingcomputer'
%     'walking'};
% 
% VOCopts.nactions=length(VOCopts.actions);

% overlap threshold

VOCopts.minoverlap=0.5;

% annotation cache for evaluation

VOCopts.annocachepath=[VOCopts.localdir '%s_anno.mat'];

% options for example implementations

VOCopts.exfdpath=[VOCopts.localdir '%s_fd.mat'];
