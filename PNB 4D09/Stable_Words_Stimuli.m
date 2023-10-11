% Clear the workspace and the screen
sca;
close all;
clearvars;

[audio, Fs]=audioread('brain_storm.wav');

try
    % Set up PsychToolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 0); % Enable sync tests for precise timing

    % Open a window
    screenNumber = max(Screen('Screens'));
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
    
    % Define colors
    white = WhiteIndex(window);
    black = BlackIndex(window);
    
    % Set text size
    Screen('TextSize', window, 40);
    
    % Load audio files
    audioFiles = cell(1, 8);
    for i = 1:8
        audioFiles{i} = audioread(['BS_', num2str(i), '.wav']); % Replace with actual paths
        audioFiles{i}(:,2) = audioFiles{i}(:,1) ;
    end
    
    % Initialize audio
    InitializePsychSound;
    pahandle = PsychPortAudio('Open', [], [], 0, Fs, 2);
    
    % Define the number of repetitions for each audio file
    numRepetitions = 5;
    
    for rep = 1:numRepetitions
        for audioFiles = 1:8
            % Display fixation cross
            DrawFormattedText(window, '+', 'center', 'center', white);
            Screen('Flip', window);
            
            % Wait for 1 second
            WaitSecs(1);
            
            % Clear the screen
            Screen('Flip', window);
            
            % Wait for 500 milliseconds
            WaitSecs(0.5);
            
            % Play audio
            PsychPortAudio('FillBuffer', pahandle, audioFiles{audioIdx}');
            PsychPortAudio('Start', pahandle, 1, 0, 1);
            
            % Wait for audio playback to finish
            audioDur = length(audioFiles{audioIdx}) / pahandle.SampleRate;
            WaitSecs(audioDur);
            
            % Stop audio
            PsychPortAudio('Stop', pahandle, 1);
        end
    end
    
    % Close audio
    PsychPortAudio('Close', pahandle);
    
    % Clear the screen and close PsychToolbox
    sca;
    
catch
    sca;
    psychrethrow(psychlasterror);
end

%%% IGNORE, OLD EXPERIMENT FOR REFERENCE %%%

% Clear the workspace and the screen
sca;
close all;
clearvars;


try
    % Set up PsychToolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'PerceptualVBLSyncTest', 1); %run screen test on timing

    % Open a window
    screenNumber = max(Screen('Screens'));
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
    
    % Define colors
    white = WhiteIndex(window);
    black = BlackIndex(window);
    
    % Set text size
    Screen('TextSize', window, 40);
    
    % Load an audio file
    [audioData, audioFreq] = audioread('C:\Users\Adam Luoma\OneDrive\Documents\McMaster\Fourth Year\PNB 4D09\green_needle.wav'); % Replace with the actual path
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
    
    % Wait for 500 milliseconds before starting audio
    WaitSecs(0.5);
    
    % Start audio playback
    PsychPortAudio('Start', pahandle, 1, 0, 1);
    
    % Wait for audio playback to finish
    PsychPortAudio('Stop', pahandle, 1);
    
    % Close audio
    PsychPortAudio('Close', pahandle);
    
    % Wait for 500 milliseconds before starting audio
    WaitSecs(0.5);
    
    % Start audio playback (set up for 5 times)
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
