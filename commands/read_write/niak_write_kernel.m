function [err,msg] = niak_write_kernel(file_name, kernel)
% Write morphological kernel to a kern file.
%
% SYNTAX:
% [ERR,MSG] = NIAK_WRITE_KERNEL(FILE_NAME, KERNEL)
%
% _________________________________________________________________________
% INPUTS:
%
% FILE_NAME     
%       (string) the name of the text tag file.
% 
% KERNEL
%       (logical, numeric or strel)
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
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Ulrik Landberg Stephansen, Aalborg University, 2012.
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
	error('Syntax : [ERR,MSG] = NIAK_WRITE_KERNEL(FILE_NAME, KERNEL). Type ''help niak_write_kernel'' for more info.')
end

if ~exist('kernel','var')
  error('Please specify KERNEL as input');
end


%% Open file for writing
[hf,msg] = fopen(file_name,'w');
if hf == -1
  err = 1;
else
  err = 0;
end


%% Extract kernel from strel
if isa(kernel, 'strel')
  kernel = getnhood(kernel);
end


%% Write kern file
fprintf(hf, 'MNI Morphology Kernel File\n\n');
fprintf(hf, 'Kernel_Type = Normal_Kernel;\n');
fprintf(hf, 'Kernel =\n');
fprintf(hf, '%%    x    y    z    t    v     coeff\n');
fprintf(hf, '%% -----------------------------------');

s = size(kernel);
c = ceil(s ./2);
for i = 1:numel(kernel)
  [x y z] = ind2sub(s, i);
  if ~all([x y z] == c)
    fprintf(hf, '\n  % .1f % .1f % .1f % .1f % .1f    % .1f', x-c(1), y-c(2), z-c(3), 0, 0, kernel(i));
  end
end
fprintf(hf, ';\n');

fclose(hf);
