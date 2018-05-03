clear all;clc;

for i=2
  [EEG_5s,BIS_ave,Length] = Load_File(i);  kkk=[];%Load File
  for j = 7
    BIS_=num2str(round(BIS_ave(j)));BIS_end=num2str(round(BIS_ave(j+24)));
    datafile = EEG_5s(1:end,j);
    for kk=1:25;kkk = [kkk,EEG_5s(1:end,j+kk-1)'];end;
    EEG_filt_fft =eegfiltfft(kkk,128,0,30)';
    EEG_filt_new = pop_eegfiltnew(kkk, 1, 30, [], 0, [], 0);
    EEMDIMF=eemd(kkk,0,1);

    data1=kkk;
    data2=EEG_filt_new;
    data3=EEMDIMF(:,3)+EEMDIMF(:,4)+EEMDIMF(:,5)+...
        EEMDIMF(:,6)+EEMDIMF(:,7)+EEMDIMF(:,8);%+EEMDIMF(:,9)+EEMDIMF(:,10)
    
%     figure;
%     plot(datafile,'g');hold on;plot(EEG_filt_fft,'b');hold on;
%     plot(data2,'r');
%     legend('原始波形','滤波后波形','滤波后波形new');set(gca,'FontName', '宋体');
%     
%     figure;k=1;
%     plot(data1,'g');hold on;plot(data2,'b');hold on;plot(data3,'r--');
%   
    y=STFT_2D_image(EEG_filt_new,BIS_,i,j);
    y1=STFT_2D_image(data3,BIS_,i,j);

  
  
  
  
  
  
  
  end
end