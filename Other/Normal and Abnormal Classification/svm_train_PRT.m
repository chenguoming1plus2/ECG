%svm_train_PRT: Normal/abnormal ECG beat detection
%Ping Cheng pingch@uvic.ca

function   ocsvm_model_seg   = svm_train_PRT(ytr,Xtr, svm_para,pl)
    [pwave,rwave,twave] = seg_method(Xtr,pl);
    pmode = svmtrain(ytr, pwave, svm_para);
    rmode = svmtrain(ytr, rwave, svm_para);
    tmode = svmtrain(ytr, twave, svm_para);
    ocsvm_model_seg = {pmode,rmode,tmode};
end 