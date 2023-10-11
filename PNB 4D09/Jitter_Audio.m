clear all
close all

[audio, Fs]=audioread('green_needle.wav');
[audio1, Fs]=audioread('green_needle.wav');

[audio, Fs]=audioread('brain_storm.wav');
[audio1, Fs]=audioread('brain_storm.wav');

rng(42);
random_numbers = rand(1, 32); % create 40 random numbers (8 sets of 4 jitters between 5 stiumuli)
disp(random_numbers); %numbers from 0-1

jitter = random_numbers*.2; % set numbers between 0-0.2 (for 0-200ms)
disp(jitter);

jitter_zeros = jitter*Fs; % set numbers in samples
disp(jitter_zeros);

zeros_matrix = reshape(jitter_zeros, 4, 8); %creates a 4 by 8 matrix of the jitters per trial

for i = 1:(size(zeros_matrix, 2))
    x = zeros_matrix(:,i);

    for j = 1:size(zeros_matrix, 1)
        zeros_appending = zeros(int32(x(j)), 1); %creates int for number of zeros
        extended_audio = [audio; zeros_appending];   % appends those zeros and another interation of the stimuli
        extended_audio = [extended_audio; audio1];  
        audiowrite('extend.wav', extended_audio, Fs);    % write & read in new version of longer audio
        [audio, Fs]=audioread('extend.wav');
    end
    %[audio, Fs]=audioread('green_needle.wav');
    [audio, fs]=audioread('brain_storm.wav');

    index = num2str(i)
    name = strcat('BS_',index,'.wav')
    audiowrite(name, extended_audio, Fs);
end   

