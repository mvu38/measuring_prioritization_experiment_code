function Params = openWindow(Params)
% Prep visual dispay

% Ensures the sync tests are run
if IsOSX
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end
Screen('Preference', 'VisualDebuglevel', 1);
Screen('Preference', 'Verbosity', 1);


HideCursor;

% Screen('Preference','TextEncodingLocale', 'UTF-8');
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing',2);

[Params.w, Params.screenRect]=Screen('OpenWindow', Params.Display.screenNumber, Params.bg);
[Params.Display.flipInterval, Params.Display.nrValidSamples, Params.Display.stddev]= Screen('GetFlipInterval', Params.w);
[x,y] = WindowCenter(Params.w);
Params.wCenter = [x y];

Screen('Blendfunction', Params.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

Screen('TextFont',Params.w, 'Arial');

Screen('TextSize', Params.w, 40);
Screen('TextStyle',Params.w, 0);

Screen('FillRect',Params.w, Params.bg);
Screen('Flip', Params.w);
end