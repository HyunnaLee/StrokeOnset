function [ feature_mean, feature_sd, selectedIdx ] = Step4_1_FeatureSelection( features, labels )
% This function is to select features using filtering approach (i.e., % univariate analysis) from the train set
%% Input arguments:
% features - a feature matrix with size of N x F.
%            N represents the number of patients.
%            F represents the number of features for each patient.
% labels - a lavel vector with size of N x 1.
%            N represents the number of patients.

%% Output:
% Mean and SD of each feature is calculated from the train set.
% These values are used to the feature normalization for both of train and
% test set.
% feature_mean - a vector with size of 1 x F. 
% feature_SD - a vector with size of 1 x F. 
% selectedIdx - a vector that contains the selected feature indexes 

labelPositive = 1;
labelNegative = 0;
PositiveFeatures = features(find(labels == labelPositive), :);
NegativeFeatures = features(find(labels == labelNegative), :);

feature_mean = mean(features, 1);
feature_sd = std(features, 0, 1);

NumFeature = size(features, 2);
Htest = ones(NumFeature,1);
Pvalue = zeros(NumFeature,1);
for i = 1:NumFeature
    x = PositiveFeatures(:,i);
    y = NegativeFeatures(:,i);   
    
    [h,p,ca,stats] = ttest2(x,y,'Vartype','unequal','Alpha', 0.2 / NumFeature);
    Htest(i,1) = h;    
    Pvalue(i,1) = p;    
end

selectedIdx = find(Htest(:,1));
if size(selectedIdx,1) < 5
    [sorted, sorted_idx] = sort(Pvalue);
    selectedIdx = sorted_idx(1:5);
end
end

