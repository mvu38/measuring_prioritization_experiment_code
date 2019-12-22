function Params = openWindow(Params)
% Prep visual dispay

% Ensures the sync tests are run
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebuglevel', 3);
Screen('Preference', 'Verbosity', 3);

HideCursor;

% Screen('Preference','TextEncodingLocale', '.1255');
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing',2);

PsychImaging('PrepareConfiguration');

switch Params.Display.stereoMode
    case 'stereoscope'
        [Params.w, Params.screenRect] = PsychImaging('OpenWindow', ...
            Params.Display.screenNumber, Params.bw, [], [], [], 4);

    case '3d'
        PsychImaging('AddTask', 'General', 'SideBySideCompressedStereo');
        
        if ~isempty(Params.Display.reduceCrossTalk)
            % Yes setup reduction for both view channels, using reduceCrossTalk as 1st parameter
            % itself.
            PsychImaging('AddTask', 'LeftView', 'StereoCrosstalkReduction',...
                'SubtractOther', Params.Display.reduceCrossTalk);
            PsychImaging('AddTask', 'RightView', 'StereoCrosstalkReduction',...
                'SubtractOther', Params.Display.reduceCrossTalk);
        end
        
        [Params.w, Params.screenRect] = PsychImaging('OpenWindow', ...
            Params.Display.screenNumber, Params.bg, [], [], [], 102);
end

[Params.Display.flipInterval, Params.Display.nrValidSamples, ...
    Params.Display.stddev]= Screen('GetFlipInterval', Params.w);
[x,y] = WindowCenter(Params.w);
Params.wCenter = [x y];

% Optional colour calibration to be implemented later

% if strcmp(Params.location, 'lab')
%     caliFile = 'calibration_14-Jun-2016 _1505_eizo.mat';
%     load (['C:\Yaniv\Color calibration\' caliFile ]);
%     Params.calibration = calibration;
%     Params.oldGamma = Screen('LoadNormalizedGammaTable', Params.w, Params.calibration.monitorGamInv ,0); %calibration.monitorGamInv is the LUT
%     
%     colorCaliFile = 'colorCalibration_14-Jun-2016_1505_eizo.mat';
%     load (['C:\Yaniv\Color calibration\' colorCaliFile ]);
%     Params.Display.colorCalibration = calibration;
% end

Screen('Blendfunction', Params.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

Screen('TextFont',Params.w, 'Arial');
end