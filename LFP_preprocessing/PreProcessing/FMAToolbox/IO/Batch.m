%Batch - Create a new batch job.
%
% This helps easily read and parse batch files.
%
%  USAGE
%
%    Batch(bfile,mfile,delay)
%
%    bfile          batch file listing the parameters for each item
%    mfile          M-file to execute (or function handle)
%    delay          optional delay (in s) before execution starts
%
%  EXAMPLE
%
%    Assuming you wish to run the following function
%
%      ComputeSomething(session,start,stop,channel);
%
%    on several dozen items, starting in one hour, you would create
%    a batch file listing the corresponding (session,start,stop,channel)
%    t-uples arranged in columns (one line per t-uple) and then call
%
%      Batch('/path/to/batch_file.txt','ComputeSomething',3600);

% Copyright (C) 2007 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

function output = Batch(bfile,mfile,delay)

% Check number of parameters
if nargin < 2,
	error('Incorrect number of parameters (type ''help <a href="matlab:help Batch">Batch</a>'' for details).');
end
if nargin == 2,
	delay = 0;
end

% Open batch file
f = fopen(bfile,'r');
if f == -1, error(['Could not open file ''' bfile '''.']); end

item = 1;
% Read batch file
while ~feof(f),
	field = 0;
	% Read next line
	line = fgetl(f);
	while ~isempty(line),
		% Get next field
		[token,line] = strtok(line);
		% Skip rest of line if this is a comment
		if isempty(token) | token(1) == '%', break; end
		field = field + 1;
		% Determine if this is a number
		n = str2num(token);
		if isempty(n),
			% It is a string, keep it as it is
			b.field{item,field} = token;
		else
			% It is a number, convert it to numerical format
			b.field{item,field} = n;
		end
	end
	if field > 0, item = item + 1; end
end

% Close file
fclose(f);

% Reset iterator
b.currentItem = 0;
b.currentField = 0;

% Set batch function
b.mfile = mfile;

% Start timer
t = timer('TimerFcn',{@RunBatch,b},'StartDelay',delay);
start(t);
