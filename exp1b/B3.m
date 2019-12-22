% Main experiment file
% This file should be clear and readable, and easily manipulated even by
% users who did not take part in coding this experiment.

%% Prep
% Clear previous screen settings. Optionally for debug - run with
% transperant window
clear Screen
% PsychDebugWindowConfiguration;

PsychDefaultSetup(2);

% Load parameters
B3Params;

% Log start time
Params.experimentStart = datestr(now,'yymmdd_HHMM');

%Set randomization to not start over on every system startup
s = RandStream.create('mt19937ar','seed',sum(100*clock));       
RandStream.setGlobalStream(s);

% Get subject number
Params.subjectNumber=input('subject number?\n');
Params.subjectPrefix = ['S' num2str(Params.subjectNumber, '%02d')];

% Log everything to diary file
diary([Params.dataFolder Params.version '_' Params.subjectPrefix '_Log_'...
    Params.experimentStart '.txt']);

try
    % Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs; WaitSecs(0.1);
    
    % Load image files
    Params.Images = loadImages(Params);    
    
    % Open PTB window
    Params = openWindow(Params);
        
    % Calibrate stereoscopic presentation if needed
    if strcmp(Params.Display.stereoMode,'stereoscope')
        Params = initialCalibration(Params);
    end
    
    % Instructions
    ins.contKey = KbName('space');
    ins.isPict = 1;
    for ii = 1:5
        if ii == 5
            ins.contKey = KbName('1!');
        end
        ins.img = ['ins' num2str(ii) '.jpg'];
        doInstructions(Params,ins);
    end
    
    %% Block order
    if mod(Params.subjectNumber,2)
        blockOrder = {'bRMS', 'bCFS'};
    else
        blockOrder = {'bCFS', 'bRMS'};
    end
    
    %% Run blocks
    for ii = 1:2
        %%% Training
        % Define block
        training = [];
        training.stimLabel = 'training';
        training.repetitions = 1;
        training.trialType = blockOrder{ii};
        eval(['training.fadeIn = Params.', blockOrder{ii},...
            '.stimulus.fadeInTime;']);
        eval(['training.alpha = Params.' blockOrder{ii}, ...
            '.stimulus.maxAlpha;']);
        
        % Run block
        Logger = runBlock(Params, training);
        
        % Insturctions
        msg.text = Params.plsCall;
        msg.rtl = 0;
        msg.contKey = KbName('1!');
        doInstructions(Params,msg);
        
        msg.text = [1500 1495 1509 32 1506 1500 32 1502 1511 1513 32 1492 ...
            1512 1493 1493 1495 32 1500 1492 1502 1513 1498];
        msg.contKey = KbName('space');
        doInstructions(Params,msg);
        
        %%% Experimental blocks
        % Define block
        exp = [];
        exp.stimLabel = 'exp';
        exp.repetitions = 1;
        exp.trialType = blockOrder{ii};
        exp.alpha = Params.alphaLevels;
        exp.orientations = [0 180];
        eval(['exp.fadeIn = Params.', blockOrder{ii},...
            '.stimulus.fadeInTime;']);
        
        % Run block
        Logger = runBlock(Params,exp);
        
        % Save file
        saveFiles(Params,Logger,blockOrder{ii});
        
        % Insturctions
        msg.text = Params.plsCall;
        msg.rtl = 0;
        msg.contKey = KbName('1!');
        doInstructions(Params,msg);
        
    end
        
    %%% Finish and close
    sca;        % Close PTB window
    diary off;  % Stop logging events

catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    Priority(0);
    ShowCursor;
end