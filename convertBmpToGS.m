function [] = convertBmpToGS(folderSyntax) % Void Function
files = dir(folderSyntax); %Klasordeki dosyalari getir
for i = 1:numel(files) % Donguye sok
    fullPath = strcat(files(i).folder,'/',files(i).name); % Tam dizini elde et
    img = imread(fullPath); % Dosyayi imread ile oku
    img = rgb2gray(img); % Okunan dosyayi RGB'den Grayscale'e donustur
    imwrite(img,fullPath); % Ayni isimle dosyayi kaydet (overwrite, ustune yaz)
end
end