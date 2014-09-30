function context_train_allboxessepdiff_wsup(cachedir, train_set, train_year, gtruthname, phrasenames, CLSFR, thiscls)

% from context_train_allboxessep_wsup: diff subset per ngram

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;
if nargin < 7, thiscls = []; end;

disp(['context_train_allboxessepdiff_wsup(''' cachedir ''',''' train_set ''',''' train_year ''',''' gtruthname ''''', phrasenames '','''  num2str(CLSFR) ''',''' thiscls ')' ]);

%if isscalar(phrasenames) && phrasenames == 0
%    load([],'phrasenames');
%end
    
numcls = length(phrasenames);
if ~isempty(thiscls), cls_inds = strmatch(thiscls, phrasenames, 'exact');
else cls_inds = 1:numcls; end
%cls_inds = 1:numcls;
%cls_inds = strmatch(cls, phrasenames, 'exact');

disp('Get training data');
[ds_all, bs_all, XX] = context_data_wsup(cachedir, train_set, train_year, cls_inds, phrasenames);
ids = textread(sprintf(conf.pascal.VOCopts.imgsetpath, train_set), '%s');

if CLSFR == 2
    clsfrtype = 'KLogReg';
elseif CLSFR == 4
    clsfrtype = 'SVRolap';
elseif CLSFR == 5
    clsfrtype = 'KSVMSIG';
elseif CLSFR == 6
    clsfrtype = 'KLinReg';
elseif CLSFR == 1
    clsfrtype = 'KSVMnoSIG';
elseif CLSFR == 3
    clsfrtype = 'LSVMnoSIG';
elseif CLSFR == 7
    clsfrtype = 'LSVMLRank';
elseif CLSFR == 8
    clsfrtype = 'LSVMPAUC';
elseif CLSFR == 10
    clsfrtype = 'KSVMLRank';
elseif CLSFR == 9
    clsfrtype = 'KSVMPAUC';
end

if strcmp(train_set, 'val2')
    savecode = 'context';
elseif strcmp(train_set, 'val1')
    savecode = 'val1context';
end
gtsubdir = '75percent';

for c = cls_inds
  cls = phrasenames{c};
  savaname = [cachedir '/../' cls '/' cls '_' savecode '_' clsfrtype '_' gtruthname];
  fprintf('Training context rescoring classifier for %s\n', cls);    
  try
      load(savaname);
  catch                        
      disp([' Get labels for the training data for class ' cls]);
      [YY YYolap] = context_labelssep_wsup(cachedir, gtruthname, ds_all{c}, train_set, train_year, cls, gtsubdir);
      
      disp(' doing string match');
      if strcmp(train_set, 'val2')
          disp('supervised');                    
          [thisids, ~] = textread(sprintf(conf.pascal.VOCopts.clsimgsetpath, gtruthname, 'test'), '%s %d');
          thisinds = logical(doStringMatch(ids, thisids));
      elseif strcmp(train_set, 'val1')
          disp('unsupervised');                              
          [thisids, tgt] = textread(sprintf(conf.pascal.VOCopts.clsimgsetpath, gtruthname, 'train'), '%s %d');
          thisids = thisids(tgt == 1);
          thisinds = logical(doStringMatch(ids(1:end-500), thisids));   %-500 as last 500 images are neg from val
          thisinds = [thisinds; true(500,1)];                  % use pos from thisids and neg from val
      end
      
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
          %model = doHardMining(Y, X, 10);
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
      elseif CLSFR == 7
          disp('doing linear svm_light rank');
          Qid = ones(size(X,1),1);
          Yrank = Y;
          Yrank(Y==1) = 2;
          Yrank(Y==-1) = 1;
          model = pasTrainLinearSvmLight_rank(X,Yrank,Qid,['-t 0 -c ' num2str(1) ' -j 2 -e 0.001 -m 500']);
      elseif CLSFR == 8
          disp('doing linear svm perf with aucorc');          
          %model = pasTrainLinearSvm_light(X,Y,'-z c -t 1 -s 1 -r 1 -d 3 -c 1 -j 2 -e 0.001 -m 500');    % params for nonlinear svm that match libsvm
          %model = pasTrainLinearSvm_light(X,Y,'-z c -t 0 -c 1 -j 2 -e 0.001 -m 500');
          model = pasTrainLinearSvm_perfNoCV(X,Y,['-t 0 -c ' num2str(0.01*size(X,1)/100) ' -l 10 -e 0.001 -m 500']);          
      elseif CLSFR == 10
          disp('doing kernel svm_light rank');
          Qid = ones(size(X,1),1);
          Yrank = Y;
          Yrank(Y==1) = 2;
          Yrank(Y==-1) = 1;
          model = pasTrainKernelSvmLight_rank(X,Yrank,Qid,['-t 1 -s 1 -r 1 -d 3 -c ' num2str(1) ' -j 2 -e 0.001 -m 500']);
      elseif CLSFR == 9
          disp('doing kernel svm perf with aucorc');          
          model = pasTrainKernelSvm_perfNoCV(X,Y,['-t 1 -s 1 -r 1 -d 3 -c ' num2str(0.01*size(X,1)/100) ' -l 10 -e 0.001 -m 500']);
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
      elseif CLSFR == 7
          s = X*model.w;
      elseif CLSFR == 8
          s = X*model.w;
      elseif CLSFR == 9
          s = pasTestKernelSvm_perfNoCV(X,model);
      elseif CLSFR == 10
          s = pasTestKernelSvmLight_rank(X,model);
      end
            
      load([cachedir gtruthname '_gt_anno_' train_set '_' train_year], 'npos');
      roc = computeROC(s, Y);
      roc.r = roc.r*roc.tp(end)/npos;
      roc.ap = averagePrecision(roc, (0:0.1:1));
      disp([' training acc is ' num2str(roc.ap)]);
            
      save(savaname, 'model', 'roc');
  end
end

catch
    disp(lasterr); keyboard;
end
