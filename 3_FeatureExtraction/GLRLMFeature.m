function [ FeatureMatrix ] = GLRLMFeature(Img, Mask, flag3D, RLMGreyLevel, RLMMaxLength)
    if nargin < 3
        flag3D = 1;
    end
    
    % Initialization
    if flag3D == 0
        RLMDirectionNum = 4;
        RLMOffsetX = [1 1 0 -1];
        RLMOffsetY = [0 -1 -1 -1]; 
        RLMOffsetZ = [0 0 0 0];
    else
        RLMDirectionNum = 13;
        RLMOffsetX = [0 -1 -1 -1 0 0 0 -1 1 -1 1 -1 1];
        RLMOffsetY = [1 1 0 -1 1 0 -1 0 0 1 -1 -1 1];
        RLMOffsetZ = [0 0 0 0 -1 1 -1 -1 -1 -1 -1 -1 -1];              
    end    
    FeatureNum = 11;
        % RLM Features 
        % 1. Short Run Emphasis (SRE)
        % 2. Long Run Emphasis (LRE)
        % 3. Gray-Level Nonuniformity (GLN)
        % 4. Run Length Nonuniformity (RLN)
        % 5. Run Percentage (RP)
        % 6. Low Gray-Level Run Emphasis (LGRE)
        % 7. High Gray-Level Run Emphasis (HGRE)
        % 8. Short Run Low Gray-Level Emphasis (SRLGE)
        % 9. Short Run High Gray-Level Emphasis (SRHGE)
        % 10. Long Run Low Gray-Level Emphasis (LRLGE)
        % 11. Long Run High Gray-Level Emphasis (LRHGE)       
    FeatureMatrix = zeros(1, FeatureNum);

    % Find WMH voxel indexes, to access as WMH.img(WMHX, WMHY, WMZ)
    VoxelIndexes = find(Mask>0);
    VoxelNum = size(VoxelIndexes, 1);
    [X, Y, Z] = ind2sub(size(Mask), VoxelIndexes);
    clear VoxelIndexes;

    % for each Direction
    RLMatrix = zeros(RLMGreyLevel, RLMMaxLength);    
    for idxDirection = 1:RLMDirectionNum
        % Calculate RLM for each direction
        PreviousRunMask = zeros(size(Img));

        for i=1:VoxelNum
            % Skip, if the current voxel was in a previous run in this direction
            if PreviousRunMask(X(i), Y(i), Z(i)) == 1
                continue;
            end

            VoxelIntensity = Img(X(i), Y(i), Z(i));
            ConsecutiveLength = 0;
            for idxDistance = 1:100
                if X(i)+idxDistance*RLMOffsetX(idxDirection) < 1 || Y(i)+idxDistance*RLMOffsetY(idxDirection) < 1 || Z(i)+idxDistance*RLMOffsetZ(idxDirection) < 1
                    continue;
                elseif X(i)+idxDistance*RLMOffsetX(idxDirection) > size(Mask, 1) || Y(i)+idxDistance*RLMOffsetY(idxDirection) > size(Mask, 2) || Z(i)+idxDistance*RLMOffsetZ(idxDirection) > size(Mask, 3)
                    continue;
                end 

                NeighborCCL = Mask(X(i)+idxDistance*RLMOffsetX(idxDirection), ...
                    Y(i)+idxDistance*RLMOffsetY(idxDirection), Z(i)+idxDistance*RLMOffsetZ(idxDirection));
                if NeighborCCL == 0
                    break;                        
                end
                NeighborIntensity = Img(X(i)+idxDistance*RLMOffsetX(idxDirection), ...
                    Y(i)+idxDistance*RLMOffsetY(idxDirection), Z(i)+idxDistance*RLMOffsetZ(idxDirection));
                if NeighborIntensity ~= VoxelIntensity
                    ConsecutiveLength = idxDistance - 1;
                    break;
                end
                PreviousRunMask(X(i)+idxDistance*RLMOffsetX(idxDirection), ...
                    Y(i)+idxDistance*RLMOffsetY(idxDirection), Z(i)+idxDistance*RLMOffsetZ(idxDirection)) = 1;
            end
            Length = 1 + ConsecutiveLength;
            ConsecutiveLength = 0;
            for idxDistance = 1:100
                if X(i)-idxDistance*RLMOffsetX(idxDirection) < 1 || Y(i)-idxDistance*RLMOffsetY(idxDirection) < 1 || Z(i)-idxDistance*RLMOffsetZ(idxDirection) < 1
                    continue;
                elseif X(i)-idxDistance*RLMOffsetX(idxDirection) > size(Mask, 1) || Y(i)-idxDistance*RLMOffsetY(idxDirection) > size(Mask, 2) || Z(i)-idxDistance*RLMOffsetZ(idxDirection) > size(Mask, 3)
                    continue;
                end                     
                NeighborCCL = Mask(X(i)-idxDistance*RLMOffsetX(idxDirection), ...
                    Y(i)-idxDistance*RLMOffsetY(idxDirection), Z(i)-idxDistance*RLMOffsetZ(idxDirection));
                if NeighborCCL == 0
                    break;                        
                end                    
                NeighborIntensity = Img(X(i)-idxDistance*RLMOffsetX(idxDirection), ...
                    Y(i)-idxDistance*RLMOffsetY(idxDirection), Z(i)-idxDistance*RLMOffsetZ(idxDirection));
                if NeighborIntensity ~= VoxelIntensity
                    ConsecutiveLength = idxDistance - 1;
                    break;
                end
                PreviousRunMask(X(i)-idxDistance*RLMOffsetX(idxDirection), ...
                    Y(i)-idxDistance*RLMOffsetY(idxDirection), Z(i)-idxDistance*RLMOffsetZ(idxDirection)) = 1;
            end
            Length = Length + ConsecutiveLength;

            if Length > RLMMaxLength
                Length = RLMMaxLength;
            end
            RLMatrix(VoxelIntensity, Length) = RLMatrix(VoxelIntensity, Length) + 1;
        end
        GLRLM{idxDirection} = RLMatrix;
    end
    RLMFeatures = GLRLM_Features1(GLRLM);
    RLMFeatures = mean(RLMFeatures, 1);
    FeatureMatrix(1,:) = RLMFeatures(:);       
end

