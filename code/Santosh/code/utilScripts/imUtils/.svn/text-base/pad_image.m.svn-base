function output_image = pad_image(input_image, y, x, bg_color)

%pads the bottom and right hand side of an image by the specified amount in
%the specified color

if(~exist('bg_color', 'var'))
    bg_color = [1 1 1];
end
output_image = ones( size(input_image,1) + y, size(input_image,2) + x, 3);

output_image(:,:,1) = output_image(:,:,1) * bg_color(1);
output_image(:,:,2) = output_image(:,:,2) * bg_color(2);
output_image(:,:,3) = output_image(:,:,3) * bg_color(3);

output_image(1:size(input_image,1), 1:size(input_image,2), :) = input_image;