function acc = svm_one_vs_all_cval_linear(X,Y,Cval,bval)

% ignore instaces with labels as '0'
zeroinds = find(Y==0);    
Y(zeroinds,:) = [];
X(zeroinds,:) = [];

% do 3 fold cross validation
%%% NOTICE THE -v 3 option
%acc = svmtrain(Y(:), double([(1:length(Y))' K]), [' -t 4 -s 0 -v 3 -w-1 1 -w1 '...
%    num2str(length(find(Y==-1))/length(find(Y==1))) ' -c ' num2str(Cval) ' -b ' num2str(bval)]) ;
acc = svmtrain(Y(:), double(X), [' -t 0 -s 0 -v 3 -w-1 1 -w1 '...
    num2str(length(find(Y==-1))/length(find(Y==1))) ' -c ' num2str(Cval) ' -b ' num2str(bval)]) ;    
