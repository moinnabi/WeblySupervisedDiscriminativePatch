function y = linspace_variable(d1, d2, nvec)

nvec = double(nvec);
nvec = cumsum(nvec);
nvec = nvec(1:end-1);
y = [d1 d1 + nvec.*(d2-d1) d2];
