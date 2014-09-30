function removeEmptyFiles(folder, str)
% removeEmptyFiles(folder, str)

files = dir(fullfile(folder, str));
fn = {files.name};
for k = 1:numel(fn)
  if files(k).bytes==0
    disp(['Deleting ' fn{k}]);
    delete(fullfile(folder, fn{k}));
  end
end
   
