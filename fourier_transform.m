function[freq,mag]=fourier_transform(signal,t,ts,N)
S=fft(signal,N);
CS=[S(N/2+1:N) S(1:N/2)];
freq=[-N/2+1:N/2]/(N*ts);
mag=abs(CS);
figure;
plot(freq,mag);