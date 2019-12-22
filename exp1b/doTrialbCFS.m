function Data = doTrialbCFS(Params, Trial)
% This function handles the running of a single bCFS trial. It recieves
% parameters in two structs - Params for parameters that are constant
% across experiments, Trial for parameters that vary with each trial.

% History:
% 20170409 two keypress at once fix, KbQueue used for greater accuracy
% 20170410 implemented optionally lower frame rate for better performance,
%          and the use of 'when' parameter for Screen('Flip')
% 20171023 horizontal frame added

%% Prep
% Determine end frame from trial
maxFrame = time2flips(Params, Params.endTrial);

% Determine location for stimulus
frameLocation = CenterRectCalib(Params,angle2pix(Params.Display, ...
    [0 0 Params.frame.width Params.frame.height]), Trial.Eye);   % Frame to draw in
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
mondrian = createMondrian(1 - Trial.Eye);   % Create mask for first frame
terminate = 0;  % Assisting variable
thisFrame = 1;  % Frame counter
fstep = Params.timeRes;  % Jump by x frames
fstepIFI = fstep * Params.Display.flipInterval;   % Which is x sec
thisFlip = 1;   % Count flips
vbl = NaN(1,ceil(maxFrame / fstep) + 1);
vbl(1) = Screen('Flip', Params.w);  % Time of trial start

while thisFrame <= maxFrame && ~terminate
    
    % Select masked-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', Params.w, 1 - Trial.Eye);
    
    % Draw bg
    if Params.drawGrad
        drawGrad(Params, 1-Trial.Eye);
    end
    
    % Draw mask:
    Screen('FillRect',Params.w, mondrian.colors', mondrian.rect');
    
    % Draw mask-side frame:
    drawFrame(Params, 1 - Trial.Eye);    % See below
    
    % Draw fixation
    drawFixation(1 - Trial.Eye);    % See below
    
    % Select stim-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', Params.w, Trial.Eye);
    
    % Draw bg
    if Params.drawGrad
        drawGrad(Params, Trial.Eye);
    end
    
    % Draw Stimulus:
    Screen('DrawTexture', Params.w, Trial.stimHandle,...
        [],stimLocation,Trial.Orientation,[],stimAlpha);
    
    % Draw stimulus-side frame
    drawFrame(Params, Trial.Eye);    % See below
    
    % Draw fixation
    drawFixation(Trial.Eye);    % See below
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', Params.w);
    
    % Now all non-drawing tasks:
    
    % Compute mask for next frame:
    if mod(thisFrame, time2flips(Params, 1 / Params.mondrian.Hz)) < fstep
        mondrian = createMondrian(1 - Trial.Eye);
    end 
     
    % Compute mask alpha for next frame:
    if maxFrame < inf
        % If there is a time cut off to the trial
        maskAlpha = 1 - min((maxFrame - (thisFrame + fstep)) / ...
            time2flips(Params, Params.mondrian.fadeOutTime),1);
        mondrian.colors(end,4) = maskAlpha;
    end
    
    % Compute stimulus alpha for next frame
    stimAlpha = min(Params.stimulus.maxAlpha * (thisFrame + fstep) / ...
        time2flips(Params, Trial.fadeIn), ...
        Params.stimulus.maxAlpha);
    
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
    
    % Advance frame counter
    thisFrame = thisFrame + fstep;
    thisFlip = thisFlip + 1;
    
    % Flip screen - currently implemented without specifying when
    vbl(thisFlip) = Screen('Flip',Params.w, ...
        vbl(thisFlip - 1) + fstepIFI - Params.Display.flipInterval / 2);
end

Data.vbl = vbl;

if ~Params.saltShaker
    KbReleaseWait();
end

% Clear presentation
Screen('Flip', Params.w);

% Stop listening
KbQueueStop();

% Anxillary functions
    function drawFixation(side)
        fixSize = angle2pix(Params.Display, Params.fixationSize);
        verFix = CenterRectCalib(Params,[0 0 fixSize/4 fixSize], ...
            side);
        horFix = CenterRectCalib(Params,[0 0 fixSize fixSize/4], ...
            side);
        
        Screen('FillRect', Params.w, [0 0 0], [verFix; horFix]');
    end

    function mondrian = createMondrian(side)
        % Rectangle sizes
        dx = angle2pix(Params.Display,Params.mondrian.width);
        dy = angle2pix(Params.Display,Params.mondrian.height);
        
        % Where to draw the rects
        frame = CenterRectCalib(Params,angle2pix(Params.Display,...
            [0 0 Params.frame.width Params.frame.height]), side);
        
        locRect = frame - [dx, dy, 0, 0];
        
        % Possible colours
        colorOpts = [eye(3); 1-eye(3)];
        
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
            mondrian.colors(ii,4) = 1;  % Alpha channel
        end
        
        % Use a large big grey rect for fading out
        mondrian.rect(end,:) = frame;
        mondrian.colors(end,1:3) = 0.5;
        mondrian.colors(end,4) = 0;
    end
end