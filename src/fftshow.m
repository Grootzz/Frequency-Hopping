function fftshow(S , fs , options)
% @funciton, fftshow(S , fs , options)
% @intro, show power spectrum 
% S@param, desired signal for fft transform
% fs@param, sampling frequency
% options@param, select show type of spectrum (single side or double sides)

n = length(S);
X = fft(S);
Y = fftshift(X);
fshift = (-n/2:n/2-1)*(fs/n); % zero-centered frequency range
fshiftHalf = (0:n/2)*(fs/n);
powershift = 10*log10((abs(Y).^2/n)/max(abs(Y).^2/n));     % zero-centered power

if(strcmp(options,'single'))
    plot(fshiftHalf,powershift(n/2:n));
elseif(strcmp(options,'double'))
    plot(fshift,powershift);
else
   disp('Please affirm options is right again!'); 
end
ylabel('dB');
end

