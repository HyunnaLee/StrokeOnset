function averTime = InfarctSegmentation( source_path )

% -------------------------------------------------------------- Scan files
adcfiles = dir(fullfile(source_path, '*_ADC.nii'));
b1000files = dir(fullfile(source_path, '*_b1000.nii'));
numfiles = size(adcfiles, 1);
if numfiles ~= size(b1000files, 1)
    return;
end

% -------------------------------------------------------- for each subject    
averTime = zeros(numfiles, 1);
for i=1:numfiles
    tStart = tic;
    InfarctSegmentation_EachSubject(source_path, adcfiles(i).name, b1000files(i).name);     
    averTime(i) = toc(tStart);
end
end

