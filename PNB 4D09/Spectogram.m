clear all
close all

[green_needle, fs]=audioread('Audio/green_needle.wav');
green_needle(:,2) = []

window_size = 512; % Length of the window in samples
overlap = round(0.5*window_size); % Overlap between windows in samples
nfft = 1024; % Number of FFT points

[S, F, T] = spectrogram(green_needle, hamming(window_size), overlap, nfft, fs);

figure;
imagesc(T, F, 10*log10(abs(S)));
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Green Needle Spectrogram');
colorbar;

saveas(gcf, 'Figures/green_needle_spectrogram.png');


[brain_storm, fs]=audioread('Audio/brain_storm.wav');
brain_storm(:,2) = []

window_size = 512; 
overlap = round(0.5*window_size); 
nfft = 1024; 

[S, F, T] = spectrogram(brain_storm, hamming(window_size), overlap, nfft, fs);

figure;
imagesc(T, F, 10*log10(abs(S)));
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Brain Storm Spectrogram');
colorbar;

saveas(gcf, 'Figures/brain_storm_spectrogram.png');

[bistable_words, fs]=audioread('Audio/bistable_words.wav');

window_size = 512; 
overlap = round(0.5*window_size); 
nfft = 1024;

[S, F, T] = spectrogram(bistable_words, hamming(window_size), overlap, nfft, fs);

figure;
imagesc(T, F, 10*log10(abs(S)));
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Bistable Spectrogram');
colorbar;

ylim([0, 12000]);

saveas(gcf, 'Figures/bistable_words_spectrogram.png');


% should I run these cross correlations (values are tiny) temporally line
% them up
cc_uncropped=normxcorr2(green_needle,brain_storm);

[cross_corr, lags] =xcorr(green_needle,brain_storm);

figure;
plot(lags,cross_corr)

figure;
plot([1:length(cc_uncropped)],cc_uncropped)

length(bistable_words)/fs

bistable_words2 = bistable_words([(0.2*fs):(1.4*fs)]);

sound(bistable_words2,(fs));

gn_rms = rms(green_needle)
bs_rms = rms(brain_storm)
bi_rms = rms(bistable_words)


