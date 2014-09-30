function img = overlaySegmentation(img,segmentation)
% img = overlaySegmentation(img,segmentation)
%
% Overlay segmentation boundaries on image.
%
% Inputs:
% img - Input image.
% segmentation - Segmentation mask.  Regions that are set to zero will
%   not have their boundaries displayed.
%
% Outputs:
% img - Image with segmentation boundaries overlayed.

%Color = [255 0 0];
Color = [0 255 0];  % make it green 

% Make sure img and segmentation are the same size:
if (size(img,1)~=size(segmentation,1)) || (size(img,2)~=size(segmentation,2))
  segmentation = imresize(segmentation,[size(img,1) size(img,2)],'nearest');
end

% Convert img to RGB if grayscale:
if size(img,3)~=3
  img(:,:,2) = img(:,:,1);
  img(:,:,3) = img(:,:,1);
end

segmentation = padarray(segmentation,[2 2],0,'both');
bw = edge(segmentation);
bw = imdilate(bw,ones(5));
bw = bw(3:end-2,3:end-2);
n = find(bw(:));
img(n) = Color(1);
img(n+size(img,1)*size(img,2)) = Color(2);
img(n+2*size(img,1)*size(img,2)) = Color(3);
