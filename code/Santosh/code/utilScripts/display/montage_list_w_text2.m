function montage_image_text = montage_list_w_text2(scene_match_files, ...
    scene_match_labels, mode, montage_title, background_color, montage_dimensions, montage_tiles_xy)
%instead of montaging a dir, it will accept a cell array of image paths and
%a cell array of text annotations to put underneath each image.  No
%duplicate checking or stuff like that.
%% some part was getting cut at the bottom, so updating it - 16nov09

%the text entries probably need to be fairly short.

if(~exist('background_color') | isempty(background_color))
    %background_color = [1 1 1];
    background_color = [0 0 0];     % DSK 26Jan12
end

if(~exist('montage_title', 'var') | isempty(montage_title))
    montage_title = '';
end
%fprintf('Creating montage for cluster titled: %s\n', montage_title);

if(size(scene_match_files,1) ~= size(scene_match_labels,1))
    fprintf('error, unequal number of images and labels\n');
    return
end

%num_images      = size(scene_match_files,1);
num_images      = length(scene_match_files);
if(~exist('montage_tiles_xy') | isempty(montage_tiles_xy))
    montage_tiles_x = ceil(sqrt(num_images));
    montage_tiles_y = ceil(num_images / montage_tiles_x);    
else
    montage_tiles_y = montage_tiles_xy(1);
    montage_tiles_x = montage_tiles_xy(2);
end
tfontsize = 50/montage_tiles_y;
%tfontsize = 200/montage_tiles_y;

whitespace = 15; %half of the number of pixels of white space to put between everything

if(~exist('montage_dimensions', 'var'))
    montage_dimensions = [montage_tiles_y * 220, montage_tiles_x * 220, 3];
end

montage_width  = floor(montage_dimensions(2)/montage_tiles_x); %this is width of each image in the montage;
montage_height = floor(montage_dimensions(1)/montage_tiles_y);
scene_match_imgs = cell(num_images, 1);


for i = 1:num_images
    if mode == 1
        current_filename = scene_match_files{i};        
        current_image = single(imread(current_filename))/255;
    elseif mode == 2
        %current_image = single(scene_match_files{i})/255;
        current_image = single(im2double(scene_match_files{i}));    % updated by DSK on 16Nov09
        %current_image = scene_match_files{i};
    end

    current_image = preserve_aspect_resize(current_image, [montage_height-2*whitespace montage_width-2*whitespace], 'bilinear');

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
montage_image_text = ones(size(montage_image,1) + 20, size(montage_image,2)+20,3); %some extra padding to cut off later

try
    close(512)
catch
    
end

figure(512)
imagesc(montage_image_text)
%fillscreen;
pause(.01)
for i = 1:num_images
    start_x = round(mod((i-1), montage_tiles_x) * montage_width + 1);
    start_y = round((floor((i-1)/montage_tiles_x)) * montage_height + 1);
    end_x = round(start_x + montage_width - 1);
    end_y = round(start_y + montage_height - 1);
    montage_image( start_y:end_y, start_x:end_x, : ) = scene_match_imgs{i};
    
    % changed on 6Dec11 to allow larger captions
    %t_handle = text(round((start_x + end_x)/2 ) - 20, end_y + 1, scene_match_labels{i});
    t_handle = text(start_x + 1, end_y + 1, scene_match_labels{i});
    set(t_handle, 'FontSize', tfontsize);
end

pause(.01) %to let the GUI catch up
clear montage_image_text
mysaveas('tmp.jpg');
%set(gca, 'position', [0 0 1 1], 'visible', 'off')
%saveas(gcf, fname);
 %set(gcf, 'paperpositionmode', 'auto');
 %print(gcf, '-dpng', '-noui', 'tmp.png')
 %img = imread('tmp.png');
%img = getimage(gcf);
%img=print2array(gcf,3);
img = imread('tmp.jpg');
%disp('try export_fig'); keyboard;
%set(gca, 'position', [0 0 1 1], 'visible', 'off');
%img = export_fig;
img = imresize(img, [size(montage_image,1)+20 size(montage_image,2)+20]);

%montage_image_text = double(frame2im(getframe))/255; %unknown size
montage_image_text = double(img)/255; %unknown size

montage_image = padarray(montage_image, [20 20], 1, 'post');
try
    montage_image_text =  montage_image_text .* montage_image;    
catch
    fprintf('assignment mismatch, probably because there were too many images in this cluster to display at once\n');
    disp('here'); keyboard;
    montage_image_text = montage_image;
end
    
try
    close(512)
catch
    
end

%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(montage_title) & 1
% append title to the top of the montage
%montage_title_img = ones(35 ,montage_dimensions(2)+20, 3);

montage_image_text = padarray(montage_image_text, [50 0], 1, 'pre');

montage_title_img = ones(size(montage_image,1) + 50 + 20, size(montage_image,2)+20,3); %some extra padding to cut off later
%montage_title_img = ones(343, 435, 3);
figure(515)
imagesc(montage_title_img)
%collen = montage_dimensions(2)+20;
%t_handle = text(startpos, 30, montage_title);
t_handle = text(10, 30, montage_title);
set(t_handle, 'FontSize', tfontsize+10);
pause(.1) %to let the GUI catch up
clear montage_title_img
%montage_title_img = double(frame2im(getframe))/255; %unknown size
%montage_title_img = montage_title_img(75:110, :,:);
%montage_title_img = padarray(montage_title_img, [0 (montage_dimensions(2)+20-size(montage_title_img,2))/2 0]);
%montage_title_img = imresize(montage_title_img, [35 montage_dimensions(2)+20]);
tmpfname = [tempname '.jpg'];
mysaveas(tmpfname);
%print(gcf, '-djpeg', tmpfname);
img = imread(tmpfname);
delete(tmpfname);
img = imresize(img, [size(montage_image_text,1) size(montage_image_text,2)]);
montage_title_img = double(img)/255; %unknown size

% try
%     montage_title_img = montage_title_img(1:35, 1:montage_dimensions(2)+20, 1:3);
% catch
%     fprintf('montage_title_img was too small some how?  setting to zeros\n')
%     montage_title_img = ones(35 ,montage_dimensions(2)+20, 3);
% end

try
    montage_image_text = montage_title_img .* montage_image_text;
    %montage_image_text = cat(1, montage_title_img, montage_image_text);    
    %montage_image_text = cat(1, montage_image_text, montage_title_img);
catch
    whos
    fprintf('assignment mismatch while appending the title text\n');
end

try
    close(515)
catch
    
end
pause(.01) %to let the GUI catch up
end

