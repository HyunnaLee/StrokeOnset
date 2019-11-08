function [ FeatureMatrix ] = FirstOrderFeature(Img, Mask, WM_mask)

    % Initialization
    FeatureNum = 6;     % size, mean, SD, skewness, kurtosis
    FeatureMatrix = zeros(1, FeatureNum);
    
    % Find WMH voxel indexes, to access as WMH.img(WMHX, WMHY, WMZ)
    VoxelIndexes = find(Mask>0);
    VoxelNum = size(VoxelIndexes, 1);
    [X, Y, Z] = ind2sub(size(Mask), VoxelIndexes);
    clear VoxelIndexes; 
    
    % Get texture feature from itensity values
    IntensityData = zeros(VoxelNum, 1);
    for i=1:VoxelNum
        IntensityData(i) = Img(X(i), Y(i), Z(i));
    end
    clear X Y Z;
    
    % Find WMH voxel indexes, to access as WMH.img(WMHX, WMHY, WMZ)
    VoxelIndexes = find(Mask==0 & WM_mask>0);
    WMVoxelNum = size(VoxelIndexes, 1);
    [X, Y, Z] = ind2sub(size(WM_mask), VoxelIndexes);
    clear VoxelIndexes; 
    WMData = zeros(WMVoxelNum, 1);
    for i=1:WMVoxelNum
        WMData(i) = Img(X(i), Y(i), Z(i));
    end
    clear X Y Z;
    
    FeatureMatrix(1, 1) = VoxelNum;
    FeatureMatrix(1, 2) = mean(IntensityData);
    FeatureMatrix(1, 3) = sqrt(var(IntensityData));
    FeatureMatrix(1, 4) = skewness(IntensityData);
    FeatureMatrix(1, 5) = kurtosis(IntensityData);
    FeatureMatrix(1, 6) = FeatureMatrix(1, 2) / mean(WMData);
end

