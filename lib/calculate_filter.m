function [a, b] = calculate_filter(Hdmag)
%% estimate poles/zeros from impulse response, h(t)
Nb = 15;                % number of zeros
Na = 15;                % number of poles
maxIter = 10;           % maximum iterations with Steiglitz-McBride algorithm
L = length(Hdmag);
W = dftmtx(L); Wb = W; Wa = W;
Wb(:,Nb+2:L) = []; Wa(:,Na+2:L) = [];

% generate the autocorrelation function
r = ifft(Hdmag.^2);

% construct an initial system model by Levinson-Durbin (AR), follow with Prony (ARMA)
aL = levinson(r,floor(L/2));
hL = impz(1,aL,Nb+2*Na+2);
[b,a] = prony(hL,Nb,Na);
% iteratively refine pole/zero positions with frequency domain Steiglitz-McBride (ARMA)
for i = 1:maxIter,
    [Hi,w] = freqz(b,a,L,'whole');
    Hai = freqz(1,a,L,'whole');
    Pi = exp(1i*angle(Hi));
    HdPi = Hdmag.*Pi;
    b = (diag(Hai)*Wb)\HdPi; B = fft(b,L);
    a = (diag(HdPi.*Hai)*Wa)\(diag(Hai)*Wb*b);
end

% force real filter coefficients (Hd should be symmetric)
if (sum(imag(b)) + sum(imag(a)) > 1e-10)
    warning('Poles and/or zeros not entirely real.  Possibly throwing away significant imaginary parts.')
    fprintf('Note:  The desired magnitude response, Hd, should be kept symmetric to ensure real coefficients!\n')
end
b = real(b.');
a = real(a.');