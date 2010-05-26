function coefs = fd_coefs
  % Generate coefficients for decimate-by-10 interpolation filter using 2*5
  % taps and passing 85% of the band.
  h = intfilt(10,5,0.85);
  % Reorder coefficients for ROM
  coefs = reshape(reshape([0,h],10,10)',1,[]);
  % Pre-quantize coefficients to 16 fractional bits
  coefs = round(coefs*2^16)/2^16;
end