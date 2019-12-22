function Params = initialCalibration(Params)
% This function moves the right- and left-eye presentation.

%% Color screen black and wait for key stroke
for side = [0 1]
    Screen('SelectStereoDrawBuffer', Params.w, side);
    Screen('FillRect',Params.w,[0 0 0]);
end
Screen('Flip',Params.w);

exitFlag = 0;
while exitFlag == 0
    WaitSecs(0.1);     % Prevent CPU overload
    [key_is_down,~,key_code,~] = KbCheck();                 %check for subject keypress
    if key_is_down
        if key_code(KbName('1!'))
            break
        elseif key_code(Params.keyEsc)
            sca;
            break;
        end
    end
end
KbReleaseWait;
for side = [0 1]
    Screen('SelectStereoDrawBuffer', Params.w, side);
    Screen('FillRect',Params.w,Params.bw);
end
Screen('Flip',Params.w);

%% Calibrate
Params.rightShift = 0; % Amount of shift of right frame
Params.leftShift = 0;  % Amount of shift of left frame
for side = [0 1]
    % Run for both sides
    
    terminate = 0;  % Assisting variable
    while ~terminate
        
        % Prepare frame
        frame = zeros(2,4);
        frame(1,:) = CenterRectCalib(Params,angle2pix(Params.Display,[0 0 Params.frame.width ...
            Params.frame.height]), side);
        frame(2,:) = CenterRectCalib(Params, angle2pix(Params.Display,[0 0 Params.frame.width + ...
            Params.frame.delta Params.frame.height + ...
            Params.frame.delta]), side);
        
        % Prepare rectangle
        rect = CenterRectCalib(Params,angle2pix(Params.Display,[0 0 Params.frame.width ...
            Params.frame.height]), 1-side);
        
        % Select eye for frame
        Screen('SelectStereoDrawBuffer', Params.w, side);
        
        % Draw frame
        Screen('FrameRect',Params.w, Params.frame.color', frame', ...
            angle2pix(Params.Display,Params.frame.penWidth));
        
        % Select eye for rectangle
        Screen('SelectStereoDrawBuffer', Params.w, 1-side);
        
        % Draw rectangle
        Screen('FillRect',Params.w, [255 0 0], rect', ...
            angle2pix(Params.Display,Params.frame.penWidth));
        
        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', Params.w);
        
        % Get response:
        [keyDown,~,keyCode,~] = KbCheck();
        
        if keyDown
            if keyCode(Params.keyEsc)
                % Close screen and break loop if esc is pressed
                sca;
                break
            end
            
            if keyCode(Params.keyCont)
                % finish this calibration session if continue key is
                % pressed
                
                break
            end
            
            if keyCode(Params.keyRightTop)
                Params.rightShift = Params.rightShift + Params.deltaShift;
            elseif keyCode(Params.keyRight)
                Params.rightShift = Params.rightShift - Params.deltaShift;
            elseif keyCode(Params.keyLeftTop)
                Params.leftShift = Params.leftShift - Params.deltaShift;
            elseif keyCode(Params.keyLeft)
                Params.leftShift = Params.leftShift + Params.deltaShift;
            end
        end
        
        Screen('Flip',Params.w);
    end
    KbReleaseWait;
end

%% Frame validation
%% Color screen black and wait for key stroke
Screen('Flip',Params.w);
for side = [0 1]
    
    % Select eye for frame
        Screen('SelectStereoDrawBuffer', Params.w, side);
        
    % Prepare frame
    frame = zeros(2,4);
    frame(1,:) = CenterRectCalib(Params,angle2pix(Params.Display,[0 0 Params.frame.width ...
        Params.frame.height]), side);
    frame(2,:) = CenterRectCalib(Params, angle2pix(Params.Display,[0 0 Params.frame.width + ...
        Params.frame.delta Params.frame.height + ...
        Params.frame.delta]), side);
    
    % Draw frame
    Screen('FrameRect',Params.w, Params.frame.color', frame', ...
        angle2pix(Params.Display,Params.frame.penWidth));
end
Screen('Flip',Params.w);


exitFlag = 0;
while exitFlag == 0
    WaitSecs(0.1);     % Prevent CPU overload
    [key_is_down,~,key_code,~] = KbCheck();                 %check for subject keypress
    if key_is_down
        if key_code(KbName('1!'))
            break
        elseif key_code(Params.keyEsc)
            sca;
            break;
        end
    end
end
KbReleaseWait;

end