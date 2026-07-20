function Correct_Subsampling_BM(comp_name)
% directory = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving';
% 
% switch comp_name
%     case 'test' %done
%         sess = {...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241123_TCI';...
%             };
%     case 'mobsrick' %done
%         sess = {...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241130_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241203_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241120_puretones';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241125_TCI';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241126_TCI';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241128_TCI';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241129_TCI';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241130_TCI';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241120_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241210_resting';...
%             };
%     case 'mickey' %done
%         sess = {...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241204_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241209_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241128_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241129_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241227_TORCs_atropine';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241231_TORCs_atropine';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250102_TORCs_atropine';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250105_TORCs_atropine';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241224_TORCs_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241226_TORCs_saline';
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241204_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241205_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241206_TORCs'
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241126_yves_train';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241128_yves_train';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241129_yves_test';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241130_yves_test';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241203_yves_test';...
%             };
%     case 'pinky' %done
%         sess = {...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241223_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241212_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241213_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241218_LSP_saline'
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241210_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241212_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241213_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241214_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241220_TORCs_atropine';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241222_TORCs_atropine';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241225_TORCs_atropine';...
%             };
%     case 'ratatouille' %done
%         sess = {...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241214_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241221_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241122_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241123_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241125_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241228_TORCs_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250101_TORCs_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250103_TORCs_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250104_TORCs_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250108_TORCs_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241212_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241213_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241214_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241120_yves_train';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241123_yves_train';...
%             };
%     case 'gruffalo' %done
%         sess = {...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250103_LSP_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241214_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241121_puretones';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241120_no_sound';...
%             };
%     case 'greta' %done
%         sess = {...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241224_TORCs_short';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241120_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241121_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241209_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241210_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241211_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241213_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241214_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241210_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241211_resting';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241209_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241210_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241212_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241213_contstream';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241214_contstream';...
%             };
%     case 'new' %running AG
%         sess = {...
%             %   '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241126_LSP';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241224_LSP_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241228_LSP_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241211_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241209_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250107_LSP_saline';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241125_yves_train';...
%             %             '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241210_TORCs';...
%             };
%     case 'leftovers'
%         sess = {...
%         '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241230_LSP_saline';...% premature end of file (xml issue) .Ignore
%         '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241217_LSP_saline';...
%         };
%     case 'Edel'
%         sessions = PathForExperimentsOB('Edel');
%         sess = sessions.path';
%     otherwise
%         % Handle unknown names
%         disp('Unknown name provided.');
% end
% % Processed
% % skip_sess = {'/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241210_TORCs';...
% %     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241204_TORCs';...
% %     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241223_TORCs';...
% %     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250103_LSP_saline';...
% %     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241224_TORCs_short';...
% %     };
% %
% %%
% for p=1:length(sess)
%     disp(['Calculating ' sess{p} ' ' num2str(length(sess)-p) '/' num2str(length(sess)) ' is left...'])
% %     cd(sess{p})
%     
%     % basal informations regarding session
%     clearvars -except path p sess comp_name directory
%     load([sess{p} '/ExpeInfo.mat'])
%     BaseFileName = ['M' num2str(ExpeInfo.nmouse) '_' ExpeInfo.date '_' ExpeInfo.SessionType];
%     FinalFolder = sess{p};
%     is_OpenEphys = false;
%     
%     % delete part
%     try
%         delete AuCx_Low_Spectrum.mat
%     end
%     try
%         delete AuCx_Middle_Spectrum.mat
%     end
%     try
%         delete B_Low_Spectrum.mat
%     end
%     try
%         delete B_Middle_Spectrum.mat
%     end
%     try
%         delete B_High_Spectrum.mat
%     end
%     try
%         delete B_UltraLow_Spectrum.mat
%     end
%     try
%         delete H_Low_Spectrum.mat
%     end
%     try
%         delete H_Middle_Spectrum.mat
%     end
%     try
%         delete PFCx_Low_Spectrum.mat
%     end
%     try
%         delete PFCx_Middle_Spectrum.mat
%     end
%     try
%         delete([BaseFileName '.lfp'])
%     end
%     for i=0:112
%         delete(['LFPData/LFP' num2str(i) '.mat'])
%     end
%     
%     % correct the .xml
%     XmlStructure = xml2struct_SB([BaseFileName '.xml']);
%     try
%         XmlStructure.parameters.programs.program{1, 5}.parameters.parameter.value.Text='1250';
%     catch
%         XmlStructure.parameters.programs.program{1, 4}.parameters.parameter.value.Text='1250';
%     end
%     XmlStructure.parameters.fieldPotentials.lfpSamplingRate.Text='1250';
%     XmlStructure.parameters.acquisitionSystem.samplingRate.Text='30000';
%     struct2xml_SB(XmlStructure,[BaseFileName '.xml']);
%     
%     % recalculate everything
%     system(['ndm_lfp ' BaseFileName])
%     SetCurrentSession([BaseFileName '.xml'])
%     InfoLFP = ExpeInfo.InfoLFP;
%     
%     load(fullfile(FinalFolder,'LFPData','InfoLFP.mat'), 'InfoLFP');
%     try
%         for i=[[6,12,15,17,18,19,21,23,31,65,105,106,111,112]+1]
%             if ~exist(['LFPData/LFP' num2str(InfoLFP.channel(i)) '.mat'],'file') %only LFP signals
%                 
%                 disp(['loading and saving LFP' num2str(InfoLFP.channel(i)) ' in LFPData...']);
%                 % FMA toolbox function to load LFP
%                 LFP_temp = GetLFP(InfoLFP.channel(i));
%                 %data to tsd
%                 LFP = tsd(LFP_temp(:,1)*1E4, LFP_temp(:,2));
%                 SessLength = max(LFP_temp(:,1));
%                 %save
%                 save([pwd '/LFPData/LFP' num2str(InfoLFP.channel(i))], 'LFP');
%                 clear LFP LFP_temp
%             end
%         end
%         disp('Done')
%     catch
%         disp('problem for lfp')
%     end
%     disp('Calculating Bulb Spectros')
%     load('ChannelsToAnalyse/Bulb_deep.mat')
%     LowSpectrumSB([cd filesep],channel,'B')
%     MiddleSpectrum_BM([cd filesep],channel,'B')
%     HighSpectrum([cd filesep],channel,'B');
%     UltraLowSpectrumBM([cd filesep],channel,'B');
%     
%     disp('Calculating HPC Spectros')
%     load('ChannelsToAnalyse/dHPC_deep.mat')
%     LowSpectrumSB([cd filesep],channel,'H')
%     MiddleSpectrum_BM([cd filesep],channel,'H')
%     
%     disp('Calculating PFC Spectros')
%     load('ChannelsToAnalyse/PFCx_deep.mat')
%     LowSpectrumSB([cd filesep],channel,'PFCx')
%     MiddleSpectrum_BM([cd filesep],channel,'PFCx')
%     
%     disp('Calculating AuCx Spectros')
%     load('ChannelsToAnalyse/AuCx.mat')
%     LowSpectrumSB([cd filesep],channel,'AuCx')
%     MiddleSpectrum_BM([cd filesep],channel,'AuCx')
% end
% 
% 

