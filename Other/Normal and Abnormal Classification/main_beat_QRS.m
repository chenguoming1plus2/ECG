%main_beat: Normal/abnormal ECG beat classification
%modified on 2017-11-06, Ping Cheng (pingch@uvic.ca)
%
%[1] Satija et. al, 'Robust cardiac event change detection method for long-term healthcare monitoring
%     applications'
%[2] Ngo et. al, 'Design of a Real-time Morphology-based Anomaly
%     Detection Method from ECG Streams'
%[3] Philip de Chazal et. al, 'Automatic Classification of Heartbeats Using
%     ECG Morphology and Heartbeat Interval Features

clear all
close all

%read raw data from the record
addpath('D:\E_ThinkpadX230\Current_ECG\Matlab\ECG_Ping\VF classification\libsvm-3.19\matlab');

load('data\mitdb_Rpeaks_filtered.mat');

database = mitdb;
L = length(database);
names = {database.name};
fs = database.fs;
theta_1 = 0.9;  % for modRRIR 0.68 - Table IV  %0.9 - Table III
theta_2 =  - 0.025; % for WCI
 
pl2 = round(0.220 * fs); % number of samples
tl2 = round(0.500 * fs); % 220ms ~ R peak ~ 500ms

signal_ref  = [100:109 111:119 121:124 200:203 205 207:210 212:215 217 219 220:223 228 230:234];

rec4 = signal_ref;

rec1 = [100:106 108 109 113 118 121 123 124 200 201 208 212 214 219 222 228 230 231]; %from Satija[1]
 
rec2 = [100 102 103 104 114 116 117 123 213 221 223 230 231 232 233]; %from Ngo[2]

rec3 = [100 103 105 111 113 117 121 123 200 202 210 212 213 214 219 221 222 228 231 232 233 234];%from Chazal[3]

rec7 = [100 102 103 113 115 121 124 205 213 214 215  230 231 233]; % the best selection


%----------------- variable train_size-----------------
% train_size_array = [10:10:100]; 
train_size_array =[20]; % for test variable nv
for k=1:length(train_size_array)
    train_size = train_size_array(k);
    
    %----------------variable nv------------------------
    nv_st = 0.02;%1/train_size_array(1) + 0.0001;
    %nv_array = [nv_st:0.02:0.30]; %for test variable train_size
    nv_array = [nv_st];%0.03 
    for j = 1:length(nv_array)
        nv = nv_array(j);    
          
        for n= 31%1:48%L  %8-bad  (Record209 - 31)
            if(~ismember(signal_ref(n), rec4))
                continue;
            end
    
        display(database(n).name)
        ecg_signal = database(n).ecg(:,1);    
        record_size = length(ecg_signal);

        % Windowed beats and corresponding labels
       R_true = database(n).R_positions; %calibrate the R-peak postions
       labels0 = database(n).R_labels;
   
   
        %% -------------------------------------------- labeling------------------------------------------------------  
        %------------labeling method 1:-----------------
        labels = labels0;
        for i = 1:length(labels)
            if (labels(i) == 1) || (labels(i) == 2) || (labels(i) == 3) || (labels(i) == 11) || (labels(i) ==15)
                labels(i) = 0;
            else
                labels(i)= 1;
            end
        end
   

        %% -------------------------------------feature extraction -----------------------------------------------
        % -----------------method 1: using R peak detector-------------------------
        %     rri_ratio = RQST_extraction_m1(ecg_signal,fs,view);
        % -----------------method 2: using annotated R peaks-------------------------
        [R_i,R_label, rri, rri_ratio] = RQST_extraction_m3(R_true, labels,theta_1);  
    
 
        %% ----------------------------------------remove outliers-----------------------------------------------
       lab_idx = labels0<=16; 
       lab_idx = lab_idx(3:(end-1));
       R_i =  R_i(lab_idx);
       R_iX = R_i/fs;
       R_label = -1 * R_label(lab_idx) + 1;
       rri = rri(lab_idx) / fs; % seconds
       rri_ratio = rri_ratio(lab_idx);
   

        %% ----------------------------------- preformance of rri_ratio --------------------------------------------------         
        scores_rri = (rri_ratio >  theta_1);
        [res_rri, count]= compute_metrics_2(scores_rri, R_label, 0, rri_ratio); 
        count_rri(n,:) = count;
        per_rri(n,:) = [signal_ref(n) res_rri];
    
    
        %% ---------------------------------- OC-SVM ----------------------------------------
        % training
        %------- Feature metrix 1-----------    
        %     X = [rri_ratio amp_ratio qrs_ratio wsi];
        %------- Feature metrix 2-----------
        a = R_i-pl2*ones(length(R_i),1);
        b = R_i+tl2*ones(length(R_i),1);
        for i = 1:length(R_i)
            %   X(i,:) = ecg_signal(a(i):b(i));
             X(i,:) = ecg_signal(a(i):b(i)) / ecg_signal(R_i(i)); % beat normalization
        end

        y = 2*R_label-1;  % Normal is positive: 1; otherwise, -1.
        idx0 = find(y==1);
       
        if(train_size > length(idx0))
            continue;
        end
        idx1 = idx0(1:train_size);
        idx2 = setdiff(1:length(R_i), idx1);

        ytr = y(idx1);
        Xtr = X(idx1,:);
        yte = y(idx2);
        Xte = X(idx2,:);
    
        svm_para =  ['-s 2 -t 2 -n ' num2str(nv) ' -g 0.5'];   
        ocsvm_model_seg = svm_train_PRT(ytr,Xtr, svm_para, pl2);
        [pred_tr, dec_value_tr] = svm_predict_PRT(ytr, Xtr, ocsvm_model_seg,pl2);
        [pred_te,dec_value_te] = svm_predict_PRT(yte, Xte, ocsvm_model_seg,pl2);  

        %----------M2-------------
        %     score = sum(pred_te(2:end,:),2); % M2:current P/R/T
        %----------M3-------------
        score = (dec_value_te > theta_2);
        score = 2*score -1;
        score = sum(score(2:end,:),2); 

        score(score>0)= 1;
        score(score<=0) = -1; % abnormal
        [res_3, count_3] = compute_metrics_2(score, yte(2:end), -1);
        cn_3(n,:) = count_3;
        per_3(n,:) = [signal_ref(n) res_3];
         % ---------------------------------- end of OC-SVM ----------------------------------------
    
    
        %% Combination of WCI and modRRIR
        scores_rri = 2* scores_rri-1;
        scores_rri = scores_rri(idx2);
        scores_rri = scores_rri(2:end);
        score_c =  scores_rri + score; % M2:current P/R/T
        score_cc = (score_c > 0);
        score_cc = 2*score_cc-1; 
        [res_4, count_4] = compute_metrics_2(score_cc, yte(2:end), -1);
        cn_4(n,:) = count_4;
        per_4(n,:) = [signal_ref(n) res_4];


    end  % end of record number n

    
    %% ----------------------------------- Overall performance--------------------------------------------------   
    a = sum(cn_4,1);
    se = roundn(a(3)/a(1),-4) * 100;
    sp = roundn(a(4)/a(2),-4) * 100;
    pp = roundn(a(3)/(a(2)-a(4)+a(3)),-4) * 100;
    acc = roundn((a(3)+a(4))/(a(1)+a(2)),-4) * 100;
    metrix = [se sp pp acc];


    %-----------------  nv vs. Overall performance------------------
    Percent_nv(j, :) = [nv metrix];


end %end of the loop for variable nv


% ----------------  Train_size vs. Overall result-------------------
% Percent_train(k,:) = [train_size metrix];


end % end of the loop for variable train_size 





