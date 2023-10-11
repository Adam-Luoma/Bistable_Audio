%% pilot_behavior.m
% Behavioral pilot to see if the task is feasible
% Task one: hit the keyboard when you hear a grace note or a target note
% Save key-hit timing, stimulus name of two ears (left and right),
% attending condition (left, right, or both), and the attended stimulus
% (stimuli if condition == both)
% Task two: play the last 1-2 second of the stimuli, and do a pattern
% match. 'Which was the sound you just heard?'. Forced binary choice. One
% choice is left ear and one choice is right ear. Save the attended
% condition and their answered condition. Don't do this for the 'both'
% condition.

sca; close all; clear all;
addpath('./utils');
%% Init setup with TDTRP
requireTDT = input("Which audio system are you using? 0=PTB, 1=TDT: ");

if requireTDT
  addpath('./ActiveXExamples/Matlab');
  circuit = 'C:\Users\TDT1\Desktop\Shu\scripts\playSound_dynamic.rcx';
  TDT = setupTDT(circuit);
  Fs_tdt = round(TDT.FS);
else
  Fs = 44100;
  n_chan = 2;
  InitializePsychSound(1);
  pahandle = openPTBHandle(Fs, n_chan);
end
%% Variables
subjid = input("ID of the subject?: ", "s");
stimtype = input("Type of stimuli? [s] or [m]: ", "s");
isPilot = input("Is it a pilot? 0=No, 1=Yes: ");
isPractice = input("Is it a practice? 0=No, 1=Yes: ");
if isPilot
  savedir = '../../../data/binaural-attention/behav_pilot/';
elseif isPractice
  savedir = '../../../data/binaural-attention/behav_practice/';
else
  savedir = '../../../data/binaural-attention/behav/';
end

if stimtype=="s"
  stimdir = '../../../stimulus/binaural-attention/stimSpeech_pan/';
  stimdir_leftright = '../../../stimulus/binaural-attention/stimSpeech_catSegment/';
  stimfiles_list = '../../../stimulus/binaural-attention/stimSpeech_filenames.csv';
elseif stimtype=="m"
  stimdir = '../../../stimulus/binaural-attention/stimMusic_pan/';
  stimdir_leftright = '../../../stimulus/binaural-attention/stimMusic_stereo/';
  stimfiles_list = '../../../stimulus/binaural-attention/stimMusic_filenames.csv';
else
  error("Invalid stimtype!");
end

savefile = ['subj' subjid '_' stimtype '.mat'];
savepath = [savedir savefile];

if isPractice
  blocks_randomized = {{'left'}, {'right'}, {'both'}};
  stimfiles_raw = {''}; % input manually
  stimfiles_randomized = stimfiles_raw(randperm(length(stimfiles_raw)));
else
  blocks = {{{'left', 'left'}, {'right', 'right'}},...
            {'both', 'both', 'both', 'both'}};
  stimfiles_raw = readtable(stimfiles_list, 'Delimiter', ',');
  stimfiles_raw = stimfiles_raw.filenames;
  [blocks_randomized, stimfiles_randomized] = ...
    randomizeBlockFiles(blocks, stimfiles_raw, stimtype, str2num(subjid));
end

n_block = length(blocks_randomized);
if isPractice
  n_trial = 2;
else
  n_trial = 8;
end

instructionText_path = 'instructions.xlsx';
instructionTexts = rows2vars(...
  readtable(instructionText_path, 'FileType', 'spreadsheet'),...
  'VariableNamesSource', 'textName');
%% Audio and visual variable
Fs_orig = 44100;
n_chan = 2;

% Define initial font size and maximum text width for Screen
font_size = 40;

%% Init keyboard table
keyResponseAll_grace = cell(1, n_trial*n_block);
keyResponseAll_patmatch = cell(n_trial*n_block, 4);

% to record presentation order
conditionOrder = cell(n_trial*n_block, 1);
stimfileOrder = cell(n_trial*n_block, 1);

%% Setup PTB
if isPilot
  Screen('Preference', 'SkipSyncTests', 1);
else
  Screen('Preference', 'SkipSyncTests', 0);
end
[window, ifi, boundaryBox] = setupPTB4me(font_size);

%% EXPERIMENT STARTS HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Give an instruction at the beginning of experiment
% Do practice trial until participants feel comfortable
% Task example (target detection and pattern match)

