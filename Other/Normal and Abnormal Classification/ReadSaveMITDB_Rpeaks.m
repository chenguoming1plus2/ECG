%-------------------------
% ReadSaveMITDB_Rpeaks.m
%   --- convert cells of beats to matrix
%
% Created by Ping Cheng, pingch@uvic.ca
% Version 1.0, at 12:35pm on Mar. 09, 2017
%-------------------------

clear, close all, clc
% MIT arrhtyhmia database
% http://www.physionet.org/physiobank/database/mitdb/

addpath('D:\E_ThinkpadX230\Current_ECG\Matlab\WFDB\mcode');
path       = 'data\mitdb\';
signal_ref  = [100:109 111:119 121:124 200:203 205 207:210 212:215 217 219 220:223 228 230:234];

for i=1:length(signal_ref) 
    %--- read ECG
    ecgName = [path num2str( signal_ref(i) )]; disp(ecgName);
    annName = [path num2str( signal_ref(i) )];
    annFile = rdann(annName,'atr');  %More info could be obtained from here.

    ann  = beat_label_table( annFile );    % processed annotations file 
    info = wfdbdesc(ecgName); %read information about the record, such as Fs, length, gain, lead num
    [tm,signal1, Fs]  = rdsamp(ecgName,1); % read 2-lead ecg signal, by Ping, 2015-02-09
    [tm,signal2]    = rdsamp(ecgName,2); 
    r = [tm, signal1,signal2];
    ecga0 = r(:,2);  % no filtering
    ecgb0 = r(:,3);
    
    ecga = filtering(r(:,2), Fs, 2); % r(:,2:3) -- Original ECG
    ecgb = filtering(r(:,3), Fs, 2); 
    
%     figure()
%     plot(ecga,'--g')
%    
    %--------------------------
    % R positions
    R_positions = zeros(length(ann),1);
    R_labels = zeros(length(ann),1);
    for kk = 1:length(ann)
        R_positions(kk) = ann(kk).sampleNumber;
        R_labels(kk) = ann(kk).typeMnemonic;
    end
    
    R_amp = ecga0(R_positions);
    for i = 2:length(R_amp)
        amp_ratio(i) = abs(R_amp(i)-R_amp(i-1)) / min(R_amp(i), R_amp(i-1)) / 0.25;  %A change: amp_ratio is larger than thres = 1.0
    end
    d_thres = 1;
   scores = rri_ratio < d_thres;
    scores = amp_ratio > d_thres;
    [res, count]= compute_metrics_2(scores,R_labels,0);
    figure(2)
    plot(R_positions, R_amp)
    hold on
    plot(R_positions(R_labels~=1), R_amp(R_labels~=1),'ro');
    hold on
    plot(R_positions, amp_ratio, 'k-')
    hold off
%     
%     figure()
%     plot(1:length(ecga0),ecga0,'g--')
%     hold on
%     plot(1:length(ecga),1.5*ecga-0.3,'b')
%     hold on
%     plot(R_positions(R_labels~=1),ecga0(R_positions((R_labels~=1))),'ko')  % no delay
    
    %-- saving data in struct form   
    mitdb(i).name  = num2str( signal_ref(i) );
    if i == 14
        mitdb(i).ecg   = [ecgb ecga];%exchange lead orders as the 2nd lead is Lead II
    else 
        mitdb(i).ecg   = [ecga ecgb];
    end
    mitdb(i).R_labels = R_labels;
    mitdb(i).leads = {info(1).Description,info(2).Description};
    mitdb(i).fs    = Fs;%info.samplingFrequency;
    mitdb(i).R_positions  = R_positions; % 3-points delay
    
end

savepath = '';
filename = 'data\mitdb_Rpeaks_filtered.mat';

save([savepath filename],'mitdb');

