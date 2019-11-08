function Step2_RatioMapGeneration( path , adcfile, b1000file, flairfile )
%% Input arguments:
% path - folder directory in which there are ADC, b1000, FLAIR files
% adcfile - name of ADC file (.nii or .hdr/.img)
% b1000file - name of b1000 file (.nii or .hdr/.img)
% flairfile - name of FLAIR file (.nii or .hdr/.img)

%% Output files:
% Registered (into ADC space) FLAIR file is generated in the path(intput argument).
% The name of the registered FLAIR - "adc_" + flairfile(intput argument)

% Ratio map for each of ADC, b1000, and (registered) FLAIR is generated in the path(intput argument).
% The name of ratio map of ADC - "ratio_" + adcfile(intput argument)
% The name of ratio map of b1000 - "ratio_" + b1000file(intput argument)
% The name of ratio map of (registered) FLAIR - "ratio_adc_" + flairfile(intput argument)

%% ------------------------------------------------- Origin to image center
Sub_Setnii_QOffset([path filesep adcfile]);
Sub_Setnii_QOffset([path filesep b1000file]);
Sub_Setnii_QOffset([path filesep flairfile]);

% ----------------------------- Find midsagittal plane by warping MNI plane
Sub_SPM_warpingmask(path, adcfile);

% ------------------------------------------------- Coregister FLAIR to ADC
Sub_SPM_coreg([path filesep adcfile], [path filesep flairfile]);

%% ------------------------------------------------------------ Load images
nii_adc   = load_untouch_nii([path filesep adcfile]);
nii_b1000 = load_untouch_nii([path filesep b1000file]);
nii_flair = load_untouch_nii([path filesep 'adc_' flairfile]);
nii_brain = load_untouch_nii([path filesep 'brain_' adcfile]);
nii_plane = load_untouch_nii([path filesep 'mid_' adcfile]);
img_adc  = single(nii_adc.img);
img_b1000  = single(nii_b1000.img);
img_flair  = single(nii_flair.img);
mask_brain = int16(nii_brain.img);
mask_plane = int16(nii_plane.img);
if size(img_adc,1) ~= size(img_b1000,1) || size(img_adc,2) ~= size(img_b1000,2) || size(img_adc,3) ~= size(img_b1000,3) ...
        || size(img_adc,1) ~= size(img_flair,1) || size(img_adc,2) ~= size(img_flair,2) || size(img_adc,3) ~= size(img_flair,3)
    return;
end

%% -------------------------------------------------- Find midsagittal line
lgc = find(mask_plane>0);
[pointX, pointY, pointZ] = ind2sub(size(mask_plane), lgc);
points = transpose(horzcat(pointX, pointY, pointZ));
[Bcoefficients, P, inliers] = ransacfitplane(points, 5, 0);
unitB = Bcoefficients(1:3);
unitB = unitB / norm(unitB);
vecLine = Bcoefficients(1:2);
vecLineLength = norm(vecLine);

% ------------------------------------------------- Generate the ratio maps
ratiomap_adc = zeros(size(img_adc));
ratiomap_b1000 = zeros(size(img_b1000));
ratiomap_flair = zeros(size(img_flair));
lgc = find(mask_brain>0);
[infarctX, infarctY, infarctZ] = ind2sub(size(mask_brain), lgc);
infarctsize = size(lgc, 1);

for i = 1:infarctsize
    C = Bcoefficients(3) * infarctZ(i) + Bcoefficients(4);
    A = Bcoefficients(1) / vecLineLength;
    B = Bcoefficients(2) / vecLineLength;
    C = C / vecLineLength;
       
    D = A * infarctX(i) + B * infarctY(i) + C;
    mirrorX = round(infarctX(i) - 2*D*A);
    mirrorY = round(infarctY(i) - 2*D*B);   
    mirrorZ = infarctZ(i);
    
    if mirrorX < 1
        mirrorX = 1;
    elseif mirrorX > size(mask_brain, 1)
        mirrorX = size(mask_brain, 1);
    end
    if mirrorY < 1
        mirrorY = 1;
    elseif mirrorY > size(mask_brain, 2)
        mirrorY = size(mask_brain, 2);
    end
     if mirrorZ < 1
        mirrorZ = 1;
    elseif mirrorZ > size(mask_brain, 3)
        mirrorZ = size(mask_brain, 3);
    end
    ratiomap_adc(infarctX(i), infarctY(i), infarctZ(i)) = img_adc(infarctX(i), infarctY(i), infarctZ(i)) / img_adc(mirrorX, mirrorY, mirrorZ);
    ratiomap_b1000(infarctX(i), infarctY(i), infarctZ(i)) = img_b1000(infarctX(i), infarctY(i), infarctZ(i)) / img_b1000(mirrorX, mirrorY, mirrorZ);
    ratiomap_flair(infarctX(i), infarctY(i), infarctZ(i)) = img_flair(infarctX(i), infarctY(i), infarctZ(i)) / img_flair(mirrorX, mirrorY, mirrorZ);
end
ratiomap_adc(isnan(ratiomap_adc)) = 1.0;
ratiomap_adc(isinf(ratiomap_adc)) = 1.0;
ratiomap_b1000(isnan(ratiomap_b1000)) = 1.0;
ratiomap_b1000(isinf(ratiomap_b1000)) = 1.0;    
ratiomap_flair(isnan(ratiomap_flair)) = 1.0;
ratiomap_flair(isinf(ratiomap_flair)) = 1.0;    
Sub_SPM_ratio2img(ratiomap_adc, path, adcfile);
Sub_SPM_ratio2img(ratiomap_b1000, path, b1000file);
Sub_SPM_ratio2img(ratiomap_flair, path, ['adc_' flairfile]);

end