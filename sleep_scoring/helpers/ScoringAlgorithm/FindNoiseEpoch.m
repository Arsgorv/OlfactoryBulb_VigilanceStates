function Epoch=FindNoiseEpoch(filename,chH,fixcax)
%% Calculate Spectrum
% added by SB, the whitened spectra have very different value ranges so the
% clim imposed in the code are not well adapted
try, fixcax, catch, fixcax=1;end
pasTheta=100; 
params.Fs=1250;
params.trialave=0;
params.err=[1 0.0500];
params.pad=2;
params.fpass=[0 20];
movingwin=[3 0.2];
params.tapers=[3 5];

scrsz = get(0,'ScreenSize');
load(strcat(filename,'H_Low_Spectrum.mat'))
fH=Spectro{3};
tH=Spectro{2};
SpH=Spectro{1};

TotalEpoch=intervalSet(0*1e4,tH(end)*1e4);
Spint=Restrict(tsd(tH*1e4,SpH),TotalEpoch);
tH=Range(Spint,'s');
SpH=Data(Spint);
disp(' ');

    disp('... Finding Noisy Epochs in LFP.');
    NoiseThresh=3E5;
    GndNoiseThresh=0.4E6; % default1E6
    Ok='n';
    while Ok~='y'
        
        g=figure('color',[1 1 1],'Position',[2 scrsz(4) scrsz(3) scrsz(4)/3]); Nf=gcf;
        imagesc(tH,fH,10*log10(SpH)'), axis xy, if fixcax, caxis([20 65]);end
        title('Spectrogramm : determine noise periods');        
        
        if Ok~='m'
            Okk='n'; % high frequency noise
            figure('color',[1 1 1],'Position',[2 scrsz(1) scrsz(3) scrsz(4)/2]),hf=gcf;
            while Okk~='y'
                
                HighSp=SpH(:,fH<=20 & fH>=18);
                subplot(2,1,1), hold off,
                imagesc(tH,fH(fH<=20 & fH>=18),10*log10(HighSp)'), axis xy,if fixcax, caxis([20 65]);end
                
                NoiseTSD=tsd(tH*1E4,mean(HighSp,2));
                NoiseEpoch=thresholdIntervals(NoiseTSD,NoiseThresh,'Direction','Above');
                
                hold on, plot(Range(NoiseTSD,'s'),Data(NoiseTSD)/max(Data(NoiseTSD))+19,'b')
                hold on, plot(Range(Restrict(NoiseTSD,NoiseEpoch),'s'),Data(Restrict(NoiseTSD,NoiseEpoch))/max(Data(NoiseTSD))+19,'*w')
                title(['18-20Hz Spectrogramm, determined High Noise Epochs are in white (total=',num2str(floor(10*sum(Stop(NoiseEpoch,'s')-Start(NoiseEpoch,'s')))/10),'s)']);
                Okk=input('--- Are you satisfied with High Noise Epochs (y/n)? ','s');
                if Okk~='y', NoiseThresh=input('Give a new High Noise Threshold (Default=3E5) : '); end
            end
            
            Okk='n'; % low frequency noise (grounding issue)
            while Okk~='y'
                LowSp=SpH(:,fH<=2);
                subplot(2,1,2), hold off,
                imagesc(tH,fH(fH<=2),10*log10(LowSp)'), axis xy,if fixcax, caxis([20 65]);end
                
                GndNoiseTSD=tsd(tH*1E4,mean(LowSp,2));
                GndNoiseEpoch=thresholdIntervals(GndNoiseTSD,GndNoiseThresh,'Direction','Above');
                
                hold on, plot(Range(GndNoiseTSD,'s'),Data(GndNoiseTSD)/max(Data(GndNoiseTSD))+1,'b')
                hold on, plot(Range(Restrict(GndNoiseTSD,GndNoiseEpoch),'s'),Data(Restrict(GndNoiseTSD,GndNoiseEpoch))/max(Data(GndNoiseTSD))+1,'*w')
                title(['0-2Hz Spectrogramm, determined Ground Noise Epochs are in white (total=',num2str(floor(10*sum(Stop(GndNoiseEpoch,'s')-Start(GndNoiseEpoch,'s')))/10),'s)']);
                Okk=input('--- Are you satisfied with Ground Noise Epochs (y/n)? ','s');
                if Okk~='y', GndNoiseThresh=input('Give a new Ground Noise Threshold (Default=1E6) : '); end
            end


 % modif KB----------------------------------------------------------------------------
 % ------------------------------------------------------------------------------------
            
            AddOk2=input('Do you want to add a ThresholdedNoiseEpoch (y/n)? ','s');
            if AddOk2=='y', 
                load(strcat(filename,'LFPData/LFP',num2str(chH),'.mat'))
                Okk='n'; % low frequency noise (grounding issue)
                figure('color',[1 1 1],'Position',[2 scrsz(4) scrsz(3) scrsz(4)/2]),
                num=gcf;
                
                while Okk~='y'
                figure(num),clf
                plot(Range(LFP,'s'),Data(LFP))
                [x,ThresholdedNoiseEpochThreshold]=ginput;
                BadEpoch=thresholdIntervals(LFP,ThresholdedNoiseEpochThreshold,'Direction','Above');
                st=Start(BadEpoch);
                en=End(BadEpoch);
                BadEpoch=intervalSet(st-5E4,en+5E4);
                BadEpoch=mergeCloseIntervals(BadEpoch,2);
                BadEpoch2=dropShortIntervals(BadEpoch,10E4);
                BadEpoch2=mergeCloseIntervals(BadEpoch,30E4);
                ThresholdedNoiseEpoch=or(BadEpoch,BadEpoch2);
                title(['Threshold: ',num2str(ThresholdedNoiseEpochThreshold)])
                hold on, plot(Range(Restrict(LFP,ThresholdedNoiseEpoch),'s'),Data(Restrict(LFP,ThresholdedNoiseEpoch)),'r')  
                Okk=input('--- Are you satisfied with Thresholded Noise Epochs (y/n -- k for keyboard)? ','s');
                if Okk=='k'
                    keyboard
                end
                
                end
            else
                ThresholdedNoiseEpoch=intervalSet([],[]);
                ThresholdedNoiseEpochThreshold=[];
            end
  
 % modif KB----------------------------------------------------------------------------
 % ------------------------------------------------------------------------------------
  
 
            
            
            AddOk=input('Do you want to add a WeirdNoiseEpoch (y/n)? ','s');
            if AddOk=='y', disp('Enter start and stop time (s) of WeirdNoise')
                disp('(e.g. [1,200, 400,500] to put 1-200s and 400-500s periods into noise)')
                WeirdNoise=input(': ');
                try WeirdNoiseEpoch=intervalSet(WeirdNoise(1:2:end)*1E4,WeirdNoise(2:2:end)*1E4);
                catch, keyboard; end
            else WeirdNoiseEpoch=intervalSet([],[]); 
            end     
            
            
        else
            % high frequency noise
            NoiseEpoch=input('Enter start and stop time of high noise periods : ');
            keyboard
            if length(NoiseEpoch)/2~=floor(length(NoiseEpoch))/2, disp('Problem: not same number of starts and ends! '); Ok='n';end
            NoiseEpoch=NoiseEpoch*1E4;
%             NoiseEpoch(NoiseEpoch>max(Range(Mmov)))=max(Range(Mmov));
            NoiseEpoch(NoiseEpoch<0)=0;
            NoiseEpoch=intervalSet(NoiseEpoch(1:2:end),NoiseEpoch(2:2:end));
            
            % low frequency noise (grounding issue)
            GndNoiseEpoch=input('Enter start and stop time of ground noise periods (very low frequencies) : ');
            keyboard
            if length(GndNoiseEpoch)/2~=floor(length(GndNoiseEpoch))/2, disp('Problem: not same number of starts and ends! '); Ok='n';end
            GndNoiseEpoch=GndNoiseEpoch*1E4;
            GndNoiseEpoch(GndNoiseEpoch<0)=0;
            GndNoiseEpoch=intervalSet(GndNoiseEpoch(1:2:end),GndNoiseEpoch(2:2:end));
        end
            
        if isempty(Start(NoiseEpoch))==0, hold on, line([Start(NoiseEpoch,'s') Start(NoiseEpoch,'s')]',[0 20],'color','k');end
        if isempty(Start(GndNoiseEpoch))==0,hold on, line([Start(GndNoiseEpoch,'s') Start(GndNoiseEpoch,'s')]',[0 20],'color','b');end
        if isempty(Start(WeirdNoiseEpoch))==0,hold on, line([Start(WeirdNoiseEpoch,'s') Start(WeirdNoiseEpoch,'s')]',[0 20],'color','c');end
        if isempty(Start(ThresholdedNoiseEpoch))==0,hold on, line([Start(ThresholdedNoiseEpoch,'s') Start(ThresholdedNoiseEpoch,'s')]',[0 20],'color','c');end        
        disp(['total noise time = ',num2str(sum(Stop(or(or(NoiseEpoch,GndNoiseEpoch),WeirdNoiseEpoch),'s')-Start(or(or(NoiseEpoch,GndNoiseEpoch),WeirdNoiseEpoch),'s'))),'s.'])
        Ok=input('--- Are you satisfied with all Noise Epochs (y/n)? ','s');
        close(g)
    end
    Epoch=TotalEpoch-GndNoiseEpoch-NoiseEpoch-WeirdNoiseEpoch-ThresholdedNoiseEpoch;
    
    % modif KB-------------------
    TotalNoiseEpoch=or(or(GndNoiseEpoch,NoiseEpoch),or(WeirdNoiseEpoch,ThresholdedNoiseEpoch));
    Epoch=Epoch-TotalNoiseEpoch;
    % modif KB-------------------
    
try
save(strcat(filename,'StateEpochSB'),'Epoch','NoiseEpoch','GndNoiseEpoch','NoiseThresh', 'GndNoiseThresh','ThresholdedNoiseEpoch','ThresholdedNoiseEpochThreshold','TotalNoiseEpoch','-v7.3','-append');
catch
save(strcat(filename,'StateEpochSB'),'Epoch','NoiseEpoch','GndNoiseEpoch','NoiseThresh', 'GndNoiseThresh','ThresholdedNoiseEpoch','ThresholdedNoiseEpochThreshold','TotalNoiseEpoch','-v7.3');
end


end