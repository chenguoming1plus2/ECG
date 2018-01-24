%beat_label_table.m  -- to label beats
%Created by Ping Cheng, pingch@uvic.ca, 2017-01-11, for MITDB

function ann_out = beat_label_table(ann)
cases = {...
    %-----------------------beat annotations----------------------------------------------
    'N';...		%1:Normal beat (displayed as "·" by the PhysioBank ATM, LightWAVE, pschart, and psfd)
    'L';...		%2:Left bundle branch block beat
    'R';...		%3:Right bundle branch block beat
    'A';...		%4:Atrial premature beat
    'V';...		%5:Premature ventricular contraction
    '/';...		%6:Paced beat, 'P'
    'a';...		%7:Aberrated atrial premature beat
    '!';...		%8:Ventricular flutter wave
    'F';...		%9:Fusion of ventricular and normal beat
    'x';...		%10:Non-conducted P-wave (blocked APC)
    'j';...		%11:Nodal (junctional) escape beat
    'f';...		%12:Fusion of paced and normal beat
    'E';...		%13:Ventricular escape beat
    'J';...		%14:Nodal (junctional) premature beat
    'e';...		%15:Atrial escape beat
    'Q';...		%16:Unclassifiable beat
    'S';...		%17:Supraventricular premature or ectopic beat (atrial or nodal)
    'r';...		%18:R-on-T premature ventricular contraction
    'n';...		%19:Supraventricular escape beat (atrial or nodal)
    '?';...		%20:Beat not classified during learning
    'B';...		%21:Bundle branch block beat (unspecified)
    '[';...		%22:Start of ventricular flutter/fibrillation
    ']';...		%23:End of ventricular flutter/fibrillation
    '(';...		%24:Waveform onset
    ')';...		%25:Waveform end
    'p';...		%26:Peak of P-wave
    't';...		%27:Peak of T-wave
    'u';...		%28:Peak of U-wave
    '`';...		%29:PQ junction
    '^';...		%30:(Non-captured) pacemaker artifact
    '|';...		%31:Isolated QRS-like artifact [1]
    '~';...		%32:Change in signal quality [1]
    '+';...		%33:Rhythm change [2]
    's';...		%34:ST segment change [2]
    'T';...		%35:T-wave change [2]
    '*';...		%36:Systole
    'D';...		%37:Diastole
    '=';...		%38:Measurement annotation [2]
    '"';...		%39:Comment annotation [2]
    '@';};		%40:Link to external data [3]

L = length(ann);

for k=1:L 
    if isempty(ann(k).typeMnemonic)
        ann(k).typeMnemonic = 41; % class 41: no type specified
    else
        ann(k).typeMnemonic = find( strcmp(cases,ann(k).typeMnemonic) );
    
%     if isempty(ann(k).typeMnemonic)
%         ann(k).typeMnemonic = ann(k).auxInfo;
%     else
%         if strcmp(ann(k).typeMnemonic,'N')
%             ann(k).auxInfo = '(N';
%         elseif strcmp(ann(k).typeMnemonic,'/')
%             ann(k).auxInfo = '(P';
%         elseif strcmp(ann(k).typeMnemonic,'Q')
%             ann(k).auxInfo = '(Q';
%         elseif strcmp(ann(k).typeMnemonic,'[')
%             ann(k).auxInfo = '(VFL';
%         elseif strcmp(ann(k).typeMnemonic,'!')
%             ann(k).auxInfo = '(VFL';
%         elseif strcmp(ann(k).typeMnemonic,']') 
%             ann(k).auxInfo = '(N';     
%         elseif  (strcmp(ann(k).typeMnemonic,'V') ) %subtype in mitdb is empty
%             ann(k).auxInfo = '(PVC';
%         elseif  (strcmp(ann(k).typeMnemonic,'~') && (ann(k).subtype==1) ) %subtype in mitdb is empty
%             ann(k).auxInfo = '(N';
%         end
     end
    
end
%}

for i=1:length(ann)
        ann_out(i).typeMnemonic = ann(i).typeMnemonic;
        ann_out(i).sampleNumber = ann(i).sampleNumber;
        ann_out(i).RpeakID = i;       
end

end


