clear all;
close all;
% %Insert audio 
% [y,Fs] = audioread('An.wav');
% %Calcul moyen 
% yf = fft(y);
% n = length(y);
% power = abs(yf).^2/n;
% moyen = mean(power);
% %Calcul moment 
% moment1 = sum(Fs.*power)/sum(power);
% Insérer audio
[y, Fs] = audioread('W_On.wav');
plot(y);
% Calculer densité spectrale de puissance et fréquences correspondantes
[Pxx, f] = pwelch(y, [], [], [], Fs);

% Calculer moyenne et moment du spectre de puissance
moyen = mean(Pxx);
moment = sum(Pxx .* f) / sum(Pxx);