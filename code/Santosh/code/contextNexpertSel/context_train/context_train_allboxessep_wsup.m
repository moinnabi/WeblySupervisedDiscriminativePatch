function context_train_allboxessep_wsup(cachedir, train_set, train_year, gtruthname, phrasenames, CLSFR, thiscls)

% from context_train but for ngram data
% %% main change is that cls is "horse" while gtruthname is "base_horse" as
% gtrtuh for horse is named so

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;
if nargin < 7, thiscls = []; end;

%diary([cachedir '/diaryoutput_contextRescore_train.txt']);
disp(['context_train_allboxessep_wsup(''' cachedir ''',''' train_set ''',''' train_year ''',''' gtruthname ''''', phrasenames '','''  num2str(CLSFR) ''',''' thiscls ')' ]);

IGNOREBADONES = 1;
trainaccthresh = 0.25;
disp('IGNOREBADONES is on'); keyboard;

numcls = length(phrasenames);

% get training accuracies
trainaps = zeros(numcls,1);
for ii=1:numcls
    myprintf(ii, 10);
    tmppr = load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_prpos_' train_set '_' train_year '.mat'], 'ap');
    trainaps(ii) = tmppr.ap;
end
myprintfn;

if ~isempty(thiscls)
    cls_inds = strmatch(thiscls, phrasenames, 'exact');
else
    if IGNOREBADONES                
        % only pass those above a threshold       
        cls_inds = find(trainaps>trainaccthresh)';
    else
        cls_inds = 1:numcls;
    end
    disp(['Doing a total of ' num2str(numel(cls_inds)) ' ngrams']);
end

disp('Get training data');
[ds_all, bs_all, XX] = context_data_wsup(cachedir, train_set, train_year, cls_inds, phrasenames);
ids = textread(sprintf(conf.pascal.VOCopts.imgsetpath, train_set), '%s');

if CLSFR == 2
    clsfrtype = 'KLogReg';
elseif CLSFR == 4
    clsfrtype = 'SVRolap';
elseif CLSFR == 3
    clsfrtype = 'LSVMnoSIG';
elseif CLSFR == 5
    clsfrtype = 'KSVMSIG';
elseif CLSFR == 6
    clsfrtype = 'KLinReg';
elseif CLSFR == 1
    clsfrtype = 'KSVMnoSIG';
end

if strcmp(train_set, 'val2')
    gtsubdir = '';
    savecode = [gtsubdir 'context'];
elseif strcmp(train_set, 'val1')
    gtsubdir = 'p33tn';
    savecode = [gtsubdir 'val1context'];
end

if IGNOREBADONES
    disp(' find the bad ngrams and remove them');
    bad_inds = find(trainaps<trainaccthresh)';
    badids = cell(numcls,1);
    for ii=bad_inds        
        [tmpids, tgt] = textread(sprintf(conf.pascal.VOCopts.clsimgsetpath, phrasenames{ii}, 'train'), '%s %d');
        badids{ii} = tmpids(tgt == 1);
    end
    
    % for remaining ngrams, discard the images marked as difficult
    good_inds = find(trainaps>trainaccthresh)';
    diffids = cell(numcls,1);
    for ii=good_inds
        diffids{ii} = write_ground_truth([cachedir '/../' phrasenames{ii} '/'], phrasenames{ii}, [], train_set, train_year);
    end
    
    badids = [badids; diffids];
    thisinds = ~logical(doStringMatch(ids(1:end-500), cat(1,badids{:})));   %-500 as last 500 images are neg from val
    thisinds = [thisinds; true(500,1)];                  % use pos from thisids and neg from val
else
    thisinds = 1:numel(ids);
end

