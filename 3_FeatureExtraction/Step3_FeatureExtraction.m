function feature_total = Step3_FeatureExtraction( path , adcfile, b1000file, flairfile )
%% Input arguments:
% path - folder directory in which there are ADC, b1000, FLAIR files
% adcfile - name of ADC file (.nii or .hdr/.img)
% b1000file - name of b1000 file (.nii or .hdr/.img)
% flairfile - name of (original) FLAIR file (.nii or .hdr/.img)

%% Output:
% Features from ADC, b1000, FLAIR images are extraction.
% the total number of the extracted features is 273(= 91 x 3).
% feature_total - a feature vector with size of 1 x 273. 

%% ------------------------------------------------------------ Load images
nii_adc   = load_untouch_nii([path filesep adcfile]);
nii_b1000 = load_untouch_nii([path filesep b1000file]);
nii_flair = load_untouch_nii([path filesep 'adc_' flairfile]);
nii_adc_ratio   = load_untouch_nii([path filesep 'ratio_' adcfile]);
nii_b1000_ratio = load_untouch_nii([path filesep 'ratio_' b1000file]);
nii_flair_ratio = load_untouch_nii([path filesep 'ratio_adc_' flairfile]);
nii_brain = load_untouch_nii([path filesep 'brain_' adcfile]);
nii_infarct = load_untouch_nii([path filesep 'infarct_' adcfile]);
nii_WM = load_untouch_nii([path filesep 'WM_' adcfile]);
img_adc  = single(nii_adc.img);
img_b1000  = single(nii_b1000.img);
img_flair  = single(nii_flair.img);
ratiomap_adc = single(nii_adc_ratio.img);
ratiomap_b1000 = single(nii_b1000_ratio.img);
ratiomap_flair = single(nii_flair_ratio.img);

ratiomap_adc(ratiomap_adc<0.25) = 0.25;
ratiomap_adc(ratiomap_adc>4) = 4.0;
ratiomap_b1000(ratiomap_b1000<0.25) = 0.25;
ratiomap_b1000(ratiomap_b1000>4) = 4.0;
ratiomap_flair(ratiomap_flair<0.45) = 0.25;
ratiomap_flair(ratiomap_flair>2) = 2.0;

mask_brain = int16(nii_brain.img);
mask_infarct = int16(nii_infarct.img);
mask_WM = int16(nii_WM.img);
featurenum = 46;
ADC = zeros(2, featurenum);    
b1000 = zeros(2, featurenum); 
FLAIR = zeros(2, featurenum);  
feature_total = zeros(1, (featurenum * 2 - 1) * 3);
if size(img_adc,1) ~= size(img_b1000,1) || size(img_adc,2) ~= size(img_b1000,2) || size(img_adc,3) ~= size(img_b1000,3) ...
        || size(img_adc,1) ~= size(img_flair,1) || size(img_adc,2) ~= size(img_flair,2) || size(img_adc,3) ~= size(img_flair,3)
    return;
end

mask_infarct = imdilate(mask_infarct>0, strel('diamond',2));

%% ------------------------------------------------- Intensity quantization 
lgc = find(mask_infarct>0);
infarctsize = size(lgc, 1);
infarctsize = infarctsize * nii_adc.hdr.dime.pixdim(2) * nii_adc.hdr.dime.pixdim(3) * nii_adc.hdr.dime.pixdim(4);
quantization_level_image = 32;
quantization_level_ratiomap = 32;
if infarctsize > 0
    normalized_adc = Sub_Intensity_Quantization(img_adc, mask_brain, 256);
    normalized_b1000 = Sub_Intensity_Quantization(img_b1000, mask_brain, 256);
    normalized_flair = Sub_Intensity_Quantization(img_flair, mask_brain, 256);
    
    quantized_adc = Sub_Intensity_Quantization(img_adc, mask_infarct, quantization_level_image);
    quantized_b1000 = Sub_Intensity_Quantization(img_b1000, mask_infarct, quantization_level_image);
    quantized_flair = Sub_Intensity_Quantization(img_flair, mask_infarct, quantization_level_image);    
      
    quantized_ratio_adc = Sub_Ratio_Quantization(ratiomap_adc, quantization_level_ratiomap);
    quantized_ratio_b1000 = Sub_Ratio_Quantization(ratiomap_b1000, quantization_level_ratiomap);
    quantized_ratio_flair = Sub_Ratio_Quantization(ratiomap_flair, quantization_level_ratiomap);      
end

