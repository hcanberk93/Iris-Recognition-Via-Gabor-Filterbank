%% Dataset Hazirlama İslemi
if ~exist('MMUleft','dir') % Sol goz dizini olusturulur
    mkdir MMUleft
    mkdir MMUleft/Test
    mkdir MMUleft/Train
end

if ~exist('MMUright','dir') % Sag goz dizini olusturulur
    mkdir MMUright
    mkdir MMUright/Test
    mkdir MMUright/Train
end
%% MMU Dosyasindaki Gozlerin Ortak Bir Klasörde Toplanmasi
copyBmpFiles("MMU/*/left"); % Sol gozleri kopyala
copyBmpFiles("MMU/*/right"); % Sag gozleri kopyala
%% Greyscale Donusumu
if ~exist('MMUleftGS','dir') && ~exist('MMUrightGS','dir') 
    %Resimler RGB formatindadir
    %Greyscale donusumler icin ayri dizin olusturulur ve orijinal icerik
    %kopyalanir
    mkdir MMUleftGS %GS - Greyscale
    mkdir MMUrightGS
    copyfile('MMUleft','MMUleftGS');
    copyfile('MMUright','MMUrightGS');
end
% Grayscale donusum sadece Train dizinine uygulanmalidir
% Test edilecek dosya, sadece test edildigi an kiyas yapilabilmesi amaciyla
% ilgili donusumlerden gecirilmelidir
convertBmpToGS('MMUleftGS/Train/*.bmp');
convertBmpToGS('MMUleftGS/Test/*.bmp');
convertBmpToGS('MMUrightGS/Train/*.bmp');
convertBmpToGS('MMUrightGS/Test/*.bmp');
%% Edge Detection (Canny) && ROI (Region of Interest) - Circular Hough Transform
% Elimizdeki greyscale gorsellerindeki iris kenarlarinin bulunmasi gerekmektedir
% Bunun icin kenar noktalarinin bulunabilmesi icin sik
% kullanilan Canny filtresi uygulanacaktir
% Canny haricinde Sobel filtresi de oldukca yaygin kullanilmaktadir
% Canny filtresinin, gurultulu gorsellere karsin daha basarili oldugu
% bilinmesinden oturu
files = dir('MMUleftGS/Train/*.bmp'); % Sol gozun oldugu dizin secilir
img = imread(strcat(files(1).folder,'/',files(1).name));
imshow(img); % Greyscale Gorsel
e = edge(img,'canny'); % Canny filtresinin implementasyonu
figure
imshow(e); % Canny Filtresi
% Iris, gorselde bulunmasi gereken bir daireyi ifade etmektedir. Bu daire ve
% dairenin sinirlari Greyscale gorselinden daha ziyade Canny filtresinde oldukca
% rahatlikla bulunabilmektedir.Gorsele Canny filtresi uygulandiktan sonra,
% goruntu islemede gerek cizgilerin gerek dairelerin de bulunmasinda
% oldukca sik kullanilan Hough donusumu kullanilarak iris bolgesi
% bulunacaktir.
% Irisi temsil eden dairenin radius degeri net olarak bilinmemektedir ve diger
% gorsellerde de degisken olacaktir. Bunun icin bu dairenin radius
% degerinin 45-75 araliginda olmasi uygun gorulmustur. Tespit edilecek
% daire, siyah renkte oldugu icin ObjectPolarity parametresi dark olarak
% girilmis ve duyarlilik %95 olarak ayarlanmistir.
% Radius parametresi, deneme yanilma yontemi (test-trial) ile sonraki
% asamalarda degistirilebilir olacaktir, parametreler tum goz gorsellerini
% kapsayabilecek genis bir araligi temsil edebilmeli ve beklenmedik
%farkli durumlar icin (dairenin tespit edilememesi veya birden daha fazla dairenin
% tespiti) cesitli iliskiler ve algoritmalar gelistirilebilir olmalidir.
[centers, radiusVal] = imfindcircles(e,[45 75],'ObjectPolarity','dark','Sensitivity',0.95);
viscircles(centers, radiusVal,'Color','b');
%% Validasyon
% Bu asamada, girilen radius parametrelerinin kapsayici olup olmadigi
% denenecek, girilen radius araliginda bir dairenin bulunmamasi durumunda
% parametreler degistirilecektir, birden daha fazla dairenin bulunmasi
% durumunda ise kullanilacak dairenin algilanmasini saglayan basit bir
% algoritma gelistirilmesi gerekecektir

