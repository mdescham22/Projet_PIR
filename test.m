% Charger le fichier audio contenant la voyelle
filename = 'A.wav';
[x, Fs] = audioread(filename);

% Afficher le spectre de fréquence de la voyelle
N = length(x);
X = fft(x);
%f = (0:N-1)*(Fs/N);


P2 = abs(X/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
figure;
plot(f,P1)




%plot(f, abs(X));
title('Spectre de fréquence');
xlabel('Fréquence (Hz)');
ylabel('Amplitude');

% Trouver les pics dans le spectre de fréquence
%[pks, locs] = findpeaks(abs(X));
[pks, locs] = findpeaks(P1);
% Ajuster une courbe de tendance polynomiale aux pics
poly_order = 20; % Ordre du polynôme à ajuster (ici 3ème degré)
p = polyfit(locs, pks, poly_order);
x_fit = linspace(min(locs), max(locs), 1000);
y_fit = polyval(p, x_fit);

% Trouver les racines de la dérivée du polynôme (correspondant aux formants)
dp = polyder(p);
formants = sort(roots(dp)); % On sélectionne les trois premiers formants
freqs = formants * Fs / N;
disp('Les fréquences des trois formants principaux sont :');
disp(freqs);

% Afficher le spectre de fréquence avec la courbe de tendance polynomiale et les formants
figure;
plot(f, P1);
hold on;
plot(x_fit, y_fit, 'r');
plot(freqs * N / Fs, polyval(p, formants), 'x');
title('Spectre de fréquence avec courbe de tendance et formants');
xlabel('Fréquence (Hz)');
ylabel('Amplitude');
legend('Spectre de fréquence', 'Courbe de tendance', 'Formants');
