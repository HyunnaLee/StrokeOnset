function Step1_InfarctSegmentation( path , adcfile, b1000file )
%% Input arguments:
% path - folder directory in which there are ADC and b1000 files to segment
% adcfile - name of ADC file (.nii or .hdr/.img)
% b1000file - name of b1000 file (.nii or .hdr/.img)
%% Output files:
% brain, WM, and infarct mask files are generated in the path(intput argument)
% The name of brain mask - "brain_" + adcfile(intput argument)
% The name of WM mask - "WM_" + adcfile(intput argument)
% The name of infact mask - "infarct_" + adcfile(intput argument)

%% ------------------------------------------------- Origin to image center
Sub_Setnii_QOffset([path filesep adcfile]);
Sub_Setnii_QOffset([path filesep b1000file]);

% ------------------------------------ Extract brain mask using SPM segment
Sub_SPM_segment([path filesep adcfile]);
Sub_SPM_seg2brainmask(path, adcfile);

%% ------------------------------------------------------------ Load images
nii_adc   = load_untouch_nii([path filesep adcfile]);
nii_brain = load_untouch_nii([path filesep 'brain_' adcfile]);
img_adc  = single(nii_adc.img);
mask_brain = int16(nii_brain.img);

%% -------------------------- Segment infarct using normalized thresholding
threshold_value = 0.835;    % Optimized value from 27 acute ischemic stroke patients
ccthr        = 0.2;         % cubic centimeter = milliliter at 4 degree of celsius
mask_brain = bwareaopen(mask_brain>0, 10000);
mask_brain = imfill(mask_brain>0,'holes');
mask_brain = imerode(mask_brain>0, strel('diamond', 1));
nii_brain.img = mask_brain;
save_untouch_nii(nii_brain, [path filesep 'brain_' adcfile]);
Sub_SPM_img2mask(path, ['brain_' adcfile], ''); 
img_adc(mask_brain==0) = 0;
lgc = img_adc(:)~=0;
img_adc_array = img_adc(lgc);

% ------------------------- Compute normalize thresholding value of ADC map
[thr_val,~] = JMRI_compute_ADC_Theshold(img_adc_array,threshold_value);
mask_infarct = img_adc<thr_val;
mask_infarct(mask_brain==0) = 0;

%% -------------------------------------------- b1000 GM histogram analysis 
Sub_SPM_seg2WMmask(path, adcfile);
nii_b1000   = load_untouch_nii([path filesep b1000file]);
nii_WM = load_untouch_nii([path filesep 'WM_' adcfile]);
img_b1000  = single(nii_b1000.img);
mask_WM = int16(nii_WM.img);
img_b1000(mask_WM==0) = 0;
img_b1000(mask_infarct==1) = 0;
lgc = img_b1000(:)~=0;
img_b1000_array = img_b1000(lgc);

mean_b1000 = mean(img_b1000_array);
SD_b1000 = sqrt(var(img_b1000_array));
thresh_b1000 = mean_b1000 + 1.5 * SD_b1000;

%% ------------------------------------- Component thresholding using b1000
mask_infarct_copy = mask_infarct;
[infarct_CCL, Num_CCL] = bwlabeln(mask_infarct_copy==1);
img_b1000  = single(nii_b1000.img);
for idxComponent = 1:Num_CCL
    lgc = find(infarct_CCL==idxComponent);
    [X, Y, Z] = ind2sub(size(infarct_CCL), lgc);
    img_CCL_array = ones(size(lgc, 1), 1);
    for i = 1:size(lgc, 1)
        img_CCL_array(i) = img_b1000(X(i), Y(i), Z(i));
    end    
    if mean(img_CCL_array) < thresh_b1000
        mask_infarct_copy(lgc) = 0;
    end
end

%% ------------------------------------ Voxel-wise thresholding using b1000 
img_b1000 = single(nii_b1000.img);
mask_infarct(img_b1000<thresh_b1000) = 0;
mask_infarct(mask_infarct_copy>0) = 1;
mask_infarct = imfill(mask_infarct>0,'holes');

%% ---------------------------------- Remove small clusters less than ccthr
pixdim = nii_adc.hdr.dime.pixdim(2:4);
ccpervoxel = pixdim(1)*pixdim(2)*pixdim(3)/1000;
size_thresh = round(ccthr/ccpervoxel);
mask_infarct = bwareaopen(mask_infarct>0, size_thresh);
mask_infarct = JMRI_remove_small_cluster(mask_brain,mask_infarct,pixdim,ccthr);

%% ------------------------------------------------ Save infarct mask image
nii_infarct = nii_brain;
nii_infarct.img = int16(mask_infarct);
save_untouch_nii(nii_infarct, [path filesep 'infarct_' adcfile]); 
Sub_SPM_img2mask(path, ['infarct_' adcfile], '');

end