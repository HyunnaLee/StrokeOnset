function [threshold_intensity,output_column] = JMRI_compute_ADC_Theshold(source_column,normalized_threshold_level)
%JMRI_compute_ADC_Theshold    Compute threshold level for ADC map
%
%   [threshold_intensity,output_column] = computeTheshold_KS(source_column,normalized_threshold_level)
%   
%   source_column               A single column of ADC map (BET recommanded)
%   normalized_threshold_level  [0 1] threshold value for normalized ADC map
%
%   threshold_intensity         intensity for trhesholding
%   output_column               normalized ADC map (single column)
%
%   If there is an error in differentiate function, check curvefit toolbox.
%
%   - Kyesam Jung (gssure@gmail.com) 2015.12.01
quant_x = 0.05:0.01:0.5;
quant_y = quantile(source_column,quant_x);
f = fit(quant_x',quant_y','poly3');
[fd1,~] = differentiate(f,quant_x);
mp = find(min(fd1)==fd1);
ft1a = fd1(1); ft1b = (f(quant_x(1))-fd1(1)*quant_x(1));
ft2a = fd1(mp);ft2b = (f(quant_x(mp))-fd1(mp)*quant_x(mp));
cross_x = (ft2b-ft1b)/(ft1a-ft2a);
cross_y = ft1a*cross_x+ft1b;
threshold_intensity = cross_y*normalized_threshold_level;
output_column = source_column/cross_y;
end