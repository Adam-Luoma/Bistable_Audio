function KbCheckTest()
    % Initialize Psychtoolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests for testing purposes

    % Open a window
    window = Screen('OpenWindow', 0);

    try
        while true
            % Check for key press
            [~, ~, keyCode] = KbCheck;

            if keyCode(KbName('e'))
                fprintf('You pressed the ''e'' key!\n');
                break;
            end
        end
    catch
        sca; % Close the screen in case of an error
        psychrethrow(psychlasterror);
    end

    % Close the screen
    sca;
end
