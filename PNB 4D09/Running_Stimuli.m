% Clear the workspace and the screen
sca;
close all;
clearvars;

try
    % Set up PsychToolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests for now (remove this line for precise timing)

    % Open a window
    screenNumber = max(Screen('Screens'));
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
    
    % Define colors
    white = WhiteIndex(window);
    black = BlackIndex(window);
    
    % Set text size
    Screen('TextSize', window, 40);
    
    % Load an image
    brainImage = imread('C:\Users\Adam Luoma\OneDrive\Documents\McMaster\Fourth Year\PNB 4D09\Brain.png');
    
    % Calculate image position
    imageRect = [0, 0, size(brainImage, 2), size(brainImage, 1)];
    imageRect = CenterRectOnPointd(imageRect, windowRect(3)/2, windowRect(4)/2);

    % Load an audio file
    [audioData, audioFreq] = audioread('C:\Users\Adam Luoma\OneDrive\Documents\McMaster\Fourth Year\PNB 4D09\bistable_words.wav'); % Replace with the actual path
    audioData(:,2) = audioData(:,1);

    % Initialize audio
    InitializePsychSound;
    pahandle = PsychPortAudio('Open', [], [], 0, audioFreq, 2);
    PsychPortAudio('FillBuffer', pahandle, audioData');
    
    % Display fixation cross
    DrawFormattedText(window, '+', 'center', 'center', white);
    Screen('Flip', window);
    
    % Wait for 1 second
    WaitSecs(1);
    
    % Clear the screen
    Screen('Flip', window);
    
    % Wait for 500 milliseconds
    WaitSecs(0.5);
    
    % Display brain image
    texture = Screen('MakeTexture', window, brainImage);
    Screen('DrawTexture', window, texture, [], imageRect);
    Screen('Flip', window);

    % Wait for 500 milliseconds before starting audio
    WaitSecs(0.5);
    
    % Start audio playback
    PsychPortAudio('Start', pahandle, 1, 0, 1);
    
    % Wait for audio playback to finish
    PsychPortAudio('Stop', pahandle, 1);
    
    % Close audio
    PsychPortAudio('Close', pahandle);
    
    % Wait for a key press to end the experiment
    KbWait;
    
    % Clear the screen and close PsychToolbox
    sca;
    
catch
    sca;
    psychrethrow(psychlasterror);
end
