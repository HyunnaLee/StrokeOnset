function [ ADCfeatures , b1000features, FLAIRfeatures ] = FeatureExtraction_DWI_FLAIR_Mismatch( source_path )

% -------------------------------------------------------------- Scan files
scan_path = '/Volumes/Seagate_Blk/Stroke_OnsetTime/1_Original/Final_2nd';
adcfiles = dir(fullfile(scan_path, '*_ADC.nii'));
b1000files = dir(fullfile(scan_path, '*_b1000.nii'));
flairfiles = dir(fullfile(scan_path, '*_FLAIR.nii'));
numfiles = size(adcfiles, 1);
if numfiles~=size(flairfiles, 1) || numfiles~=size(b1000files, 1)
    return;
end  

% --------------------------------------- Extract features for each subject    
featurenum = 46;
ADCfeatures = zeros(numfiles, featurenum * 2 - 1);
b1000features = zeros(numfiles, featurenum * 2 - 1);
FLAIRfeatures = zeros(numfiles, featurenum * 2 - 1);
for i=1:numfiles
%    InfarctSegmentationWithB1000_EachSubject(source_path, adcfiles(i).name, b1000files(i).name);
%     InfarctSegmentationWithoutB1000_EachSubject(source_path, adcfiles(i).name);
%    RatioMapGeneration_EachSubject(source_path, adcfiles(i).name, b1000files(i).name, flairfiles(i).name);
 	[ADC, b1000, FLAIR] = FeatureExtraction_EachSubject(source_path, adcfiles(i).name, b1000files(i).name, flairfiles(i).name);
    ADCfeatures(i, 1:featurenum) = ADC(1, 1:featurenum);
    ADCfeatures(i, 1+featurenum:featurenum*2-1) = ADC(2, 2:featurenum);
    b1000features(i, 1:featurenum) = b1000(1, 1:featurenum);
    b1000features(i, 1+featurenum:featurenum*2-1) = b1000(2, 2:featurenum);
    FLAIRfeatures(i, 1:featurenum) = FLAIR(1, 1:featurenum);
    FLAIRfeatures(i, 1+featurenum:featurenum*2-1) = FLAIR(2, 2:featurenum);        
end
end

