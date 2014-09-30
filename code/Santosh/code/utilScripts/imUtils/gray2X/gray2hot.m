function jet_image = gray2hot(image, normalize)
%like gray2jet, but keeps the minimum value zero (black)

if(size(image,3) > 1)
    image = rgb2gray(image);
end

if(~exist('normalize', 'var'))
    normalize = 1;
end

if(normalize)
    image_min = min(min(image));
    image = image - image_min;

    image_max = max(max(image));
    if(image_max < .00001)
        image_max = .00001;
    end
    image = image./image_max;
end

%calling the jet command opens a window or changes the colormap, so lets
%just hard code it here.
hot_colormap = hot(100);

jet_image = interp1( 0:99, hot_colormap, image*99, 'linear');