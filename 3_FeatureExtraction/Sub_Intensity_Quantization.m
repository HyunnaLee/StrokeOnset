function [ QuantizedImg ] = Sub_Intensity_Quantization( image, mask, level )
%SUB_INTENSITY_QUANTIZATION Summary of this function goes here
%   Detailed explanation goes here

% image(mask==0) = 0;
% lgc = image(:)~=0;
% lgc = find(mask>0);
Intensities = image(mask>0);    

%minIntensity = floor(min(Intensities)); 
%maxIntensity = ceil(max(Intensities));
minIntensity = floor(quantile(Intensities, 0.01)); 
maxIntensity = ceil(quantile(Intensities, 0.99));
QuantizationSize = (maxIntensity - minIntensity) / level;
QuantizationLevel = [(minIntensity+QuantizationSize):QuantizationSize:(maxIntensity-QuantizationSize)];
QuantizedImg = imquantize(image, QuantizationLevel);   
end

