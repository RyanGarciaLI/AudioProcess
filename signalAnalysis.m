% A demo of signal analysis and processing. 
% Copyright © RyanGarciaLI
% Steps:
%   1. Analyse Signal:
%       - Convert Stereo to Mono
%       - Plot Signal against time domain
%   2. Pre-processing:
%       - Find start/end point of audio: energy & zero crossing => trim
%       - Analyze time-frequence: Discrete Fourier Transform => spectrum
%   3. Extract Feature From Trimmed Signal:
%       - Filter frequence by Mel Scale (!!!)
%       - (Mel Frequence) Cepstral Coeffiecient
%           (1) pre-emphasis (high-passing) => s'(k) = s(k) - a*s(k-1)
%           (2) hanning windowing (smoothing) => frames = (total -
%               frameSize)/shift + 1
%           (3a) Directly calculate CC: (!!!)
%               . Discrete Fourier Transform => Xm
%               . Logistic => Log(Xm) 
%               . Inverse Discrete Fourier Transform 
%                       => Cepstral Coeffiecient 
%           (3b) Linear Predictive Coding (Compression)
%               . auto-correlation => r(k) = sum(s(i)*s(k+i))
%                                  => auto-correlation matrix
%               . lpc = [r1, r2, ..., rp] * inv(acm)

%   4. Recognition by comparing cpestral coefficient. (!!!)
%      
%   Note: (!!!) means not demostrate here.     


clearvars
close all
[signal_stereo, fs] = audioread('s5A.wav');
channel = 1;
signal = signal_stereo(:, channel); % in mono

N = 480; % # of samples in a frame
m = 240; % # of non_overlapping samples
T = length(signal); % Total length of signal

N_frame = floor((T-N)/m + 1); % # of frames
energy = zeros(N_frame);
zero_cross = zeros(N_frame);

% empirical parameters
energy_start = 0.2;
energy_end = 0.125;
N_zc_start = 20;
N_zc_end = 50;
start_frame = -1;
end_frame = -1;

for si=1:N_frame
    f_begin = 1 + (si-1) * m;   % frame begin index
    f_end = f_begin + N - 1;    % frame end index
    frame = signal(f_begin:f_end);
    energy(si) = sum(frame.^2);
    for i=(f_begin+1):f_end
        if sign(signal(i)) ~= sign(signal(i-1))
            zero_cross(si) = zero_cross(si) + 1;
        end
    end
end

% find starting point
for si=1:N_frame
    if checkStartPtr(energy(si:si+2), zero_cross(si:si+2), energy_start, N_zc_start)
        start_frame = si;
        break
    end
end

% find ending point
for si=1:N_frame
    if si > start_frame && energy(si) < energy_end && zero_cross(si) < N_zc_end
        end_frame = si;
        break;
    end
end

% extract a segment
T1 = 1 + (start_frame - 1) * m;     % start point
T2 = 1 + N + (end_frame - 1) * m;   % end point
n_seg = 20 * 10^(-3) / (1/24000); % # of samples in segment
T1_seg = 1 + (start_frame + 9 - 1) * m; % segment starting point
T2_seg = T1_seg + n_seg - 1; % segment ending point

% DFT
seg = signal(T1_seg:T2_seg);
seg_len = length(seg);
xm = zeros(1, seg_len);
i = sqrt(-1);
for m=0:seg_len-1
    for k=0:seg_len-1
        xm(m+1) = xm(m+1) + seg(k+1) * exp((-i)*2*pi*k*m/seg_len);
    end
end

magnitude = abs(xm);


frame_space = linspace(1,N_frame,N_frame);
figure(1);
h311 = subplot(3, 1, 1);
plot(signal);
hold on
xlabel('time')
ylabel("Voltage")
xline(T1, 'color', 'r');
xline(T2, 'color', 'r');
xline(T1_seg, 'color', 'black')
xline(T2_seg, 'color', 'black')
subtitle("Red lines: Start/End Point; Black lines: Seg1");

h312 = subplot(3,1,2);
plot(frame_space, energy);
hold on
xlabel('Frame Number')
ylabel('Energy')
xline(start_frame, 'color', 'r');
xline(end_frame, 'color', 'r');
% yline(energy_start, 'color', 'b')
% yline(energy_end, 'color', 'g')

h313 = subplot(3,1,3);
plot(frame_space,zero_cross);
hold on
xlabel('Frame Number')
ylabel('zero rates')
xline(start_frame, 'color', 'r');
xline(end_frame, 'color', 'r');
% yline(N_zc_start, 'color', 'b')
% yline(N_zc_end, 'color', 'g')
drawnow

% DFT in function
DFT(seg);

% pre-emphasis
pem_seg = zeros(1,seg_len);
pem_seg(1) = seg(1);
for k=2:seg_len-1
    pem_seg(k) = seg(k) - 0.95 * seg(k-1);
end

figure(3);
tiledlayout(2,1)
nexttile
plot(seg)
xlabel("time");
ylabel("Voltage");
subtitle('Raw signal');
nexttile
plot(pem_seg);
xlabel("time");
ylabel("Voltage");
subtitle("Pre-emphasis");

% autocorrelation
order = 10;
autocorr = zeros(1,order+1);
for j=0:order
    for k=j:seg_len-1
        autocorr(j+1) = autocorr(j+1) + pem_seg(k+1) * pem_seg(k+1-j);
    end
end

% autocorrelation matrix
acm = zeros(order, order);  % auto-correlation matrix 
for j=1:order
    for k=j:order
        acm(j,k) = autocorr(k-j+1);
    end
end

acm = acm + acm.' - eye(order) * autocorr(1);

% linear predictive coding
lpc = autocorr(2:11) / acm;

% some utility functions
function isStartPtr = checkStartPtr(energy, zero_cross, energy_th, zc_th)
    for i=1:length(energy)
        if energy(i) < energy_th || zero_cross(i) < zc_th
            isStartPtr = false;
            return
        end
    end
    isStartPtr = true;
end

function isEndPtr = checkEndPtr(energy, zero_cross, energy_th, zc_th)
    for i=1:length(energy)
        if energy(i) > energy_th || zero_cross(i) > zc_th
            isEndPtr = false;
            return
        end
    end
    isEndPtr = true;
end


% DFT function
function xm = DFT(s)
figure(2);

l = length(s);
xm = zeros(1, l);
i = sqrt(-1);
for m=0:l-1
    for k=0:l-1
        xm(m+1) = xm(m+1) + s(k+1) * exp((-i)*2*pi*k*m/l);
    end
end

magnitude = abs(xm);
plot(0:l-1, magnitude);
xlabel('Frequency');
ylabel('Energy');
end

