% README.txt

Hi Santosh

The entrance to the code is "demo_cvpr15.m"

Because of the very slow access to the Robson via SSH, I changed all the directories to the directories on my local PC at Italy (but still availible as comment), please uncomment them first, then run the code for a subcagegory and report me if you find any bug in the code.

These are the main functions:

+ load_component_data -> load the subcategory data for a particular component.

+ subcategory_patch_discovery -> extract patches for each subcategory
	- auto_get_part_fast -> Select random "patches" on each Positive image (belongs to this subcategory)
	- relative_position -> Find relative position and Deformation Parameter for each Query patch
	- orig_train_elda - > Train Examplar-LDA for each patch (Query)
	- deform_param -> Compute Deformation Parameter for each Query patch
	- part_inference_inbox -> detect patches inside a given bounding box
	- compute_rep_score - > Computing Representation measure based on SP/AP consistancy
	- compute_disc_score -> Computing Discriminative measure inside the subcategory
	- subcategory_patch_selection -> Patch selection for each subcategory
	- retrain_patch_svm/retrain_patch_lsvm/retrain_patch_llda -> Retraining the Patch Models Using Linear SVM / Latent-SVM / Latent-LDA

+ patch_calibration_subcategory -> calibrate patches for each subcategory



Please drop me a line if something is not clear in the code.

Thanks,
Moin
