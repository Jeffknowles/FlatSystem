function [x,phi] = gen_ifpulse(fs,IF,phi0,a)
% GEN_IFPULSE  generate modulated signals given desired instantaneous frequency
%
% Usage:
%   [x,phi] = gen_ifpulse(fs,IF,phi0,a)
%
% Inputs:
%   fs   -  sampling rate [Hz]
%   IF   -  desired instantaneous frequency vector [Hz]
%   phi0 -  initial phase [radians]
%   a    -  amplitude vector (scalar or length(IF))
%
% Outputs:
%   x    -  analytic (complex) phase modulated signal
%   phi  -  calculated phi(t) based on integration of IF
%
% This function generates monocomponent pulses based on the desired instantaneous
% frequency (IF).  Any valid function of frequency vs. time, IF(t), can be
% converted to a frequency modulated pulse by applying phase modulation.
% Multicomponent signals can be constructed by combining separate monocomponent
% pulses.
%
% Method:
%
%   x(t) = A(t) e^(j phi(t))
%
% where:
%
%   phi(t) = 2 PI Int{ IF(t) dt }
%


% check for errors in definition
if any(isinf(IF)), error('Cannot numerically integrate instantaneous frequency.  Vector contains Inf values.'), end

% integrate the function, IF(t), to find phi(t)
phi = cumtrapz(IF)./fs;

% generate FM waveform
x = a .* exp(1i*2*pi*phi + 1i*phi0);

