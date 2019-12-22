function response = doInstructions(Params, Trial)
% This function displays text instructions and waits for keypress.
% Alternitively, if the field 'isPict' is present and set to 1, it draws a
% picture insturctions
Screen('Flip',Params.w);
for eye = 0:1
    rect = CenterRectCalib(Params,angle2pix(Params.Display,[0 0 Params.frame.width ...
            Params.frame.height] - [0,0,Params.frame.penWidth,Params.frame.penWidth]), eye);
    
    % Select image buffer for drawing:
    Screen('SelectStereoDrawBuffer', Params.w, eye);
        
    % Display message
    if isfield(Trial,'isPict') && Trial.isPict
        img = imread([Params.stimFolder Trial.img], 'jpg');
        img = Screen('MakeTexture',Params.w,img);
        Screen('DrawTexture',Params.w,img,[],rect);
    else
        Screen('TextSize', Params.w, 16);
        Screen('TextStyle',Params.w, 0);
        DrawFormattedText(Params.w, Trial.text, 'center', 'center',...
            [0 0 0],[],[],[],2,Trial.rtl,rect);
    end
    
    % Draw frame
    drawFrame(Params,eye);
end
Screen('DrawingFinished',Params.w);
Screen('Flip',Params.w);

% Collect response
if Trial.contKey
    exitFlag = 0;
    while exitFlag == 0
        WaitSecs(0.1);     % Prevent CPU overload
        [key_is_down,~,key_code,~] = KbCheck();                 %check for subject keypress
        if key_is_down
            if sum(key_code(Trial.contKey))
                response = find(key_code);
                break
            elseif key_code(Params.keyEsc)
                sca;
                break;
            end
        end
    end
    KbReleaseWait;
    Screen('Flip', Params.w);
end
end