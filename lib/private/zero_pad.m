function wfout = zero_pad(wf, fs, period_i, period_t, t_ramp)

if nargin < 5
    t_ramp = .01;    
end
% add roll on
expsize = round(t_ramp * fs);
xtscale=wf(1:expsize).*exp(-((expsize:-1:1)-1)/(expsize/5))';
wf(1:expsize)=xtscale;

% add roll off
xtscale=wf(end-expsize+1:end).*exp(-((1:expsize)-1)/(expsize/5))';
wf(end-expsize+1:end)=xtscale;

wfout = [zeros(round(period_i*fs),1); wf(:); zeros(round(period_t*fs),1)];

