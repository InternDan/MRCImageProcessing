function [out,outHeader] = scancoParameterCalculatorCortical(img,bw,info,threshold,robust)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Expects img to be the slice stack you want to analyze (be sure it's
%%taller than the thickest object you want to analyze), bw is a mask
%%representing ONLY the bone (not the medullary cavity) with pores covered, info is a single
%%info struct from dicominfo, and the threshold is what you're using to
%%delineate bone.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find start slice
[a b c] = size(bw);
start = 1;
stop = c;

bw = bwBiggest(bw);
img(~bw) = 0;

bwPorosity = img > threshold;
BV = length(find(bwPorosity)) * info.SliceThickness^3;

% bw = imclose(bw,true(5,5,5));
[a b c] = size(bw);
bwFilled = false(size(bw));
for i = 1:c
%     clc;
%     i/c
    bwFilled(:,:,i) = imfill(imclose(bw(:,:,i),strel('disk',5,0)),'holes');
end
% bwFilled = bw;
TV = length(find(bwFilled)) * info.SliceThickness^3;
BVTV = BV/TV;

BAr = BV / (c*info.SliceThickness);
MAr = (TV - BV) / (c*info.SliceThickness);
TAr = TV / (c*info.SliceThickness);

valuesPorosity = find(img(find(bwPorosity)) > threshold);
porosity = 1 - (length(valuesPorosity) / length(find(bw)));

%find the ultimate erosion to identify the local maxima in the binary array
cc = bwconncomp(bw);
numPixels = cellfun(@numel,cc.PixelIdxList);
[biggest,idx] = max(numPixels);
bw = false(size(bw));
bw(cc.PixelIdxList{idx}) = true;
stats = regionprops(bw,'BoundingBox');
bwForLargeCalculations = bw;
bwUlt = bwulterode(bwForLargeCalculations);

%identify the background of the binary array
bwBackground = ~bwForLargeCalculations;
%     D1 = bwdistsc(bw);%does what I want for thickness of spacing
% try
%     D2 = bwdist(gpuArray(bwBackground));
%     D2 = gather(D2);
% catch
    D2 = bwdist(bwBackground);%does what I want for thickness of structures
% end
D2(~bwUlt) = 0;

if robust == 1
    [meanRad,stdRad] = calculateThickness(D2,7);
    TbTh = meanRad * 2 * info.SliceThickness;
    TbThSTD = stdRad * 2 * info.SliceThickness;
else
    %do foreground structure
    rads = D2(find(bwUlt));%find the radii of the spheres at the local maxima
    [r c v] = ind2sub(size(bwUlt),find(bwUlt));
    xyzUlt = [r c v];%find xyz coords of the local maxima
    %plot the spheres inside the surface
%     shp = shpFromBW(bw,2);
%     figure
%     plot(shp,'FaceColor','w','LineStyle','none','FaceAlpha',0.3);
%     camlight();
%     drawnow();
%     hold on;
%     [x y z] = sphere;
%     for i = 1:length(xyzUlt)
%         surf((x*rads(i)+xyzUlt(i,1)),(y*rads(i)+xyzUlt(i,2)),(z*rads(i)+xyzUlt(i,3)),'LineStyle','none','FaceColor','r');
%         axis tight;
%         drawnow();
%     end

    xyzUlt = xyzUlt .* info.SliceThickness;%convert to physical units
    diams = 2 * rads .* info.SliceThickness;%convert to diameters and in physical units

    TbTh = mean(diams);%mean structure thickness
    TbThSTD = std(diams);%standard deviation of structure thicknesses
end



%find TMD and vBMD
clear bwBackground bwUlt bb xyzUlt
[densityMatrix junk] = calculateDensityFromDICOM(info,img);
clear junk;
TMD = mean(densityMatrix(find(bwPorosity)));
vBMD = mean(densityMatrix(find(bwFilled)));

try
out = {datestr(now),...
    info.Filename,...
    TbTh,...
    TbThSTD,...
    TMD,...
    porosity,...
    TAr,...
    BAr,...
    MAr,...
    start,...
    stop,...
    info.SliceThickness,...
    threshold};
catch
    out = {datestr(now),...
    info.File,...
    TbTh,...
    TbThSTD,...
    TMD,...
    porosity,...
    TAr,...
    BAr,...
    MAr,...
    start,...
    stop,...
    info.SliceThickness,...
    threshold};
end
%     TV,...
%     BV,...
outHeader = {'Date Analysis Performed',...
    'File ID',...
    'Mean Cortical Thickness (mm)',...
    'Cortical Thickness Standard Deviation (mm)',...
    'Tissue Mineral Density(mgHA/cm^3)',...
    'Porosity',...
    'Total Area (mm^2)',...
    'Bone Area (mm^2)',...
    'Medullary Area (mm^2)',...
    'Start Slice',...
    'Stop Slice',...
    'Voxel Dimension (mm^3)',...
    'Lower Threshold'};
%     'Total Volume (mm^3)',...
%     'Bone Volume (mm^3)',...