%% ------------------------------------------------------- Extract features
if infarctsize > 0
    IntensityTextures = FirstOrderFeature(normalized_adc, mask_infarct, mask_WM);
    GradientTextures = SecondOrderFeature(normalized_adc, mask_infarct, 0);
    GLCMTextures = GLCMFeature(quantized_adc, mask_infarct, 0, quantization_level_image);
    GLRLMTextures = GLRLMFeature(quantized_adc, mask_infarct, 0, quantization_level_image, 32);
    LBPTextures = LBPFeature(normalized_adc, mask_infarct, 0);
    ADC(1,:) = horzcat(IntensityTextures,GradientTextures,GLCMTextures,...
        GLRLMTextures,LBPTextures);

    IntensityTextures_r = FirstOrderFeature(ratiomap_adc, mask_infarct, mask_WM);
    GradientTextures_r = SecondOrderFeature(ratiomap_adc, mask_infarct, 0);
    GLCMTextures_r = GLCMFeature(quantized_ratio_adc, mask_infarct, 0, quantization_level_ratiomap);
    GLRLMTextures_r = GLRLMFeature(quantized_ratio_adc, mask_infarct, 0, quantization_level_ratiomap, 32);
    LBPTextures_r = LBPFeature(ratiomap_adc, mask_infarct, 0);
    Results = horzcat(IntensityTextures_r,GradientTextures_r,...
        GLCMTextures_r,GLRLMTextures_r,LBPTextures_r);
    ADC(2,:) = Results;   
    
    IntensityTextures = FirstOrderFeature(normalized_b1000, mask_infarct, mask_WM);
    GradientTextures = SecondOrderFeature(normalized_b1000, mask_infarct, 0);
    GLCMTextures = GLCMFeature(quantized_b1000, mask_infarct, 0, quantization_level_image);
    GLRLMTextures = GLRLMFeature(quantized_b1000, mask_infarct, 0, quantization_level_image, 32);
    LBPTextures = LBPFeature(normalized_b1000, mask_infarct, 0);
    b1000(1,:) = horzcat(IntensityTextures,GradientTextures,GLCMTextures,...
        GLRLMTextures,LBPTextures);
    
    IntensityTextures_r = FirstOrderFeature(ratiomap_b1000, mask_infarct, mask_WM);
    GradientTextures_r = SecondOrderFeature(ratiomap_b1000, mask_infarct, 0);
    GLCMTextures_r = GLCMFeature(quantized_ratio_b1000, mask_infarct, 0, quantization_level_ratiomap);
    GLRLMTextures_r = GLRLMFeature(quantized_ratio_b1000, mask_infarct, 0, quantization_level_ratiomap, 32);
    LBPTextures_r = LBPFeature(ratiomap_b1000, mask_infarct, 0);
    Results = horzcat(IntensityTextures_r,GradientTextures_r,...
        GLCMTextures_r,GLRLMTextures_r,LBPTextures_r);
    b1000(2,:) = Results;     
    
    IntensityTextures = FirstOrderFeature(normalized_flair, mask_infarct, mask_WM);
    GradientTextures = SecondOrderFeature(normalized_flair, mask_infarct, 0);
    GLCMTextures = GLCMFeature(quantized_flair, mask_infarct, 0, quantization_level_image);
    GLRLMTextures = GLRLMFeature(quantized_flair, mask_infarct, 0, quantization_level_image, 32);
    LBPTextures = LBPFeature(normalized_flair, mask_infarct, 0);
    FLAIR(1,:) = horzcat(IntensityTextures,GradientTextures,GLCMTextures,...
        GLRLMTextures,LBPTextures);
    
    IntensityTextures_r = FirstOrderFeature(ratiomap_flair, mask_infarct, mask_WM);
    GradientTextures_r = SecondOrderFeature(ratiomap_flair, mask_infarct, 0);
    GLCMTextures_r = GLCMFeature(quantized_ratio_flair, mask_infarct, 0, quantization_level_ratiomap);
    GLRLMTextures_r = GLRLMFeature(quantized_ratio_flair, mask_infarct, 0, quantization_level_ratiomap, 32);
    LBPTextures_r = LBPFeature(ratiomap_flair, mask_infarct, 0);
    Results = horzcat(IntensityTextures_r,GradientTextures_r,...
        GLCMTextures_r,GLRLMTextures_r,LBPTextures_r);
    FLAIR(2,:) = Results;   
    
    ADC(1,1) = infarctsize;
    ADC(2,1) = infarctsize;
    b1000(:,1) = ADC(:,1);
    FLAIR(:,1) = ADC(:,1);
    feature_ADC(1:featurenum) = ADC(1, 1:featurenum);
    feature_ADC(1+featurenum:featurenum*2-1) = ADC(2, 2:featurenum);
    feature_b1000(1:featurenum) = b1000(1, 1:featurenum);
    feature_b1000(1+featurenum:featurenum*2-1) = b1000(2, 2:featurenum); 
    feature_FLAIR(1:featurenum) = FLAIR(1, 1:featurenum);
    feature_FLAIR(1+featurenum:featurenum*2-1) = FLAIR(2, 2:featurenum);       
    feature_total = [feature_ADC feature_b1000 feature_FLAIR];
end

end