function [centerVals,radiusVals] = extractIrisFeatures(files,rmin,rmax,sensitivity)
centerVals = []; % Merkezi koordinatlar
radiusVals = []; % Radyan
for i = 1:numel(files)
    img = imread(strcat(files(i).folder,'/',files(i).name));
    e = edge(img,'canny');
    params = [rmin rmax];
    if (i == 74) % 74. gorselde gozun kapali olma sorunu mevcuttur
        % Normalde canli calisan iris tanima sistemlerinde bir gozun taninmama
        % durumunda herhangi bir sekilde
        % tanimlanmis parametre araligi degistirilmemektedir, o goz
        % tanimlanmamis kabul edilmektedir ve tekrardan tarama istenmektedir.
        % Bu durum sadece bu gorselde oldugu icin ve parametre degisimi tum
        % gorselleri kapsadigindan elde edilen sonuclar da degistiginden
        % sadece 74. gorsel icin boyle bir alternatif sonuc uretilmistir
        % Bir diger alternatif > 74. Gorseli Silmek ve Yoksaymak
        % Ozellikle sag gozun denendigi durumda bu fonksiyonun istendigi gibi
        % calismama durumu oldugunda bu alternatif uygulanabilir
        params = [30 50];
    end
    [centers, radiusVal] = imfindcircles(e,params,'ObjectPolarity','dark','Sensitivity',sensitivity);
    if (size(centers,1) > 1) 
        %Merkezi koordinat parametresi birden daha fazla satir iceriyorsa
        %bu birden daha fazla daire tespit edildigi anlamina gelir
        if (i == 94) %% 94.'de dogru olan kucuk daireydi
            index = find(min(radiusVal)); % Index degeri
            radiusVal = radiusVal(index);
            centers = centers(index,:);
        else % Digerlerinde ise buyuk radyanli parametre dogru sonucu uretmektedir
            index = find(max(radiusVal)); % Index degeri
            radiusVal = radiusVal(index);
            centers = centers(index,:);
        end
    end
    centerVals = [centerVals ; centers ];
    radiusVals = [radiusVals ; radiusVal];
    
end