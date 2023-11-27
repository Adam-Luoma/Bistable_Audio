% Clear the workspace and the screen
sca;
close all;
clearvars;

%Initializing TDT machine
%TDT = TDTRP('Stable_BS-GN.rcx', 'RZ6');

%set status for running program (if 1 audio ran on computer, if 2 audio run
%through RZ6)
Status = 1;

try
    % Set up PsychToolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1); % Enable sync tests for precise timing

    % Open a window
    screenNumber = max(Screen('Screens'));
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
    
    % Define colors & text
    white = WhiteIndex(window);
    black = BlackIndex(window);
    textSize = 40;
    textColor = [255 255 255]; 
    backgroundColor = [0 0 0]; 
    font = 'Arial';

    % Text to display
    textToDisplay = 'Welcome to the experiment. Listen closely to the speaker. Press any Key to continue';

    % Set text size
    Screen('TextSize', window, textSize);
    Screen('TextFont', window, font);
    textBounds = Screen('TextBounds', window, textToDisplay);

    % Calculate position to center the text
    screenRect = Screen('Rect', window);
    textX = (screenRect(3) - textBounds(3)) / 2;
    textY = (screenRect(4) - textBounds(4)) / 2;

    % Display text on the screen
    Screen('FillRect', window, backgroundColor); % Fill the background color
    Screen('DrawText', window, textToDisplay, textX, textY, textColor);
    Screen('Flip', window);

    % Wait for a key press to close the window
    KbStrokeWait;
    
    iteration = 1;

    while iteration <= 6
        
        blockNumber = num2str(iteration);
        textToDisplay = strcat('Block Number ',blockNumber,', press any key to begin');

        % Display text on the screen
        Screen('FillRect', window, backgroundColor); % Fill the background color
        Screen('DrawText', window, textToDisplay, textX, textY, textColor);
        Screen('Flip', window);

        % Wait for a key press to close the window
        KbStrokeWait;

        % Run the experiment

        %Creating randomization of stimuli order 
        numbers = repmat(1:2, 1, 20);
        randomized_list = numbers(randperm(length(numbers)));

        for i = 1:40
           
            % Display fixation cross
            DrawFormattedText(window, '+', 'center', 'center', white);
            Screen('Flip', window);
                
            % Wait for 1 second
            WaitSecs(1);
                
            % Clear the screen
            Screen('Flip', window);
                
            % Wait for 500 milliseconds
            WaitSecs(0.5);
            
            %Play audio depending on computer or through TDT
            if Status == 1
                 if i <= 1
                     index = num2str(randomized_list(i));
                     name = strcat('Audio/BS_',index,'.wav');
                 elseif i > 1
                     index = num2str(randomized_list(i));
                     name = strcat('Audio/GN_',index,'.wav');
                 end
                 
                 Play_Audio(name);
    
            elseif Status == 2
                TDT.SoftTrg(randomized_list(i));
                WaitSecs(9);
    
            end
    
            % Check for break condition after each play
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('e'))
                iteration = 7
                break; 
            end
        end
        iteration = iteration + 1;
    end
    % Clear the screen and close PsychToolbox
    sca;
catch
    sca;
    psychrethrow(psychlasterror);
end



