function [pCenterVals,pRadiusVals] = extractPupilFeatures(files,rmin,rmax,sensitivity)
pCenterVals = []; % Merkezi koordinatlar
pRadiusVals = []; % Radyan
for i = 1:numel(files)
    img = imread(strcat(files(i).folder,'/',files(i).name));
    e = edge(img,'canny');
    
    [centers, radiusVal] = imfindcircles(e,[rmin rmax],'ObjectPolarity','dark','Sensitivity',sensitivity);
    
    pCenterVals = [pCenterVals ; centers ];
    pRadiusVals = [pRadiusVals ; radiusVal];
    
end