% Clear the workspace and the screen
sca;
close all;
clearvars;

% Set the seed
seed = 42; % Replace with your desired seed
rng(seed);

% Create a list with each number occurring 5 times
numbers = repmat(1:8, 1, 5);

% Shuffle the list
randomized_list = numbers(randperm(length(numbers)));

try
    % Set up PsychToolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1); % Enable sync tests for precise timing

    % Open a window
    screenNumber = max(Screen('Screens'));
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
    
    % Define colors
    white = WhiteIndex(window);
    black = BlackIndex(window);
    
    % Set text size
    Screen('TextSize', window, 40);
    
    % Run the experiment
    for i = 1:length(randomized_list)
       
        % Display fixation cross
        DrawFormattedText(window, '+', 'center', 'center', white);
        Screen('Flip', window);
            
        % Wait for 1 second
        WaitSecs(1);
            
        % Clear the screen
        Screen('Flip', window);
            
        % Wait for 500 milliseconds
        WaitSecs(0.5);
        
        %find the audio file
        index = num2str(randomized_list(i))
        name = strcat('Audio\BS_',index,'.wav')

        %Play Audio
        Play_Audio(name)
       
        % Check for break condition after each play
        [~, ~, keyCode] = KbCheck;
        if keyCode(KbName('e'))
            break; 
        end
    end
    % Clear the screen and close PsychToolbox
    sca;
catch
    sca;
    psychrethrow(psychlasterror);
end
