function feats = getHOGFeaturesFromWarpImg(neg, fsize, sbin, biasval, domode)

%disp('reading images');
%warped = warppos_img(neg, fsize, sbin);
warped = warppos_img_noBdrAdded(neg, fsize, sbin);
%disp('computing features');
feats = cell(length(neg),1);
parfor i = 1:length(neg)
    %myprintf(i,100);
    hogfeat = features(double(warped{i}), sbin);
    if domode == 2
        hogfeat2 = features(double(warped{i}), sbin/2);
        feats{i} = [hogfeat(:); hogfeat2(:); biasval];
    elseif domode == 1
        feats{i} = [hogfeat(:); biasval];
    end
end
%myprintfn;

%{
            %warped = warppos_img(pos, fsize, sbin);
            warped = warppos_img_noBdrAdded(pos, fsize, sbin);
            feats = cell(length(pos),1);
            for i = 1:length(pos)
                hogfeat = features(double(warped{i}), sbin);
                hogfeat2 = features(double(warped{i}), sbin/2);
                %feats{i} = [hogfeat(:); biasval];
                feats{i} = [hogfeat(:); hogfeat2(:); biasval];
            end
            %}

%{
    warped = warppos_img(neg, fsize, sbin);
    disp('computing features');
    for i = 1:length(neg)
        myprintf(i,100);
        hogfeat = features(double(warped{i}), sbin);
        feats{i} = [hogfeat(:); biasval];
    end
    %}   

