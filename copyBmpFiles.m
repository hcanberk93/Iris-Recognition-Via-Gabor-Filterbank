function [] = copyBmpFiles(folderSyntax) % Void Function
files = dir(folderSyntax); % Belirtilen dizindeki tum dosyalari elde eder
folderName = split(folderSyntax,"/"); % Split ile sol veya sag oldugu bulunur
folderName = strcat(folderName(1),folderName(3)); % Ilgili dizin ismi olusturulur
orgFolderName = folderName; % strcat kullanildigindan her dongude asil dizinin resetlenmesi gerekir
for i = 1:numel(files) %Tum dosyalar donguye sokulur
    fileName = files(i).name; % Dosya ismi elde edilir
    if (fileName == "." || fileName == ".." || fileName == "Thumbs.db") % Donguye sadece *.bmp dosyalari sokulur
        continue;
    else % *.bmp dosyalari uzerindeki islemler
        % %80 Train %20 Test olarak dosyalar ayrilir
        % .bmp dosyasinin ismindeki son rakam 5 ise Test'e
        % 1,2,3,4 ise Train dosyasina gonderilir
        folderName = orgFolderName; % Dongu basinda dizin ismi resetlenir
        imgNumber = split(files(i).name,'.'); %Dosya ismi ile uzanti ayrilir
        imgNumber = char(imgNumber{1}); %  Dosya ismi secilir
        imgNumber = imgNumber(end); % Dosya isminin sonundaki rakam alinir
        if (imgNumber =='5') % Dosya numarasi 5 ise Test dizinine
            folderName = strcat(folderName,'/Test');
        else % Degilse Train dizinine gonderilir
            folderName = strcat(folderName,'/Train');
        end
         %Dosyanin ilgili dizine gonderilmesi
        movefile(strcat(files(i).folder,'/',fileName),folderName);
    end
end
end