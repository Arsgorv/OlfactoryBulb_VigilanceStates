function [params,movingwin,suffix]=SpectrumParametersBM(option,askcheck,Displ)

% BM :  just add middle spectrum

%SpectrumParametersML
%
% inputs:
% option (optional) = 'high' for [20-200Hz], 'low' for [1-20Hz] (default=low)
%
% outputs:
% params = structure containing pad/err/tralave/fpass/tapers/Fs...
% movingwin = 
% 
% example :
% [params,movingwin]=SpectrumParametersML('low',0);
% [params,movingwin]=SpectrumParametersML('high',0);
%
% [Sp,t,f]=LoadSpectrumML('PFCx_deep');
% [Sp,t,f]=LoadSpectrumML(30,pwd,'low'); % to load SpectrumDataL/Spectrum30.mat

%% compute
params.trialave=0;
params.err=[1 0.0500];
params.pad=2;
params.normsize=50; % nbr of timepoints used for normalization
params.Fs=1250;

if exist('option','var') && strcmp(option,'high')
    params.fpass=[20 200];
    params.tapers=[2 3];
    movingwin=[0.1 0.005];
    suffix='H';
    
elseif exist('option','var') && strcmp(option,'ultralow')
    params.fpass=[0.1 10];
    params.tapers=[3 5]; %[1 2]
    movingwin=[5 0.2]; %4
    suffix='UL';
    
elseif exist('option','var') && strcmp(option,'ultralow_bm')
    params.fpass=[0.1 1];
    params.tapers=[3 5]; %[1 2]
    movingwin=[15 1]; %4
    suffix='UL';
    
elseif exist('option','var') && strcmp(option,'ultralow_bm2')
    params.fpass=[.5 8];
    params.tapers=[3 5]; %[1 2]
    movingwin=[3 .2]; %4
    suffix='UL';
    
elseif exist('option','var') && strcmp(option,'GammaSO')
    params.fpass=[20 70];
    params.tapers=[2 3];
    movingwin=[0.1 0.005];
    suffix='H';   
    
elseif ((exist('option','var') && strcmp(option,'low')) || ~exist('option','var'))
    params.fpass=[0.1 20];
   %A numeric vector [TW K] where TW is the
%   time-bandwidth product and K is the number of
%   tapers to be used (less than or equal to
%   2TW-1).
    params.tapers=[3 5]; 
    movingwin=[3 0.2];
    suffix='L'; 
        
elseif ((exist('option','var') && strcmp(option,'newlow')) || ~exist('option','var'))
    params.fpass=[0.1 20];
    params.tapers=[1 2];
    movingwin=[3 0.2];
    suffix='L';
    
elseif ((exist('option','var') && strcmp(option,'lowkb')) || ~exist('option','var'))
    params.fpass=[0.1 20];
    params.tapers=[3 5];
    movingwin=[3 0.2];
    params.Fs=1250;
    suffix='L';
    
    
% Part add by BM 02/2021
elseif exist('option','var') && strcmp(option,'middle')
    params.fpass=[5 100];
    params.tapers=[1 2];
    movingwin=[0.2 0.005]; %4
    suffix='M';
    
    % Part added for audiodram piezo analyis
    elseif exist('option','var') && strcmp(option,'piezo')

     params.fpass=[0.5 30];
    params.tapers=[1 2];
    movingwin=[2 0.1]; %4
    suffix='P';
    
end

if  ~exist('option','var'), disp('Using default parameters... ');end

if  ~exist('askcheck','var'), askcheck=0;end

if  ~exist('Displ','var'), Displ=0;end
        
%% ckecking
if Displ
    disp(['movingwin ',option,' = [',num2str(movingwin),']']);
    disp(['params ',option,' =']);
    disp(params);
end

if askcheck
    ok=input('Do you want to change parameters (y/n)? ','s');
    while ok~='n'
        movingwin=input('Enter movingwin (default=[3 0.2]): ');
        params.fpass=input('Enter fpass (default=[0.01 20]): ');
        params.tapers=input('Enter params.tapers (default=[3 5]): ');
        params.Fs=input('Enter params.Fs (low=250, high=1250): ');
        disp(['movingwin = [',num2str(movingwin),']'])
        disp('params = ')
        disp(params)
        ok=input('Do you want to change parameters (y/n)? ','s');
    end
end


