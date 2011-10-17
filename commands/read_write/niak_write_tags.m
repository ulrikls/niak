function [err,msg] = niak_write_tags(file_name,coords,labels)
% Write landmark coordinates in to a tag file.
% Labels are optional.
%
% SYNTAX:
% [ERR,MSG] = NIAK_WRITE_TAGS(FILE_NAME,COORDS,LABELS)
%
% _________________________________________________________________________
% INPUTS:
%
% FILE_NAME     
%       (string) the name of the text tag file.
% 
% COORDS
%       (matrix N x 3*V) COORDS(I,:) is the 3D-coordinates of the I point
%       in the tag file, where V is the number of volumes.
%
% LABELS
%       (cell of string) LABELS{I} is the label of the Ith tag.
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
% NIAK_READ_TAGS
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Ulrik Landberg Stephansen, Aalborg University, 2011.
% Maintainer: usteph08@student.aau.dk
% See licensing information in the code.
% Keywords: xfm, minc, tag

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
	error('Syntax : [ERR,MSG] = NIAK_READ_TAB(FILE_NAME,COORDS,LABELS). Type ''help niak_write_tags'' for more info.')
end

if ~exist('coords','var')
  error('Please specify COORDS as input');
end

if ~exist('labels','var')
  labels = [];
end
if isempty(labels)
  labels = cell([length(coords) 1]);
end

%% Open file for writing
[hf,msg] = fopen(file_name,'w');
if hf == -1
  err = 1;
else
  err = 0;
end

%% Get number of volumes
noVol = floor(size(coords,2) / 3);

%% Write tag file
fprintf(hf, 'MNI Tag Point File\n');
fprintf(hf, 'Volumes = %u;\n\n', noVol);
fprintf(hf, 'Points =');

for i = 1:size(coords,1)
  fprintf(hf, '\n');
  for v = 1:noVol
    lim = (1:3) + (v-1) * 3;
    fprintf(hf, ' %.15g %.15g %.15g', coords(i,lim));
  end
  if ~isempty(labels{i})
    fprintf(hf, ' "%s"', labels{i});
  end
end
fprintf(hf, ';\n');

fclose(hf);
