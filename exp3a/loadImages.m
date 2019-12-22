function Images = loadImages(Params)
% Reads the stimuli list csv files to load images from disk to memory

% Display message
fprintf('Loading stimuli, please wait.');
% Read csv file
Images = readtable(Params.stimList, 'HeaderLines', 0, ...
    'ReadVariableNames', 1, 'Delimiter', ',');
Images{end,'image'} = {NaN};    % Preallocate

for ii = 1:height(Images)
    if strcmp(Images{ii,'filename'}{:}(end-2:end),'png')
        % If png read alpha layer
        [img, ~, thisAlpha] = imread([Params.stimFolder ...
            Images{ii,'filename'}{:}]);
        img(:,:,4) = thisAlpha;
        Images{ii,'image'} = {img};
    else
        Images{ii,'image'} = {imread([Params.stimFolder ...
            Images{ii,'filename'}{:}])};
    end
    if ~mod(ii,ceil(height(Images)/6)); fprintf('.'); end;
end


end