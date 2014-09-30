function Y = resize3DMat(Y,X)
% this function takes a 3D matrix Y and resizes to have same size as
% another 3D matrix X

%{
% this version is no faster
if size(X,1) ~= size(Y,1) || size(X,2) ~= size(Y,2)     % if both do not have same dimensions
    siz = [size(X,1) size(X,2)];
    for i=1:size(X,3)
        % assigning it to X as I don't want to assign fresh memory and X is
        % not being used here anyway (but as per good code practice you
        % should actually do this!)
        X(:,:,i) = imresize(Y(:,:,i), [siz(1) siz(2)], 'nearest');
    end    
end
Y = X;
%}

%%{
if size(X,1) ~= size(Y,1) || size(X,2) ~= size(Y,2)     % if both do not have same dimensions
    Yr = zeros(size(X), class(X));
    siz = [size(X,1) size(X,2)];
    for i=1:size(X,3)
        Yr(:,:,i) = imresize(Y(:,:,i), [siz(1) siz(2)], 'nearest');
    end
    Y = Yr;
    clear Yr;
end
%%}
