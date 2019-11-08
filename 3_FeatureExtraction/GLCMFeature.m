function [ FeatureMatrix ] = GLCMFeature(Img, Mask, flag3D, GLCMGreyLevel)
    if nargin < 3
        flag3D = 1;
    end
    
    % Initialization
    GLCMDistanceNum = 1;
    if flag3D == 0
        GLCMDirectionNum = 4;
        GLCMOffsetX = [1 1 0 -1];
        GLCMOffsetY = [0 -1 -1 -1]; 
        GLCMOffsetZ = [0 0 0 0];
    else
        GLCMDirectionNum = 13;
        GLCMOffsetX = [0 -1 -1 -1 0 0 0 -1 1 -1 1 -1 1];
        GLCMOffsetY = [1 1 0 -1 1 0 -1 0 0 1 -1 -1 1];
        GLCMOffsetZ = [0 0 0 0 -1 1 -1 -1 -1 -1 -1 -1 -1];           
    end
    FeatureNum = 21;
        % GLCM Features (Soh, 1999; Haralick, 1973; Clausi 2002)
        % f1. Uniformity / Energy / Angular Second Moment (done)
        % f2. Entropy (done)
        % f3. Dissimilarity (done)
        % f4. Contrast / Inertia (done)
        % f5. Inverse difference    
        % f6. correlation
        % f7. Homogeneity / Inverse difference moment
        % f8. Autocorrelation
        % f9. Cluster Shade
        % f10. Cluster Prominence
        % f11. Maximum probability
        % f12. Sum of Squares
        % f13. Sum Average
        % f14. Sum Variance
        % f15. Sum Entropy
        % f16. Difference variance
        % f17. Difference entropy
        % f18. Information measures of correlation (1)
        % f19. Information measures of correlation (2)
        % f20. Inverse difference normalized (INN)
        % f21. Inverse difference moment normalized (IDN)  
        % fXX. Maximal correlation coefficient        
    FeatureMatrix = zeros(1, FeatureNum);
       
    % for each WMH component
    GLCMatrix = zeros(GLCMGreyLevel);
    % Find WMH voxel indexes, to access as WMH.img(WMHX, WMHY, WMZ)
    VoxelIndexes = find(Mask>0);
    VoxelNum = size(VoxelIndexes, 1);
    [WMHX, WMHY, WMHZ] = ind2sub(size(Mask), VoxelIndexes);
    clear VoxelIndexes;

    % for each GLCM distance
    for idxDistance = 1:GLCMDistanceNum
        % for each Direction
        for idxDirection = 1:GLCMDirectionNum
            % Calculate GLCM for each combination of distance and direction

            for i=1:VoxelNum
                VoxelIntensity = Img(WMHX(i), WMHY(i), WMHZ(i));
                if WMHX(i)+idxDistance*GLCMOffsetX(idxDirection) < 1 || WMHY(i)+idxDistance*GLCMOffsetY(idxDirection) < 1 || WMHZ(i)+idxDistance*GLCMOffsetZ(idxDirection) < 1
                    continue;
                elseif WMHX(i)+idxDistance*GLCMOffsetX(idxDirection) > size(Mask, 1) || WMHY(i)+idxDistance*GLCMOffsetY(idxDirection) > size(Mask, 2) || WMHZ(i)+idxDistance*GLCMOffsetZ(idxDirection) > size(Mask, 3)
                    continue;
                end

                NeighborCCL = Mask(WMHX(i)+idxDistance*GLCMOffsetX(idxDirection), ...
                            WMHY(i)+idxDistance*GLCMOffsetY(idxDirection), WMHZ(i)+idxDistance*GLCMOffsetZ(idxDirection));       
                if NeighborCCL > 0
                    NeighborIntensity = Img(WMHX(i)+idxDistance*GLCMOffsetX(idxDirection), ...
                                        WMHY(i)+idxDistance*GLCMOffsetY(idxDirection), WMHZ(i)+idxDistance*GLCMOffsetZ(idxDirection));
                    GLCMatrix(VoxelIntensity, NeighborIntensity) = GLCMatrix(VoxelIntensity, NeighborIntensity) + 1;
                    GLCMatrix(NeighborIntensity, VoxelIntensity) = GLCMatrix(NeighborIntensity, VoxelIntensity) + 1;
                end
            end
        end
    end
    GLCMFeatures = GLCM_Features3(GLCMatrix,0);
    FeatureMatrix(1, 1) = GLCMFeatures.energ;
    FeatureMatrix(1, 2) = GLCMFeatures.entro;
    FeatureMatrix(1, 3) = GLCMFeatures.dissi;
    FeatureMatrix(1, 4) = GLCMFeatures.contr;
    FeatureMatrix(1, 5) = GLCMFeatures.homom;
    FeatureMatrix(1, 6) = GLCMFeatures.corrp;
    FeatureMatrix(1, 7) = GLCMFeatures.homop;
    FeatureMatrix(1, 8) = GLCMFeatures.autoc;
    FeatureMatrix(1, 9) = GLCMFeatures.cshad;
    FeatureMatrix(1, 10) = GLCMFeatures.cprom;
    FeatureMatrix(1, 11) = GLCMFeatures.maxpr;
    FeatureMatrix(1, 12) = GLCMFeatures.sosvh;
    FeatureMatrix(1, 13) = GLCMFeatures.savgh;
    FeatureMatrix(1, 14) = GLCMFeatures.svarh;    
    FeatureMatrix(1, 15) = GLCMFeatures.senth;
    FeatureMatrix(1, 16) = GLCMFeatures.dvarh;
    FeatureMatrix(1, 17) = GLCMFeatures.denth;
    FeatureMatrix(1, 18) = GLCMFeatures.inf1h;
    FeatureMatrix(1, 19) = GLCMFeatures.inf2h;  
    FeatureMatrix(1, 20) = GLCMFeatures.indnc;
    FeatureMatrix(1, 21) = GLCMFeatures.idmnc;        
end

