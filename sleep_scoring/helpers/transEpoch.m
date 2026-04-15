function [aft_cell,bef_cell]=transEpoch(varargin)

%aft_cell(i,j)=intervalset of Epochi that is followed by EPochj
%bef_cell(i,j)=intervalset of Epochi that follows EPochj
%%Example
%     [aft_cell,bef_cell]=transEpoch(SWSEpoch,Wake);
% %Start(aft_cell{1,2}) ---> beginning of all SWS that is followed by Wake
% % Start(bef_cell{1,2}) ---> beginning of all SWS that is preceded by Wake
% %Start(aft_cell{2,1})---> beginning of all Wake  that is followed by SWS
% %Start(bef_cell{2,1})---> beginning of all Wake  that is preceded by SWS

% aft_cell{1,2} --> SWS before Wake
% aft_cell{2,1} --> Wake before SWS
% bef_cell{1,2} --> SWS after Wake
% bef_cell{1,2} --> Wake after SWS


k=size(varargin,2);
aft_cell=cell(k,k);
for i=1:k
    bef=Stop(varargin{i});
    for j=1:k
        if i~=j
            aft=Start(varargin{j});
            ind=[];
          for t=1:length(bef)
            if sum(bef(t)==aft)==1
                ind=[ind t];
            end
          end
            aft_cell{i,j}=subset(varargin{i},ind);
        end
    end
end
  
bef_cell=cell(k,k);
for i=1:k
    bef=Start(varargin{i});
    for j=1:k
        if i~=j
            aft=Stop(varargin{j});
            ind=[];
          for t=1:length(bef)
            if sum(bef(t)==aft)==1
                ind=[ind t];
            end
          end
            bef_cell{i,j}=subset(varargin{i},ind);
        end
    end
end
end  
