function y=STFT_Modify(kkk,BIS,i,j)

datafile = kkk;%pop_eegfiltnew(kkk, 1, 30, [], 0, [], 0)+0;% filter 2
% x = 1.1*eegfilt(kkk,128,0,30)';%+1000*sin(0.3*t*pi)';
x=datafile(641:end);
fs = 128;
% define analysis parameters
xlen = length(x);                   % length of the signal
wlen = 128;                        % window length (recomended to be power of 2)
hop = wlen/4;                       % hop size (recomended to be power of 2)
nfft = 1024*4;                        % number of fft points (recomended to be power of 2)

% perform STFT
[S, f, t] = STFT(x, wlen, hop, nfft, fs);

% define the coherent amplification of the window
K = sum(hamming(wlen, 'periodic'))/wlen;

% take the amplitude of fft(x) and scale it, so not to be a
% function of the length of the window and its coherent amplification
S = abs(S)/wlen/K;

% correction of the DC & Nyquist component
if rem(nfft, 2)                     % odd nfft excludes Nyquist point
    S(2:end, :) = S(2:end, :).*2;
else                                % even nfft includes Nyquist point
    S(2:end-1, :) = S(2:end-1, :).*2;
end

% convert amplitude spectrum to dB (min = -120 dB)
S = 10*log10(S + 1e-6);

% plot the spectrogram
figure();
imagesc(t,f,abs(S))% STFT
axis xy;
shading interp
axis tight
box on
view(0, 90)
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
% xlabel('Time/s');
% ylabel('Frequency, Hz');
axis([0 xlen/128 0 30]);colormap jet
% set(gca,'xtick',[]);  %set(gca,'XTickLabel','');
% set(gca,'ytick',[]);  %set(gca,'YTickLabel','');
% set(gca,'position',[0 0 1 1]);
% set(gcf,'Visible','off');

path_temp = './data';
      if ~exist(path_temp)
          mkdir(path_temp);
      end
% saveas(gcf,[path_temp '/B',BIS,'_P',num2str(i),'_',num2str(j),'.png']);
% clearvars -except i EEG_5s BIS_ave Length
y=1;
% clc;%close all;
% caxis([0 40])    %ÃÌº”ƒ‹¡ø∑∂Œß