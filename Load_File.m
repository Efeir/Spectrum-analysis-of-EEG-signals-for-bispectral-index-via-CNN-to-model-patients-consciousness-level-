function [EEG_5s,BIS_ave,Length] = Load_File(file_num)

    a=dir('../EEG_Files/*.mat');
    file_name=a(file_num).name; 
    load(['../EEG_Files/' file_name]);
    
    EEG_5s = Pack_;
    BIS_ave = BIS_Ave;
    [~,n]=size(BIS_Ave);
    
    Length = n;
    clear BIS_Ave Pack_
end











