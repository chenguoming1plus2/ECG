%svm_predict_PRT: Prediction
%Ping Cheng pingch@uvic.ca

function [pred_tr, dec_value] = svm_predict_PRT(ytr, Xtr, ocsvm_model_seg,pl)
    [pwave,rwave,twave] = seg_method(Xtr,pl);
    [pred0, ~, dec_value0] = svmpredict(ytr, pwave, ocsvm_model_seg{1});
    [pred1, ~, dec_value1] = svmpredict(ytr, rwave, ocsvm_model_seg{2});
    [pred2, ~, dec_value2] = svmpredict(ytr, twave, ocsvm_model_seg{3});
    pred_tr = [pred0,pred1,pred2];
    dec_value = [dec_value0 dec_value1 dec_value2];
end