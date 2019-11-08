function [ result_measure, result_roc, likelihood ] = Step5_TestRF(test_feature, test_label, feature_mean, feature_sd, selectedIdx, minimumInfarctSize, RFmodel, RFthrehold)


%% Feature normalization
NumFeature = size(test_feature, 2);
rescaled = test_feature;
for c = 1:NumFeature
    rescaled(:,c) = test_feature(:,c) - feature_mean(c);
    rescaled(:,c) = rescaled(:,c) / feature_sd(c);
end
SelectedFeatureSet = rescaled(:,selectedIdx);

%% size thresholding
removed_cases = find(test_feature(:,1)<minimumInfarctSize);
SelectedFeatureSet(removed_cases, :) = [];
test_label(removed_cases, :) = [];
labelPositive = 1;
labelNegative = 0;

%% ----------------------------------------------- Evaulate the performance
[labelTestPredict, prob_estimates] = predict(RFmodel,SelectedFeatureSet);
[A, B, C, D, E] = perfcurve(test_label,prob_estimates(:,2),labelPositive);
result_roc.X = A;
result_roc.Y = B;
result_roc.T = C;
result_roc.AUC = D;
result_roc.cutPt = E;

likelihood = prob_estimates(:,2);
labelTestPredict = str2num(cell2mat(labelTestPredict));
labelTestPredict(prob_estimates(:,2)>RFthrehold) = labelPositive;
labelTestPredict(prob_estimates(:,2)<=RFthrehold) = labelNegative;
labelTestP = labelTestPredict(test_label==labelPositive);
TP = numel(find(labelTestP==labelPositive));
FN = numel(find(labelTestP==labelNegative));
labelTestN = labelTestPredict(test_label==labelNegative);
FP = numel(find(labelTestN==labelPositive));
TN = numel(find(labelTestN==labelNegative));  

result_measure.accuracy =  (TP+TN)/( TP + FN + FP + TN );
result_measure.specificity = TN / (TN+FP) ; % tn / ( tn + fp) 
result_measure.sensitivity =  TP / (TP+FN) ; % tp / (tp + fn)
result_measure.PPV = TP / (TP + FP);
result_measure.NPV = TN / (FN + TN);   
    
end        
        

