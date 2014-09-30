function I = myCombineNimgs(varargin)

numrows = size(varargin{1},1);
numcols = size(varargin{1},2);
numdep = size(varargin{1},3);
seplen1 = round(numrows/10);
seplen2 = round(numcols/10);

switch nargin
    case 2
        I1 = varargin{1};
        I2 = varargin{2};
        I2 = imresize(I2, [size(I1,1) size(I1,2)]);
        I = [I1 ones(numrows, seplen2, numdep) I2];
    case 4
        I1 = varargin{1};
        I2 = varargin{2};
        I3 = varargin{3};
        I4 = varargin{4};
        I2 = imresize(I2, [size(I1,1) size(I1,2)]);
        I3 = imresize(I3, [size(I1,1) size(I1,2)]);
        I4 = imresize(I4, [size(I1,1) size(I1,2)]);
        I = [I1 ones(numrows, seplen2, numdep) I2;...
            ones(seplen1,2*numcols+seplen2,numdep); ...
            I3 ones(numrows,seplen2,numdep) I4];
    case 3
        I1 = varargin{1};
        I2 = varargin{2};
        I3 = varargin{3};
        I4 = zeros(size(I1));
        I = [I1 ones(numrows, seplen2, numdep) I2;...
            ones(seplen1,2*numcols+seplen2,numdep); ...
            I3 ones(numrows,seplen2,numdep) I4];    
end        