function im = myvisualizeW(w)
% from visualizemodel

pad = 2; bs = 20;
w = foldHOG(w);
scale = max(w(:));
im = HOGpicture(w, bs);
im = imresize(im, 2);
im = padarray(im, [pad pad], 0);
im = uint8(im * (255/scale));
