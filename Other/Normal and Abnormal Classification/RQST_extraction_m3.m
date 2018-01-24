%RQST_extraction_m3: Extract features RRIR and modRRIR
%Ping Cheng, pingch@uvic.ca
%Last modified: 2017-12-13

function [R_i,R_label, rri0, rri_ratio] = RQST_extraction_m3(R_positions, labels,d_thres)               
% R positions are from the annotated R positions
    R_i = R_positions(3:(end-1));
    R_label = labels(3:(end-1));


   %% -----------------------------------------rule 1: RR interval ratio-------------------------------------------------------
   rri = [0;R_i(2:end) - R_i(1:end-1)]; 
   rri0 = rri;
  for i = 3:length(rri)
    rri_ratio_orig(i) = min(rri(i), rri(i-1)) / max(rri(i), rri(i-1)) ;  % A change : rri_ratio is less than thres =1
  end
   for i = 3:length(rri)
        rri_ratio(i) = min(rri(i), rri(i-1)) / max(rri(i), rri(i-1)) ;  % A change : rri_ratio is less than thres =1
        if rri_ratio(i) < d_thres
            rri(i) = rri(i-2);
        end
   end
   rri_ratio = rri_ratio';
   
   
    if 0
        R_t = R_i/fs;
        rri_thres = 1;
        figure(12)
        plot(R_t, rri_ratio_orig, 'g--')
        hold on
        plot(R_t, rri_ratio, 'k-')
        hold on 
        plot(R_t, rri_thres, 'm-.');
        hold on
        plot(R_t(find(rri_ratio<rri_thres)), rri_ratio(rri_ratio<rri_thres),'bs' );
        hold on
        plot(R_t(find(R_label==1)), rri_ratio(R_label==1),'ro');
        hold off
        legend('RRIR','Modified RRIR','Threshold','Real Abnormal','Detected Abnormal','Location','NorthEast');
        xlabel('Time (s)')
        save('Record209_modRRIR.mat','R_i','R_label','rri_ratio_orig','rri_ratio','fs', 'ecg_signal'); % to illustrate the effective of the modified RRIR
    end


end % end of QRST extration funciton



 

    
    