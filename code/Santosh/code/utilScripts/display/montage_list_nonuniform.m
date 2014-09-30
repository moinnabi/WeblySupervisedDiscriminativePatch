function montage_image = montage_list_nonuniform(scene_match_files, mode, background_color, montage_dimensions, montage_tiles_xy)
%instead of montaging a dir, it will accept a cell array of image paths and
%a cell array of text annotations to put underneath each image.  No
%duplicate checking or stuff like that.

if(~exist('background_color','var'))
    background_color = [1 1 1];
end

num_images      = length(scene_match_files);

if(~exist('montage_tiles_xy') | isempty(montage_tiles_xy))
    montage_tiles_x = ceil(sqrt(num_images));
    montage_tiles_y = ceil(num_images / montage_tiles_x);    
else
    montage_tiles_y = montage_tiles_xy(1);
    montage_tiles_x = montage_tiles_xy(2);
end
% montage_tiles_x = 5;    % CHANGED FROM 10 TO 5
% montage_tiles_y = ceil(num_images / 5);

whitespace = 6; %half of the number of pixels of white space to put between everything

if(~exist('montage_dimensions', 'var'))  | isempty(montage_dimensions)
    montage_dimensions = [montage_tiles_y * 1000, montage_tiles_x * 1000, 3];
    %montage_dimensions = [montage_tiles_y * 120, 1500, 3]; 
end 

montage_width  = floor(montage_dimensions(2)/montage_tiles_x); %this is width of each image in the montage;
montage_height = floor(montage_dimensions(1)/montage_tiles_y);
scene_match_imgs = cell(num_images, 1);

for i = 1:num_images
    if mode == 1
        current_filename = scene_match_files{i};
        current_image = single(imread(current_filename))/255;
    elseif mode == 2
        current_image = single(im2double(scene_match_files{i}));
        %current_image = scene_match_files{i};
    end    
    if mod(i,2) == 0    % even
        current_image = preserve_aspect_resize(current_image, [montage_height-2*whitespace 0.5*montage_width-2*whitespace], 'bilinear');
    else                % odd
        current_image = preserve_aspect_resize(current_image, [montage_height-2*whitespace 1.5*montage_width-2*whitespace], 'bilinear');
    end

    padded_image = ones([montage_height montage_width 3]);
    padded_image(:,:,1) = padded_image(:,:,1) * background_color(1);
    padded_image(:,:,2) = padded_image(:,:,2) * background_color(2);
    padded_image(:,:,3) = padded_image(:,:,3) * background_color(3);
    if(size(current_image,3) == 3)
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, :) = current_image;
    else
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, 1) = current_image;
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, 2) = current_image;
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, 3) = current_image;
    end

    scene_match_imgs{i} = padded_image;
end

montage_image = ones(montage_dimensions);
for i = 1:num_images
    start_x = round(mod((i-1), montage_tiles_x) * montage_width + 1);
    start_y = round((floor((i-1)/montage_tiles_x)) * montage_height + 1);
    end_x = round(start_x + montage_width - 1);
    end_y = round(start_y + montage_height - 1);

    montage_image( start_y:end_y, start_x:end_x, : ) = scene_match_imgs{i};
end
