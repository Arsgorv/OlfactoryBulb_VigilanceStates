function MiddleSpectrum_BM(filename,ch,struc)

% whitening was removed on 14/05/2018

if filename(end)==filesep
    
else
    filename = [filename filesep];
end

if isnumeric(ch) % added by SB to allow loading of LFP files that are not single channels - for example local act
    load(strcat('LFPData/LFP',num2str(ch),'.mat'));
else
    load(strcat('LFPData/',ch,'.mat'));
end


% Below is a modification from Juliy 2017, to harmonize codes in the lab, only change is that params.fpass=[0 20] become params.fpass=[0.1 20];
[params,movingwin,~]=SpectrumParametersBM('middle'); % low or high

disp('... Calculating spectrogramm.');

if ~isempty(strcmp(filename, 'ProjetAversion'))
    Breath=LFP;
end

[Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);

Spectro={Sp,t,f};
save(strcat([filename,struc,'_Middle_Spectrum.mat']),'Spectro','ch','-v7.3')

end

















