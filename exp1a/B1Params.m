% Parameter file for the experiment. All parameters should be placed here,
% in the struct Params. All parameters should have a comment explaining
% them, and stating the units they are specified in.

%% General parameters
Params.version = 'UpDownScramble'; % Name of the experiment for file naming

Params.location = 'lab3d';  % Name of experiment room. This determines screen size and distance, and stereo method

% Do you want to use a salt shaker to test experiment? If not keep to 0 to
% prevent "stuck key" subject
Params.saltShaker = 0;  
Params.Display = mkDisplay(Params);  % This is where display parameters are saved

%% Files and folders
Params.dataFolder = '../Data/';  % Where to save data
Params.fileFormat = 'csv';  % File format for saving data, can be 'mat' or any format supported by tablewrite
Params.stimList = 'stims1.csv'; % csv file with list of stimuli
Params.stimFolder = './Stimuli/';  % Where are the stimuli saved


%% Response keys
Params.keyRight = KbName('/?'); % What is the key for right hand?
Params.keyLeft = KbName('z'); % What is the key for left hand?
Params.keyEsc = KbName('F3'); % Abort experiment key
Params.keyLeftTop = KbName('a');   % Right top key
if IsOSX
    Params.keyRightTop = KbName('''"');    % Left top key
else
    Params.keyRightTop = KbName('''');    % Left top key
end

Params.keyCont = KbName('1!');  % Continue key for experimenter

% Define variable levels for output for each key
Params.respMap = zeros(1,255);  % This just sets up the variable
Params.respMap(Params.keyRight) = 1;    % Right key is top
Params.respMap(Params.keyLeft) = 2;     % Left key is bottom

%% Timing parameters
Params.endTrial = 10;      % When to end trial (sec). no limit - inf.
Params.ITI = 1;             % Inter trial interval (sec)
Params.breakEvery = 103;    % Break every x trials
Params.timeline.mask = 4/60;  % mask duration in s
Params.timeline.stimulus = 2/60; % stimulus duration in s

%% General presentation
Params.bg = [0.5 0.5 0.5]*256;  % Background color in RGB
Params.fixationSize = 1.75;    % Fixation size in visual angle
Params.orientation = 'horizontal';  % Orientation of task

%% Stimulus presentation parameters
Params.stimulus.size = 14;   % Stim width/height in visual angle
Params.stimulus.maxAlpha = 0.5;    % Default maximum stimulus opacity value
Params.stimulus.fadeInTime = 1;     % Initial time period for stimulus fade in (sec)
Params.alphaLevels = logspace(log10(.3), log10(.9), 6);  % Levels for chronometric function
%% Presentation frame
Params.frame.type = 'line';    % Type of convergence frame to draw, only lines implemented

Params.frame.height = 14.5;         % width of inner frame in visual angle
Params.frame.width = 34.5;         % height of inner frame in visual angle

% Specific parameters by frame type - these change the appearance of the
% frame type you chose
switch Params.frame.type
    case 'line'
        Params.frame.color = [0 0 0]; % Color of frame in rgb
        Params.frame.penWidth = .28;   % Width of stroke in visual angles
        Params.frame.delta = 1;   % Space b/w two line frames in visual angle
end

%% Mondrian parameters
Params.mondrian.rectNum = 500;  % Number of rectangles in mondrian
Params.mondrian.width = 1.2;     % Min rectangle width (max is times 2), visual angles
Params.mondrian.height = 1.2;    % Min rectangle height (max is times 2), visual angles
Params.mondrian.Hz = 10;    % Mondrian change rate (Hz)
Params.mondrian.fadeOutTime = 3;    % Fade out time for mondrian from end of trial (sec)
Params.mondrian.maxAlpha = 1; % Maximum alpha value for mask

%% Break message
Params.breakMessage.text = [1492 1508 1505 1511 1492 44 32 1500 1495 1509,...
    32 1506 1500 92 110 32 1502 1511 1513 32 1492 1512 1493 1493 1495,...
    32 1500 1492 1502 1513 1498];
Params.breakMessage.rtl = 0;
Params.breakMessage.contKey = KbName('space');
Params.plsCall = [1488 1504 1488 32 1511 1512 1488 32 1500 1504 1505 1497, ...
        1497 1503];

%% Hard conscious control parameters
Params.hardCon.stimOnsetRange = [0 0];  % Range for abrupt stim onset from mask onset (sec)
