%For Normal vs. Abnormal detection
%Created on Oct. 19, 2017 by Ping Cheng

%% Beat segmentation    
clear all
close all
if 0
    load beat_segment.mat
    fs = 360;  % MITDB
    pl = round(0.250 * fs); % number of samples
    tl = round(0.500 * fs); % 220ms ~ R peak ~ 500ms
    signal = ecg_mitdb_100;
    qrs = R_i;
    % x_seg_min = min(signal);
    % x_seg_max = max(signal);
    % signal = (signal - x_seg_min) / (x_seg_max - x_seg_min);
    % x = [1:length(signal)];
    % plot(x/fs,signal(x),'LineWidth',1.5)
    xlabel('Time (s)','FontSize',14);
    ylabel('Amplitude (mV)','FontSize',14);
    hold on

    seg_idx =round( [(2.3*fs):(4.8*fs)]);
    qrs_idx = find((R_i<seg_idx(end)) & (R_i>seg_idx(1)));
    qrs_seg = R_i(qrs_idx) - seg_idx(1) + 1;
    x_seg = signal(seg_idx);

    plot( [1:length(x_seg)]/fs, x_seg,'LineWidth',1.5);
    hold on
    plot(qrs_seg/fs, x_seg(qrs_seg),'ro','LineWidth',1.5)
    set(gca,'FontSize',14) % gca is for the axis change
    axis([0 2.6 -0.35 1.01]);
    set(gca,'FontSize',14)
    hold on

    %divide every segment into several QRS blocks
    delta = 80;
    win1 = ceil(2*delta * fs /1000);  %????RR interval???
    win11 = ceil(win1/3);
    win12 = win1 - win11;

    qrs_start= qrs_seg - win11;
    qrs_stop = qrs_seg + win12;
    winhigh = 1.1;
    winlow = -0.1;
    segLineR = (winlow-0.3:0.01:winhigh-0.1);

    for i = 1: 3
        plot(ones(length(segLineR),1)*qrs_seg(i)/fs, segLineR, 'k-.','LineWidth',1.5)
        hold on
    end
    plot_arrow([qrs_seg(1)/fs qrs_seg(2)/fs], [0.9 0.9], 'RRI_i_-_1');
    hold on;
    plot_arrow([qrs_seg(2)/fs qrs_seg(3)/fs], [0.9 0.9], 'RRI_i');
    hold on;

    % Annotations for a single beat
    beat_start = qrs_seg(2)-pl;
    beat_end = qrs_seg(2)+tl;
    segLineBeat = (winlow-0.3:0.01:winhigh-0.3);
    segLineQRS = (winlow:0.01:winhigh-0.3);
    plot(ones(length(segLineBeat),1) * beat_start/fs, segLineBeat,'k-.','LineWidth',1.0)
    hold on
    plot(ones(length(segLineBeat),1) * beat_end/fs, segLineBeat,'k-.','LineWidth',1.0)
    hold on
    plot(ones(length(segLineQRS),1) * qrs_start(2)/fs, segLineQRS,'k-.','LineWidth',1.0)
    hold on 
    plot(ones(length(segLineQRS),1) * qrs_stop(2)/fs,segLineQRS,'k-.','LineWidth',1.0)
    plot_arrow([beat_start qrs_start(2)]/fs, [0.60 0.60],' P')
    plot_arrow([qrs_start(2) qrs_stop(2)]/fs, [0.75 0.75],'QRS')
    plot_arrow([qrs_stop(2) beat_end]/fs, [0.60 0.60],'T')
    plot_arrow([beat_start qrs_seg(2)]/fs, [-0.25 -0.25], '0.22')
    plot_arrow([qrs_seg(2) beat_end ]/fs, [-0.25 -0.25], '0.50')
    set(gca,'FontSize',14)
    hold off
end



%% Modified RRIR
if 1
    filename = 'Record209_modRRIR.mat';
    load(filename);
    rri_ratio_orig = rri_ratio_orig;
    rri_ratio= rri_ratio;
    R_t = R_i/fs;
    rri_thres = ones(length(R_t),1) *0.9;
    
    %classification performance
    label_normal = -1 * R_label +1;
    scores_rri0 = (rri_ratio_orig >  rri_thres(1));
    [res_rri0, count0]= compute_metrics_2(scores_rri0, label_normal, 0, rri_ratio_orig); 
    scores_rri = (rri_ratio >  rri_thres(1));
    [res_rri, count]= compute_metrics_2(scores_rri, label_normal, 0, rri_ratio); 
    
    figure(12)
    plot(R_t, rri_ratio_orig, 'g--','LineWidth',1.5);
    hold on
    plot(R_t, rri_ratio, 'b-','LineWidth',1.5);
    hold on 
    plot(R_t, rri_thres, 'm--', 'LineWidth',1.5);
    hold on
