function tic_toc_print(fmt, varargin)
% Print only after pth second has passed since the last print. 
% Arguments are the same as for fprintf.

pth = 10; %1

persistent th;

if isempty(th)
  th = tic();
end

if toc(th) > pth
  fprintf(fmt, varargin{:});
  drawnow;
  th = tic();
end
