function y=STFT_2D_image(kkk,BIS,i,j)
% clear, clc
% for i=1
% % i=5;j=658;
% for j=1
% clear;
% [EEG_5s,BIS_ave,Length] = Load_File(ii); %Load File

% datafile = EEG_5s(1:end,j)';
%  t=1:1:640;pi=3.1415926535;
%  datafile = sin(0.1*pi*t)+sin(0.3*pi*t);
% kkk=[];
% for hh=1:61
%     kkk=[kkk,EEG_5s(1:end,j+hh-1)'];
% end
% load a .wav file
% datafile =eegfiltfft(kkk,128,0,30)'-2000;  % filter 1
datafile = kkk;%pop_eegfiltnew(kkk, 1, 30, [], 0, [], 0)+0;% filter 2
% x = 1.1*eegfilt(kkk,128,0,30)';%+1000*sin(0.3*t*pi)';
x=datafile(641:end);
fs = 128;
% define analysis parameters
xlen = length(x);                   % length of the signal
wlen = 256;                        % window length (recomended to be power of 2)
hop = wlen/4;                       % hop size (recomended to be power of 2)
nfft = 1024;                        % number of fft points (recomended to be power of 2)

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

% subplot(3,1,1);
% plot((1:xlen)/128,kkk(641:end),'g');axis([0.5 xlen/128 0 4100]);legend('raw data')
% title(['BIS= ' num2str(round(BIS_ave(j)))]);
% 
% subplot(3,1,2);
% plot((1:xlen)/128,x,'b');axis([0.5 xlen/128 0 4100]);legend('filt data')
% 
% subplot(3,1,3);
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
% % %file_STFT
% % % handl = colorbar;
% % % set(handl, 'FontName', 'Times New Roman', 'FontSize', 14)
% % % ylabel(handl, 'Magnitude, dB')
path_temp = './data';
      if ~exist(path_temp)
          mkdir(path_temp);
      end
% saveas(gcf,[path_temp '/B',BIS,'_P',num2str(i),'_',num2str(j),'.png']);
% clearvars -except i EEG_5s BIS_ave Length
y=1;
% clc;%close all;
% caxis([0 40])    %ÃÌº”ƒ‹¡ø∑∂Œß
