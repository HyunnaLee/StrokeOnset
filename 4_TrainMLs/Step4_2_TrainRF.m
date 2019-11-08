function [optimalRFmodel, optimalThrehold] = Step4_2_TrainRF(train_feature, train_label, feature_mean, feature_sd, selectedIdx, minimumInfarctSize)

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

%% Tree Bagger
labelPositive = 1;
labelNegative = 0;
optimalRFmodel = TreeBagger(500,SelectedFeatureSet,train_label);
[labelTestPredict, prob_estimates] = predict(optimalRFmodel,SelectedFeatureSet);

beta = 0.5;
for i_prob = 1:25
    % F score 
    t_prob = 0.5 + 0.025 * (i_prob-13);
    labelPredict(prob_estimates(:,2)>t_prob) = labelPositive;
    labelPredict(prob_estimates(:,2)<=t_prob) = labelNegative;
    labelTestP = labelPredict(train_label==labelPositive);
    TP = numel(find(labelTestP==labelPositive));
    FN = numel(find(labelTestP==labelNegative));
    labelTestN = labelPredict(train_label==labelNegative);
    FP = numel(find(labelTestN==labelPositive));
    TN = numel(find(labelTestN==labelNegative));                

    specificity = TN / (TN+FP) ; % tn / ( tn + fp) 
    sensitivity =  TP / (TP+FN) ; % tp / (tp + fn)                        
    recall = TP/(TP + FN);
    precision = TP/(TP + FP);            
    Fterm = (precision*recall)/(((beta^2)*precision)+recall);
    F0_5score(i_prob) = ((1+(beta^2)) * Fterm);
    F1score(i_prob) = ((precision*recall)/(precision+recall));  
    Youdenindex(i_prob) = sensitivity + specificity - 1;
end
[maxF0_5score, idxOptimalThresh] = max(F0_5score); 
optimalThrehold = 0.5 + 0.025 * (idxOptimalThresh-13);
end        
        

