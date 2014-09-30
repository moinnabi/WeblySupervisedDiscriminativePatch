function dstmd = chisq(h,g)

%d(X,Y) = sum ((X(i)-Y(i))²)/(X(i)+Y(i))

h = h./(sum(h(:))+eps); g = g./(sum(g(:))+eps);
t = ((h-g).*(h-g))./(h+g+eps);
dstmd = 0.5*sum(t(:));
