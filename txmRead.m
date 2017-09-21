function [header headerShort img] = txmRead(pathstr)

%%Expects a full file path to the txm file. Depends on TomoToolbox read
%%functions

[header headerShort] = txmheader_read8(pathstr);

img = zeros([headerShort.ImageWidth headerShort.ImageHeight headerShort.NoOfImages],'uint16');

ct=0;
for i = 1:headerShort.NoOfImages
    ct=ct+1;
    if mod(ct,10) == 0
        clc
        ct
    end
%     progressbar(i/headerShort.NoOfImages)
    img(:,:,i) = txmimage_read8(header,ct,0,0);
end