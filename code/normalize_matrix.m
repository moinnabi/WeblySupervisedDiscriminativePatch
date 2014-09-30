function matrix_normal = normalize_matrix(matrix)
% normalize a matrix along columns

matrix_normal = zeros(size(matrix,1), size(matrix,2));

for column = 1:size(matrix,2)
    
    vector = matrix(:,column);
    vector_norm = normallize_vector(vector);
    matrix_normal(:,column) = vector_norm;
   
end

function vector_norm = normallize_vector(vector)
%vector should be horizontal

vector_norm = zeros(1,length(vector));
ma = max(vector);
mi = min(vector);

for i = 1:length(vector)
    if ma-mi == 0
        vector_norm(1,i) = 0 ;
    else
    vector_norm(1,i) = 1 - ((ma-vector(i))/(ma-mi));
    end
end



    
    