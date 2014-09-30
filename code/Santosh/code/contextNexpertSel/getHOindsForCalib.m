function getHOindsForCalib

disp('write hoinds');
VOCinit;
ids = textread(sprintf(VOCopts.imgsetpath, 'test'), '%s');
%hoinds = myRand(round(numel(ids)/3), numel(ids));
hoinds = randperm(numel(ids),round(numel(ids)/3));
fidw = fopen(sprintf(VOCopts.imgsetpath, 'hoinds'), 'w');
for j=1:length(hoinds)
    fprintf(fidw, '%d\n', hoinds(j));
end
fclose(fidw);

