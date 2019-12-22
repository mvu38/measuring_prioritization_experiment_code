function Display = mkDisplay(Params)
% Saves room and screen parameters for angle to pixel conversions and
% stereo display. Display.stereoMode has two options right now:
% 'stereoscope' for side-by-side display, and '3d' for compressed
% side-by-side for 3d screen.

%% Parameters that need to be input
switch Params.location
    case 'yaniv'
        Display.dimensions = [28.5 17.9];       % (cm)    
        Display.distance = 30;              % Viewing distance (cm)
        Display.reduceCrossTalk = [];    % If you want cross-talk reduction b/w sides, specify gain. Otherwise leave empty
        
        % This command depends on OS. For windows max is correct
        Display.screenNumber=max(Screen('screens'));
        
    case 'lab'
        Display.dimensions = [31.8 23.8];       % (cm)
        Display.distance = 30.5;              % Viewing distance (cm)
        Display.reduceCrossTalk = [];    % If you want cross-talk reduction b/w sides, specify gain. Otherwise leave empty
        
        % This command depends on OS. For windows max is correct
        Display.screenNumber=max(Screen('screens'));
    case 'lab3d'
        Display.dimensions = [51 28.8];       % (cm)
        Display.distance = 45;              % Viewing distance (cm)
        Display.reduceCrossTalk = [];    % If you want cross-talk reduction b/w sides, specify gain. Otherwise leave empty
        
        % This command depends on OS. For windows max is correct
        Display.screenNumber=max(Screen('screens'));
end

%% Parameters that are computed automatically
Display.frameRate=Screen('FrameRate',Display.screenNumber);   % Get screen refresh rate

Display.flipInterval = 1 / Display.frameRate * 1000;   % Time of frame (ms). Will change when window opens to accurate ifi

[Display.width, Display.height] = Screen('WindowSize', Display.screenNumber); % get the screen dimensions

Display.pixelSize = mean(Display.dimensions./[Display.width, Display.height]);

end
