function ClEpoch=CleanUpEpoch(Epoch,sorted)
%remove intervals with a null duration

if nargin==1
    sorted=0;
end

stp=Stop(Epoch);
str=Start(Epoch);
ind=find(stp-str==0);
stp(ind)=[];
str(ind)=[];

if sorted
    for i=1:length(stp)-1
        if stp(i)>str(i+1)
            str(i+1)=stp(i);
        end
    end
end


ClEpoch=intervalSet(str,stp);
end