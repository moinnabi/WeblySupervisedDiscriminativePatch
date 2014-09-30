function writeFinalMontages_latent2(dispdir, mimg_init, mlab_init, mimg_lrs1, mlab_lrs1, ...
    mimg_lrs21, mlab_lrs21, mimg_lrs22, mlab_lrs22, mimg_lrs23, mlab_lrs23, ...
    mimg_lrs2, mlab_lrs2, mimg_mix, mlab_mix, mimg_f, mlab_f)

for k=1:length(mimg_init)
    savename = [dispdir '/montageOverIt_' num2str(k-1) '.jpg'];
    allimgs = []; alllabs = [];
    %if ~exist(savename, 'file')    % 10Dec11: commented as the displays would be
    %updated over time as new indices are computed
        myprintf(k-1);
        p=1;
        allimgs{p} = mimg_init{k}; alllabs{p} = mlab_init{k};
        if nargin > 3 && ~isempty(mimg_lrs1)
            p = p + 1;
            allimgs{p} = mimg_lrs1{k}; alllabs{p} = mlab_lrs1{k};
        end
        if nargin > 5 && ~isempty(mimg_lrs21)
            p = p + 1;
            allimgs{p} = mimg_lrs21{k}; alllabs{p} = mlab_lrs21{k};
        end
        if nargin > 7 && ~isempty(mimg_lrs22)
            p = p + 1;
            allimgs{p} = mimg_lrs22{k}; alllabs{p} = mlab_lrs22{k};
        end
        if nargin > 9 && ~isempty(mimg_lrs23)
            p = p + 1;
            allimgs{p} = mimg_lrs23{k}; alllabs{p} = mlab_lrs23{k};
        end
        if nargin > 11 && ~isempty(mimg_lrs2)
            p = p + 1;
            allimgs{p} = mimg_lrs2{k}; alllabs{p} = mlab_lrs2{k};
        end
        if nargin > 13 && ~isempty(mimg_mix)
            p = p + 1;
            allimgs{p} = mimg_mix{k}; alllabs{p} = mlab_mix{k};
        end
        if nargin > 15 && ~isempty(mimg_f)
            p = p + 1;
            allimgs{p} = mimg_f{k}; alllabs{p} = mlab_f{k};
        end
        %%allmim = montage_list_w_text2(allimgs, alllabs, 2, [], [], [5000 5000 3]); % disabling text to parallelize
        allmim = montage_list(allimgs, 2, [0 0 0], [5000 5000 3]);
        imwrite(allmim, savename);
    %end
end
myprintfn;
