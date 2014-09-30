function [models skipped]= load_candidate_models(cls)
% returns random, initial part models
   
%WORKDIR = ['/projects/grail/moinnabi/eccv14/data/bcp_elda/'];
%basedir = ['/projects/grail/moinnabi/eccv14/'];
% BDglobals;
% VOCinit;

VOCopts.localdir = fullfile('/projects/grail/moinnabi/eccv14/data/bcp_elda');

basedir = sprintf('%s/object_exemplars/%s', VOCopts.localdir, cls);

data = dir(fullfile(basedir, 'exemplar*.mat'));

%candidate_dir = fullfile('/projects/grail/moinnabi/eccv14/data/bcp_elda/', 'candidates', cls);

start = tic;

skipped = zeros(1,length(data));

for i = 1:length(data)
   if(toc(start)>5)
      fprintf('%d/%d\n', i, length(data));
      start = tic;
   end
   if(~exist(fullfile(candidate_dir, data(i).name)))
       skipped(i) = 1;
   end
     mtmp = load(fullfile(basedir, data(i).name));
     models{i} = mtmp.m.model;
     models{i}.name = data(i).name;

      models{i} = convert_part_model(convert_part_model(models{i})); % Remove extra fields

   %if(object_level)
   %   models{i}.spat_const = [0 1 0 1 0.8 1];
   %end
   models{i}.spat_const = [0 1 0.8 1 0 1];
end

%models = models(~skipped);
