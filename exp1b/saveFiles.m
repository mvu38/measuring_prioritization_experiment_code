function saveFiles(Params,Logger,text)
% Saves Params and Logger to file, according to format specified in Params.
% The optional input variable 'text' allows for appending a label to the
% filename.

% Allow for no added text in file name
if ~exist('text','var')
    text = '';
end

% Prepare file name
saveTo = [Params.dataFolder Params.subjectPrefix text '_' ...
    Params.experimentStart];

% Allow for a single file format
if ~iscell(Params.fileFormat); Params.fileFormat = {Params.fileFormat}; end;

% Save
for frmt = 1:length(Params.fileFormat)
    switch Params.fileFormat{frmt}
        case 'mat'
            save(saveTo ,'Params','Logger');
            disp(['Saved data to ' saveTo '.mat']');
        otherwise
            writetable(struct2table(Logger),[saveTo '.' Params.fileFormat{frmt}]);
            save([saveTo '_Params'] ,'Params');
            disp(['Saved data to ' saveTo Params.fileFormat{frmt}]);
            disp(['and params to ' saveTo '_Params.mat']);
    end
end