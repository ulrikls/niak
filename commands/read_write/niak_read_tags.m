function [coord,labels] = niak_read_tags(file_name)
%
% _________________________________________________________________________
% SUMMARY NIAK_READ_TAGS
%
% Read coordinates in a tag file.
%
% SYNTAX:
% [COORD,LABELS] = NIAK_READ_TAB(FILE_NAME)
%
% _________________________________________________________________________
% INPUTS:
%
% FILE_NAME     
%       (string) the name of a (text) tag file.
% 
% _________________________________________________________________________
% OUTPUTS:
%
% COORD
%       (matrix N x 3*V) COORD(I,:) is the 3D-coordinates of the I point in
%       the tag file, where V is the number of volumes.
%
% LABELS
%       (cell of string) LABELS{I} is the label of the Ith tag.
%
% _________________________________________________________________________
% SEE ALSO:
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : xfm, minc


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

if ~exist('file_name','var')
    error('Syntax : [COORD,LABELS] = NIAK_READ_TAB(FILE_NAME). Type ''help niak_read_tags'' for more infos.')
end

if ~exist(file_name,'file')
    error(cat(2,'Could not find any file matching the description ',file_name));
end

hf = fopen(file_name);
tab = fread(hf, Inf, 'uint8=>char')';
fclose(hf);

noVol = regexp(tab,'Volumes = (\d+);','tokens','once');
noVol = str2double(noVol{1});

tab = niak_string2lines(tab);
start = find(strcmp('Points =', tab), 1) + 1;
tab = tab(start:end);

coord = zeros([length(tab) 3]);
labels = cell([length(tab) 1]);

for num_l = 1:length(tab)
    line_tab = niak_string2words(tab{num_l});
    for v = 1:noVol
      lim = (1:3) + (v-1) * 3;
      coord(num_l,lim) = str2double(line_tab(lim));
    end
    ind_num = strfind(tab{num_l},'"');
    if length(ind_num) > 1
      labels{num_l} = tab{num_l}(ind_num(1)+1:ind_num(2)-1);
    end
end