[noRadVal , multipleRadVal ] = validateParams(files,45,75,0.95);
% Bu parametreler sonucu 2 gorselde birden daha fazla daire tespit edilmis
% olup, en uygun olanın radyani daha buyuk olan daireler oldugu
% gorulmustur, bununla beraber 9 gorselde 45-75 radyan araliginda herhangi 
% bir daire tespit edilememis olmasi, aralik skalasinin arttirilma
% ihtiyacini sergilemektedir, bunun icin yeni radyan parametreleri
% denenecektir
%%
[noRadVal , multipleRadVal ] = validateParams(files,40,100,0.95);
% Parametre araliginin genisletilmesiyle beraber herhangi bir dairenin
% tespit edilmedigi bir gorsel kalmamasiyla beraber, 62 gorselde birden
% daha fazla daire tespit (2 ve daha fazlasi) edilmistir ve fazladan daire 
% tespit edilen gorsellerin hepsini kapsayacak bir algoritma belirlemek ise
% tum kombinasyonlari goz onunde bulundurma gereksiniminden oturu
% maliyetli olmaktadir, bundan oturu hassasiyet ayari degistirilerek
% tekrardan bir belirleme yapilabilir.
%% 
%Deneme Yanilma Yontemiyle En Ideal Kapsayici Parametreler Asagidaki Gibi
%Oldugu Gorulmektedir, 6 gorselde birden daha fazla daire tespit edilmis,
%94 haricinde buyuk radius olanlarin dogru gosterildigi gozlemlenmistir.
%74'te ise kapali goz olmasi sebebiyle bulunamamistir. 74 ve 94 icin farkli
%parametre kullanilarak cikarim yapilmasi daha uygun gorulmustur fakat
%genel olarak tum gozleri en kapsayici parametreler asagida gosterildigi
%gibi oldugu icin Test kisminda asagidaki parametreler kullanilacaktir. Bu
%ise nazaran basarim oranini dusurebilecek bir olgu olmaktadir
[noRadVal , multipleRadVal ] = validateParams(files,35,100,0.93);
%% Iris Ozniteliklerinin Cikarimi
% Bu asamada tum dosyalardaki mevcut iris ozniteliklerinin ( iris merkezi
% koordinatları ve radius degerleri) cikarimi gerceklestirilecek ve tum bu
% degiskenler, goruntuden ilgili alanin kestiriminde kullanilacagi icin
% dizilerde tutulacaktir
% Rmin > 35 Rmax>100 Sensitivity>0.93
[centerVals, radiusVals] = extractIrisFeatures(files,35,100,0.93);
%% Goruntu Maskeleme
% Bu asamada belirlenen koordinatlar ile goruntulerden irisin tespit
% edildigi ortam cikartilarak sadece irisin kendisi elde edilecektir. Bunun
% icin maskeleme kullanilacaktir. Bu bloktaki kodlar sadece temel mantigin
% anlatilabilmesi ve gosterimin saglanabilmesi amaciyla yazilmistir, tum
% gorsellere uygulanabilmesi icin bir donguye ihtiyacimiz vardir

% cirX , cirY -> Tespit edilen daire merkezinin X ve Y koordinatları
cirX = centers(1);
cirY = centers(2);
% Iris tanimada isimize yarayacak kisim iris olmaktadir, dolayisiyla sadece
% irisin alindigi ve geri kalanin silindigi bir maske olusturulur. Bunun
% icin ise ndgrid komutu, X ve Y duzlemleri icin sirasiyla 
% tum piksellerden cirX ve cirY parametrelerinin cikartilmasiyla kullanilir
[xx,yy] = ndgrid(((1:size(img,1))-cirY),((1:size(img,2))-cirX));
% Iris'in bir daire oldugunu ve bir daire icini ifade eden denklemin
% x^2+y^2<r^2 oldugunu bilmekteyiz. Elimizdeki  xx ve yy gridleri ile
% bu denklem kullanilarak maske elde edilir. 
mask = (xx.^2 + yy.^2)<radiusVal^2;
% Maskenin gosterimi
imshow(mask);
% Filtre kullanilarak maskedeki 0 olan indeksler, goruntude de 0 degerine
% esitlenir.
img(mask==0) = 255; % Disinda kalan alan beyaza cevrilir
figure
imshow(img);
J = imcrop(img,[cirX-radiusVal cirY-radiusVal 2*radiusVal 2*radiusVal]);
figure
imshow(J);
%imwrite(J, 'a.png', 'Transparency', 0);
%% Goruntu Maskeleme Dongusu
% Bu dongude, tum gorsellerden tipki ust bloktaki gibi irisin ayrilma
% islemi gerceklestirilecektir ve bu irisler baska bir dosyaya
% kaydedilecektir.
if ~exist('MMUleftIris','dir') % Sol iris dizini olusturulur
    mkdir MMUleftIris
