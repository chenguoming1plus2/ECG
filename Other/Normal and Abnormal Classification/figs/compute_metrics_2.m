function [stats,count] = compute_metrics_2(labels,scores,value,decision_values)
% Inputs:
%       labels: classified labels
%       scores: the ground truth

% positive class: Shockable rhythms
fv = find(scores == 1);
tp = sum(labels(fv)==1);
fn = sum(labels(fv)==value);
pc = tp + fn;

% negative class: Others
rs = find(scores == value);
tn = sum(labels(rs)==value);
fp = sum(labels(rs)==1);
nc = tn + fp;

% metrics
sen = tp/(tp+fn) * 100; %Sensitivity, Also known as Recall
esp = tn/(tn+fp) * 100; %Especificity,  Also known as True Negative Rate
pp  = tp/(tp+fp) * 100; %Pos. Predictivity, Also as Precision
acc = (tp + tn) / (pc + nc) * 100; % Accuracy
err = 100-acc;               % Error rate
fsc = 2*pp*sen / (pp + sen); % F-measure
ber = 0.5* (fn/pc + fp/nc ) * 100 ;  
gme = sqrt(sen*esp); % G-measure

% ROC curve
if nargin > 3
    if length(unique(scores)) == 1
        auc = NaN;
    else
       [~,~,~,auc] = perfcurve(scores,decision_values,1); %assign 1 to be the positive class label
        if auc < 0.5
            auc = 1 - auc;
        end
        auc = auc*100;
    end
else 
    auc = 0;
end

%stats = [sen,esp,pp,acc,err,fsc,ber,gme,auc];
stats = roundn([acc,sen,esp,pp,auc],-1);
count = [pc nc tp tn];


