function varargout = BraintumorGUI(varargin)
% BRAINTUMORGUI MATLAB code for BraintumorGUI.fig
%      BRAINTUMORGUI, by itself, creates a new BRAINTUMORGUI or raises the existing
%      singleton*.
%
%      H = BRAINTUMORGUI returns the handle to a new BRAINTUMORGUI or the handle to
%      the existing singleton*.
%
%      BRAINTUMORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRAINTUMORGUI.M with the given input arguments.
%
%      BRAINTUMORGUI('Property','Value',...) creates a new BRAINTUMORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BraintumorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BraintumorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BraintumorGUI

% Last Modified by GUIDE v2.5 06-Aug-2021 10:28:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BraintumorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BraintumorGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before BraintumorGUI is made visible.
function BraintumorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BraintumorGUI (see VARARGIN)

% Choose default command line output for BraintumorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BraintumorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BraintumorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global brainImg
[filename, pathname] = uigetfile({'*.jpg'; '*.bmp'; '*.tif'; '*.gif'; '*.png'; '*.jpeg'}, 'Load Image File');
if isequal(filename,0)||isequal(pathname,0)
    warndlg('Press OK to continue', 'Warning');
else
brainImg = imread([pathname filename]);
axes(handles.axes1);
imshow(brainImg);
axis off
helpdlg(' Image loaded successfully ', 'Alert'); 
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global brainImg inp
num_iter = 10;
delta_t = 1/7;
kappa = 15;
option = 2;

inp = anisodiff(brainImg,num_iter,delta_t,kappa,option);

inp = uint8(inp);

inp=imresize(inp,[256,256]);
if size(inp,3)>1
    inp=rgb2gray(inp);
end
axes(handles.axes2);
imshow(inp);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
global  inp  Lrgb
%% thresholding
sout=imresize(inp,[256,256]);
t0=60;
th=t0+((max(inp(:))+min(inp(:)))./2);
for i=1:1:size(inp,1)
    for j=1:1:size(inp,2)
        if inp(i,j)>th
            sout(i,j)=1;
        else
            sout(i,j)=0;
        end
    end
end
%% watershed segmentation
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(sout), hy, 'replicate');
Ix = imfilter(double(sout), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
L = watershed(gradmag);
Lrgb = label2rgb(L);
axes(handles.axes3);
imshow(Lrgb);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
global  inp tumor_label label stats density area sout h tumor


sout=imresize(inp,[256,256]);
t0=60;
th=t0+((max(inp(:))+min(inp(:)))./2);
for i=1:1:size(inp,1)
    for j=1:1:size(inp,2)
        if inp(i,j)>th
            sout(i,j)=1;
        else
            sout(i,j)=0;
        end
    end
end

%% Morphological Operation
label=bwlabel(sout);
stats=regionprops(logical(sout),'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
high_dense_area=density>0.6;
max_area=max(area(high_dense_area));
tumor_label=find(area==max_area);
tumor=ismember(label,tumor_label);

if max_area>100
   axes(handles.axes4);
   imshow(tumor);
else
    h = msgbox('No Tumor!!','status');
   
    return;
end




% --- Executes on button press in pushbutton4.

function pushbutton4_Callback(hObject, eventdata, handles)

global inp tumor_label sout h
label=bwlabel(sout);
stats=regionprops(logical(sout),'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];

high_dense_area=density>0.6;

max_area=max(area(high_dense_area));
tumor_label=find(area==max_area);
tumor=ismember(label,tumor_label);

if max_area>100

imshow(tumor);
 set(handles.edit2,'String','Tumor present');
  
else
    h = msgbox('No Tumor!!','status');
     set(handles.edit2,'String','No tumor');
    %disp('No tumor');
    return;
end
%% Bounding box
box = stats(tumor_label);
wantedBox = box.BoundingBox;
axes(handles.axes5);
imshow(inp);
hold on;
rectangle('Position',wantedBox,'EdgeColor','y');
hold off;  

dilationAmount = 5;
rad = floor(dilationAmount);
[r,c] = size(tumor);
filledImage = imfill(tumor, 'holes');

for i=1:r
   for j=1:c
       x1=i-rad;
       x2=i+rad;
       y1=j-rad;
       y2=j+rad;
       if x1<1
           x1=1;
       end
       if x2>r
           x2=r;
       end
       if y1<1
           y1=1;
       end
       if y2>c
           y2=c;
       end
       erodedImage(i,j) = min(min(filledImage(x1:x2,y1:y2)));
   end
end
%figure
%imshow(erodedImage);
%title('eroded image','FontSize',20);


tumorOutline=tumor - erodedImage;


axes(handles.axes6);
imshow(tumorOutline);




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)





% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
%% Bounding box
global area  numWhitePixels  perimeter1  tumor  x y    labeledImage centroid numberOfPixels2 perimeter numberOfPixels1 

numWhitePixels = sum(tumor(:))
labeledImage = bwlabel(tumor);
measurements = regionprops(tumor,  ...
    'area', 'Centroid', 'Perimeter');

area = measurements.Area
centroid = measurements.Centroid
perimeter = measurements.Perimeter

% Calculate the area, in pixels
numberOfPixels1 = sum(tumor(:));
numberOfPixels2 = bwarea(tumor);
area=sqrt(numberOfPixels2);

 %convert into mm
area=area*0.26458333;
perimeter1=perimeter*0.26458333;

% Get coordinates of the boundary in tumor
structBoundaries = bwboundaries(tumor);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.



   set(handles.text8,'String',area);
   set(handles.text9,'String',perimeter1);
   set(handles.text16,'String',centroid);
   
if numberOfPixels2 <= 100
   set(handles.edit1,'String','NoTumor');
     elseif (numberOfPixels2 >= 100) && (numberOfPixels2 <=2000)
   set(handles.edit1,'String','Low');
elseif (numberOfPixels2 >= 2000) && (numberOfPixels2 <=4500)
     set(handles.edit1,'String','Medium');
else
set(handles.edit1,'String','High');
end
 

 message = sprintf('Number of pixels = %d\nArea in pixels = %.2f\nperimeter = %.2f\nCentroid at (x,y) = (%.1f, %.1f)\n', ...
 numberOfPixels1, numberOfPixels2, perimeter, ...
centroid(1), centroid(2));
msgbox(message);
 
% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
global im 

im = handles.axes4;
c=input('Enter the Class(Number from 1-4)');
%% Feature Extraction
F=feature_statistical(im);
try 
    load DB;
    
    F=[F c];
    DB=[DB; F];
    save DB.mat DB 
catch 
    DB=[F c]; % 10 12 1
    save DB.mat DB
end



% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)

axes(handles.axes1); cla(handles.axes1); title('');
axes(handles.axes2); cla(handles.axes2); title('');
axes(handles.axes3); cla(handles.axes3); title('');
axes(handles.axes4); cla(handles.axes4); title('');
axes(handles.axes5); cla(handles.axes5); title('');
axes(handles.axes6); cla(handles.axes6); title('');


set(handles.text8,'String','');
set(handles.text9,'String','');
set(handles.text16,'String','');
set(handles.edit1,'String','');
set(handles.edit2,'String','');

function edit1_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)



if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
