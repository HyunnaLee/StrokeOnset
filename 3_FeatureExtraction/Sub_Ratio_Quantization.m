function [ QuantizedImg ] = Sub_Ratio_Quantization( image, level )
%SUB_INTENSITY_QUANTIZATION Summary of this function goes here
%   Detailed explanation goes here

% image(mask==0) = 0;
% lgc = image(:)~=0;
% Intensities = image(lgc);    
% 
% minIntensity = floor(min(Intensities)); 
% maxIntensity = ceil(max(Intensities));
minIntensity = 0.25; 
maxIntensity = 4.0;
QuantizationSize = (maxIntensity - minIntensity) / level;
QuantizationLevel = [(minIntensity+QuantizationSize):QuantizationSize:(maxIntensity-QuantizationSize)];
QuantizedImg = imquantize(image, QuantizationLevel);   
end

