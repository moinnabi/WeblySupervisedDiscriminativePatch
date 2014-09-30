function [ps_new] = download_img_db(ps_old,finalresdir)

ps_new = []; %should be refined

i = 1;
index = 1;
while i <= length(ps_old)
    imgurl = ps_old{i}.imgurl;
    id = [int2str(i),'.jpg']; % sorted
    adrs = [finalresdir,'Img/',id]
    
    [filestr,status] = urlwrite(imgurl,adrs); %download Image from INTERNET
    
    if status == 1
        ps_new{index}.I = filestr;
        ps_new{index}.component = ps_old{index}.component;
        ps_new{index}.bbox = ps_old{index}.bbox;
        ps_new{index}.cls = ps_old{index}.cls;
        ps_new{index}.id = [int2str(index),'.jpg'] % sorted

        ps_new{index}.flip = ps_old{index}.flip;
        ps_new{index}.trunc = ps_old{index}.trunc;
        index = index + 1;
    end
    i = i +1;
end