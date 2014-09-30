function mvImgsNcreateTxt_parforhelper(imgtxtfname_train, trainInds, imgtxtfname_val, valInds, ...
    imgtxtfname_test, testInds, newids, imgsetdir, objname, do_mode)

if do_mode == 1
    % create train.txt file
    fidw = fopen(imgtxtfname_train, 'w');
    for j=1:length(trainInds)       % first write positive image names
        fprintf(fidw, '%s 1\n', newids{trainInds(j)});
    end
    [negids, gt] = textread([imgsetdir '/../voc/' objname '_train.txt'], '%s %d');
    negids = negids(gt == -1);
    for j = 1:length(negids)        % now write negative image names
        fprintf(fidw, '%s -1\n', negids{j});
    end
    fclose(fidw);
elseif do_mode == 2
    % create val.txt file
    fidw = fopen(imgtxtfname_val, 'w');
    for j=1:length(valInds)         % first write positive image names
        fprintf(fidw, '%s 1\n', newids{valInds(j)});
    end
    [negids, gt] = textread([imgsetdir '/../voc/' objname '_val.txt'], '%s %d');
    negids = negids(gt == -1);
    for j = 1:length(negids)        % now write negative image names
        fprintf(fidw, '%s -1\n', negids{j});
    end
    fclose(fidw);
elseif do_mode == 3
    % create test.txt file
    fidw = fopen(imgtxtfname_test, 'w');
    for j=1:length(testInds)    % first write positive image names
        fprintf(fidw, '%s 1\n', newids{testInds(j)});
    end
    [negids gt] = textread([imgsetdir '/../voc/' objname '_test.txt'], '%s %d');
    negids = negids(gt == -1);
    for j = 1:length(negids)       % now write negative image names
        fprintf(fidw, '%s -1\n', negids{j});
    end
    fclose(fidw);
end
