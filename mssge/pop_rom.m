% Populate the histogram ROM

B = zeros(256,1);

for i=0:255
    odec01 = 0;
    odec00 = 0;
    odec10 = 0;
    odec11 = 0;
    
    %disp([num2str(i),' in binary notation is ',dec2bin(i,8),'!']);
    
    inbin = dec2bin(i,8);
    for j = 1:2:7
        switch inbin(j:j+1)
            case '01'
                odec01 = odec01 + 1;
            case '00'
                odec00 = odec00 + 1;
            case '10'
                odec10 = odec10 + 1;
            case '11'
                odec11 = odec11 + 1;
            otherwise
                disp('***Bad dinary***')
        end
    end
    
    B(i+1) = bin2dec( [ dec2bin(odec01,3) dec2bin(odec00,3) dec2bin(odec10,3) dec2bin(odec11,3) ] );
end
