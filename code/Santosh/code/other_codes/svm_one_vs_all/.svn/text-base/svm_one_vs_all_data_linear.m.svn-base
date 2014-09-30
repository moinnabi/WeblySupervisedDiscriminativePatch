function [libsvm_cl, err, Cval, thresh] = svm_one_vs_all_data_linear(X,Y,Cval,bval)
% X should be n x D where D is #dims
% Y should be n x 1 where n is #samples

try

% ignore instaces with labels as '0'
zeroinds = find(Y==0);    
Y(zeroinds,:) = [];
X(zeroinds,:) = [];

if isempty(bval), bval = 0; end

if isempty(Cval)
    disp('picking the cval using cross-validation');
    Cval = svm_one_vs_all_linear_pickC(X,Y,bval);
    %svm_one_vs_all_pickC
end

libsvm_cl = svmtrain(Y(:), double(X), [' -t 0 -s 0 -w-1 1 -w1 '...
    num2str(length(find(Y==-1))/length(find(Y==1))) ' -c ' num2str(Cval) ' -b ' num2str(bval)]) ;    

% test it on train
[~, ~, scores_train] = svmpredict(ones(size(X,1), 1), double(X), libsvm_cl);
scores_train = libsvm_cl.Label(1)*scores_train;
%scores_train = libsvm_cl.sv_coef' * K(libsvm_cl.SVs, :) - libsvm_cl.rho ;
err  = mean(scores_train(:) .* Y(:) < 0);

% set a threshold
pos_vals = sort(scores_train(Y==1));
thresh = pos_vals(ceil(length(pos_vals)*0.05));        
%{
libsvm_cl.zeroinds = zeroinds;
libsvm_cl.cval = Cval;
%}

catch
    disp(lasterr); keyboard;
end
