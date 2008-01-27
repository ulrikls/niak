function [vols_a,extras] = niak_slice_timing(vols,opt)

% Correct for differences in slice timing in a 4D fMRI acquisition via
% linear temporal interpolation
%
% SYNTAX
% vol_a = niak_slice_timing(vols,opt)
%
% INPUTS
% vols          (4D array) a 3D+t dataset
% opt           (structure) with the following fields :
%
%               interpolation_method   (string, default 'linear') the method for
%                       temporal interpolation, choices 'linear' or 'sync'.
%                       Linear interpolation is not exact,
%                       yet it is much more stable than sync interpolation
%                       regarding noise and discontinuities and therefore recommended.
%
%               slice_order	(vector of integer) slice_order(i) is the number of the ith slice
%                       in the volume (assumed to be identical in all
%                       volumes), the order of slices representing their
%                       temporal acquisition order.
%                       ex : slice_order = [1 3 5 2 4 6]
%                       for 6 slices acquired in 'interleaved' mode,
%                       starting by odd slices. Note that the slices are
%                       assumed to be axial, i.e. slice z at time t is
%                       vols(:,:,z,t).
%
%               ref_slice	(integer, default midle slice in acquisition time)
%                       slice for time 0
%
%               timing		(vector 2*1) timing(1) : time between two slices
%                           timing(2) : time between last slice and next volume
%
%               flag_verbose (boolean, default 1) if the flag is 1, then
%                       the function prints some infos during the
%                       processing.
%
% OUTPUTS
% vols_a        (4D array) same as vols after slice timing correction has
%                       been applied through linear interpolation
%
% COMMENTS
%
% The linear interpolation was coded by P Bellec, MNI 2008
%
% The sync interpolation is a port from SPM5.
% First code : Darren Gitelman at Northwestern U., 1998
% Based (in large part) on ACQCORRECT.PRO from Geoff Aguirre and
% Eric Zarahn at U. Penn.
% Subsequently modified by R Henson, C Buechel, J Ashburner and M Erb.
% adapted to NIAK format and patched to avoid loops by P Bellec, MNI 2008.
%
% Copyright (C) Wellcome Department of Imaging Neuroscience 2005
% Copyright (C) Pierre Bellec 2008

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

% Setting up default
gb_name_structure = 'opt';
gb_list_fields = {'interpolation_method','slice_order','ref_slice','timing','flag_verbose'};
gb_list_defaults = {'linear',NaN,[],NaN,1};
niak_set_defaults

nb_slices = length(slice_order);
if length(size(vols))>3
    [nx,ny,nz,nt] = size(vols);
else
    [nx,ny,nz] = size(vols);
    nt = 1;
end

if ~(nz == nb_slices)
    fprintf('Error : the number of slices in slice_order should correspond to the 3rd dimension of vols. Try to proceed anyway...')
end

if isempty(ref_slice)
    ref_slice = slice_order(ceil(nb_slices/2));
end

TR 	= (nb_slices-1)*timing(1)+timing(2);

if flag_verbose == 1
    fprintf('Your TR is %1.1f\n',TR);
end
    
vols_a = zeros(size(vols));

if strcmp(interpolation_method,'linear')
    
    [tmp,time_slices] = sort(slice_order);
    time_slices = time_slices * timing(1);
    time_slices = time_slices-time_slices(ref_slice);
    
    for num_z = 1:nz
        times_ref = (0:nt+1)*TR;
        times_z = (1:nt)*TR+time_slices(num_z);
        
        slices_z = squeeze(vols(:,:,num_z,:));
        slices_z = reshape(slices_z,[nx*ny,nt])';
        slices_z_a = interp1(times_ref(:),[slices_z(1,:) ; slices_z ; slices_z(nt,:)],times_z(:),'linear');
        vols_a(:,:,num_z,:) = reshape(slices_z_a',[nx ny nt]);
    end
    
elseif strcmp(interpolation_method,'sync')
       
    nt2	= 2^(floor(log2(nt))+1);

    %  signal is odd  -- impacts how Phi is reflected
    %  across the Nyquist frequency. Opposite to use in pvwave.
    OffSet  = 0;    
    
    factor = timing(1)/TR;    

    for num_z = 1:nb_slices

        rslice = find(slice_order==ref_slice);
        % Set up time acquired within slice order
        shiftamount  = (find(slice_order == num_z) - rslice) * factor;

        % Extracting all time series in a slice.
        slices_z = zeros([nt2 nx*ny]);
        slices_tmp = squeeze(vols(:,:,num_z,:));
        slices_z(1:nt,:) = reshape(slices_tmp,[nx*ny nt])';
        % linear interpolation to avoid edge effect
        vals1 = slices_z(nt,:);
        vals2 = slices_z(1,:);
        xtmp = 0:(nt2-nt-1);
        slices_z(nt+1:nt2,:) = (xtmp'*ones([1 nx*ny])).*( ones([nt2-nt 1])*(vals2-vals1)/(nt2-nt-1)) + ones([nt2-nt 1])*vals1;

        % Phi represents a range of phases up to the Nyquist frequency
        % Shifted phi 1 to right.
        phi = zeros(1,nt2);
        list_f = 1:nt2/2;
        phi(list_f+1) = -1*shiftamount*2*pi./(nt2./list_f);


        % Mirror phi about the center
        % 1 is added on both sides to reflect Matlab's 1 based indices
        % Offset is opposite to program in pvwave again because indices are 1 based
        phi(nt2/2+1+1-OffSet:nt2) = -fliplr(phi(1+1:nt2/2+OffSet));

        % Transform phi to the frequency domain and take the complex transpose
        shifter = [cos(phi) + sin(phi)*sqrt(-1)].';
        shifter = shifter(:,ones(size(slices_z,2),1)); % Tony's trick

        % Applying the filter in the Fourier domain, and going back in the real
        % domain
        fslices_z = real(ifft(fft(slices_z).*shifter));
        vols_a(:,:,num_z,:) = reshape(fslices_z(1:nt,:)',[nx ny nt]);

    end
    
else
    
    fprintf('Unkown interpolation method : %s',interpolation_method)
    
end