%% old

% delete AuCx_Low_Spectrum.mat
% delete AuCx_Middle_Spectrum.mat
% delete B_Low_Spectrum.mat
% clear B_Middle_Spectrum.mat
% delete B_High_Spectrum.mat
% delete B_UltraLow_Spectrum.mat
% delete H_Low_Spectrum.mat
% delete H_Middle_Spectrum.mat
% delete PFCx_Low_Spectrum.mat
% delete PFCx_Middle_Spectrum.mat
%
% % for OB, AuCx, HPC, PFC
% %% for OB
% filename=pwd;
% load('ChannelsToAnalyse/Bulb_deep.mat'), ch=channel;
% load(['LFPData/LFP' num2str(channel) '.mat'])
% struc='B';
%
% % Low
% [params,movingwin,~]=SpectrumParametersBM('low'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_Low_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% % Middle
% [params,movingwin,~]=SpectrumParametersBM('middle'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_Middle_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% % High
% [params,movingwin,~]=SpectrumParametersBM('high'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_High_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% % UltraLow
% [params,movingwin,~]=SpectrumParametersBM('ultralow_bm'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_UltraLow_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% %% for AuCx
% filename=pwd;
% load('ChannelsToAnalyse/AuCx.mat')
% load(['LFPData/LFP' num2str(channel) '.mat'])
% struc='AuCx';
%
% % Low
% [params,movingwin,~]=SpectrumParametersBM('low'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% Spectro2{3} = interp1(linspace(0,1,length()));
% save(strcat([filename,struc,'_Low_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% % Middle
% [params,movingwin,~]=SpectrumParametersBM('middle'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_Middle_Spectrum.mat']),'Spectro','ch','-v7.3')
%
%
% %% for AuCx
% filename=pwd;
% load('ChannelsToAnalyse/dHPC_deep.mat')
% load(['LFPData/LFP' num2str(channel) '.mat'])
% struc='H';
%
% % Low
% [params,movingwin,~]=SpectrumParametersBM('low'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_Low_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% % Middle
% [params,movingwin,~]=SpectrumParametersBM('middle'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_Middle_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% %% for PFC
% filename=pwd;
% load('ChannelsToAnalyse/PFCx_deep.mat')
% load(['LFPData/LFP' num2str(channel) '.mat'])
% struc='PFCx';
%
% % Low
% [params,movingwin,~]=SpectrumParametersBM('low'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_Low_Spectrum.mat']),'Spectro','ch','-v7.3')
%
% % Middle
% [params,movingwin,~]=SpectrumParametersBM('middle'); % low or high
% params.Fs=1875;
% [Sp,t,f]=mtspecgramc(Data(LFP),movingwin,params);
% Spectro={Sp,t,f};
% save(strcat([filename,struc,'_Middle_Spectrum.mat']),'Spectro','ch','-v7.3')
%
%% Correct accelero LFPs
sessions = PathForExperimentsOB('Shropshire');
sess = sessions.path;

for p=64:length(sess)
    disp(['Calculating ' sess{p} ' ' num2str(length(sess)-p) '/' num2str(length(sess)) ' is left...'])
    
    % basal informations regarding session
    clearvars -except path p sess comp_name directory
    load([sess{p} '/ExpeInfo.mat'])
    BaseFileName = ['M' num2str(ExpeInfo.nmouse) '_' ExpeInfo.date '_' ExpeInfo.SessionType];
    FinalFolder = sess{p};
    is_OpenEphys = false;
    cd(FinalFolder)
    SetCurrentSession([BaseFileName '.xml'])
    InfoLFP = ExpeInfo.InfoLFP;
    
    load(fullfile(FinalFolder,'LFPData','InfoLFP.mat'), 'InfoLFP');
    try
        for i=[[96, 97, 98, 99, 100, 101, 102, 103, 104]+1]
            if ~exist(['LFPData/LFP' num2str(InfoLFP.channel(i)) '.mat'],'file') %only LFP signals
                
                disp(['loading and saving LFP' num2str(InfoLFP.channel(i)) ' in LFPData...']);
                % FMA toolbox function to load LFP
                LFP_temp = GetLFP(InfoLFP.channel(i));
                %data to tsd
                LFP = tsd(LFP_temp(:,1)*1E4, LFP_temp(:,2));
                SessLength = max(LFP_temp(:,1));
                %save
                save([pwd '/LFPData/LFP' num2str(InfoLFP.channel(i))], 'LFP');
                clear LFP LFP_temp
            end
        end
        disp('Done')
    catch
        disp('problem for lfp')
    end
    
    MakeData_Accelero(FinalFolder, 'recompute', 1)
end
end