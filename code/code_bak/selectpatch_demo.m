%demo for selecting patches

dir_main = '/projects/grail/moinnabi/eccv14/data/bcp_init/horse/';
dir_sub = dir(fullfile(dir_main));

for sub_ = 23:158

    dir_class = dir_sub(sub_).name %dir_class = 'portrait_horse_super'; %'saddlebred_horse_super';
    %dir_data = [dir_main,dir_class,'/'];
    load(['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/',dir_class,'/imgdata_50.mat'],'patch_per_comp');
    
    for comp = 1:length(patch_per_comp)
        models_all = patch_per_comp{comp}.models_all;
        app_consist_score = patch_per_comp{comp}.app_consist_score;
        sp_consistant_parts = patch_per_comp{comp}.sp_consistant_parts;
        I = patch_per_comp{comp}.I;
        bbox = patch_per_comp{comp}.bbox;
        gtbox = patch_per_comp{comp}.gtbox;

        top_score = 5;%sum over max top_score values for each part
        top_elements = ceil((size(app_consist_score,1))/top_score); %how many top images should be considered

        app_consist_score_perpart = zeros(1,numPatches);
        for part = 1:numPatches
            [sortedValues_img,sortIndex_img] = sort(app_consist_score(:,part),'descend');
            app_consist_score_perpart(part) = sum(sortedValues_img(1:top_elements));
        end

        part_selected = zeros(1,numPatches);
        
        app_th = 800;
        sp_th = 0.1;
        
        for pat = 1:numPatches
            if (app_consist_score_perpart(pat) > app_th) && (sp_consistant_parts(pat) > sp_th)
                part_selected(pat) = 1;
            end
        end

        figure(comp); clf;
        part_selected_ind = find(part_selected);
        for part= 1:min(25,length(part_selected_ind))
            pa = part_selected_ind(part);
            subplot(sqrt(25),sqrt(25),part);
            showboxes(imread(I{pa}), [bbox{pa}(1:4); gtbox{pa}]);
        end
        mkdir(['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/',dir_class,'/',int2str(comp),'/']);
        saveas(gcf, ['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/',dir_class,'/',int2str(comp),'/queryPatches.jpg']);
        close all;
    end
end

