function mim = showClusIndsAfterTraining(inds, pos, model, originalInds)

% this file needs to be commented
warptmp = warppos_display(model, pos);
allimgs = cell(length(pos),1); alllabs = cell(length(pos),1);
for jj = 1:length(pos)
    myprintf(jj);
                
    allimgs{jj} = uint8(warptmp{jj});    
    alllabs{jj} = mat2str([originalInds(jj); inds{jj}(1:min(5,length(inds{jj})))]);
end
mim = montage_list_w_text2(allimgs, alllabs, 2, [], [], [1500 1500 3]);
myprintfn;
