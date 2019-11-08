function [ optimalGLMmodel, optimalThrehold ] = Step4_2_TrainGLM(train_feature, train_label, feature_mean, feature_sd, selectedIdx, minimumInfarctSize)
%% Input arguments:
% Mean and SD of each feature was calculated from the train set.
% These values are used to the feature normalization for both of train and
% test set.
% feature_mean - a vector with size of 1 x F.
%                F represents the number of features for each patient.
% feature_SD - a vector with size of 1 x F. 
% selectedIdx - a vector that contains the selected feature indexes 
%% Output:

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

%% Logistic regression 
optimalGLMmodel = fitglm(SelectedFeatureSet, train_label, 'Distribution','binomial', 'link', 'logit');
prob_estimates = predict(optimalGLMmodel,SelectedFeatureSet);
beta = 0.5;
labelPositive = 1;
labelNegative = 0;

for i_prob = 1:25
    % F score 
    t_prob = 0.5 + 0.025 * (i_prob-13);
    labelPredict(prob_estimates(:,1)>t_prob) = labelPositive;
    labelPredict(prob_estimates(:,1)<=t_prob) = labelNegative;
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
        

