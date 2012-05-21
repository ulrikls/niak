function [err,msg] = niak_write_surf(file_name,ssurf)
% Write a triangular surface mesh in the MNI .obj format
%
% SYNTAX:
% [ERR,MSG] = NIAK_WRITE_SURF(FILE_NAME,SSURF)
%
% _________________________________________________________________________
% INPUTS :
%
% FILE_NAME
%    (string) the name of the .obj surface file.
%
% SSURF
%    (structure, with the following fields) 
%
%    COORD
%        (array 3 x v) node coordinates. v=#vertices.
%
%    NORMAL
%        (array, 3 x v) list of normal vectors, only .obj files.
%
%    TRI
%        (vector, t x 3) list of triangle elements. t=#triangles.
%
%    COLR
%        (vector or matrix) 4 x 1 vector of colours for the whole surface,
%        or 4 x v matrix of colours for each vertex, either uint8 in [0 255], 
%        or float in [0 1], only .obj files.
%
% _________________________________________________________________________
% OUTPUTS:
%
% ERR
%       (boolean) if ERR == 1 an error occured, ERR = 0 otherwise.
%
% MSG 
%       (string) the error message (empty if ERR==0).
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_READ_SURF
%
% _________________________________________________________________________
% COMMENTS:
%
% .obj file is the montreal neurological institute (MNI) specific ASCII or
% binary triangular mesh data structure.
%
% Copyright (c) Ulrik Landberg Stephansen, Aalborg University, 2012.
% Maintainer: usteph08@student.aau.dk
% See licensing information in the code.
% Keywords : surface, reader

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Validate inputs
if ~exist('file_name','var')
	error('Syntax : [ERR,MSG] = NIAK_WRITE_SURF(FILE_NAME,SSURF). Type ''help niak_write_surf'' for more info.')
end

gb_name_structure = 'ssurf'; %#ok<NASGU>
gb_list_fields =   {'coord','normal', 'tri', 'colr'   }; %#ok<NASGU>
gb_list_defaults = { NaN   , []     ,  NaN , [1 1 1 1]'}; %#ok<NASGU>
niak_set_defaults


%% Open file for writing
[hf,msg] = fopen(file_name,'w');
if hf == -1
  err = 1;
else
  err = 0;
end


%% Write .obj file

% surfprop, npoints
fprintf(hf, 'P 0.3 0.6 0.6 30 1 %d\n', size(ssurf.coord,2));

% point_array
fprintf(hf, ' %g %g %g\n', ssurf.coord);
fprintf(hf, '\n');

% normals
if isempty(ssurf.normal)
  ssurf.normal = zeros(size(ssurf.coord));
end
if ~all(size(ssurf.coord) == size(ssurf.normal))
  error('Size of COORD and NORMAL differs. Type ''help niak_write_surf'' for more info.')
end
fprintf(hf, ' %g %g %g\n', ssurf.normal);
fprintf(hf, '\n');

% nitems
fprintf(hf, ' %d\n', size(ssurf.tri,1));

% colour_flag, colour_table
if size(ssurf.colr,2) == size(ssurf.coord,2) % per-vertex
  fprintf(hf, ' 2\n');
  fprintf(hf, ' %g %g %g %g\n', ssurf.colr);
else
  fprintf(hf, ' 0 %g %g %g %g\n', ssurf.colr(1:4,1));
end
fprintf(hf, '\n');

% end_indices
fprintf(hf, ' %u %u %u %u %u %u %u %u\n', 3:3:numel(ssurf.tri));
fprintf(hf, '\n\n');

% indices
fprintf(hf, ' %u %u %u %u %u %u %u %u\n', ssurf.tri' - 1);
fprintf(hf, '\n');

fclose(hf);




