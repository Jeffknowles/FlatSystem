function WF=pulsegen(pulseparam)
% user defined parameters
fs = pulseparam.Fs; %192e3;%           % sampling rate of generated waveform [Hz]
T = pulseparam.DUR;             % pulse length [sec]
f1i = pulseparam.f1i;              % initial frequency [Hz]
f1t = pulseparam.f1t;             % final frequency [Hz]

phi0 = -pi/2;           % inital phase [radians]
modfn = pulseparam.sweeptype;%'hfm';          % predetermined frequency modulation type
ampfn = 'rcos';         % windowed amplitude function

% generate time series vector
t = (0:1/fs:T)';
WF=zeros(size(t));

for kHARM=1:pulseparam.nharm;
    f0=kHARM*pulseparam.f1i;
    f1=kHARM*pulseparam.f1t;
    
    B = abs(f1-f0);
    
    % define instantaneous amplitude vector
    A = ones(length(t),1);
    switch ampfn
        case 'rcos'
            idx = round(0.0625*length(A));
            A(1:idx+1) = A(1:idx+1) .* cos(pi/2*(0:1/idx:1) - pi/2)';
            A(end-idx:end) = A(end-idx:end) .* cos(pi/2*(0:1/idx:1))';
        case 'none'
    end
    
    % define instantaneous frequency, IF(t), and its integral, phi_ref(t)
    switch modfn
        case 'cw'
            %%% CW
            IF = f0*ones(size(t));
            phiref = f0.*t;
            
        case 'lfm'
            %%% LFM
            IF = f0*ones(size(t)) + (f1-f0)/(T).*t;
            phiref = f0.*t + 0.5*(f1-f0)/(T).*t.^2;
            
        case 'sfm'
            %%% SFM
            fm = 5000;
            IF = B./2*sin(2*pi*fm*t) + f0+B/2;
            phiref = -B/(4*pi*fm).*cos(2*pi*fm*t) + f0+B/2*t;  % wrong phase
            
        case 'hfm'      % only valid for downward sweep
            %%% HFM
            a = T*(f0*f1)/B;
            b = T*f1/B;
            IF = a./(t+b);
            phiref = a*log(t+b); % + 0.775/2;    % for some reason, phase is off from 0 radians - the amount depends on T and fs
    end
    
    plot(A)
    % generate phase modulated pulse
    [x,phi] = gen_ifpulse(fs,IF,phi0,A);
    WF=WF+real(x);
    
    
    
end

