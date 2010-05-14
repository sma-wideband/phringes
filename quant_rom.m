
function [out] = quant_rom()

addr = 0:(2^15 - 1);
out = zeros(length(addr),1);

for i=0:(2^15 - 1)
    bin = dec2bin(i,15);
    thresh = bin2dec(bin(1:7));
    data = bin2dec(bin(8:15));
    if data>127
        signed = data - 256;
    else
        signed = data;
    end
    
    if signed>=thresh
        out(i+1) = 1;
    elseif (signed>=0)&&(signed<thresh)
        out(i+1) = 0;
    elseif (signed<0)&&(signed>=-thresh)
        out(i+1) = 2;
    elseif signed<-thresh
        out(i+1) = 3;
    else
        %disp('Signed number is invalid!')
    end
    
    if thresh==30
        %s = sprintf('binary: %s, signed: %d, output: %s\n',dec2bin(data,8),signed,dec2bin(out(i+1),2));
        %disp(s);
    end
    
end