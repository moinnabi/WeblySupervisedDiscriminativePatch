function sample_selected = select_sample(detect_response,top_num)

num_img = length(detect_response);

for img = 1:img_num
    if  ~isempty(detect_response{img})
        Patches(img,:) = horzcat(detect_response{img}.patches{:});
    end
end

sample_selected.image = 
sample_selected.bb = 
sample_selected.score =

