function response = check3d(Params)
% This function displays text instructions and waits for keypress.
% Alternitively, if the field 'isPict' is present and set to 1, it draws a
% picture insturctions
col = [1 0 0; 0 1 0];

Screen('Flip',Params.w);
for eye = 0:1
    rect = CenterRectCalib(Params,angle2pix(Params.Display,[0 0 5 ...
        5]), eye);
    
    % Select image buffer for drawing:
    Screen('SelectStereoDrawBuffer', Params.w, eye);
    
    Screen('FillRect', Params.w, col(eye+1,:), rect);
end
Screen('DrawingFinished',Params.w);
Screen('Flip',Params.w);

% Collect response
exitFlag = 0;
while exitFlag == 0
    WaitSecs(0.1);     % Prevent CPU overload
    [key_is_down,~,key_code,~] = KbCheck();                 %check for subject keypress
    if key_is_down
        if sum(key_code(KbName('1!')))
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