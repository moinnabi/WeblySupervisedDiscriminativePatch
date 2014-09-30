function output_image = pad_image2(input_image, y, x, bg_color)

%pads all sides of an image by the specified amount in
%the specified color

%try
if(~exist('bg_color', 'var'))
    bg_color = [1 1 1];
end
output_image = ones( size(input_image,1) + 2*y, size(input_image,2) + 2*x, 3);

output_image(:,:,1) = output_image(:,:,1) * bg_color(1);
output_image(:,:,2) = output_image(:,:,2) * bg_color(2);
output_image(:,:,3) = output_image(:,:,3) * bg_color(3);

output_image(y+[1:size(input_image,1)], x+[1:size(input_image,2)], :) = input_image;

%catch
%    disp(lasterr); keyboard;
%end
