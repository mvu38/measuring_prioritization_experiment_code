function Logger = runBlock(Params, Block)
% This script runs a block of trials, and updates the
% Logger structure.

% try
% Choose only relevant stimuli
Images = Params.Images(strcmp(Params.Images.label, Block.stimLabel),:);
Images.Properties.RowNames = Images.filename;

% Make a trial plan
Plan = trialPlanner();  % See below

% Preallocate Logger struct
Logger = struct('Subject',[],'Trial',[],'Stimulus',[], 'Location',[],...
    'Orientation', [], 'Alpha', [], 'Response',[],'RT',[],'Acc',[],...
    'vbl', []);
Logger(length(Plan)).Trial = NaN;

% Add trial data to general Logger
for jj = transpose(intersect(fieldnames(Logger),fieldnames(Plan)))
    for trl = 1:NTrials
        Logger = setfield(Logger,{trl},jj{:},...
            getfield(Plan,{trl},jj{:}));
    end
end

% Up the priority
Priority(1);

% Start keyboard listener
keysOfInterest=zeros(1,256);
keysOfInterest(Params.keyRight) = 1;
keysOfInterest(Params.keyLeft) = 1;
keysOfInterest(Params.keyEsc) = 1;
KbQueueCreate([], keysOfInterest);

% Trial loop
ITIStart = GetSecs();   % When did the ITI start
for trl = 1:length(Plan)
    
    Trial = Plan(trl);
    
    % Make texture
    Trial.stimHandle = Screen('MakeTexture', Params.w, ...
        Images{Trial.Stimulus, 'image'}{:});
    
    % Wait ITI
    WaitSecs(Params.ITI() - (GetSecs() - ITIStart));
    
    % Do Trial
    data = doTrial(Params,Trial);
    ITIStart = GetSecs();
    
    % Add trial data to general Logger
    for jj = transpose(fieldnames(data))
        Logger = setfield(Logger,{trl},jj{:},getfield(data,jj{:}));
    end
    
    % Close stimuli textures to save memory
    Screen('Close', Trial.stimHandle);
    
    % Take a break if needed
    if ~(mod(trl, Params.breakEvery)) && trl~=length(Block)
        doInstructions(Params, Params.breakMessage);
    end
end


KbQueueRelease();
% catch
%     Priority(0);
%     return % Make sure partial Logger is returned to global workspace if errors
% end

%% Auxillary functions
    function Plan = trialPlanner()
        
        % Default orientation
        if ~isfield(Block, 'orientations') || isempty(Block.orientations)
            Block.orientations = 0;
        end
        
        % Default orientation
        if ~isfield(Block, 'alpha') || isempty(Block.alpha)
            Block.alpha = Params.stimulus.maxAlpha;
        end

        
        % Get relevant file names for this block from csv
        stimuli = Images.filename(strcmp(Images.label,Block.stimLabel));
        
        % Random eye and location
        NTrials = length(Block.orientations) * Block.repetitions *...
            length(Block.alpha) *length(stimuli);
        
        % Preallocate
        Plan = struct('Subject',[],'Trial',[],'Stimulus',[],...
            'Location',[], 'Orientation', [], 'Alpha', []);
        Plan(NTrials).Trial = NaN;
        count = 1;
        
        % randomly assign location and eye (if applicable) within
        % condition
        locations = Shuffle([ones(1,ceil(length(Block.orientations) * ...
            length(Block.alpha) * Block.repetitions * length(stimuli)/2)) ...
            zeros(1,floor(length(Block.orientations) * ...
            length(Block.alpha) * Block.repetitions * length(stimuli)/2))] + 9);
        
        % Assign values to trials
        for rep = 1:Block.repetitions
            startBlock = count;
            for orient = 1:length(Block.orientations)
                for alpha = 1:length(Block.alpha)
                    for stim = 1:length(stimuli)
                        Plan(count).Subject = Params.subjectNumber;
                        Plan(count).Stimulus = Images.filename{stim};
                        Plan(count).Location = locations(count - startBlock + 1);
                        Plan(count).Orientation = Block.orientations(orient);
                        Plan(count).Alpha = Block.alpha(alpha);
                        count = count+1;
                    end
                end
            end
            % Shuffle keeping block order
            Plan(startBlock:count-1) = Shuffle(Plan(startBlock:count-1));
        end
        
        for ii = 1:length(Plan); Plan(ii).Trial = ii; end;
    end

end