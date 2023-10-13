function Play_Audio(audioFilePath)
    % Initialize audio
    [audio, Fs]=audioread('brain_storm.wav');

    InitializePsychSound; 
    pahandle = PsychPortAudio('Open', [], [], 0, Fs, 2); % Use the same sample rate
    
    try
        % Load audio file
        [audioData, audioFreq] = audioread(audioFilePath);
        audioData(:,2) = audioData(:,1);
        
        % Fill audio buffer
        PsychPortAudio('FillBuffer', pahandle, audioData');
        
        % Start audio playback
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        
        % Wait for audio playback to finish
        audioDur = length(audioData) / audioFreq;
        WaitSecs(audioDur);
        
        % Stop audio
        PsychPortAudio('Stop', pahandle, 1);
    catch
        psychrethrow(psychlasterror);
    end
    
    % Close audio
    PsychPortAudio('Close', pahandle);
end
