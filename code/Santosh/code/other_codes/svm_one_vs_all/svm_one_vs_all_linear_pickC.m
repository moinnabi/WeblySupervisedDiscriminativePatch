function cself = svm_one_vs_all_linear_pickC(X,Y,bval)

c_begin = -10;
c_end= 15;
c_step = 2;
c_step_fine = 0.5;

% coarse search
cgrid_coarse = [];
cnt = 1;
for i=c_begin:c_step:c_end
    cgrid_coarse(cnt) = 2^i;
    cnt = cnt + 1;
end
acc = zeros(length(cgrid_coarse),1);
for j=1:length(cgrid_coarse)
    disp(['doing cgrid_coarse ' num2str(cgrid_coarse(j))]);
    acc(j) = svm_one_vs_all_cval_linear(X,Y,cgrid_coarse(j),bval);
end
[cselc_val tmpind] = max(acc);
cselc = cgrid_coarse(tmpind);

% (local) finer search
cgrid_fine = [];
cnt = 1;
for j=log2(cselc)-2:c_step_fine:log2(cselc)+2
    cgrid_fine(cnt) = 2^j;
    cnt = cnt + 1;
end
acc = zeros(length(cgrid_fine),1);
for j=1:length(cgrid_fine)
    disp(['doing cgrid_fine ' num2str(cgrid_fine(j))]);
    acc(j) = svm_one_vs_all_cval_linear(X,Y,cgrid_fine(j),bval);
end
[cself_val tmpind] = max(acc);
cself = cgrid_fine(tmpind);
