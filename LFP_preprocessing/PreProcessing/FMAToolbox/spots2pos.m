% spots2pos - Extract position samples from .spots file.
%
%  Extract position samples from .spots file, merge multiple LEDs,
%  interpolate missing samples, resample and save to .pos file.
%
%  USAGE
%
%    spots2pos(filename,<options>)
%
%    filename       either a single spots file, or a concatenation event file
%                   (.cat.evt) to process and concatenate multiple spots files
%                   belonging to the same set
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'input'       input frequency (default = 25)
%     'output'      output frequency (default = 39.0625)
%     'resolution'  [maxX maxY] video resolution (default = [320 240])
%     'threshold'   threshold (default = 0)
%     'leds'        1 or 2 (default = 1)
%    =========================================================================
%
%  NOTE
%
%    Typical values for 'resolution' include [320 240] and [720 576].

%  CUSTOM DEFAULTS
%
%    Properties 'input', 'output', 'resolution', 'threshold' and 'leds' can
%    have custom default values (type 'help <a href="matlab:help CustomDefaults">CustomDefaults</a>' for details).

% Copyright (C) 2004-2010 by Michaël Zugaro, 2004 by Ken Harris
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

function spots2pos(filename,varargin)

nSamplesPerScreen = 100;

% Check number of parameters
if nargin < 1,
	error('Incorrect number of parameters (type ''help spots2pos'' for details).');
end

% Default values
inputFrequency = GetCustomDefaults('input',25);
outputFrequency = GetCustomDefaults('output',39.0625);
threshold = GetCustomDefaults('threshold',0);
leds = GetCustomDefaults('leds',1);
resolution = GetCustomDefaults('resolution',[320 240]);
events = [];

% Is the input file a spots file or an event file?
if ~isempty(regexp(filename,'[.]cat[.]evt$')),
	events = LoadEvents(filename);
	if isempty(events.time), error('Empty event file.'); end
	bases = regexprep(events.description,{'beginning of ','end of '},'');
	bases = {bases{1:2:end}}';
	durations = diff(events.time);
	durations = durations(1:2:end);
	path = fileparts(filename);
	if isempty(path), path = '.'; end
else
	[path,filename] = fileparts(filename);
	if isempty(path), path = '.'; end
	bases = {filename};
end

% Parse options
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+firstIndex) ' is not a property (type ''help spots2pos'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'input',
			inputFrequency = varargin{i+1};
			if ~isnumeric(inputFrequency) | any(size(inputFrequency)~=1) | inputFrequency <= 0,
				error('Incorrect value for property ''input'' (type ''help spots2pos'' for details).');
			end
		case 'output',
			outputFrequency = varargin{i+1};
			if ~isnumeric(outputFrequency) | any(size(outputFrequency)~=1) | outputFrequency <= 0,
				error('Incorrect value for property ''output'' (type ''help spots2pos'' for details).');
			end
		case 'resolution',
			resolution = varargin{i+1};
			if ~isnumeric(resolution) | length(resolution)~=2 | any(resolution) <= 0,
				error('Incorrect value for property ''resolution'' (type ''help spots2pos'' for details).');
			end
		case 'threshold',
			threshold = varargin{i+1};
			if ~isnumeric(threshold) | any(size(threshold)~=1) | threshold <= 0,
				error('Incorrect value for property ''threshold'' (type ''help spots2pos'' for details).');
			end
		case 'leds',
			leds = varargin{i+1};
			if ~isscalar(leds) | ~isnumeric(leds) | leds ~= round(leds) | leds <= 0,
				error('Incorrect value for property ''leds'' (type ''help spots2pos'' for details).');
			end
		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help spots2pos'' for details).']);
	end
end

concatenated = [];

