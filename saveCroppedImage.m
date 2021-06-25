function [] = saveCroppedImage(files,folderName,centerVals,radiusVals,isIris)
for i=1:numel(files)
    img = imread(strcat(files(i).folder,'/',files(i).name));
    cirX = centerVals(i,1);
    cirY = centerVals(i,2);
    [xx,yy] = ndgrid(((1:size(img,1))-cirY),((1:size(img,2))-cirX));
    if (isIris)
        mask = (xx.^2 + yy.^2)<(radiusVals(i))^2;
        img(mask==0) = 255;
        J = imcrop(img,[cirX-radiusVals(i) cirY-radiusVals(i) 2*radiusVals(i) 2*radiusVals(i)]);
        imwrite(J,strcat(folderName,'/',files(i).name));
    else
        mask = (xx.^2 + yy.^2)>(radiusVals(i))^2;
        img(mask==0) = 255;
        imwrite(img,strcat(folderName,'/',files(i).name));
    end
end
end