end

files = dir('MMUleftGS/Train/*.bmp');
saveCroppedImage(files,'MMUleftIris',centerVals,radiusVals,true);
%% Gozbebegi Tespiti
files = dir('MMUleftIris/*.bmp'); % Iris dizini
% Gozbebegi icin parametre denenmesi (Sonuc basarili)
[noRadVal, multipleRadVal] = validateParams(files,15,35,0.85); 
%% Gozbebegi Parametre Cikarimi
[pCenterVals,pRadiusVals] = extractPupilFeatures(files,15,35,0.85);
%% Gozbebegi Maskelemesi
files = dir('MMUleftIris/*.bmp');
img = imread(strcat(files(1).folder,'/',files(1).name));
cirX = pCenterVals(1);
cirY = pCenterVals(2);
[xx,yy] = ndgrid(((1:size(img,1))-cirY),((1:size(img,2))-cirX));
mask = (xx.^2 + yy.^2)>pRadiusVals(1)^2;
img(mask==0) = 255;
imshow(img);
figure
imshow(mask);
%% Gozbebeginin Cikarildigi Gorsellerin Kaydedilmesi
if ~exist('MMUleftIrisWOPupils','dir') % Sol iris dizini olusturulur
    mkdir MMUleftIrisWOPupils
end
files = dir('MMUleftIris/*.bmp');
saveCroppedImage(files,'MMUleftIrisWOPupils',pCenterVals,pRadiusVals,false);
%% Eslestirme
imgTest = imread('MMULeftGS/Test/aeval5.bmp');
e = edge(imgTest,'canny'); % Canny filtresinin implementasyonu
[centers, radiusVal] = imfindcircles(e,[35 100],'ObjectPolarity','dark','Sensitivity',0.93);
cirX = centers(1);
cirY = centers(2);
[xx,yy] = ndgrid(((1:size(imgTest,1))-cirY),((1:size(imgTest,2))-cirX));
mask = (xx.^2 + yy.^2)<radiusVal^2;
imgTest(mask==0) = 255;
J = imcrop(imgTest,[cirX-radiusVal cirY-radiusVal 2*radiusVal 2*radiusVal]);

e = edge(J,'canny');
[pCenters, pRadiusVal] = imfindcircles(e,[15 35],'ObjectPolarity','dark','Sensitivity',0.85);

cirX = pCenters(1);
cirY = pCenters(2);
[xx,yy] = ndgrid(((1:size(J,1))-cirY),((1:size(J,2))-cirX));
mask = (xx.^2 + yy.^2)>(pRadiusVal^2);
J(mask==0) = 255;

imgTest = imresize(J,[100,100]);
gaborArray = gaborFilterBank(5,8,39,39);
g1 = gaborFeatures(imgTest,gaborArray,4,4);
clear gaborArray
%g1 = log_gabor_filter(imgTest,2,6,3,1.7,0.65,1.3);
% imhTest = imhist(J);

files = dir('MMUleftIrisWOPupils/*.bmp');
distanceVal = zeros(numel(files),1);
for i = 1:numel(files)
    img = imread(strcat(files(i).folder,'/',files(i).name));
    img = imresize(img,[100,100]);
    gaborArray = gaborFilterBank(5,8,39,39);
    g2 = gaborFeatures(img,gaborArray,4,4);
    clear gaborArray
    
    E_distance = mean(mean(sqrt(sum((g2-g1).^2))));
    %hd = pdist2(imhTest,imhTrain,'hamming');
    %E_distance = abs(graythresh(g1)-graythresh(g2));
    distanceVal(i) = E_distance;
