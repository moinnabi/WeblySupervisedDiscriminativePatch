function im = color(input)

% im = color(input)
% Convert input image to color.

if iscell(input)
    for i=1:numel(input)
        im{i} = color(input{i});
    end
    return;
end

if size(input, 3) == 1
  im(:,:,1) = input;
  im(:,:,2) = input;
  im(:,:,3) = input;
else
  im = input;
end


