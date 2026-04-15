function ndm_dir = GetNdmScriptsDir(force_select)
% GetNdmScriptsDir
% Loads ndm scripts folder from a user cfg file.
% If missing or invalid, asks user to select it and saves it for next time.
%
% Usage:
%   ndm_dir = GetNdmScriptsDir();
%   ndm_dir = GetNdmScriptsDir(true);   % force re-selection

if nargin < 1
    force_select = false;
end

cfg_file = fullfile(prefdir, 'ndm_scripts_dir.cfg');
ndm_dir = '';

% Try to load saved path
if ~force_select && exist(cfg_file, 'file')
    fid = fopen(cfg_file, 'r');
    if fid ~= -1
        line_in = fgetl(fid);
        fclose(fid);

        if ischar(line_in)
            ndm_dir = strtrim(line_in);
            if ~isfolder(ndm_dir)
                ndm_dir = '';
            end
        end
    end
end

% Ask user if nothing valid was found
if isempty(ndm_dir)
    ndm_dir = uigetdir('', 'Select the folder containing ndm scripts (ndm_concatenate, ndm_lfp, etc.) up to "ndm_scripts\ndmanager-plugins\scripts"');

    if isequal(ndm_dir, 0) || ~isfolder(ndm_dir)
        error('You must select a valid ndm_scripts directory.');
    end

    fid = fopen(cfg_file, 'w');
    if fid == -1
        error('Could not save ndm scripts path to cfg file: %s', cfg_file);
    end
    fprintf(fid, '%s\n', ndm_dir);
    fclose(fid);
end