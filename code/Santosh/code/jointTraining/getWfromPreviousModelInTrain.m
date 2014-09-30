function w = getWfromPreviousModelInTrain(modelname)

load(modelname, 'model');
blocks = fv_model_args(model);
w = cat(1, blocks{:});
