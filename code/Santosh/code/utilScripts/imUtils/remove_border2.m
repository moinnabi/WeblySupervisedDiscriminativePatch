function [image,valid_pixels] = remove_border2(image, boundary_width, color);

%like remove_border, but boundary_width is now a vector, specifying the
%amount of y and x border to color out

%simply whites out the border of the image.  Called in texture_match when
%displaying the original image.
height = size(image,1);
width = size(image,2);

image(1:boundary_width(1), :,:)             = color;
image(:, 1:boundary_width(2),:)             = color;
image(height-boundary_width(1)+1:height,:,:)  = color;
image(:,width-boundary_width(2)+1:width,:)    = color;

valid_pixels = (width-(boundary_width(2)*2)) * (height-(boundary_width(1)*2));