clear;
vowel_a = 'a_Baptiste.wav';
[y,fs] = audioread(vowel_a);
x = linspace(10^4,3*10^4,1);
%xp = x(10^4:2*10^4,1);
plot(y)
xlabel('Sample Number')
ylabel('Amplitude')
% y=fft(x);
% plot(y);
% m = length(vowel_a);       % original sample length
% n = pow2(nextpow2(m));  % transform length
% y = fft(vowel_a,n);        % DFT of signal