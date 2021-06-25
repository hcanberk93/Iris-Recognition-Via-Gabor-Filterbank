function varargout = irisGUI(varargin)
%IRISGUI MATLAB code file for irisGUI.fig
%      IRISGUI, by itself, creates a new IRISGUI or raises the existing
%      singleton*.
%
%      H = IRISGUI returns the handle to a new IRISGUI or the handle to
%      the existing singleton*.
%
%      IRISGUI('Property','Value',...) creates a new IRISGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to irisGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IRISGUI('CALLBACK') and IRISGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IRISGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help irisGUI

% Last Modified by GUIDE v2.5 09-Oct-2020 04:19:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @irisGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @irisGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before irisGUI is made visible.
function irisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for irisGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes irisGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = irisGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in compare.
function compare_Callback(hObject, eventdata, handles)
% hObject    handle to compare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'img')
    errordlg('Lutfen kiyaslanacak goruntuyu seciniz','Hata')
elseif (~exist('MMUleftIrisWOPupils','dir'))
    str = 'Egitim dizini olan MMUleftIrisWOPupils bulunamamistir.';
    str2 = 'Asagidaki sartlarin saglandigindan emin olun:';
    str3 = '1 -) Kiyas yapilmadan once dataset hazirlanmalidir.';
    str4 = '2 -) Program dogru dizinde calistirilmalidir.';
    str5 = '3 -) MMUleftIrisWOPupils dizini mevcut olmalidir';
    %errorMsg = strcat(str,str2,str3,str4,str5);
    errorMsg = sprintf('\n%s \n%s \n%s \n%s \n%s \n',str,str2,str3,str4,str5);
    errordlg(errorMsg,'Hata');
else
img = handles.img;
imgTest = img;
imgTest = rgb2gray(imgTest);
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

set(handles.matchedPicName,'String',files(index).name);
axes(handles.matchedBmp);
imgMatch = imread(files(index).name);
imshow(imgMatch);

testFileName = split(handles.selectedPicName.String,'.');
testFileName = testFileName {1}(1:end-2);
trainFileName = split(files(index).name,'.');
trainFileName = trainFileName {1}(1:end-2);
matchStatus = strcmp(testFileName,trainFileName);
if (matchStatus)
    set(handles.matchInfo,'String','Eslesme Saglandi, Giris Basarili');
    set(handles.matchInfo,'ForegroundColor','green');
else
    set(handles.matchInfo,'String','Eslesme Saglanamadi, Giris Basarisiz');
    set(handles.matchInfo,'ForegroundColor','red');
end

end


% --- Executes on button press in gozat.
function gozat_Callback(hObject, eventdata, handles)
% hObject    handle to gozat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file = uigetfile('.bmp');
if file == 0
    return
end

imgNumber = split(file,'.'); %Dosya ismi ile uzanti ayrilir
imgNumber = char(imgNumber{1}); %  Dosya ismi secilir
imgNumber = imgNumber(end); % Dosya isminin sonundaki rakam alinir

if ~strcmp(imgNumber,'5')
    errordlg('Sectiginiz goruntu test goruntusu degildir. Test goruntusune ait dosya ismi 5 ile bitmektedir','Hata')
else

set(handles.selectedPicName,'String',file);

img = imread(file);
axes(handles.selectedBmp);
imshow(img);
handles.img = img;
guidata(hObject, handles);
end


% --- Executes on button press in prepareDataset.
function prepareDataset_Callback(hObject, eventdata, handles)
% hObject    handle to prepareDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~exist('MMUleft','dir') % Sol goz dizini olusturulur
    mkdir MMUleft
    mkdir MMUleft/Test
    mkdir MMUleft/Train
end

copyBmpFiles("MMU/*/left"); % Sol gozleri kopyala

if ~exist('MMUleftGS','dir') && ~exist('MMUrightGS','dir') 
    mkdir MMUleftGS %GS - Greyscale
    copyfile('MMUleft','MMUleftGS');
end

convertBmpToGS('MMUleftGS/Train/*.bmp');
files = dir('MMUleftGS/Train/*.bmp'); % Sol gozun oldugu dizin secilir
[centerVals, radiusVals] = extractIrisFeatures(files,35,100,0.93);

if ~exist('MMUleftIris','dir') % Sol iris dizini olusturulur
    mkdir MMUleftIris
end

files = dir('MMUleftGS/Train/*.bmp');
saveCroppedImage(files,'MMUleftIris',centerVals,radiusVals,true);

files = dir('MMUleftIris/*.bmp'); % Iris dizini
[pCenterVals,pRadiusVals] = extractPupilFeatures(files,15,35,0.85);
if ~exist('MMUleftIrisWOPupils','dir') % Sol iris dizini olusturulur
    mkdir MMUleftIrisWOPupils
end
files = dir('MMUleftIris/*.bmp');
saveCroppedImage(files,'MMUleftIrisWOPupils',pCenterVals,pRadiusVals,false);