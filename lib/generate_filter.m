function [a, b] = generate_filter(stimulus_wf, response_wf, params, varargin)

if length(varargin) > 0
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case 'plot'
                plottest = varargin{k+1};
            otherwise
                disp(['Warning no argument', varargin{k}])
        end
    end
end

leedin = .05;
idx_start = max(round((params.t_start - leedin) * params.fs), 1);
idx_stop = min(round((params.t_stop + leedin) * params.fs), length(stimulus_wf));

% set indicies for the stimulus
idx1 = round(idx_start:idx_stop);

% use xcorr to find time delay
[corr, lags] = xcorr(response_wf, stimulus_wf);

[mx, mxidx] = max(corr);
offset = lags(mxidx)
idx2 = offset + idx1;

% set data into ts
ts1.fs = params.fs;
ts1.time = ts1.fs .* (1:length(idx1));
ts1.data = stimulus_wf(idx1);
ts1.data = ts1.data./rms(ts1.data(:));                           % normalize data
ts1.data = ts1.data - ones(length(idx1),1)*mean(ts1.data);       % subtract DC offset

ts2.fs = params.fs;
ts2.time = ts2.fs .* (1:length(idx2));
ts2.data = response_wf(idx2);
ts2.data = ts2.data./rms(ts2.data(:));                           % normalize data
ts2.data = ts2.data - ones(length(idx2),1)*mean(ts2.data);       % subtract DC offset

%% calculate system impulse response
% Take Fourier transform of input and output signals
nfft = 2^nextpow2(length(ts1.data));
X = fft(ts1.data,nfft);
Y = fft(ts2.data,nfft);
F = (0:(nfft-1))*(ts1.fs/nfft);
Fnorm = F/ts1.fs;

% Compute the frequency response at all frequencies
H = Y./X;

% Find which fft samples are in the chirp freq range
f1 = params.fmin; % chirp low freq
f2 = params.fmax; % chirp high freq
k1 = ceil((f1/ts1.fs)*nfft)+1;  % which fft sample corresponds to f1
k2 = floor((f2/ts1.fs)*nfft)+1; % which fft sample corresponds to f2

% Set H to unity below f1 and -20dB above f2 (lowpass filter effect)
H(1:(k1-1)) = ones(k1-1,1);
H((k2+1):(nfft/2)) = ones((nfft/2)-k2,1);
H((nfft/2)+1) = .1;
H(((nfft/2)+2):nfft) = conj(flipud(H(2:(nfft/2))));

% Smooth output signal's magnitude response, phase is effectively 0
% Not sure why there are lots of deviations:
%   Could be due to reverb or other reflections interfering with
%   recorded microphone signal)
Hdmag = abs(H);
Hdmag_filt = resample(Hdmag,1,800);
Hdmag_filt = sgolayfilt(Hdmag_filt,2,7);       % use SG filter
F_filt = (0:1/(length(Hdmag_filt)-1):1)';

[a, b] = calculate_filter(Hdmag_filt);

% scale all coefficients evenly, forcing a0=1
b = b/a(1);
a = a/a(1);


%% test filter by running output through filter - should match input signal

ts3 = ts2;
ts3.data = filter(a,b,ts2.data);

if plottest
    % Examine time series and spectrogram of data for a quick-look
    % plot time series
    figure(1)
    subplot(2,1,1)
    plot(ts1.time,ts1.data)
    grid on;
    title(sprintf('%s - stimulus'),'interpreter','none')
    
    subplot(2,1,2)
    plot(ts2.time,ts2.data)
    grid on;
    title(sprintf('%s - response'),'interpreter','none')
    
    % plot spectrograms
    figure(2)
    spectrogram(ts1.data,hann(256),250,256,ts1.fs,'yaxis');
    title(sprintf('%s - stimulus'),'interpreter','none')
    set(gca,'clim',[-120 -40])
    colorbar
    colormap jet
    
    figure(3)
    spectrogram(ts2.data,hann(256),250,256,ts2.fs,'yaxis');
    title(sprintf('%s - response'),'interpreter','none')
    set(gca,'clim',[-120 -40])
    colorbar
    colormap jet
    
    % plot input output response
    figure(4)
    subplot(2,1,1)
    plot(F,db(abs(X)),F,db(abs(Y)),'r',F,db(abs(H)),'k'); hold on
    plot(F_filt * ts1.fs, db(Hdmag_filt), 'g', 'linewidth', 2)
    grid on
    legend('Input Signal','Output Signal')
    ylabel('Magnitued [dB]')
    title('Magnitude response of Input/Output')
    subplot(2,1,2)
    plot(F,unwrap(angle(X))*pi/180,F,unwrap(angle(Y))*pi/180,'r',F,unwrap(angle(H))*pi/180,'k')
    grid on
    title('Phase response of Input/Output')
    ylabel('Phase [Degrees]')
    xlabel('Frequency [Hz]')
    
    figure(6)
    [Hz1,FF] = freqz(b,a,1024,'whole',params.fs);
    Hz2 = freqz(a,b,1024,'whole',params.fs);
    subplot(2,1,1)
    plot(FF,db(abs(Hz1)),FF,db(abs(Hz2)),'g'); hold on;
    plot(F_filt*params.fs, db(Hdmag_filt),'--k')
    grid on
    title('Magnitude Response of Estimated and Inverted Filter')
    ylabel('Magnitude [dB]')
    
    subplot(2,1,2)
    plot(FF,unwrap(angle(Hz1))*pi/180,FF,unwrap(angle(Hz2))*pi/180,'g')
    grid on
    title('Phase Respanse of Estimated and Inverted Filter')
    ylabel('Phase [Degrees]')
    xlabel('Frequency [Hz]')
    
    figure(7)
    zplane(a,b)
    
    figure(8)
    subplot(2,1,1)
    plot(ts1.time, ts1.data,'k', ts1.time, filter(a,b, ts2.data),'r')
    subplot(2,1,2)
    nfft = 2^nextpow2(length(ts1.data));
    X = fft(ts1.data,nfft);
    Y = fft(filter(a, b, ts2.data),nfft);
    F = (0:(nfft-1))*(ts1.fs/nfft);
    plot(F,db(abs(X)), 'k',F,db(abs(Y)), 'r'); hold on
    xlim([0, params.fs/2])
    ylim([0, 60])
    
end