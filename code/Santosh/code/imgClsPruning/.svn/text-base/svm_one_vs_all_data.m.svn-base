function [libsvm_cl, err] = svm_one_vs_all_data(X,Y,Cval,bval)

try

% compute K (linear kernel)
K = X' * X ; % see kernel2.m in computeKernels (X should be D x n where D is #dims)
%K = (1+X*X').^2;
%K_test = X' * Xt;

% ignore instaces with labels as '0'
zeroinds = find(Y==0);    
Y(zeroinds,:) = [];
K(zeroinds,:) = [];
K(:,zeroinds) = [];

if isempty(bval)
    bval = 0;
end

if isempty(Cval)
    disp('picking the cval using cross-validation');
    Cval = svm_one_vs_all_pickC(K,Y,bval);
end

libsvm_cl = svmtrain(Y(:), double([(1:length(Y))' K]), [' -t 4 -s 0 -w-1 1 -w1 '...
    num2str(length(find(Y==-1))/length(find(Y==1))) ' -c ' num2str(Cval) ' -b ' num2str(bval)]) ;    

ap = mean(libsvm_cl.sv_coef(Y(libsvm_cl.SVs) > 0)) ;
am = mean(libsvm_cl.sv_coef(Y(libsvm_cl.SVs) < 0)) ;
if ap < am
    if Y(1) ~= -1, disp('critereon passed but actually Y(1) = 1?!'); keyboard; end        
    fprintf('svmflip: SVM appears to be flipped. Adjusting.\n');
    libsvm_cl.sv_coef  = - libsvm_cl.sv_coef ;
    libsvm_cl.rho      = - libsvm_cl.rho ;
end

% test it on train
scores_train = libsvm_cl.sv_coef' * K(libsvm_cl.SVs, :) - libsvm_cl.rho ;
err  = mean(scores_train .* Y' < 0);

% set a threshold
pos_vals = sort(scores_train(Y==1));
libsvm_cl.thresh = pos_vals(ceil(length(pos_vals)*0.05));        

libsvm_cl.zeroinds = zeroinds;
libsvm_cl.cval = Cval;

% useful to compute w, b (for direct testing not involving trianData matrix)
trainData = X';
SVs2 = trainData(libsvm_cl.SVs,:);
libsvm_cl.W = SVs2' * libsvm_cl.sv_coef;
%score_test = testData * libsvm_cl.W *  - libsvm_cl.rho;
        
catch
    disp(lasterr); keyboard;
end