end
index = find(distanceVal == min(distanceVal));
disp(index);
disp(files(index).name);
%% Basarim Orani Tespiti
filesTest = dir('MMUleftGS/Test/*.bmp');
matchVals = false(numel(filesTest),1);
for i=1:numel(filesTest)
    imgTest = imread(strcat(filesTest(i).folder,'/',filesTest(i).name));
    %imgTest = imread('MMULeftGS/Test/chualsl5.bmp');
    e = edge(imgTest,'canny'); % Canny filtresinin implementasyonu
    [centers, radiusVal] = imfindcircles(e,[35 100],'ObjectPolarity','dark','Sensitivity',0.93);
    cirX = centers(1);
    cirY = centers(2);
    [xx,yy] = ndgrid(((1:size(imgTest,1))-cirY),((1:size(imgTest,2))-cirX));
    mask = (xx.^2 + yy.^2)<radiusVal^2;
    imgTest(mask==0) = 255;
    J = imcrop(imgTest,[cirX-radiusVal cirY-radiusVal 2*radiusVal 2*radiusVal]);

    e = edge(J,'canny');
    [pCenters, pRadiusVal] = imfindcircles(e,[15 35],'ObjectPolarity','dark','Sensitivity',0.85);

    cirX = pCenters(1);
    cirY = pCenters(2);
    [xx,yy] = ndgrid(((1:size(J,1))-cirY),((1:size(J,2))-cirX));
    mask = (xx.^2 + yy.^2)>(pRadiusVal^2);
    J(mask==0) = 255;

    imgTest = imresize(J,[100,100]);
    gaborArray = gaborFilterBank(5,8,39,39);
    g1 = gaborFeatures(imgTest,gaborArray,4,4);
    clear gaborArray
    
    files = dir('MMUleftIrisWOPupils/*.bmp');
    distanceVal = zeros(numel(files),1);
    for k = 1:numel(files)
        imgTrain = imread(strcat(files(k).folder,'/',files(k).name));
        imgTrain = imresize(imgTrain,[100,100]);
        
        gaborArray = gaborFilterBank(5,8,39,39);
        g2 = gaborFeatures(imgTrain,gaborArray,4,4);
        clear gaborArray
        
        E_distance = mean(mean(sqrt(sum((g2-g1).^2))));
        %imhTrain = imhist(imgTrain);
        %E_distance = abs(norm(g1-g2));
        %E_distance = mean(sqrt(sum((g1-g2).^2)));
        distanceVal(k) = E_distance;
    end
    index = find(distanceVal == min(distanceVal));
    disp(index);
    disp(files(index).name);
    
    testFileName = split(filesTest(i).name,'.');
    testFileName = testFileName {1}(1:end-2);
    trainFileName = split(files(index).name,'.');
    trainFileName = trainFileName {1}(1:end-2);
    matchVals(i) = strcmp(testFileName,trainFileName);
end
%% Pattern Template Olusturulmasi (Feature Extraction)
% Elimizdeki iris gorsellerinin kiyaslanabilmesi icin sayisallastirilmasi
% gerekecektir, bu asama aslinda Oznitelik Cikarim (Feature Extraction)
% asamasi olarak da adlandirilmaktadir ve bunun icin ise birtakim fonksiyonlar
% kullanilmasi gereklidir. Wavelet, gabor, log tabanlı gabor, gauss filtresi
% laplacian'ı bu fonksiyonların en cok bilinen ornekleridir. Bu calismada gabor 
% tercih edilmistir.
% Bir kiyas algoritması (MSE veya Hamming), kiyas bit duzeyinde (bitwise)
% gerceklesecegi icin ve her bir iris orneginin boyutu (width, height)
% degisken olabileceginden oturu renk pikselleri uzerinden kiyas
% algoritmasi calistirilamaz. Bir oruntu sablonuna ihtiyac duyulmasinin
% sebeplerinden birisi bu olmaktadir.
img = imread(strcat(files(1).folder,'/',files(1).name));
img2 = imread(strcat(files(2).folder,'/',files(2).name));
wavelength = 20;
orientation = 90;
g = gabor(wavelength,orientation);
outMag = imgaborfilt(img,g);
%% Hamming Distance
img = imread('cameraman.tif');
gaborArray = gaborFilterBank(5,8,39,39);  % Generates the Gabor filter bank
featureVector = gaborFeatures(img,gaborArray,4,4);   % Extracts Gabor feature vector, 'featureVector', from the image, 'img'.
% 