function varargout = RegisterVolumes(varargin)
% REGISTERVOLUMES MATLAB code for RegisterVolumes.fig
%      REGISTERVOLUMES, by itself, creates a new REGISTERVOLUMES or raises the existing
%      singleton*.
%
%      H = REGISTERVOLUMES returns the handle to a new REGISTERVOLUMES or the handle to
%      the existing singleton*.
%
%      REGISTERVOLUMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTERVOLUMES.M with the given input arguments.
%
%      REGISTERVOLUMES('Property','Value',...) creates a new REGISTERVOLUMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegisterVolumes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegisterVolumes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegisterVolumes

% Last Modified by GUIDE v2.5 09-Mar-2017 14:38:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegisterVolumes_OpeningFcn, ...
                   'gui_OutputFcn',  @RegisterVolumes_OutputFcn, ...
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


% --- Executes just before RegisterVolumes is made visible.
function RegisterVolumes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegisterVolumes (see VARARGIN)

% Choose default command line output for RegisterVolumes
handles.output = hObject;

handles.sliceMoving = 1;
handles.sliceReference = 1;

handles.movingFileType = 'txm';
handles.referenceFileType = 'txm';

optimizer.MaximumIterations = 300;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegisterVolumes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RegisterVolumes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonFlipAxis.
function pushbuttonFlipAxis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFlipAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuAxis.
function popupmenuAxis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuAxis


% --- Executes during object creation, after setting all properties.
function popupmenuAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonRotateAxis.
function pushbuttonRotateAxis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRotateAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editDegrees_Callback(hObject, eventdata, handles)
% hObject    handle to editDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDegrees as text
%        str2double(get(hObject,'String')) returns contents of editDegrees as a double


