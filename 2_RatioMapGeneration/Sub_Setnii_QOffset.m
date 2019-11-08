function Sub_Setnii_QOffset(sourcepath,origin_ijk)
%KS_nii_set_qoffset  Set origin of NIfTI
%
%   KS_nii_set_qoffset(sourcepath,origin_ijk)
%       sourcepath = path of *.nii or *.nii.gz
%       origin_ijk = coordinates of volume for setting origin (default = a middle of the volume)
%
% Kyesam Jung, 2016.04.25
nii0 = load_untouch_nii(sourcepath);
if nii0.hdr.hist.sform_code<=0
    disp('## qform_code should be over 0.')
    return;
end
rotmtx0 = [nii0.hdr.hist.srow_x;nii0.hdr.hist.srow_y;nii0.hdr.hist.srow_z];
rotmtx = rotmtx0(:,1:3);
nii0_modi = nii0;
sz = size(nii0.img);
if nargin<2
    X = [sz(1)/2;sz(2)/2;sz(3)/2];
else
    X = origin_ijk;
    if size(X,1)<size(X,2)
        X = X';
    end
end
T = -1*rotmtx*X;
nii0_modi.hdr.hist.qoffset_x = T(1);
nii0_modi.hdr.hist.qoffset_y = T(2);
nii0_modi.hdr.hist.qoffset_z = T(3);
nii0_modi.hdr.hist.srow_x(4) = nii0_modi.hdr.hist.qoffset_x;
nii0_modi.hdr.hist.srow_y(4) = nii0_modi.hdr.hist.qoffset_y;
nii0_modi.hdr.hist.srow_z(4) = nii0_modi.hdr.hist.qoffset_z;
save_untouch_nii(nii0_modi,sourcepath)
end