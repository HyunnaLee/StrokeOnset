function [ FeatureMatrix ] = LBPFeature(Img, Mask, flag3D)
    if nargin < 3
        flag3D = 1;
    end
    
    % Initialization
    LBPCombinationNum = 1;  % (r, n) = (1,8), (2,16), and (2, 8)
    LBPRadius = 1;    %[1 2 2];
    LBPNeighbor = 8;  %[8 16 8]; 
    FeatureNum = 4;         % mean, SD, skewness, kurtosis
    FeatureMatrix = zeros(LBPCombinationNum, FeatureNum);  
    NumX = size(Img, 1);
    NumY = size(Img, 2);
    NumZ = size(Img, 3);   
    
    for idxLBP = 1:LBPCombinationNum
        % Generate sampling filters
        Samples = generateRadialFilterLBP(LBPNeighbor(idxLBP), LBPRadius(idxLBP));
        if flag3D == 0
            LBPVolume = zeros(size(Img));
            for z = 1:NumZ
                CurrentSliceImg = Img(:,:,z);
                CurrentSliceLBP = efficientLBP(CurrentSliceImg, 'filtR', Samples, 'isRotInv', true, 'isChanWiseRot', false);
                LBPVolume(:,:,z) = CurrentSliceLBP;
            end            
        else
            AxialLBPMap = zeros(size(Img));
            AxialLBPVolume = AxialLBPMap;
            for z = 1:NumZ
                CurrentSliceImg = Img(:,:,z);
                CurrentSliceLBP = efficientLBP(CurrentSliceImg, 'filtR', Samples, 'isRotInv', true, 'isChanWiseRot', false);
                AxialLBPMap(:,:,z) = CurrentSliceLBP;
            end
            for z = 2:NumZ-1
                AxialLBPVolume(:,:,z) = AxialLBPMap(:,:,z-1)*power(2,LBPNeighbor(idxLBP)*2) + AxialLBPMap(:,:,z-1) ...
                    + AxialLBPMap(:,:,z)*power(2,LBPNeighbor(idxLBP))*2 ...
                    + AxialLBPMap(:,:,z+1) + AxialLBPMap(:,:,z+1)*power(2,LBPNeighbor(idxLBP)*2) ;
            end        
            AxialLBPVolume = AxialLBPVolume / 2;
            clear AxialLBPMap CurrentSliceImg CurrentSliceLBP;

            CoronalLBPMap = zeros(size(Img));
            CoronalLBPVolume = CoronalLBPMap;
            for x = 1:NumX
                CurrentSliceImg = Img(x,:,:);
                CurrentSliceLBP = efficientLBP(CurrentSliceImg, 'filtR', Samples, 'isRotInv', true, 'isChanWiseRot', false);
                CoronalLBPMap(x,:,:) = CurrentSliceLBP;
            end
            for x = 2:NumX-1
                CoronalLBPVolume(x,:,:) = CoronalLBPMap(x-1,:,:)*power(2,LBPNeighbor(idxLBP)*2) + CoronalLBPMap(x-1,:,:) ...
                    + CoronalLBPMap(x,:,:)*power(2,LBPNeighbor(idxLBP))*2 ...
                    + CoronalLBPMap(x+1,:,:) + CoronalLBPMap(x+1,:,:)*power(2,LBPNeighbor(idxLBP)*2) ;
            end        
            CoronalLBPVolume = CoronalLBPVolume / 2;        
            clear CoronalLBPMap CurrentSliceImg CurrentSliceLBP;

            SagittalLBPMap = zeros(size(Img));
            SagittalLBPVolume = SagittalLBPMap;
            for y = 1:NumY
                CurrentSliceImg = Img(:,y,:);
                CurrentSliceLBP = efficientLBP(CurrentSliceImg, 'filtR', Samples, 'isRotInv', true, 'isChanWiseRot', false);
                SagittalLBPMap(:,y,:) = CurrentSliceLBP;
            end
            for y = 2:NumY-1
                SagittalLBPVolume(:,y,:) = SagittalLBPMap(:,y-1,:)*power(2,LBPNeighbor(idxLBP)*2) + SagittalLBPMap(:,y-1,:) ...
                    + SagittalLBPMap(:,y,:)*power(2,LBPNeighbor(idxLBP))*2 ...
                    + SagittalLBPMap(:,y+1,:) + SagittalLBPMap(:,y+1,:)*power(2,LBPNeighbor(idxLBP)*2) ;
            end        
            SagittalLBPVolume = SagittalLBPVolume / 2;    
            LBPVolume = (AxialLBPVolume+CoronalLBPVolume+SagittalLBPVolume) / 3;
            clear SagittalLBPMap CurrentSliceImg CurrentSliceLBP AxialLBPVolume CoronalLBPVolume SagittalLBPVolume;
        end
        
        VoxelIndexes = find(Mask>0);
        VoxelNum = size(VoxelIndexes, 1);
        [X, Y, Z] = ind2sub(size(Mask), VoxelIndexes);
        clear VoxelIndexes; 

        % Get texture feature from gradient values
        LBPData = zeros(VoxelNum, 1);
        for i=1:VoxelNum
            LBPData(i) = LBPVolume(X(i), Y(i), Z(i));
        end

        FeatureMatrix(idxLBP, 1) = mean(LBPData);
        FeatureMatrix(idxLBP, 2) = sqrt(var(LBPData));
        FeatureMatrix(idxLBP, 3) = skewness(LBPData);
        FeatureMatrix(idxLBP, 4) = kurtosis(LBPData);            
    end
end

