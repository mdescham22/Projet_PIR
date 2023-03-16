[y,fs]=audioread('A.wav');
%sound(y, fs, 16);


segmentlen = 100;
noverlap = 90;
NFFT = 128;

%spectrogram(y,segmentlen,noverlap,NFFT,fs,'yaxis')
%title('Signal Spectrogram')


x1 = y.*hamming(length(y));
preemph = [1 0.63];
x1 = filter(1,preemph,x1);

A = lpc(x1,8);
rts = roots(A);

rts = rts(imag(rts)>=0);
angz = atan2(imag(rts),real(rts));

[frqs,indices] = sort(angz.*(fs/(2*pi)));
bw = -1/2*(fs/(2*pi))*log(abs(rts(indices)));

nn = 1;
for kk = 1:length(frqs)
    if (frqs(kk) > 90 && bw(kk) <400)
        formants(nn) = frqs(kk);
        nn = nn+1;
    end
end
formants

L=length(y);
signal = fft(y);
P2 = abs(signal/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
plot(f,P1)
p=polyfit(f,P1,6);
res=polyval(p,f);
hold on
plot(res)
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

%plot(y)
%p=polyfit(x,y,n);
%petit ajout