%     plot(R_t(find(rri_ratio<rri_thres)), rri_ratio(rri_ratio<rri_thres),'bs','LineWidth',1.5 );
%     hold on
    plot(R_t(find(R_label==1)), rri_ratio(R_label==1),'ro','LineWidth',1.5);
    hold off
    legend('RRIR','modRRIR','Threshold','Real Abnormal','Detected Abnormal','Location','NorthEast');
    xlabel('Time (s)','FontSize',14);
    set(gca,'FontSize',14)
    axis([590 650 0 1.1]);
    annotation('textbox',[0.21 0.21 0.1 0.65],'FitBoxToText','on')
    figure(2) % the ecg waveform    
    idx =  find(R_t>596 & R_t<=604);
    idx2 = idx(R_label(idx) == 1);
    idx2 = idx2(2:end);
    plot(R_t(idx2),ecg_signal(R_i(idx2)),'ro','LineWidth',1.5);
    hold on
    plot([1:length(ecg_signal)]/fs, ecg_signal,'LineWidth',1.5);
    
    legend('Real Abnormal','Location','NorthEast')
    xlabel('Time (s)','FontSize',14);
    ylabel('Amplitude (mV)','FontSize',14);
    axis([596 604 -0.5 1.2])
    set(gca,'FontSize',14)
    stop
   % save('Record209_modRRIR.mat','R_i','R_label','rri_ratio_orig','rri_ratio','fs', 'ecg_signal'); % to illustrate the effective of the modified RRIR
end


%% OC-SVM: train_size vs. Overall result
if 0
    % nv = 0.02
%     filename = 'perform_trainSize_select7.mat';
    filename = 'perform_trainSize_select3.mat';
    load(filename);
    Percent_train(end,:) = [];
    figure('NumberTitle', 'off', 'Name', 'Performance vs. Training Size')
    plot(Percent_train(:,1), Percent_train(:,2),'b-o','LineWidth',1.5);
    hold on
    plot(Percent_train(:,1), Percent_train(:,3),'r-*','LineWidth',1.5);
    hold on
    plot(Percent_train(:,1), Percent_train(:,4),'k-^','LineWidth',1.5);
    hold on
    plot(Percent_train(:,1), Percent_train(:,5),'g-s','LineWidth',1.5);
    axis([5 105 70 105]);
    legend('SE','SP','PP','ACC','Location','NorthEast');
    xlabel('Num. of Beats for Training ','FontSize',14);
    ylabel('Percentage (%)','FontSize',14);
    set(gca,'FontSize',14)
    %save('perform_trainSize.mat', 'Percent_train');
end


%Performance vs. nu
if 1
    load('perform_nu_select3.mat')
    plot(Percent_nv(:,1), Percent_nv(:,2),'b-o','LineWidth',1.5);
    hold on
    plot(Percent_nv(:,1), Percent_nv(:,3),'r-*','LineWidth',1.5);
    hold on
    plot(Percent_nv(:,1), Percent_nv(:,4),'k-^','LineWidth',1.5);
    hold on
    plot(Percent_nv(:,1), Percent_nv(:,5),'g-s','LineWidth',1.5);
    axis([0.02 0.33 40 105]);
    legend('SE','SP','PP','ACC','Location','NorthEast');
    xlabel('$\nu$','FontSize',14,'Interpreter','latex');
    ylabel('Percentage (%)','FontSize',14);
    set(gca,'FontSize',14)
    % save('perform_nv.mat', 'Percent_nv');
end


%HeartCare  -  subject01 - Health
if 0
    filename = 'subject01_health.mat';
    load(filename)    
    figure(1)
    plot([1:length(ecg_signal)]/fs, ecg_signal, 'b-','LineWidth',1.5);
    hold on 
    plot(abID/fs, ecg_signal(abID),'ks','LineWidth',1.5);
    hold on
    plot(R_i/fs,ecg_signal(R_i),'go','LineWidth',1.5)
    hold off
    axis([54 60 -0.15 0.201])
    xlabel('Time (s) ', 'FontSize',14);
    ylabel('Amplitude (mV)', 'FontSize',14);
    set(gca, 'FontSize',14)
% save('subject01_health.mat','ecg_signal','abID','fs')
end


%HeartCare  -  subject02 - Long QT
if 0
    filename = 'subject02_LQT.mat';
    load(filename)    
    figure(1)
    plot([1:length(ecg_signal)]/fs, ecg_signal, 'b-','LineWidth',1.5);
    hold on 
    plot(abID/fs, ecg_signal(abID),'ks','LineWidth',1.5);
    hold on
    plot(R_i/fs,ecg_signal(R_i),'go','LineWidth',1.5)
    hold off
    
    axis([8 16 -0.15 0.201])                     %%%  normal
    %axis([54 62 -0.4 0.3])                  %%% abnormal
    
    xlabel('Time (s) ', 'FontSize',14);
    ylabel('Amplitude (mV)', 'FontSize',14);
    set(gca, 'FontSize',14) 
% save('subject01_health.mat','ecg_signal','abID','fs')
end