% Process each file
for i = 1:length(bases),
	new = ProcessOne([path '/' bases{i} '.spots'],inputFrequency,outputFrequency,resolution,threshold,leds);
	% Concatenate
	if ~isempty(events),
		% Compare source and target durations (and # samples)
		nSourceSamples = size(new,1);
		sourceDuration = nSourceSamples/outputFrequency;
		nTargetSamples = round(outputFrequency*durations(i));
		% Display some info
		disp('File size adjustment for position file');
		disp(['    duration    ' num2str(sourceDuration) ' -> ' num2str(durations(i)) ' (' num2str(durations(i)-sourceDuration) ')']);
		disp(['    # frames    ' int2str(nSourceSamples) ' -> ' int2str(nTargetSamples) ' (' int2str(nTargetSamples-nSourceSamples) ')']);
		if abs(durations(i)-sourceDuration) > 3,
			disp('    *** large shift may indicate a problem ***');
		end
		% Truncate or fill
		if nTargetSamples <= nSourceSamples,
			concatenated = [concatenated;new(1:nTargetSamples,:)];
		else
			concatenated = [concatenated;new;-1*ones(nTargetSamples-nSourceSamples,size(new,2))];
		end
	end
end

% Concatenate
if ~isempty(events),
	filename = regexprep(filename,'.cat.evt','.pos');
	dlmwrite([path '/' filename],round(concatenated),'\t');
	disp(['Concatenated positions saved to ''' filename '''.']);
end

% ------------------------------------------------------------------------------------------

function resampledPositions = ProcessOne(filename,inputFrequency,outputFrequency,resolution,threshold,leds)

twoLEDs = leds == 2;
maxX = resolution(1);
maxY = resolution(2);
resampledPositions = [];

% Load .spots file
spots = [];
if exist(filename),
  	spots = load(filename);
	spots(:,1) = spots(:,1)+1;
	initialTimestamps = (1:max(spots(:,1)))';
	spots = spots(spots(:,7)>=threshold,:);
	nFrames = size(initialTimestamps,1);
end
if isempty(spots),
	warning(['Empty spots file ''' filename ''' (or threshold too high)']);
	return
end

fig = figure;
Browse(fig,'off');

% Optionnally, remove spurious spots
while true,
	plot(spots(:,3),spots(:,4),'.','markersize',1);
	xlim([-5 maxX+5]);ylim([-5 maxY+5]);
	set(gca,'ydir','reverse');
	keyin = input('In the figure window, are there spurious spots you wish to remove (y/n)? ', 's');
	if strcmp(lower(keyin),'y'),
		zoom on;
		input('In the figure window, draw a polygon around the points you wish to remove.\n(left click = add polygon point, right click = cancel last polygon point, middle click = close polygon)\nZoom on the area of interest if necessary, then hit ENTER to start... ','s');
		zoom off;
		keep = ~UIInPolygon(spots(:,3),spots(:,4));
		spots = spots(keep,:);
	elseif strcmp(lower(keyin),'n'),
		break;
	end
end
if isempty(spots),
	warning(['No spots left in file ''' filename ''' after removal of spurious spots.']);
	return
end

if twoLEDs,

	% Two LEDs

	% Select front versus rear LED in CrCb color space
	fig2 = figure;
	crcb = spots(:,8:9);
	plot(crcb(:,1),crcb(:,2),'.','markersize',1);
	xlabel('Cr');
	ylabel('Cb');
	zoom on;
	fprintf('\nDiscrimination of front (resp. left) and rear (resp. right) lights\n---------------------------------------\n');
	fprintf('In the figure window, draw a polygon around the points corresponding to the front or left spot.\n(left click = add polygon point, right click = cancel last polygon point, middle click = close polygon)... ','s');
	isFrontSpot = ~UIInPolygon(crcb(:,1),crcb(:,2));
	frontSpots = spots(isFrontSpot,:);
	backSpots = spots(~isFrontSpot,:);
	plot(frontSpots(:,3),frontSpots(:,4),'.','color',[1 0 0],'markersize',10,'linestyle','none');
	hold on;
	plot(backSpots(:,3),backSpots(:,4),'.','color',[0 1 0],'markersize',10,'linestyle','none');

	% Make trajectory
	positions = -1*ones(nFrames,4);
	nFrontSpots = Accumulate(frontSpots(:,1)); % number of spots in each frame
	nFrontSpots(nFrontSpots==0) = -1; % to avoid division by 0 (will be discarded later anyway)
	meanFrontX = Accumulate(frontSpots(:,1),frontSpots(:,3))./nFrontSpots; % mean X for each frame
	meanFrontY = Accumulate(frontSpots(:,1),frontSpots(:,4))./nFrontSpots;
	goodFrames = nFrontSpots ~= -1;
	positions(goodFrames,1:2) = [meanFrontX(goodFrames) meanFrontY(goodFrames)];

	nBackSpots = Accumulate(backSpots(:,1));
	nBackSpots(nBackSpots==0) = -1;
	meanBackX = Accumulate(backSpots(:,1),backSpots(:,3))./nBackSpots;
	meanBackY = Accumulate(backSpots(:,1),backSpots(:,4))./nBackSpots;
	goodFrames = nBackSpots ~= -1;
	positions(goodFrames,3:4) = [meanBackX(goodFrames) meanBackY(goodFrames)];

else

	% One LED

	% Discard frames with 0 spots; merge all spots in each frame
	nSpots = Accumulate(spots(:,1)); % number of spots in each frame
	nSpots(nSpots==0) = -1; % to avoid division by 0 (will be discarded later anyway)
	meanX = Accumulate(spots(:,1),spots(:,3))./nSpots; % mean X for each frame
	meanY = Accumulate(spots(:,1),spots(:,4))./nSpots;

	% Make trajectory
	goodFrames = nSpots ~= -1;
	positions = -1*ones(nFrames,2);
	positions(goodFrames,:) = [meanX(goodFrames) meanY(goodFrames)];

end

% Interpolate missing stretches up to 10 frames long
interpolatedPositions = Clean(positions,10,inf);
interpolatedPositions(interpolatedPositions==-1) = NaN; % so it doesn't interpolate between 100 and -1 and get 50.

% Make positions by interpolating
sourceTimestamps = (0:nFrames-1)'/inputFrequency;
duration = sourceTimestamps(end,1);
targetTimestamps = (0:1/outputFrequency:duration)';
warning('off','MATLAB:interp1:NaNinY');
resampledPositions = interp1(sourceTimestamps,interpolatedPositions,targetTimestamps,'linear',-1);
warning('on','MATLAB:interp1:NaNinY');
resampledPositions(~isfinite(resampledPositions)) = -1;

figure(fig);
hold on;
k = 0;
cleanPositions = resampledPositions(any(resampledPositions~=-1,2),:);
p = [];
p2 = [];
while ~strcmp(input('Hit ENTER to show the next N samples, or type ''done''+ENTER to proceed... ','s'),'done'),
	k = k+1;
	n1 = (k-1)*nSamplesPerScreen+1;
	n2 = k*nSamplesPerScreen;
	if n2 > length(cleanPositions), break; end
	if ~isempty(p), delete(p); end
	if ~isempty(p2), delete(p2); end
	p = plot(cleanPositions(n1:n2,1),cleanPositions(n1:n2,2),'.','color',[1 0 0],'markersize',10,'linestyle','none');
	if twoLEDs,
		p2 = plot(cleanPositions(n1:n2,3),cleanPositions(n1:n2,4),'.','color',[0 1 0],'markersize',10,'linestyle','none');
	end
end
close(fig);

if ~isempty(spots),
	[unused,basename] = fileparts(filename);
	dlmwrite([basename '.pos'],round(resampledPositions),'\t');
	disp(['Saved to ''' basename '.pos''.']);
end

% ------------------------------------------------------------------------------------------

function cleanPositions = Clean(positions,maxGap,maxDistance)

if nargin<2
	maxGap = 20;
end

if nargin<3
	maxDistance = 30;
end

n = size(positions,1);

% Work on column pairs (each column pair corresponds to one LED)
for i = 1:size(positions,2)/2,

	% Interpolate missing values or large jumps
	j = (i-1)*2+1;
	jump = abs(diff(positions(:,j)))>10|abs(diff(positions(:,j+1)))>10;
	good = find(positions(:,j)>-1 & ~([jump;0] | [0;jump]));
	if length(good) < 2,
		cleanPositions(:,[j j+1]) = -ones(size(positions,1),2);
	else
		cleanPositions(:,[j j+1]) = round(interp1(good,positions(good,[j j+1]),1:n,'linear',-1));
	end

	% Find missing stretches
	d = [-(positions(1,j)==-1) ; diff(positions(:,j)>-1)];
	start = find(d<0);
	stop = find(d>0)-1;
	% If last point is bad, final stretch should be discarded
	if positions(end,j) == -1,
		stop = [stop;n];
	end

	% Do not interpolate data that does not conform to (maxGap,maxDistance) constraints
	if length(start>0),
		i1 = Clip(start-1,1,n);
		i2 = Clip(stop+1,1,n);

		discard = find(stop-start>=maxGap ...
			| abs(positions(i1,j)-positions(i2,j)) > maxDistance ...
			| abs(positions(i1,j+1)-positions(i2,j+1)) > maxDistance);

		for k = discard(:),
			cleanPositions(start(k):stop(k),[j j+1]) = -1;
		end
	end

end