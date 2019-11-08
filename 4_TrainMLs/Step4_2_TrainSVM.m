function [ optimalSVMmodel, optimalThrehold ] = Step4_2_TrainSVM(train_feature, train_label, feature_mean, feature_sd, selectedIdx, minimumInfarctSize)

%% Feature normalization
NumFeature = size(train_feature, 2);
rescaled = train_feature;
for c = 1:NumFeature
    rescaled(:,c) = train_feature(:,c) - feature_mean(c);
    rescaled(:,c) = rescaled(:,c) / feature_sd(c);
end
SelectedFeatureSet = rescaled(:,selectedIdx);

%% size thresholding
removed_cases = find(train_feature(:,1)<minimumInfarctSize);
SelectedFeatureSet(removed_cases, :) = [];
train_label(removed_cases, :) = [];

%% Set validation set (equal to train set)
labelTraningSet = train_label; 
labelValidateSet = train_label; 
featureTrainingSet = SelectedFeatureSet;  
featureValidationSet = SelectedFeatureSet;
labelPositive = 1;
labelNegative = 0;

%% Find optimal svm parameters
TypeKernel = 1;
idxModel = 1;
beta = 0.5;
for c = -5:2:15
    for g = -15:2:3
        
        if TypeKernel == 1      % linear
            strCommand = ['-s 0 -c ', num2str(2^c), ' -t 0 -g ', num2str(2^g), ' -r 0 -d 3 -h 0 -b 1'];
        else
            strCommand = ['-s 0 -c ', num2str(2^c), ' -t 2 -g ', num2str(2^g), ' -r 0 -d 3 -h 0 -b 1'];
        end
        
        SVMmodel(idxModel) = svmtrain(labelTraningSet,featureTrainingSet, strCommand);
        [labelValidatePredict, sfs_accuracy_L, prob_estimates] = svmpredict(labelValidateSet, featureValidationSet, SVMmodel(idxModel), '-b 1'); 

        for i_prob = 1:25
            % F score 
            t_prob = 0.5 + 0.025 * (i_prob-13);
            labelValidatePredict(prob_estimates(:,1)>t_prob) = labelPositive;
            labelValidatePredict(prob_estimates(:,1)<=t_prob) = labelNegative;
            labelTestP = labelValidatePredict(labelValidateSet==labelPositive);
            TP = numel(find(labelTestP==labelPositive));
            FN = numel(find(labelTestP==labelNegative));
            labelTestN = labelValidatePredict(labelValidateSet==labelNegative);
            FP = numel(find(labelTestN==labelPositive));
            TN = numel(find(labelTestN==labelNegative));                

            specificity = TN / (TN+FP) ; % tn / ( tn + fp) 
            sensitivity =  TP / (TP+FN) ; % tp / (tp + fn)                        
            recall = TP/(TP + FN);
            precision = TP/(TP + FP);            
            Fterm = (precision*recall)/(((beta^2)*precision)+recall);
            F0_5score_temp(i_prob) = ((1+(beta^2)) * Fterm);
            F1score_temp(i_prob) = ((precision*recall)/(precision+recall));  
            Youdenindex(i_prob) = sensitivity + specificity - 1;
        end
        [maxF0_5score_temp, idxOptimalThresh] = max(F0_5score_temp);

        F0_5score(idxModel) = F0_5score_temp(idxOptimalThresh);
        F1score(idxModel) = F1score_temp(idxOptimalThresh);
        ProbThreshold(idxModel) = 0.5 + 0.025 * (idxOptimalThresh-13);

        idxModel = idxModel + 1;       
        clear F0_5score_temp F1score_temp;
    end
end
clear labelTestP labelTestN TP FN FP TN;

[maxF0_5score, idxOptimalSVM] = max(F0_5score); 
if numel(find(F0_5score==maxF0_5score)) > 1
    [maxF1score, idxSubOptimalSVM] = max(F1score(idxOptimalSVM));
    optimalSVMmodel = SVMmodel(idxOptimalSVM(idxSubOptimalSVM(1)));  
    optimalThrehold = ProbThreshold(idxOptimalSVM(idxSubOptimalSVM(1)))
else
    optimalSVMmodel = SVMmodel(idxOptimalSVM);  
    optimalThrehold = ProbThreshold(idxOptimalSVM);  
end 
    
end        
        

