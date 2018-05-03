

clear all;clc;

for i=2
  [EEG_5s,BIS_ave,Length] = Load_File(i); kkk=[]; %Load File
  for j = 7
    datafile = EEG_5s(1:end,j);for kk=1:25;kkk = [kkk,EEG_5s(1:end,j+kk-1)'];end;
    EEG_filt_fft =eegfiltfft(kkk,128,0,30)'-2000;
    EEG_filt_new = pop_eegfiltnew(kkk, 1, 30, [], 0, [], 0);
    
%     EEG_filt_new = pop_eegfiltnew(EEG, 1, 30, [], 0, [], 0);

    data1=datafile;
    data2=EEG_filt_new;
    
    figure;
    plot(datafile,'g');hold on;plot(EEG_filt_fft,'b');hold on;
    plot(data2,'r');
    legend('原始波形','滤波后波形','滤波后波形new');set(gca,'FontName', '宋体');
    
    figure;k=1;
    plot(kkk,'g');%hold on;plot(EEG_filt_fft,'b');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  end
end






























