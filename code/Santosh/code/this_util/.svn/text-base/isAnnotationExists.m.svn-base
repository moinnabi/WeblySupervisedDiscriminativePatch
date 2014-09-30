function retval = isAnnotationExists(VOCopts, postag)

if nargin < 2
    postag = 'NOUN';
end

if strcmp(postag, 'NOUN')
    [gtids,t]=textread(sprintf(VOCopts.imgsetpath,VOCopts.testset),'%s %d');
elseif strcmp(postag, 'VERB')
    [gtids,t]=textread(sprintf(VOCopts.action.imgsetpath, VOCopts.testset), '%s %d');
end

% check some random file in the testset exists or not
% if it exists, then there is anotation available
retval = exist(sprintf(VOCopts.annopath,gtids{10}), 'file');
