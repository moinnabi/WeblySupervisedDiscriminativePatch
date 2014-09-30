function writeFinalMontages_latent(dispdir, mimg_cell, mlab_cell)

nummaxcomp = max(prod(mysize(mimg_cell), 2));
dummyIm = zeros(10,10,3);
for k=1:nummaxcomp  %length(mimg_cell{1})
    savename = [dispdir '/montageOverIt_' num2str(k-1, '%03d') '.jpg'];
    allimgs = []; alllabs = [];
    %if ~exist(savename, 'file')    % 10Dec11: commented as the displays would be
    %updated over time as new indices are computed
    myprintf(k-1);
    for p=1:numel(mimg_cell)
        if k <= length(mimg_cell{p})
            allimgs{p} = mimg_cell{p}{k}; alllabs{p} = mlab_cell{p}{k};
        else
            allimgs{p} = dummyIm; alllabs{p} = ' ';
        end
    end
    allmim = montage_list(allimgs, 2, [0 0 0], [2500 2500 3]);
    imwrite(allmim, savename);
    %end
end
myprintfn;
