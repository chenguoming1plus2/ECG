%seg_method: segment a single heartbeat into three parts
%Ping Cheng pingch@uvic.ca
%Last modified: 2017-12-13

function [pwave,rwave,twave] = seg_method(beat,pl)
    pwave = beat(:,1:(pl-15));
    rwave = beat(:,(pl-15):(pl+15));
    twave = beat(:,(pl+15):end);
end