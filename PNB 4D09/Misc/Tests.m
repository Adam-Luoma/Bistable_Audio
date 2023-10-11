sca;
close all;
clearvars;

try
    % Set up PsychToolbox
    PsychDefaultSetup(2);
    Screen('Preference', ', 1)
catch
    sca;
    psychrethrow(psychlasterror);
end