for i_block = 1:n_block
  %% Give an instruction at the beginning of block
  % Set condition (left, right, or both)
  % 'Attend to the `condition` ear(s)'
  cond_block = blocks_randomized{i_block};

  if strcmp(cond_block, 'both')
    textInstruction_cond = eval(instructionTexts.block_both{1});
  else
    textInstruction_cond = eval(instructionTexts.block_lr{1});
  end

  % disp text until a key is pressed
  dispTextWhileKeyIsUp(window, textInstruction_cond, boundaryBox);

  WaitSecs(0.5);

  for i_trial = 1:n_trial
    %% Record condition and information
    idx_trialblock = i_trial + n_trial*(i_block-1);
    stimidx = idx_trialblock; % idx_trialblock or i_trial

    stimfile_raw = stimfiles_raw_randomized{stimidx};
    stimfile = appendText_filename(stimfile_raw, cond_block);
    stimpath = [stimdir stimfile];

    conditionOrder{idx_trialblock, 1} = cond_block;
    stimfileOrder{idx_trialblock, 1} = stimfile;

    %% Buffer sound
    % Fill the audio playback buffer with the audio data 'wavedata':
    [wav_orig, Fs_orig] = audioread(stimpath);
    aInfo = audioinfo(stimpath);
    wavLenSec = aInfo.Duration;

    if requireTDT
      loadSoundToTDT(wav, Fs_orig, Fs_TDT, aInfo);
    else
      PsychPortAudio('FillBuffer', pahandle, wav_orig');
    end
    % Calculate how long the beep and pause are in frames
    wavLenFrames = round(wavLenSec / ifi);
    onesecLenFrames = round(1 / ifi);

    % Prepare key response to save
    keyResponses_grace = cell(wavLenFrames+1, 4);
    % keyIsDown, secs, keyCode, deltaSecs

    %% Give an instruction at the beginning of trial

    if strcmp(cond_block, 'both')
      textInstruction_cond = eval(instructionTexts.trial_both{1});
    else
      textInstruction_cond = eval(instructionTexts.trial_lr{1});
    end
    
    if stimtype=="s"
      textInstruction_task = eval(instructionTexts.trial_task_s{1});
    elseif stimtype=="m"
      textInstruction_task = eval(instructionTexts.trial_task_m{1});
    end

    textInstruction = [textInstruction_cond, textInstruction_task];

    % disp text until a key is pressed
    dispTextWhileKeyIsUp(window, textInstruction, boundaryBox);
    WaitSecs(0.5);

    %% Play sound and trigger%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dispTextForNFrames(window, '+', onesecLenFrames, boundaryBox); % show the cross for 1 sec

    % trigger sound
    if requireTDT
      TDT.trg(1);
    else
      PsychPortAudio('Start', pahandle);
    end
    
    [keyResponses_grace{1, :}] = KbCheck();

    for i = 1:wavLenFrames
      [keyResponses_grace{i+1, :}] = KbCheck();
      DrawFormattedText(window, '+', 'center', 'center', [1 1 1],...
        [], [], [], [], [], boundaryBox);
      Screen('Flip', window);
    end

    if ~requireTDT
      PsychPortAudio('Stop', pahandle);
    end

    dispTextForNFrames(window, '+', onesecLenFrames,boundaryBox);
    %% Summarize key response
    keyResponses_grace{1, 1} = 1; % just to preserve the initial secs
    keyResponses_grace_nonzero = ...
      keyResponses_grace([1;find(diff(cell2mat(keyResponses_grace(:, 1)))==1)+1], :);
    % get the only starting frame of a key press
    keyResponses_grace_nonzero(:, 2) = ...
      mat2cell(cell2mat(keyResponses_grace_nonzero(:, 2)) - ...
      keyResponses_grace_nonzero{1, 2}, ...
      ones(1, size(keyResponses_grace_nonzero, 1)), 1);
    keyResponsesTime_grace = cell2mat(keyResponses_grace_nonzero(:, 2));

    %% Save response
    keyResponseAll_grace{1, idx_trialblock} = keyResponsesTime_grace;
    %% Task at the end of trial
    if ~strcmp(cond_block, 'both')
      %% Prepare the audio
      % get the audio
      nsec_patmatch = 8;
      patmatchLenFrames = round(nsec_patmatch / ifi);
      idx_patmatch = Fs*(wavLenSec - nsec_patmatch);
      
      if stimtype=="s"
        [stimfile_left, stimfile_right] = getLeftRightOnlyFilename(stimfile_raw);
        left_patmatch = audioread([stimdir_leftright stimfile_left], [idx_patmatch, inf]);
        right_patmatch = audioread([stimdir_leftright stimfile_right], [idx_patmatch, inf]);
      elseif stimtype=="m"
        stimfile_leftright = [stimdir_leftright stimfile_raw];
        y = audioread(stimfile_leftright, [idx_patmatch, inf]);
        left_patmatch = y(:, 1);
        right_patmatch = y(:, 2);
      end
      if size(left_patmatch, 2)==1
        left_patmatch = [left_patmatch left_patmatch];
        right_patmatch = [right_patmatch right_patmatch];
      end

      % randomize order
      rng(str2num(subjid)+idx_trialblock);
      leftPlaysFirst = round(rand(1));
      if leftPlaysFirst
        sound1 = left_patmatch;
        sound2 = right_patmatch;
      else
        sound1 = right_patmatch;
        sound2 = left_patmatch;
      end

      %% Display prompt
      % Display until a key is pressed
      % Display 'The last portion of the music will be played again.'
      % 'Detect which melody was the one you were just attending to'
      textInstruction = eval(instructionTexts.patmatch1{1});

      % disp text until a key is pressed
      dispTextWhileKeyIsUp(window, textInstruction, boundaryBox);
      WaitSecs(0.5); 

      %% load sound 1
      if requireTDT
        loadSoundToTDT(sound1, Fs_orig, Fs_TDT, aInfo);
      else
        PsychPortAudio('FillBuffer', pahandle, sound1');
      end

      % show text for 1 sec
      dispTextForNFrames(window, 'Sound 1', onesecLenFrames, boundaryBox);

      % Start sound
      if requireTDT
        TDT.trg(2);
      else
        PsychPortAudio('Start', pahandle);
      end

      % show text while playing + 1 sec after that
      dispTextForNFrames(window, 'Sound 1', patmatchLenFrames,boundaryBox);

      if ~requireTDT
        PsychPortAudio('Stop', pahandle);
      end

      dispTextForNFrames(window, 'Sound 1', onesecLenFrames,boundaryBox);

      %% play sound 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if requireTDT
        loadSoundToTDT(sound2, Fs_orig, Fs_TDT, aInfo);
      else
        PsychPortAudio('FillBuffer', pahandle, sound2');
      end

      % show text for 1 sec
      dispTextForNFrames(window, 'Sound 2', onesecLenFrames, boundaryBox);

      % Start sound
      if requireTDT
        TDT.trg(3);
      else
        PsychPortAudio('Start', pahandle);
      end

      % show text while playing + 1 sec after that
      dispTextForNFrames(window, 'Sound 2', patmatchLenFrames,boundaryBox);

      if ~requireTDT
        PsychPortAudio('Stop', pahandle);
      end

      dispTextForNFrames(window, 'Sound 2', onesecLenFrames,boundaryBox);

      %% Get the response
      if xor(leftPlaysFirst, strcmp(cond_block, 'left'))
        correctMatch_key = '2';
      else
        correctMatch_key = '1';
      end

      textInstruction = eval(instructionTexts.patmatch2{1});

      % Display text_instruction until space bar is placed
      keyIsDown = 0;
      while true
        DrawFormattedText(window, textInstruction, 'center', 'center', [1 1 1], ...
          [], [], [], [], [], boundaryBox);
        Screen('Flip', window);
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();

        if keyIsDown
          kbName = KbName(keyCode);
          kbName = kbName(1);
          if kbName==correctMatch_key
            patmatchIsCorrect = 1;
          else
            patmatchIsCorrect = 0;
          end
          break
        end
      end
      WaitSecs(0.5);
      %% Save response
      keyResponseAll_patmatch{idx_trialblock, 1} = kbName;
      keyResponseAll_patmatch{idx_trialblock, 2} = correctMatch_key;
      keyResponseAll_patmatch{idx_trialblock, 3} = patmatchIsCorrect;
      keyResponseAll_patmatch{idx_trialblock, 4} = leftPlaysFirst;
    else
      %% Fill in blank response
      keyResponseAll_patmatch{idx_trialblock, 1} = 'NA';
      keyResponseAll_patmatch{idx_trialblock, 2} = -1;
      keyResponseAll_patmatch{idx_trialblock, 3} = -1;
      keyResponseAll_patmatch{idx_trialblock, 4} = -1;
    end
  end

  %% Give some rest
  textInstruction = eval(instructionTexts.rest{1});

  % disp text until a key is pressed
  dispTextWhileKeyIsUp(window, textInstruction, boundaryBox);
  WaitSecs(0.5);

end

%% Export Response
responseTable = table();
responseTable.Block = repelem(1:n_block, n_trial)';
responseTable.Trial = repmat(1:n_trial, 1, n_block)';
responseTable.Condition = conditionOrder;
responseTable.StimulusFile = stimfileOrder;

responseTable.PatmatchResponse = keyResponseAll_patmatch(:, 1);
responseTable.PatmatchAnswer = keyResponseAll_patmatch(:, 2);
responseTable.PatmatchIsCorrect = keyResponseAll_patmatch(:, 3);
responseTable.PatmatchLeftPlaysFirst = keyResponseAll_patmatch(:, 4);

responseTable.GraceResponseTime = keyResponseAll_grace';

save(savepath, 'responseTable');

if ~requireTDT
  PsychPortAudio('Close', pahandle);
end
%% End experiment
sca; close all;
%% Don't ignore keyboard input except for subject response
ListenChar(0);
% sca; close all; clear all;