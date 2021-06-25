function [noRadVal,multipleRadVal] = validateParams(files,rmin,rmax,sensitivity)
noRadVal = []; % Radius degerinin bulunmadigi indeksler
multipleRadVal = []; % Birden fazla radius degerinin bulundugu indeksler
for i=1:numel(files)
    img = imread(strcat(files(i).folder,'/',files(i).name));
    e = edge(img,'canny');
    [centers, radiusVal] = imfindcircles(e,[rmin rmax],'ObjectPolarity','dark','Sensitivity',sensitivity);
    if (numel(radiusVal) == 0)
        noRadVal = [noRadVal i];
    elseif (numel(radiusVal)>1)
        multipleRadVal = [multipleRadVal i];
    end
end
end