function [dur,durT]=DurationEpoch(Epoch,s)

% [dur,durT]=DurationEpoch(Epoch,s)
% if s='s': result in seconds
try
    s;
    dur=End(Epoch,s)-Start(Epoch,s);
durT=sum(End(Epoch,s)-Start(Epoch,s));
catch 
dur=End(Epoch)-Start(Epoch);
durT=sum(End(Epoch)-Start(Epoch));
end
