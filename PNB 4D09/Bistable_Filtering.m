[bistable_words, fs]=audioread('bistable_words.wav');

max_intense = max(bistable_words);

old_rms = rms(bistable_words);

for i=1:length(bistable_words)
    if bistable_words(i) < (max_intense*0.50)
        bistable_words(i) = bistable_words(i)/2;
    end
end
    
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

audiowrite('Audio/Filter_Tests/bistable_50.wav', bistable_words, fs);

new_rms = rms(bistable_words);

%create step vertor (1s and 0s where you can multiply by the notch filter)


