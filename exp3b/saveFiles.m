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
    %% Send data by mail
    setpref('Internet','E_mail','kleimanlabhuji@gmail.com');
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username','kleimanlabhuji@gmail.com');
    setpref('Internet','SMTP_Password','kleimanlabhuji2015');
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
        'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    sendmail('yaniv.abir+data@mail.huji.ac.il',...
        ['Data DeepShallow: ',Params.subjectPrefix], '',[saveTo '.' Params.fileFormat{frmt}]);
end