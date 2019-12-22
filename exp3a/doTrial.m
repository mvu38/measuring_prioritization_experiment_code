function Data = doTrial(Params, Trial)
% This function handles the running of a single bCFS trial. It recieves
% parameters in two structs - Params for parameters that are constant
% across experiments, Trial for parameters that vary with each trial.

% History:
% 20170409 two keypress at once fix, KbQueue used for greater accuracy
% 20170410 implemented optionally lower frame rate for better performance,
%          and the use of 'when' parameter for Screen('Flip')

%% Prep
% Determine end frame from trial
maxDisp = round(Params.endTrial / ...
    (Params.timeline.stimulus + Params.timeline.mask));

% Determine location for stimulus
frameLocation = CenterRect(angle2pix(Params.Display, ...
    [0 0 Params.frame.width Params.frame.height]), Params.screenRect);   % Frame to draw in
stimLocation = angle2pix(Params.Display,...
    [0 0 Params.stimulus.size Params.stimulus.size]); % Rect the size of the stimulus

switch Params.orientation
    case 'vertical'
        if Trial.Location == 9
            % If stimulus is top
            frameLocation(4) = (frameLocation(4)-frameLocation(2)) / 2 + ...
                frameLocation(2);
        elseif Trial.Location == 10
            % If stimulus is bottom
            frameLocation(2) = frameLocation(4) - ...
                (frameLocation(4)-frameLocation(2)) / 2;
        end
    case 'horizontal'
        if Trial.Location == 9
            % If stimulus is right
            frameLocation(1) = frameLocation(3) - ...
                (frameLocation(3)-frameLocation(1)) / 2;
        elseif Trial.Location == 10
            % If stimulus is left
            frameLocation(3) = (frameLocation(3)-frameLocation(1)) / 2 + ...
                frameLocation(1);
        end
end
stimLocation = CenterRect(stimLocation, frameLocation);

% Start listening to keyboard
KbQueueStart();

% Missing values
Data.RT=NaN;
Data.Response=NaN;

%% Animation loops
stimAlpha = 0;  % Initial stimulus alpha
mondrian = createMondrian();   % Create mask for first frame
terminate = 0;  % Assisting variable
thisDisp = 1;  % Frame counter
vbl = NaN(1,maxDisp * 2 + 3);
vbl(1) = Screen('Flip', Params.w);  % Time of trial start
IFI1 = Params.Display.flipInterval *2;  % Time from first 0 flip to first mask
% Set IFI for mask
IFI2 = round2flips(Params,Params.timeline.mask);
thisFlip = 1;   %Flip counter

while thisDisp <= maxDisp && ~terminate
    
    % Draw mask:
    Screen('FillRect',Params.w, mondrian.colors', mondrian.rect');
    
    % Draw mask-side frame:
    drawFrame(Params);    % See below
    
    % Draw fixation
    drawFixation();    % See below
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', Params.w);
    
    % Now all non-drawing tasks:
    
    % Advance counters
    thisFlip = thisFlip + 1;

    % Get response:
    [keyDown, firstPress] = KbQueueCheck();
    
    if keyDown
        if firstPress(Params.keyEsc)
            % Close screen and break loop if esc is pressed
            sca;
            break
        elseif sum(firstPress([Params.keyRight,Params.keyLeft]) > 0) == 1
            Data.RT = firstPress(firstPress > 0) - vbl(1);
            Data.Response = Params.respMap(firstPress > 0);
            Data.Acc = Params.respMap(firstPress > 0)+8 == Trial.Location;
            terminate = 1;
        end
    end
    
    % Flip screen
    vbl(thisFlip) = Screen('Flip',Params.w, ...
        vbl(thisFlip - 1) + IFI1 - Params.Display.flipInterval / 2);
    
    
    % Draw Stimulus:
    Screen('DrawTexture', Params.w, Trial.stimHandle,...
        [],stimLocation,Trial.Orientation,[],stimAlpha);
    
    % Draw stimulus-side frame
    drawFrame(Params);    % See below
    
    % Draw fixation
    drawFixation();    % See below
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', Params.w);
    
    % Compute stimulus alpha for next frame
    stimAlpha = (min(Trial.Alpha * (thisDisp + 1) / ...
        time2stim(Params, Params.stimulus.fadeInTime), ...
        Trial.Alpha));
    
    % Compute mask for next frame:
    if mod(thisDisp * Params.timeline.mask, 1/ Params.mondrian.Hz) < ...
            Params.timeline.mask
        mondrian = createMondrian();
    end
        
    % Compute mask alpha for next frame:
    if maxDisp < inf
        % If there is a time cut off to the trial
        maskAlpha = round(min(255,(1 - min((maxDisp - (thisDisp + 1)) / ...
            time2stim(Params, Params.mondrian.fadeOutTime),...
            Params.mondrian.maxAlpha)) * 255));
        mondrian.colors(end,4) = maskAlpha;
    end
    
    % Set IFI for stimulus
    IFI1 = round2flips(Params, Params.timeline.stimulus);
    
    % Advance counters
    thisFlip = thisFlip + 1;
    thisDisp = thisDisp + 1;
    
    % Flip screen
    vbl(thisFlip) = Screen('Flip',Params.w, ...
        vbl(thisFlip - 1) + IFI2 - Params.Display.flipInterval / 2);
    
end

% Clear presentation
vbl(thisFlip) = Screen('Flip', Params.w);

Data.vbl = vbl;

if ~Params.saltShaker
    KbReleaseWait();
end

% Stop listening
KbQueueStop();

% Anxillary functions
    function drawFixation()
        fixSize = angle2pix(Params.Display, Params.fixationSize);
        verFix = CenterRect([0 0 fixSize/4 fixSize], ...
            Params.screenRect);
        horFix = CenterRect([0 0 fixSize fixSize/4], ...
            Params.screenRect);
        
        Screen('FillRect', Params.w, [0 0 0], [verFix; horFix]');
    end

    function mondrian = createMondrian()
        % Rectangle sizes
        dx = angle2pix(Params.Display,Params.mondrian.width);
        dy = angle2pix(Params.Display,Params.mondrian.height);
        
        % Where to draw the rects
        frame = CenterRect(angle2pix(Params.Display,...
            [0 0 Params.frame.width Params.frame.height]), Params.screenRect);
        
        locRect = frame - [dx, dy, 0, 0];
        
        % Possible colours
        colorOpts = [eye(3); 1-eye(3)]*255;
        
        % Preallocate
        mondrian.rect = zeros(Params.mondrian.rectNum + 1,4);
        mondrian.colors = zeros(Params.mondrian.rectNum + 1,4);
        
        % Randomly draw rects
        for ii = 1:Params.mondrian.rectNum
            mondrian.rect(ii,1) = max(randi(locRect(3) - locRect(1)) + locRect(1),...
                frame(1));
            mondrian.rect(ii,2) = max(randi(locRect(4) - locRect(2)) + locRect(2),...
                frame(2));
            mondrian.rect(ii,3) = min(mondrian.rect(ii,1) + randi(dx) + dx, ...
                frame(3));
            mondrian.rect(ii,4) = min(mondrian.rect(ii,2) + randi(dy) + dy,...
                frame(4));
            
            mondrian.colors(ii,1:3) = colorOpts(randi(6),:);
            mondrian.colors(ii,4) = 255;  % Alpha channel
        end
        
        % Use a large big grey rect for fading out
        mondrian.rect(end,:) = frame;
        mondrian.colors(end,1:3) = 128;
        mondrian.colors(end,4) = (1-Params.mondrian.maxAlpha)*255;
    end
end