function I = sexy_graph_asym_img(A, cachedir, params)

%{
% Create a graph visualization of a matrix using graphviz via sfdp mode
% Input:
%   A: a symmetric binary adjacency matrix
%   params: an optional set of parameters, calls
%     [params]=sexy_graph_params(A), if params is not present
%     params.sfdp_coloring=1 will enable sfdp edge coloring based on
%     sfdp emedding distance
% Output:
%   I: the graph image
%
%   If no output arguments are specified, then a pdf file is
%   written to disk.
%
% Examples:
% To write a PDF, call function without output parameters
%   >> sexy_graph(A);
% To write an image, just call with output
%   >> I = sexy_graph(A);
% To write a PDF with sfdp coloring
%   >> params = sexy_graph_params(A);
%   >> params.sfdp_coloring = 1;
%   >> sexy_graph(A,params);
% To write a PDF with eigenvector coloring
%   >> params = sexy_graph_params(A);
%   >> params = eigenvector_node_coloring(A, params, 2);
%   >> sexy_graph(A,params);
%
% Graphviz needs to be installed! Try running the command "dot" on
% the command line to see if it is installed or not.
%
% NOTE: A should be symmetric and have 1 component (not enforced)
%
% Tomasz Malisiewicz (tomasz@csail.mit.edu)
% updated for asymmetric by Santosh Divvala
%}

try
    
% turn diagonal off
A = A - diag(diag(A));

if 1
    layoutEngine = '-Kfdp';    % for ispart, isa graph
    %layoutEngine = '-Ksfdp';    % for fastImgCl graph    
else
    layoutEngine = '';
end

if ~exist('params','var')
    params = sexy_graph_params(A);
    params.sfdp_coloring = 1;
    params.tmpdir = cachedir; %'/tmp/';
end

% set file names
params.gv_file  = [params.tmpdir params.file_prefix '.gv'];
params.png_file = [params.tmpdir params.file_prefix '.png'];
params.pdf_file = [params.tmpdir params.file_prefix '.pdf'];
 
% set node params for visualizing graph
for i = 1:size(A,1)
    params.colstring{i} = sprintf('fillcolor="%.3f %.3f %.3f"',...
        params.colors(i,1), ...
        params.colors(i,2),...
        params.colors(i,3));
    
    %params.node_names{i} = sprintf('image="%s"',params.node_names{i});
    params.node_names{i} = sprintf('label="%s"',params.node_names{i});       
end

[u,v] = write_dot_file(A, params);

if params.sfdp_coloring == 1
    positions = load_positions_from_sfdp(params.gv_file,layoutEngine);
    params.edge_colors = edge_colors_from_positions(u,v,positions,params.NC);
    %fprintf(1,'Re-dumping graph with colors\n');
    write_dot_file(A, params);
end

