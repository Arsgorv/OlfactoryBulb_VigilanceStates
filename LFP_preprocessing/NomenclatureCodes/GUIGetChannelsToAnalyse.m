function GUIGetChannelsToAnalyse
load('ExpeInfo.mat')
%check if some channels already exists
% AddOpts.Resize = 'on';
% AddOpts.WindowStyle = 'normal';
% AddOpts.Interpreter = 'tex';
ChannelsToAnalyseNomenclature
if not((isfield(ExpeInfo,'ChannelToAnalyse')))
    ExpeInfo.ChannelToAnalyse = struct;
end

for a= 1: length(locations_to_analyse)
    if isfield(ExpeInfo.ChannelToAnalyse,locations_to_analyse{a})
        default_answer{a} = num2str(ExpeInfo.ChannelToAnalyse.(locations_to_analyse{a}));
    else
        default_answer{a} = 'NaN';
    end
end

answer = inputdlgcol(locations_to_analyse, 'ChannelToAnalyse', 1, default_answer,'on',3);
ExpeInfo = rmfield(ExpeInfo,'ChannelToAnalyse'); % add by BM on 02/11/2023
for a = 1 : length(answer)
    if not(isnan(eval(answer{a})))
        ExpeInfo.ChannelToAnalyse.(locations_to_analyse{a}) = eval(answer{a});
    end
end
ExpeInfo.ChannelToAnalyse
save('ExpeInfo.mat','ExpeInfo')