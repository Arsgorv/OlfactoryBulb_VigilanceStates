function S = state_colors_AG()
% state_colors_AG  Single source of truth for vigilance-state names and colors.
%
% OUTPUT
%   S.names         {'Wake','N1','N2','REM'}
%   S.shortNames    {'W','N1','N2','R'}
%   S.colors        cell of 1x3 RGB triplets, same order as names
%   S.colorsMat     [4x3] matrix version of colors
%   S.bgLight       background color for "lights ON" shading
%   S.bgDark        background color for "lights OFF" shading
%
% Colors are kept consistent with Baptiste's ferret-paper convention:
%   Wake = blue, N1 = orange (was IS), N2 = red (was core SWS), REM = green.

S.names      = {'Wake', 'N1',     'N2',          'REM'};
S.shortNames = {'W',    'N1',     'N2',          'R'};
S.colors     = { ...
    [0.20 0.20 0.80], ...   % Wake
    [1.00 0.50 0.00], ...   % N1 (= IS in legacy scoring)
    [0.85 0.10 0.10], ...   % N2 (= deep SWS)
    [0.20 0.75 0.20]};      % REM

S.colorsMat  = cell2mat(S.colors(:));   % 4 x 3

% Light/dark background shading for ZT/24-h figures
S.bgLight = [1.00 0.98 0.85];   % pale yellow
S.bgDark  = [0.85 0.86 0.94];   % pale grey-blue

end
