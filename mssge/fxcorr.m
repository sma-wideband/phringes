function fx = fxcorr(a,b)
fa=fft(a);
fb=fft(b);
fx=sum(conj(fa).*fb,2);