for c = cls_inds
  cls = phrasenames{c};
  savaname = [cachedir '/../' cls '/' cls '_' savecode '_' clsfrtype '_' gtruthname];
  fprintf('Training context rescoring classifier for %s\n', cls);    
  try
      load(savaname);
  catch
      disp([' Get labels for the training data for class ' cls]);
      [YY YYolap] = context_labelssep_wsup(cachedir, gtruthname, ds_all{c}, train_set, train_year, cls, gtsubdir);
                          
      disp(' Collect training feature vectors and labels into a single matrix and vector');
      X = cell2mat(XX(c,thisinds)');
      Y = cell2mat(YY(thisinds));
      Yolap = cell2mat(YYolap(thisinds));
      
      disp(' Remove dont care examples');
      I = find(Y == 0);
      Y(I) = [];
      Yolap(I) = [];
      X(I,:) = [];
      
      % Train the rescoring SVM
      if CLSFR == 1
          disp('doing non linear (polynomial) svm');
          model = svmtrain(Y, X, '-s 0 -t 1 -g 1 -r 1 -d 3 -c 1 -w1 2 -e 0.001 -m 500');
      elseif CLSFR == 5
          disp('doing non linear (polynomial) svm with prob');
          model = svmtrain(Y, X, '-s 0 -t 1 -g 1 -r 1 -d 3 -c 1 -w1 2 -e 0.001 -m 500 -b 1');
      elseif CLSFR == 2
          disp('doing non linear (polynomial) logreg');
          % select subset
          posinds = find(Y==1);
          neginds = find(Y==-1);
          randinds = [posinds; neginds(randperm(length(neginds), min(2000,length(neginds))))];
          
          Xtrn = X(randinds,:);
          Ytrn = Y(randinds,:);
          Kpoly = (1+Xtrn*Xtrn').^2;  %Kpoly = kernelPoly(X,X,2);
          %funObj = @(u)LogisticLoss(u,Kpoly,Y);
          %model = minFunc(@penalizedKernelL2, zeros(size(X,1),1), options, Kpoly, funObj, 1e-2);
          %model = fminunc(funObj, zeros(size(X,1),1), options); % does medium-scale (good for < 1000 vars)
          funObj = @(u)penalizedLogisticLoss_yMergedwithW(u,Kpoly,Ytrn,1e-2);          
          options = optimset('GradObj','on','Hessian','on');
          model.w = fminunc(funObj, zeros(size(Xtrn,1),1), options);
          model.X = Xtrn;
      elseif CLSFR == 3
          disp('doing linear svm');
          model = svmtrain(Y, X, '-s 0 -t 0 -c 1 -w1 2 -e 0.001 -m 500');
      elseif CLSFR == 4
          disp('doing sv regression');
          Yolap(Yolap == -Inf) = 0;
          posinds = find(Y==1);
          neginds = find(Y==-1);
          randinds = [posinds; neginds(randperm(length(neginds), min(2000,length(neginds))))];
          model = svmtrain(Yolap(randinds,:), X(randinds,:), '-s 3 -t 1 -g 1 -r 1 -d 6 -p 0.1 -c 1 -e 0.001 -m 500');
      elseif CLSFR == 6
          disp('doing linear kernel regression');
          Yolap(Yolap == -Inf) = 0;
          
          posinds = find(Y==1);
          neginds = find(Y==-1);
          randinds = [posinds; neginds(randperm(length(neginds), min(4000,length(neginds))))];
          
          Xtrn = X(randinds,:);
          Yolaptrn = Yolap(randinds,:);
          
          %model = polyfitn(X, Yolap, 2);   % rank issues and gives bad result
          %model = X\Yolap;                 % does well but doesnt beat ksvm          
          Kpoly = (1+Xtrn*Xtrn').^2;
          %model = Kpoly\Yolap;     % rank issues and gives bad result
          model.w = pinv(Kpoly)*Yolaptrn;  % takes too long and crashes due to memory                    
          model.X = Xtrn;
      end
      
      % compute training acc      
      s = [];
      if CLSFR == 1 || CLSFR == 3          
          [~, ~, s] = svmpredict(ones(size(X,1), 1), X, model);
          s = model.Label(1)*s;          
      elseif CLSFR == 5
          [~, ~, s] = svmpredict(ones(size(X,1), 1), X, model, '-b 1');
          s = s(:,model.Label == 1);
      elseif CLSFR == 2
          %s = 1./(1+exp(-Kpoly*model.w));
          s = zeros(size(X,1),1);
          for ii=1:size(X,1)
              kvect = (1 + model.X * X(ii,:)').^2;
              s(ii) = 1./(1+exp(- model.w' * kvect));
          end
      elseif CLSFR == 4
          %s = polyvaln(model, X);
          %s = X*model;          
          [~, ~, s] = svmpredict(ones(size(X,1), 1), X, model);
          %s = model.Label(1)*s;
      elseif CLSFR == 6
          s = model.w' * (1+model.X*X').^2;
      end
            
      load([cachedir gtruthname '_gt_anno_' train_set '_' [gtsubdir train_year]], 'npos');
      roc = computeROC(s, Y);
      roc.r = roc.r*roc.tp(end)/npos;
      roc.ap = averagePrecision(roc, (0:0.1:1));
      disp([' training acc is ' num2str(roc.ap)]);
      
      save(savaname, 'model', 'roc');
  end
end

diary off;

catch
    disp(lasterr); keyboard;
end
