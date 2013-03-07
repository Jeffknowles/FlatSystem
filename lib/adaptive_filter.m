function [e,w,y] = adaptive_filter(d,x,M,N)
% ANC_WIENER  Adaptive noise canceller using Wiener filtering
%
% The Wiener filter is optimal in MSE sense, but requires a WSS assumption.
%
% The Wiener filter automatically corrects for the delay by detecting the time
% shift in the crosscorrelation sequence and adjusting the group delay of the
% filter.  The magnitude is also adjusted to correct for the difference in noise
% amplitudes.  This appears to be extremely effective for a scaled and delayed
% version of the reference noise signal.
%
% E = ANC_WIENER(D,X,M) computes the M Wiener filter coefficients on the complete
%     data vector, D, and noise reference vector, X.  The return vector, E, is
%     the filtered reference noise subtracted from the original data vector.
% E = ANC_WIENER(D,X,M,N) uses only the first N data samples of vectors D and X
% [E,W] = ANC_WIENER(...) returns the vector of Wiener filter coefficients, W
% [E,W,Y] = ANC_WIENER(...) returns the Wiener filter output, Y

% use data vector length for noise statistic estimation (if not specified)
if ~exist('N','var')
    N = min(length(d),length(x));
end

% compute noise statistics
Rxx = xcorr(x,N,'biased');
Rxx = Rxx(N+1:N+M);
Rxx = toeplitz(Rxx);

%Rxx = eye(M);

rdx = xcorr(d,x,N,'biased');
rdx = rdx(N+1:N+M);

% compute Wiener filter coefficients
w = Rxx\rdx;

% filter reference noise sequence and subtract from signal
y = fftfilt(w,x);
e = d - y;
