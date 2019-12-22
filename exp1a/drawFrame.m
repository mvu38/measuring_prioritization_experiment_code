function drawFrame(Params)
% This function draws the frame
switch Params.frame.type
    case 'line'
        rects = zeros(2,4);
        rects(1,:) = CenterRect(angle2pix(Params.Display,[0 0 Params.frame.width ...
            Params.frame.height]), Params.screenRect);
        rects(2,:) = CenterRect(angle2pix(Params.Display,[0 0 Params.frame.width + ...
            Params.frame.delta Params.frame.height + ...
            Params.frame.delta]), Params.screenRect);
        Screen('FrameRect',Params.w, Params.frame.color', rects', ...
            angle2pix(Params.Display,Params.frame.penWidth));
end
end