% --- Executes during object creation, after setting all properties.
function editDegrees_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderReference_Callback(hObject, eventdata, handles)
% hObject    handle to sliderReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.sliceReference = round(get(handles.sliderReference,'Value'));

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);
updateBothImages(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function sliderReference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderMoving_Callback(hObject, eventdata, handles)
% hObject    handle to sliderMoving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.sliceMoving = round(get(handles.sliderMoving,'Value'));

guidata(hObject, handles);
updateBothImages(hObject, eventdata, handles);
updateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function sliderMoving_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderMoving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonRegisterVolumes.
function pushbuttonRegisterVolumes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRegisterVolumes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[optimizer, metric] = imregconfig('monomodal');
metric = registration.metric.MattesMutualInformation;
optimizer.MaximumIterations = round(str2num(cell2mat(get(handles.editIterations,'String'))));
% optimizer.MinimumStepLength = 1.00e-8;
% optimizer.MaximumStepLength = 0.5;


handles.imgRegistered = imregister(handles.imgMoving,handles.imgReference,'rigid',optimizer,metric,...
    'DisplayOptimization',1,'PyramidLevels',4);

[a b c] = size(handles.imgRegistered);
clear fused;
for i = 1:c
    fused(:,:,i) = imfuse(handles.imgReference(:,:,i),handles.imgRegistered(:,:,i),'blend');
end

handles.fused = fused;

[a b c] = size(handles.fused);
set(handles.sliderFused,'Value',1);
set(handles.sliderFused,'min',1);
set(handles.sliderFused,'max',c);
set(handles.sliderFused,'SliderStep',[1,1]/(c-1));

imshow(handles.fused(:,:,1),'Parent',handles.axesFused);

guidata(hObject, handles);




function editIterations_Callback(hObject, eventdata, handles)
% hObject    handle to editIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIterations as text
%        str2double(get(hObject,'String')) returns contents of editIterations as a double


% --- Executes during object creation, after setting all properties.
function editIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadMovingVolume.
function pushbuttonLoadMovingVolume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadMovingVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(handles.movingFileType,'dcm')
    handles.pathstrMoving = uigetdir(pwd,'Please select the folder of the volume to be registered');
    [handles.imgMoving handles.infoMoving] = readDICOMStack(handles.pathstrMoving);
    
elseif strcmpi(handles.movingFileType,'txm')
    [handles.movingFileName handles.movingPathName] = uigetfile([pwd '\*.txm'],'Please select your TXM file');
    [handles.header handles.headerShort] = txmheader_read8(fullfile(handles.movingPathName,handles.movingFileName));
    
    handles.infoMoving = handles.headerShort;
    handles.infoMoving.SliceThickness = handles.infoMoving.PixelSize;
    handles.infoMoving.SliceThickness = handles.infoMoving.SliceThickness / 1000;
    handles.infoMoving.Height = handles.infoMoving.ImageHeight;%may need to be switched with below
    handles.infoMoving.Width = handles.infoMoving.ImageWidth;
    handles.infoMoving.BitDepth = 16;
    handles.infoMoving.Format = 'DICOM';
    handles.infoMoving.FileName = handles.infoMoving.File;
    handles.infoMoving.FileSize = handles.infoMoving.Height * handles.infoMoving.Width * 2^16;
    handles.infoMoving.FormatVersion = 3;
    handles.infoMoving.ColorType = 'grayscale';
    handles.infoMoving.Modality = 'CT';
    handles.infoMoving.Manufacturer = 'Zeiss';
    handles.infoMoving.InstitutionName = 'Washington University in St. Louis';
    handles.infoMoving.PatientName = handles.movingFileName(1:end-4);
    handles.infoMoving.KVP = txmdata_read8(handles.header,'Voltage');
    handles.infoMoving.DeviceSerialNumber = '8802030299';
    handles.infoMoving.BitsAllocated = 16;
    handles.infoMoving.BitsStored = 15;
    handles.infoMoving.SliceLocation = 20;
    handles.infoMoving.ImagePositionPatient = [0;0;handles.infoMoving.SliceLocation];
    handles.infoMoving.PixelSpacing = [handles.infoMoving.SliceThickness;handles.infoMoving.SliceThickness];

    handles.img = zeros([handles.headerShort.ImageWidth handles.headerShort.ImageHeight handles.headerShort.NoOfImages],'uint16');

    ct=0;
    for i = 1:handles.headerShort.NoOfImages
        ct=ct+1;
        handles.imgMoving(:,:,i) = txmimage_read8(handles.header,ct,0,0);
    end

end

handles.imgMoving = padarray(handles.imgMoving,[50 50 50]);

handles.abc = size(handles.imgMoving);
set(handles.sliderMoving,'Value',1);
set(handles.sliderMoving,'min',1);
set(handles.sliderMoving,'max',handles.abc(3));
set(handles.sliderMoving,'SliderStep',[1,1]/(handles.abc(3)-1));


    
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonLoadReferenceVolume.
function pushbuttonLoadReferenceVolume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadReferenceVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(handles.referenceFileType,'dcm')
    handles.pathstrReference = uigetdir(pwd,'Please select the folder of the volume to be registered');
    [handles.imgReference handles.infoReference] = readDICOMStack(handles.pathstrReference);
elseif strcmpi(handles.referenceFileType,'txm')
    [handles.referenceFileName handles.referencePathName] = uigetfile([pwd '\*.txm'],'Please select your TXM file');
    [handles.header handles.headerShort] = txmheader_read8(fullfile(handles.referencePathName,handles.referenceFileName));
    
    handles.infoReference = handles.headerShort;
    handles.infoReference.SliceThickness = handles.infoReference.PixelSize;
    handles.infoReference.SliceThickness = handles.infoReference.SliceThickness / 1000;
    handles.infoReference.Height = handles.infoReference.ImageHeight;%may need to be switched with below
    handles.infoReference.Width = handles.infoReference.ImageWidth;
    handles.infoReference.BitDepth = 16;
    handles.infoReference.Format = 'DICOM';
    handles.infoReference.FileName = handles.infoReference.File;
    handles.infoReference.FileSize = handles.infoReference.Height * handles.infoReference.Width * 2^16;
    handles.infoReference.FormatVersion = 3;
    handles.infoReference.ColorType = 'grayscale';
    handles.infoReference.Modality = 'CT';
    handles.infoReference.Manufacturer = 'Zeiss';
    handles.infoReference.InstitutionName = 'Washington University in St. Louis';
    handles.infoReference.PatientName = handles.referenceFileName(1:end-4);
    handles.infoReference.KVP = txmdata_read8(handles.header,'Voltage');
    handles.infoReference.DeviceSerialNumber = '8802030299';
    handles.infoReference.BitsAllocated = 16;
    handles.infoReference.BitsStored = 15;
    handles.infoReference.SliceLocation = 20;
    handles.infoReference.ImagePositionPatient = [0;0;handles.infoReference.SliceLocation];
    handles.infoReference.PixelSpacing = [handles.infoReference.SliceThickness;handles.infoReference.SliceThickness];

    handles.img = zeros([handles.headerShort.ImageWidth handles.headerShort.ImageHeight handles.headerShort.NoOfImages],'uint16');

    ct=0;
    for i = 1:handles.headerShort.NoOfImages
        ct=ct+1;
        handles.imgReference(:,:,i) = txmimage_read8(handles.header,ct,0,0);
    end

end

handles.imgReference = padarray(handles.imgReference,[50 50 50]);

handles.abc = size(handles.imgReference);
set(handles.sliderReference,'Value',1);
set(handles.sliderReference,'min',1);
set(handles.sliderReference,'max',handles.abc(3));
set(handles.sliderReference,'SliderStep',[1,1]/(handles.abc(3)-1));
    
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes on selection change in popupmenuFileTypeReference.
function popupmenuFileTypeReference_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFileTypeReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFileTypeReference contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFileTypeReference
str = get(handles.popupmenuFileTypeReference,'String');
val = get(handles.popupmenuFileTypeReference,'Value');
switch str{val}
    case 'TXM'
        handles.referenceFileType = 'txm';
    case 'DICOM'
        handles.referenceFileType = 'dcm';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuFileTypeReference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFileTypeReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuFileTypeMoving.
function popupmenuFileTypeMoving_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFileTypeMoving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFileTypeMoving contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFileTypeMoving
str = get(handles.popupmenuFileTypeMoving,'String');
val = get(handles.popupmenuFileTypeMoving,'Value');
switch str{val}
    case 'TXM'
        handles.movingFileType = 'txm';
    case 'DICOM'
        handles.movingFileType = 'dcm';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuFileTypeMoving_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFileTypeMoving (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







function updateImage(hObject,eventdata,handles)

if isfield(handles,'imgMoving') && isfield(handles,'imgReference')
    imshow(imadjust(handles.imgMoving(:,:,handles.sliceMoving)),'Parent',handles.axesMovingXY);
    imshow(imadjust(handles.imgReference(:,:,handles.sliceReference)),'Parent',handles.axesReferenceXY);
elseif isfield(handles,'imgMoving') && ~isfield(handles,'imgReference')
    imshow(imadjust(handles.imgMoving(:,:,handles.sliceMoving)),'Parent',handles.axesMovingXY);
elseif ~isfield(handles,'imgMoving') && isfield(handles,'imgReference')
    imshow(imadjust(handles.imgReference(:,:,handles.sliceReference)),'Parent',handles.axesReferenceXY);
end

guidata(hObject, handles);


% --- Executes on button press in pushbuttonCenterMovingToReference.
function pushbuttonCenterMovingToReference_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCenterMovingToReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[a b c] = size(handles.imgReference);

[a1 b1 c1] = size(handles.imgMoving);

if a > a1
    aDiff = a - a1;
    bDiff = b - b1;
    cDiff = c - c1;
    
    handles.imgMoving = padarray(handles.imgMoving,[round(aDiff/2) round(bDiff/2) round(cDiff/2)]);
end

guidata(hObject, handles);

updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonMove.
function pushbuttonMove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenuUDLR.
function popupmenuUDLR_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuUDLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuUDLR contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuUDLR


% --- Executes during object creation, after setting all properties.
function popupmenuUDLR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuUDLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMoveVoxels_Callback(hObject, eventdata, handles)
% hObject    handle to editMoveVoxels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMoveVoxels as text
%        str2double(get(hObject,'String')) returns contents of editMoveVoxels as a double


% --- Executes during object creation, after setting all properties.
function editMoveVoxels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMoveVoxels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateBothImages(hObject, eventdata, handles)

if isfield(handles,'imgMoving') && isfield(handles,'imgReference')
    imshowpair(handles.imgMoving(:,:,handles.sliceMoving),handles.imgReference(:,:,handles.sliceMoving),'Parent',handles.axesMovingOverlapSlice);
    imshowpair(handles.imgReference(:,:,handles.sliceReference),handles.imgMoving(:,:,handles.sliceReference),'Parent',handles.axesReferenceOverlapSlice);
end

guidata(hObject, handles);


% --- Executes on slider movement.
function sliderFused_Callback(hObject, eventdata, handles)
% hObject    handle to sliderFused (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.fusedSlice = round(get(handles.sliderFused,'Value'));
imshow(handles.fused(:,:,handles.fusedSlice),'Parent',handles.axesFused);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderFused_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderFused (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
