function Y=filtering(X,sfreq,kind);

% sfreq = sampling frequency
% kind: type of filtering
% low-pass filtering

X=X-mean(X); % mean = 0
% moving averaging 32Hz, 2017-09-26
b=[.2 .2 .2 .2 .2]; % original
% b=ones(1,15)/15; % changed by Ping at 11:42pm on Sept. 19,2017
a=[1];
switch kind
    case 0
        X=X;
    case 1
        X=filter(b,a,X);
    case 2
        X=filtfilt(b,a,X);
end;
% drift suppression
T=1/sfreq;	     % sampling peroid [s]
Fc=1;	         % cut-off [Hz]
c1=1/[1+tan(Fc*pi*T)];
c2=[1-tan(Fc*pi*T)]/[1+tan(Fc*pi*T)];
b=[c1 -c1]; a=[1 -c2];
switch kind
    case 0
        X=X;
    case 1
        X=filter(b,a,X);
    case 2
        X=filtfilt(b,a,X);
end;

%	---- Butturworth filtration
%	 mb order; 30 Hz lowpass;
fh=sfreq/2;			         % 1/2 sampling rate
mb=2;                        % order of filter
[b,a]= butter(mb,30/fh);     % 30Hz - cut-off frequency
switch kind
    case 0
        X=X;
    case 1
        X=filter(b,a,X);
    case 2
        X=filtfilt(b,a,X);
end;
Y=X;
