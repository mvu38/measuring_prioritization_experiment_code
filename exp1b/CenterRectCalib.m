function nRect = CenterRectCalib(Params,oRect, eye)
% This function centers a rect in the screen, according to the calibrated
% location of the relevant eye.

if eye
    nRect = CenterRectOnPoint(oRect, Params.wCenter(1) + Params.rightShift,...
        Params.wCenter(2));
else
    nRect = CenterRectOnPoint(oRect, Params.wCenter(1) + Params.leftShift,...
        Params.wCenter(2));
end
end