%disp('shi');
if nargout == 0
    %If no outputs are specified, we write a pdf file.
    %fprintf(1,'creating pdf file %s\n', params.pdf_file);
    [basedir,tmp,tmp] = fileparts(params.pdf_file);        
    %[~,~]=unix(sprintf('cd %s && dot -Kfdp -Tsvg %s > %s', ...
    %    basedir,params.gv_file, params.pdf_file));
    %[~,~]=unix(sprintf('cd %s && dot -Ksfdp -Tpng %s > %s', ...    % sfdp seems to produce an edgeless graph
    [~,~]=unix(sprintf('cd %s && dot %s -Tpng %s > %s', ...
        basedir, layoutEngine, params.gv_file, params.png_file)); 
else
    fprintf(1,'Creating png file and loading\n');
    [aaa,bbb,ccc] = fileparts(params.gv_file);

    %[~,~]=unix(sprintf('cd %s && dot -Kfdp -Tpng %s > %s', ...
    [~,~]=unix(sprintf('cd %s && dot %s -Tpng %s > %s', ...  % 27Mar12: sfdp doesn't work on warp
        aaa, layoutEngine, params.gv_file, params.png_file));
    I = imread(params.png_file);
    delete(params.png_file);
end

% delete graphviz file
delete(params.gv_file);
    
catch
    disp(lasterr); keyboard;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [u,v] = write_dot_file(A, params)
% Writes the dot file which graphviz will use as input, and return
% the indices of the edges

gv_file = params.gv_file;

fid = fopen(gv_file,'w');
fprintf(fid,'// Dotfile written by make_memex_graph.m\n');
fprintf(fid,['// Matlab wrapper by Tomasz Malisiewicz (tomasz@' ...
    'csail.mit.edu)\n']);
fprintf(fid,['// Code available: https://github.com/quantombone/' ...
    'graphviz_matlab_magic\n']);

% write init info
fprintf(fid,'digraph G {\n');
fprintf(fid,['node [style="filled" width=2.0 height=1.0' ...
    ' penwidth=10 labelloc="c" imagescale=height fixedsize=true fontsize="30"' ...
    ' labelfontcolor="black"]\n']);       
fprintf(fid,'graph [outputorder="edgesfirst" size="20,20" dpi=300]\n');
fprintf(fid,'edge [fontsize="10.0" penwidth=10 weight=10]\n');
fprintf(fid,'overlap="scale"\n');

% write node info
for i = 1:size(A,1)
    fprintf(fid,'%d [%s %s %s];\n',i,...
        params.shapestring{i},...                
        params.node_names{i},...
        params.icon_string{i});
end

%{
% assume symmetric (binary ">0" ?)
[u,v] = find(A>0);
goods = (v>=u);
u = u(goods);
v = v(goods);
%} 
[u,v] = find(A>0);

Avals = unique(A(:));
Avals = Avals(Avals ~= 0);

% write edge info
for i = 1:length(u)
    
    %if u(i)>v(i), continue; end    % symmetric, so just consider upper triangular
    
    en = '';
    if isfield(params,'edge_names')
        en = params.edge_names{u(i),v(i)};
    end
    
    if isfield(params,'edge_colors')
        ec = params.edge_colors(i,:);
    else
        if length(Avals) == params.NC   % for doing isa, partof, ispart relationships            
            if A(u(i),v(i)) == Avals(1)
                ec = [1 0 0];   % red (10, isa)
            elseif A(u(i),v(i)) == Avals(2)
                ec = [0 1 0];   % green (20, haspart)
            elseif A(u(i),v(i)) == Avals(3)
                ec = [0 0 1];   % blue
            end
        else
            ec = [1 1 1];
        end
        ec = rgb2hsv(ec);
    end
    
    fprintf(fid,'%d -> %d [weight=%.5f arrowsize=1.5 color="%.3f %.3f %.3f" %s];\n',...
        u(i), v(i), full(A(u(i),v(i))),... 
        ec(1),ec(2),ec(3),...
        en); 
end
fprintf(fid,'}\n');

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function positions = load_positions_from_sfdp(gv_file, layoutEngine)
% Use some simple shell tricks to grep out the positions of nodes
% after we run graphviz on the input file and return a simple ascii
% output file.
plain_file = [gv_file '.plain'];
nodes_file = [gv_file '.nodes'];

[~,~]=unix(sprintf('dot %s -Tplain %s > %s', layoutEngine, gv_file, plain_file));

fprintf(1,'creating colors\n');
[~,~]=unix(sprintf('grep node %s | awk ''{print($2,$3,$4)}'' > %s',...
    plain_file, nodes_file));

r = load(nodes_file,'-ascii');
positions = r(:,2:3);
ids = r(:,1);
[aa,bb] = sort(ids);
positions = positions(bb,:);

% Clean up files
delete(plain_file);
delete(nodes_file);

function edge_colors = edge_colors_from_positions(u,v,positions,NC)
%Given the [u,v] indices of connected nodes as well as their
%positions, compute the 2D distance between connected nodes.  Then
%create edge colors which map the shortest edge to red and the
%longest edge to blue using Matlab's jet color scheme.

% Compute the euclided distances between connected nodes
dists = sqrt(sum( (positions(u,:)-positions(v,:)).^2,2));

%quantize colors into NC different discrete colors
%NC = 200;
colorsheet = jet(NC);
colorsheet = colorsheet(end:-1:1,:);

% map dists to [0,1] range
dists = dists - min(dists);
dists = dists / (max(dists)+eps);   % max() - min() but min() will be zero as already subtracted

% map all dists [0 1] to [1 NC] range (round them to be integers between [1 NC])
dists = round(dists*(NC-1)+1);

%graphviz needs colors in hsv format
edge_colors = colorsheet(dists,:);
edge_colors = rgb2hsv(edge_colors);
