function [ FeatureMatrix ] = SecondOrderFeature(Img, Mask, flag3D)
    if nargin < 3
        flag3D = 1;
    end
    
    % Initialization
    FeatureNum = 4;     % mean, SD, skewness, kurtosis
    FeatureMatrix = zeros(1, FeatureNum);
    
    % Calculate the gradient maps
    Gx = DGradient(double(Img), 1.0, 1, '2ndOrder');
    Gy = DGradient(double(Img), 1.0, 2, '2ndOrder');
    Gz = DGradient(double(Img), 1.0, 3, '2ndOrder');
    if flag3D == 0
        Gradient = sqrt(Gx.*Gx + Gy.*Gy);
    else
        Gradient = sqrt(Gx.*Gx + Gy.*Gy + Gz.*Gz);
    end
    
    % Find WMH voxel indexes, to access as WMH.img(WMHX, WMHY, WMZ)
    VoxelIndexes = find(Mask>0);
    VoxelNum = size(VoxelIndexes, 1);
    [X, Y, Z] = ind2sub(size(Mask), VoxelIndexes);
    clear VoxelIndexes; 

    % Get texture feature from gradient values
    GradientData = zeros(VoxelNum, 1);
    % 3D graidient
    for i=1:VoxelNum
        GradientData(i) = Gradient(X(i), Y(i), Z(i));
    end            

    FeatureMatrix(1, 1) = mean(GradientData);
    FeatureMatrix(1, 2) = sqrt(var(GradientData));
    FeatureMatrix(1, 3) = skewness(GradientData);
    FeatureMatrix(1, 4) = kurtosis(GradientData);          

end

