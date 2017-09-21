function varargout = contouringGUI(varargin)
% CONTOURINGGUI MATLAB code for contouringGUI.fig
%      CONTOURINGGUI, by itself, creates a new CONTOURINGGUI or raises the existing
%      singleton*.
%
%      H = CONTOURINGGUI returns the handle to a new CONTOURINGGUI or the handle to
%      the existing singleton*.
%
%      CONTOURINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTOURINGGUI.M with the given input arguments.
%
%      CONTOURINGGUI('Property','Value',...) creates a new CONTOURINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before contouringGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to contouringGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help contouringGUI

% Last Modified by GUIDE v2.5 29-Aug-2017 14:23:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @contouringGUI_OpeningFcn, ...
    'gui_OutputFcn',  @contouringGUI_OutputFcn, ...
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


% --- Executes just before contouringGUI is made visible.
function contouringGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to contouringGUI (see VARARGIN)

% Choose default command line output for contouringGUI
handles.output = hObject;

% parpool;

%set image volume name
% handles.volumeName = 'img';

%set potential filter parameters
handles.sigma = 0.8;
handles.radius = 2;

%initialize contouring values
handles.contourMethod = 'Chan-Vese';
handles.smoothFactor = 1;
handles.contractionBias = 0.05;
handles.iterations = 100;

%pause flag
handles.startStop = 0;

set(handles.textBusy,'String','Not Busy');

%initialize mask clearing slices
% handles.startClear = 1;
% handles.endClear = 999;

%initialize morph start and stop
handles.startMorph = 1;
handles.endMorph = 999;

%set a random threshold to initialize
handles.threshold = 6000;

handles.lowerThreshold = 6000;

handles.imgScale = 1;

handles.speckleSize = 20;

handles.peel = 4;

handles.sphereSize = 6;

handles.stlWriteMethod = 'binary';

handles.slice = 1;

handles.DICOMPrefix = 'Prefix';

handles.STLColor = [255 0 0];

handles.rotateDegrees = 90;
handles.rotateAxis = 1;

handles.primitive = 'rectangle';
handles.primitiveHeight = 10;
handles.primitiveWidth = 10;
handles.primitiveRotationAngle = 0;

handles.analysis = 'VolumeRender';

handles.morphologicalOperation = 'Close';
handles.morphologicalImageMask = 'Mask';
handles.morphologicalRadius = 3;
handles.morphological2D3D = '3D';

handles.colormap = 'gray';

%initialize empty slice matrix
handles.empty = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes contouringGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Executes on button press in pushbuttonLoadTifStack.
function pushbuttonLoadTifStack_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadTifStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = loadTifStack(handles,hObject);
updateImage(hObject, eventdata, handles);

% --- Outputs from this function are returned to the command line.
function varargout = contouringGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderIMG_Callback(hObject, eventdata, handles)
% hObject    handle to sliderIMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.slice = round(get(handles.sliderIMG,'Value'));
set(handles.editSliceNumber,'String',num2str(handles.slice));
updateImage(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderIMG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderIMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonLoadIMG.
function pushbuttonLoadIMG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadIMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    if isfield(handles,'img') == 1
        clear handles.img;
    end
    if isfield(handles,'bwContour') == 1
        clear handles.bwContour;handles=rmfield(handles,'bwContour');
    end
    
    handles.pathstr = uigetdir(pwd,'Please select the folder containing your DICOM files');
    
    handles.files = dir(fullfile(handles.pathstr, '*.dcm*'));
%     mrFlag = 0;
    if isempty(handles.files)
        handles.files = dir(fullfile(handles.pathstr, 'IM*'));
%         mrFlag = 1;
    end
    handles.info = dicominfo(fullfile(handles.pathstr,handles.files(1).name));
    
    if ~isfield(handles.info,'Manufacturer')
        handles.info.Manufacturer = 'ZEISS';
    end
    
    if ~isfield(handles.info,'Private_0029_1004') && ~isempty(strfind(handles.info.Manufacturer,'SCANCO'))
        handles.info.Private_0029_1004 = str2num(handles.info.ReferringPhysicianName.FamilyName);
        handles.info.Private_0029_1005 = str2num(handles.info.ReferringPhysicianName.GivenName);
        handles.info.Private_0029_1000 = str2num(handles.info.ReferringPhysicianName.MiddleName);
        handles.info.Private_0029_1006 = str2num(handles.info.ReferringPhysicianName.NamePrefix);
    end
    
    if ~isfield(handles.info,'SliceThickness')
        handles.info.SliceThickness = handles.info.PixelSpacing(1);
    end
    
    handles.img = zeros(handles.info.Height,handles.info.Width,length(handles.files),'uint16');
    
    for i = 1:length(handles.files)
        set(handles.textPercentLoaded,'String',num2str(i/length(handles.files)));
        drawnow();
%         if mrFlag == 1
            infotmp(i) = dicominfo(fullfile(handles.pathstr,handles.files(i).name));
            locTmp1(i) = infotmp(i).ImagePositionPatient(1);
            locTmp2(i) = infotmp(i).ImagePositionPatient(2);
            locTmp3(i) = infotmp(i).ImagePositionPatient(3);
%         end
        handles.img(:,:,i) = dicomread(fullfile(handles.pathstr,handles.files(i).name));
    end
    dif1 = diff(locTmp1);
    dif2 = diff(locTmp2);
    dif3 = diff(locTmp3);
    test1 = length(find(dif1));
    test2 = length(find(dif2));
    test3 = length(find(dif3));
%     if mrFlag == 1
    if test1 > test2 && test1 > test3
        [order I] = sort(locTmp1);
        handles.img = handles.img(:,:,I);
    elseif test2 > test1 && test2 > test3
        [order I] = sort(locTmp2);
        handles.img = handles.img(:,:,I);
    elseif test3 > test1 && test3 > test2
        [order I] = sort(locTmp3);
        handles.img = handles.img(:,:,I);
    end
    
    if isfield(handles.info,'LargestImagePixelValue') == 1
        if handles.info.LargestImagePixelValue == 255
            handles.img = uint16((double(handles.img) ./ 255) .* 2^16);
            handles.info.LargestImagePixelValue = 2^16;
            handles.info.BitDepth = 15;
        end
    end
    
    cameratoolbar('Show');
    handles.dataMax = max(max(max(handles.img)));
    
    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    
    
    handles.abc = size(handles.img);
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    
    set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
    
    handles.primitiveCenter(1) = round(handles.abc(2)/2);
    handles.primitiveCenter(2) = round(handles.abc(1)/2);
    % handles.bwContour = false(size(handles.img));
    % handles.bwContourOrig = handles.bwContour;
    
    set(handles.textCurrentDirectory,'String',handles.pathstr);
    
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    handles.hOut = 1;%handles.theMax / 2^15;
    handles.lOut = 0;
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
    updateImage(hObject,eventdata,handles);
    
    set(gcf,'menubar','figure');
    set(gcf,'toolbar','figure');
    set(handles.textBusy,'String','Not Busy');
    
    guidata(hObject, handles);
catch
    set(handles.textBusy,'String','Failed');
end


% --- Executes on button press in pushbuttonDrawContour.
function pushbuttonDrawContour_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDrawContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'bwContour') == 0
    handles.bwContour = false(size(handles.img));
end
h = imfreehand(handles.axesIMG);
handles.bwContour(:,:,handles.slice) = createMask(h);
guidata(hObject, handles);
updateImage(hObject,eventdata,handles);


% --- Executes on button press in pushbuttonSubtractContour.
function pushbuttonSubtractContour_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSubtractContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = imfreehand(handles.axesIMG);
tmp = h.createMask;
tmp2 = handles.bwContour(:,:,handles.slice);
tmp2(tmp) = 0;
handles.bwContour(:,:,handles.slice) = tmp2;
guidata(hObject, handles);
updateImage(hObject,eventdata,handles);


% --- Executes on button press in pushbuttonAddContour.
function pushbuttonAddContour_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = imfreehand(handles.axesIMG);
tmp = h.createMask;
tmp2 = handles.bwContour(:,:,handles.slice);
tmp2(tmp) = 1;
handles.bwContour(:,:,handles.slice) = tmp2;
guidata(hObject, handles);
updateImage(hObject,eventdata,handles);


% --- Executes on button press in pushbuttonMorphRange.
function pushbuttonMorphRange_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMorphRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    bwTemp = interp_shape(handles.bwContour(:,:,handles.startMorph),handles.bwContour(:,:,handles.endMorph),abs(handles.startMorph - handles.endMorph)+1);
    bwTemp = flip(bwTemp,3);
    handles.bwContour(:,:,handles.startMorph:handles.endMorph) = bwTemp;
    guidata(hObject, handles);
    updateImage(hObject,eventdata,handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end


% --- Executes on button press in pushbuttonAdjustCurrentSlice.
function pushbuttonAdjustCurrentSlice_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdjustCurrentSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    img = handles.img(:,:,handles.slice);
    bw = handles.bwContour(:,:,handles.slice);
    bw = activecontour(img,bw,...
        handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
    handles.bwContour(:,:,handles.slice) = bw;
    guidata(hObject, handles);
    updateImage(hObject,eventdata,handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end

% --- Executes on selection change in popupmenuContourMethod.
function popupmenuContourMethod_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuContourMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuContourMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuContourMethod
str = get(handles.popupmenuContourMethod,'String');
val = get(handles.popupmenuContourMethod,'Value');
switch str{val}
    case 'Chan-Vese'
        handles.contourMethod = 'Chan-Vese';
    case 'Edge'
        handles.contourMethod = 'Edge';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuContourMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuContourMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSmoothFactor_Callback(hObject, eventdata, handles)
% hObject    handle to editSmoothFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSmoothFactor as text
%        str2double(get(hObject,'String')) returns contents of editSmoothFactor as a double
handles.smoothFactor = str2num(get(handles.editSmoothFactor,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSmoothFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmoothFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editContractionBias_Callback(hObject, eventdata, handles)
% hObject    handle to editContractionBias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editContractionBias as text
%        str2double(get(hObject,'String')) returns contents of editContractionBias as a double
handles.contractionBias = str2num(get(handles.editContractionBias,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editContractionBias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editContractionBias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editIterations_Callback(hObject, eventdata, handles)
% hObject    handle to editIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIterations as text
%        str2double(get(hObject,'String')) returns contents of editIterations as a double
handles.iterations = str2num(get(handles.editIterations,'String'));
guidata(hObject, handles);

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


% --- Executes on button press in pushbuttonExecuteAnalysis.
function pushbuttonExecuteAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExecuteAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(handles.analysis,'Cortical') == 1
    timerFcn = {@corticalAnalysis,handles,hObject};
    start(timer('StartDelay',0.2,'TimerFcn',timerFcn));
%     corticalAnalysis(handles,hObject);
    
elseif strcmpi(handles.analysis,'Cancellous') == 1
    handles = cancellousAnalysis(handles,hObject);
    
elseif strcmpi(handles.analysis,'FractureCallusVascularity') == 1
    handles = fractureCallusVascularity(handles,hObject);
    
elseif strcmpi(handles.analysis,'Arterial') == 1
    handles = arterialOlga(handles,hObject);
    
elseif strcmpi(handles.analysis,'MarrowFat') == 1
    handles = marrowFat(handles,hObject);
    
elseif strcmpi(handles.analysis,'TangIVDPMA') == 1
    handles = tangIVDPMA(handles,hObject);
    
elseif strcmpi(handles.analysis,'MakeDatasetIsotropic') == 1
    handles = makeDatasetIsotropic(handles,hObject);
    
elseif strcmpi(handles.analysis,'GenerateHistogram') == 1
    generateHistogram(handles,hObject);
    
elseif strcmpi(handles.analysis,'SaveCurrentImage') == 1
    saveCurrentImage(handles,hObject);
    
elseif strcmpi(handles.analysis,'WriteToTiff') == 1
    writeToTiff(handles,hObject);
    
elseif strcmpi(handles.analysis,'TendonFootprint') == 1
    handles = tendonFootprint(handles,hObject);
    
elseif strcmpi(handles.analysis,'MakeGif') == 1
    handles = makeGIF(handles,hObject);
    
elseif strcmpi(handles.analysis,'LinearMeasure') == 1
    handles = linearMeasure(handles,hObject);
        
elseif strcmpi(handles.analysis,'ObjectAndVoids') == 1
    handles = objectAndVoids(handles,hObject);
    
elseif strcmpi(handles.analysis,'VolumeRender') == 1
    handles = volumeRender(handles,hObject);
    
elseif strcmpi(handles.analysis,'TangIVDPMANotochord') == 1
    handles = tangIVDPMANotocord(handles,hObject);
    
elseif strcmpi(handles.analysis,'NeedlePuncture') == 1
    handles = needlePuncture(handles,hObject);
    
elseif strcmpi(handles.analysis,'DisplacementMap') == 1
    handles = displacementMap(handles,hObject);
    
elseif strcmpi(handles.analysis,'ShapeAnalysis') == 1
    handles = shapeAnalysis(handles,hObject);
    
elseif strcmpi(handles.analysis,'MaskVolume') == 1
    handles = maskVolume(handles,hObject);
    
elseif strcmpi(handles.analysis,'RegisterVolumes') == 1
    handles = registerVolumes(handles,hObject);
    
elseif strcmpi(handles.analysis,'2D-Analysis') == 1
    handles = twoDAnalysis(handles,hObject);
    
elseif strcmpi(handles.analysis,'FractureCallus3PtBendBreak') == 1
    handles = fractureCallus3PtBendBreak(handles,hObject);
    
elseif strcmpi(handles.analysis,'GuilakKneeSurface') == 1
    handles = guilakKneeSurface(handles,hObject);
    
elseif strcmpi(handles.analysis,'SkeletonizationAnalysis') == 1
    handles = skeletonizationAnalysis(handles,hObject);
elseif strcmpi(handles.analysis,'DistanceMap') == 1
    handles = distanceMap(handles,hObject);
elseif strcmpi(handles.analysis,'WriteToDICOM') == 1
    writeCurrentImageStackToDICOM(handles,hObject);

end


function editSigma_Callback(hObject, eventdata, handles)
% hObject    handle to editSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigma as text
%        str2double(get(hObject,'String')) returns contents of editSigma as a double
handles.sigma = str2num(get(handles.editSigma,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRadius_Callback(hObject, eventdata, handles)
% hObject    handle to editRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRadius as text
%        str2double(get(hObject,'String')) returns contents of editRadius as a double
handles.radius = str2num(get(handles.editRadius,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to sliderThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.threshold = get(handles.sliderThreshold,'Value');
lowThreshTmp = handles.threshold;
highThreshTmp = handles.upperThreshold;
set(handles.text9,'String',num2str(handles.threshold));
set(handles.editThreshold,'String',num2str(handles.threshold));
% handles.bwContour(:,:,handles.slice) = handles.img(:,:,handles.slice) > handles.lowerThreshold;
tmp = false(size(handles.img(:,:,handles.slice)));
tmp(find(handles.img(:,:,handles.slice) > lowThreshTmp)) = 1;
tmp(find(handles.img(:,:,handles.slice) > highThreshTmp)) = 0;
imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),tmp,'blend','Parent',handles.axesIMG);
impixelinfo(handles.axesIMG);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in togglebuttonIterateBackwards.
function togglebuttonIterateBackwards_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonIterateBackwards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonIterateBackwards
if length(find(handles.bwContour(:,:,handles.slice))) ~= 0
    handles.startStop = get(handles.togglebuttonIterateBackwards,'Value');
    while handles.startStop == 1 && handles.slice > 1
        drawnow();
        handles.startStop = get(handles.togglebuttonIterateBackwards,'Value');
        if handles.startStop == 0
            break
        end
        guidata(hObject, handles);
        drawnow();
        img = handles.img(:,:,handles.slice-1);
        bw = handles.bwContour(:,:,handles.slice);
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        handles.bwContour(:,:,handles.slice-1) = bw;
        imshowpair(imadjust(handles.img(:,:,handles.slice-1),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice-1),'blend','Parent',handles.axesIMG);
        colormap(handles.axesIMG,handles.colormap);
        impixelinfo(handles.axesIMG);
        handles.slice = handles.slice - 1;
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        guidata(hObject, handles);
    end
    if handles.slice == 1
        img = handles.img(:,:,1);
        bw = handles.bwContour(:,:,2);
        bw = activecontour(img,bw,...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        handles.bwContour(:,:,1) = bw;
        imshowpair(imadjust(handles.img(:,:,1),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,1),'blend','Parent',handles.axesIMG);
        colormap(handles.axesIMG,handles.colormap);
        impixelinfo(handles.axesIMG);
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        
        guidata(hObject, handles);
    end
end


% --- Executes on button press in togglebuttonIterateForwards.
function togglebuttonIterateForwards_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonIterateForwards (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonIterateForwards
if length(find(handles.bwContour(:,:,handles.slice))) ~= 0
    handles.startStop = get(handles.togglebuttonIterateForwards,'Value');
    while handles.startStop == 1 && handles.slice < handles.abc(3)
        drawnow();
        handles.startStop = get(handles.togglebuttonIterateForwards,'Value');
        if handles.startStop == 0
            break
        end
        guidata(hObject,handles);
        drawnow();
        handles.bwContour(:,:,handles.slice+1) = activecontour(handles.img(:,:,handles.slice+1),handles.bwContour(:,:,handles.slice),...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        handles.slice = handles.slice+1;
        guidata(hObject,handles);
        updateImage(hObject, eventdata, handles);
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        %         guidata(hObject,handles);
    end
    if handles.slice == handles.abc(3)
        handles.bwContour(:,:,end) = activecontour(handles.img(:,:,handles.slice),handles.bwContour(:,:,handles.slice-1),...
            handles.iterations,handles.contourMethod,'SmoothFactor',handles.smoothFactor,'ContractionBias',handles.contractionBias);
        guidata(hObject,handles);
        updateImage(hObject, eventdata, handles);
        set(handles.sliderIMG,'Value',handles.slice);
        set(handles.editSliceNumber,'String',num2str(handles.slice));
        drawnow();
        %         guidata(hObject, handles);
    end
end


% --- Executes on button press in pushbuttonClearMaskRange.
function pushbuttonClearMaskRange_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearMaskRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bwContour(:,:,handles.startMorph:handles.endMorph) = false(size(handles.bwContour(:,:,handles.startMorph:handles.endMorph)));
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonClearAllMasks.
function pushbuttonClearAllMasks_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAllMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.bwContour = [];
if isfield(handles,'bwContour') == 1
    handles = rmfield(handles,'bwContour');
end
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

function editStartClear_Callback(hObject, eventdata, handles)
% hObject    handle to editStartClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartClear as text
%        str2double(get(hObject,'String')) returns contents of editStartClear as a double
handles.startClear = str2num(get(handles.editStartMorph,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editStartClear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEndClear_Callback(hObject, eventdata, handles)
% hObject    handle to editEndClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEndClear as text
%        str2double(get(hObject,'String')) returns contents of editEndClear as a double
handles.endClear = str2num(get(handles.editEndMorph,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editEndClear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editStartMorph_Callback(hObject, eventdata, handles)
% hObject    handle to editStartMorph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartMorph as text
%        str2double(get(hObject,'String')) returns contents of editStartMorph as a double
handles.startMorph = str2num(get(handles.editStartMorph,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editStartMorph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartMorph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editEndMorph_Callback(hObject, eventdata, handles)
% hObject    handle to editEndMorph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEndMorph as text
%        str2double(get(hObject,'String')) returns contents of editEndMorph as a double
handles.endMorph = str2num(get(handles.editEndMorph,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editEndMorph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndMorph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonUpdateEmptyRegions.
function pushbuttonUpdateEmptyRegions_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUpdateEmptyRegions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    clear handles.empty handles.emptyRanges;
    handles.emptyRanges = cell(0);
    guidata(hObject, handles);
    
    [a b c] = size(handles.img);
    empties = zeros([1,c]);
    for i = 1:c
        if length(find(handles.bwContour(:,:,i))) == 0
            empties(i) = 1;
        end
    end
    
    diffs = diff(empties);
    starts = find(diffs == -1);
    starts = starts + 1;
    stops = find(diffs == 1);
    
    if empties(1) ~= 1
        starts = [1,starts];
    end
    
    if empties(c) ~= 1
        stops = [stops,c];
    end
    
    
    for i = 1:length(starts)
        el{i} = [num2str(starts(i)) ' , ' num2str(stops(i))];
    end
    
    set(handles.text13,'String',el);
    
    handles.maskedRanges = el;
    
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
catch
    set(handles.textBusy,'String','Failed');
end


function editThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editThreshold as text
%        str2double(get(hObject,'String')) returns contents of editThreshold as a double
handles.threshold = str2num(get(handles.editThreshold,'String'));
set(handles.sliderThreshold,'Value',handles.threshold);
tmp = handles.img(:,:,handles.slice) > handles.threshold;
imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),tmp,'blend','Parent',handles.axesIMG);
impixelinfo(handles.axesIMG);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonCreate3DObject.
function pushbuttonCreate3DObject_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCreate3DObject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.textBusy,'String','Busy');
drawnow();
handles.shp = shpFromBW(handles.bwContour,handles.sphereSize);
figure();
plot(handles.shp,'FaceColor',handles.STLColor ./ 255,'LineStyle','none');
camlight();

guidata(hObject, handles);
set(handles.textBusy,'String','Not Busy');
guidata(hObject, handles);
drawnow();

% --- Executes on button press in pushbuttonWriteSTL.
function pushbuttonWriteSTL_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonWriteSTL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    if strcmpi(handles.stlWriteMethod,'ascii') == 1
        fName = ['scaled-' num2str(handles.imgScale) '-' handles.DICOMPrefix '-stl-ascii.stl'];
        stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'mode','ascii');
    else
        fName = ['scaled-' num2str(handles.imgScale) '-' handles.DICOMPrefix '-stl.stl'];
        stlwrite(fullfile(handles.pathstr,fName),handles.shp.boundaryFacets,handles.shp.Points,'FaceColor',handles.STLColor);
    end
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in pushbuttonSetMaskThreshold.
function pushbuttonSetMaskThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMaskThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bwContour = handles.img > handles.lowerThreshold;
handles.bwContour(handles.img > handles.upperThreshold) = 0;
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonRemoveSpeckleNoiseFromMask.
function pushbuttonRemoveSpeckleNoiseFromMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemoveSpeckleNoiseFromMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.bwContour = bwareaopen(handles.bwContour,handles.speckleSize);
    handles.bwContour(:,:,handles.slice) = handles.bwContour(:,:,handles.slice);
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    impixelinfo(handles.axesIMG);
    
    guidata(hObject, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

function editSpeckleSize_Callback(hObject, eventdata, handles)
% hObject    handle to editSpeckleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpeckleSize as text
%        str2double(get(hObject,'String')) returns contents of editSpeckleSize as a double
handles.speckleSize = str2num(get(handles.editSpeckleSize,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSpeckleSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpeckleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSliceNumber_Callback(hObject, eventdata, handles)
% hObject    handle to editSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSliceNumber as text
%        str2double(get(hObject,'String')) returns contents of editSliceNumber as a double
handles.slice = str2num(get(handles.editSliceNumber,'String'));
set(handles.sliderIMG,'Value',handles.slice);
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonScaleImageSize.
function pushbuttonScaleImageSize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonScaleImageSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.img = imresize3(handles.img,handles.imgScale);
    [a b c] = size(handles.img);
    if isfield(handles,'bwContour')
        handles.bwContour = resize3DMatrixBW(handles.bwContour,handles.imgScale);
    end
    handles.abc = size(handles.img);
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness / handles.imgScale));
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

function editScaleImageSize_Callback(hObject, eventdata, handles)
% hObject    handle to editScaleImageSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editScaleImageSize as text
%        str2double(get(hObject,'String')) returns contents of editScaleImageSize as a double
handles.imgScale = str2num(get(handles.editScaleImageSize,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editScaleImageSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editScaleImageSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSphereSizeForAlphaShape_Callback(hObject, eventdata, handles)
% hObject    handle to editSphereSizeForAlphaShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSphereSizeForAlphaShape as text
%        str2double(get(hObject,'String')) returns contents of editSphereSizeForAlphaShape as a double
handles.sphereSize = str2num(get(handles.editSphereSizeForAlphaShape,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSphereSizeForAlphaShape_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSphereSizeForAlphaShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSTLAsciiBinary.
function popupmenuSTLAsciiBinary_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLAsciiBinary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSTLAsciiBinary contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSTLAsciiBinary
str = get(handles.popupmenuSTLAsciiBinary,'String');
val = get(handles.popupmenuSTLAsciiBinary,'Value');
switch str{val}
    case 'ascii'
        handles.stlWriteMethod = 'ascii';
    case 'binary'
        handles.stlWriteMethod = 'binary';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSTLAsciiBinary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLAsciiBinary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonIsolateObjectOfInterest.
function pushbuttonIsolateObjectOfInterest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonIsolateObjectOfInterest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img(~handles.bwContour) = 0;
% end
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonCropImageToMask.
function pushbuttonCropImageToMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCropImageToMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x y z] = ind2sub(size(handles.bwContour),find(handles.bwContour));
xMin = min(x);
xMax = max(x);
yMin = min(y);
yMax = max(y);
zMin = min(z);
zMax = max(z);

handles.img = handles.img(xMin:xMax,yMin:yMax,zMin:zMax);
handles.bwContour = handles.bwContour(xMin:xMax,yMin:yMax,zMin:zMax);

handles.slice = 1;
handles.abc = size(handles.img);
set(handles.sliderIMG,'Value',1);
set(handles.sliderIMG,'min',1);
set(handles.sliderIMG,'max',handles.abc(3));
set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);



function editDICOMPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to editDICOMPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDICOMPrefix as text
%        str2double(get(hObject,'String')) returns contents of editDICOMPrefix as a double
handles.DICOMPrefix = get(handles.editDICOMPrefix,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editDICOMPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDICOMPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetMaskToComponent.
function pushbuttonSetMaskToComponent_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMaskToComponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    
    str = get(handles.popupmenuMaskComponents,'String');
    val = get(handles.popupmenuMaskComponents,'Value');
    str = str{val};
    
    handles.bwContour = bwIndex(handles.bwContour, str2num(str));
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in togglebuttonInvertImage.
function togglebuttonInvertImage_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonInvertImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonInvertImage
handles.img = 2^15 - handles.img; %change to info bit thing
% end

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on selection change in popupmenuSTLColor.
function popupmenuSTLColor_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSTLColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSTLColor
str = get(handles.popupmenuSTLColor,'String');
val = get(handles.popupmenuSTLColor,'Value');
if strcmpi(str{val},'r') == 1
    handles.STLColor = [255 0 0];
elseif strcmpi(str{val},'g') == 1
    handles.STLColor = [0 255 0];
elseif strcmpi(str{val},'b') == 1
    handles.STLColor = [0 0 255];
elseif strcmpi(str{val},'y') == 1
    handles.STLColor = [255 255 0];
elseif strcmpi(str{val},'k') == 1
    handles.STLColor = [0 0 0];
elseif strcmpi(str{val},'c') == 1
    handles.STLColor = [0 255 255];
elseif strcmpi(str{val},'w') == 1
    handles.STLColor = [255 255 255];
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSTLColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSTLColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function textPercentLoaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textPercentLoaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbuttonRotateImage.
function pushbuttonRotateImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRotateImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [a b c] = size(handles.img);
    
    tmp = cell([1 c]);
    tmp2 = cell([1 c]);
    for i = 1:c
        tmp{i} = imrotate(handles.img(:,:,i),handles.rotateDegrees,'crop');
        if isfield(handles,'bwContour') == 1
            tmp2{i} = imrotate(handles.bwContour(:,:,i),handles.rotateDegrees,'crop');
        end
    end
    clear handles.img;
    for i = 1:c
        handles.img(:,:,i) = tmp{i};
    end
    
    if isfield(handles,'bwContour') == 1
        clear handles.bwContour;
        for i = 1:c
            handles.bwContour(:,:,i) = tmp2{i};
        end
    end
    %set to update graphics stuff
    handles.abc = size(handles.img);
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.slice = 1;
    
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

function editRotationDegrees_Callback(hObject, eventdata, handles)
% hObject    handle to editRotationDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRotationDegrees as text
%        str2double(get(hObject,'String')) returns contents of editRotationDegrees as a double
handles.rotateDegrees = str2num(get(handles.editRotationDegrees,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editRotationDegrees_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRotationDegrees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonFlipImage.
function pushbuttonFlipImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFlipImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.img = flip(handles.img,handles.rotateAxis);
if isfield(handles,'bwContour') == 1
    handles.bwContour = flip(handles.bwContour,handles.rotateAxis);
end

handles.abc = size(handles.img);
% handles.bwContour = false(size(handles.img));

set(handles.sliderIMG,'Value',1);
set(handles.sliderIMG,'min',1);
set(handles.sliderIMG,'max',handles.abc(3));
set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));

handles.slice = 1;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on selection change in popupmenuRotationAxis.
function popupmenuRotationAxis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRotationAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuRotationAxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRotationAxis
str = get(handles.popupmenuRotationAxis,'String');
val = get(handles.popupmenuRotationAxis,'Value');
switch str{val}
    case '1'
        handles.rotateAxis = 2;
    case '2'
        handles.rotateAxis = 1;
    case '3'
        handles.rotateAxis = 3;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuRotationAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRotationAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonMorphAll.
function pushbuttonMorphAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMorphAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    clear handles.maskedRanges;
    guidata(hObject, handles);
    
    [a b c] = size(handles.img);
    empties = zeros([1,c]);
    for i = 1:c
        if length(find(handles.bwContour(:,:,i))) == 0
            empties(i) = 1;
        end
    end
    
    diffs = diff(empties);
    starts = find(diffs == -1);
    starts = starts + 1;
    stops = find(diffs == 1);
    
    if empties(1) ~= 1
        starts = [1,starts];
    end
    
    if empties(c) ~= 1
        stops = [stops,c];
    end
    
    for i = 1:length(starts)
        ranges(i,:) = [starts(i),stops(i)];
    end
    
    for i = 1:length(ranges)-1
        start = ranges(i,2);
        stop = ranges(i+1,1);
        
        bwTemp = interp_shape(handles.bwContour(:,:,start),handles.bwContour(:,:,stop),abs(start-stop + 1));
        bwTemp = flip(bwTemp,3);
        handles.bwContour(:,:,start+1:stop-1) = bwTemp;
    end
    
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end


% --- Executes on button press in pushbuttonCreatePrimitive.
function pushbuttonCreatePrimitive_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCreatePrimitive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.popupmenuPrimitive,'String');
val = get(handles.popupmenuPrimitive,'Value');
switch str{val}
    case 'Oval'
        handles.primitive = 'oval';
    case 'Rectangle'
        handles.primitive = 'rectangle';
end

if strcmpi(handles.primitive,'oval') == 1
    
    a=handles.primitiveWidth; % horizontal radius
    b=handles.primitiveHeight; % vertical radius
    x0=handles.primitiveCenter(1); % x0,y0 ellipse centre coordinates
    y0=handles.primitiveCenter(2);
    t=-pi:0.01:pi;
    x=x0+a*cos(t);
    y=y0+b*sin(t);
    phi = handles.primitiveRotationAngle;
    %     x = (x-x0) * cos(phi) - (y-y0) * sin(phi) + x0;
    %     y = (x-x0) * sin(phi) + (y-y0) * cos(phi) + y0;
    %add rotation matirx
    hold on;
    plot(x,y,'Parent',handles.axesIMG)
    hold off;
    
    
    ct=0;%make query set representing whole slice
    for i = min(x):max(x)
        for j = floor(min(y)):floor(max(y))
            ct=ct+1;
            xq(ct) = i;
            yq(ct) = j;
        end
    end
    
    
    
    xc = x0;
    yc = y0;
    if isfield(handles,'bwContour') == 0
        handles.bwContour = false(size(handles.img));
        tmp = false(size(handles.bwContour(:,:,handles.slice)));
    else
        tmp = false(size(handles.bwContour(:,:,handles.slice)));
    end
    for i = 1:length(xq)
        progressbar(i/length(xq))
        if ((xq(i)-xc)*cos(0)-(yq(i)-yc)*sin(0)).^2/a^2 + ((xq(i)-xc)*sin(0)+(yq(i)-yc)*cos(0)).^2/b^2 <= 1
            tmp(round(yq(i)),round(xq(i))) = 1;
        end
    end
    handles.bwContour(:,:,handles.slice) = tmp;
    if handles.primitiveRotationAngle ~= 0
        handles.bwContour(:,:,handles.slice) = imrotate(handles.bwContour(:,:,handles.slice),rad2deg(handles.primitiveRotationAngle),'crop');
        handles.bwContour(:,:,handles.slice) = imclose(handles.bwContour(:,:,handles.slice),strel('disk',4,0));
    end
    
    guidata(hObject, handles);
    
    
    
elseif strcmpi(handles.primitive,'rectangle') == 1
    %     handles.primitiveCenter = [round(handles.abc(1)/2),round(handles.abc(2)/2)];
    if isfield(handles,'bwContour') == 0
        handles.bwContour = false(size(handles.img));
    end
    hold on;
    [P,R] = DrawRectangle([handles.primitiveCenter(1),handles.primitiveCenter(2),...
        handles.primitiveWidth,handles.primitiveHeight,str2num(get(handles.editRotatePrimitive,'String'))]);
    ct=0;%make query set representing whole slice
    for i = 1:handles.abc(1)
        for j = 1:handles.abc(2)
            ct=ct+1;
            xq(ct) = i;
            yq(ct) = j;
        end
    end
    
    %     [P,R] = DrawRectangle([handles.primitiveCenter(1),handles.primitiveCenter(2),...
    %         handles.primitiveWidth,handles.primitiveHeight,0]);
    [in] = inpoly([xq',yq'],[P(6:10)',P(1:5)']);
    tmp = reshape(in,[handles.abc(2) handles.abc(1)]);
    tmp = imrotate(tmp,90);
    tmp = flipud(tmp);
    %     in(on) = 1;
    %     tmp = false(size(handles.bwContour(:,:,handles.slice)));
    %     tmp(in) = 1;
    %     tmp = imrotate(tmp,rad2deg(str2num(get(handles.editRotatePrimitive,'String'))),'crop');
    handles.bwContour(:,:,handles.slice) = tmp;
    %     handles.bwContour(:,:,handles.slice) = imclose(handles.bwContour(:,:,handles.slice),true(9,9));
    
    hold off;
    
    guidata(hObject, handles);
end

[row col] = find(handles.bwContour(:,:,handles.slice));
cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes on selection change in popupmenuPrimitive.
function popupmenuPrimitive_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPrimitive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPrimitive contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPrimitive


% --- Executes during object creation, after setting all properties.
function popupmenuPrimitive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPrimitive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPrimitiveHeight_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPrimitiveHeight as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveHeight as a double
handles.primitiveHeight = str2num(get(handles.editPrimitiveHeight,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPrimitiveWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPrimitiveWidth as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveWidth as a double
handles.primitiveWidth = str2num(get(handles.editPrimitiveWidth,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRotatePrimitive_Callback(hObject, eventdata, handles)
% hObject    handle to editRotatePrimitive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRotatePrimitive as text
%        str2double(get(hObject,'String')) returns contents of editRotatePrimitive as a double
handles.primitiveRotationAngle = str2num(get(handles.editRotatePrimitive,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editRotatePrimitive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRotatePrimitive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTranslateUp_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTranslateUp as text
%        str2double(get(hObject,'String')) returns contents of editTranslateUp as a double


% --- Executes during object creation, after setting all properties.
function editTranslateUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTranslateDown_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTranslateDown as text
%        str2double(get(hObject,'String')) returns contents of editTranslateDown as a double


% --- Executes during object creation, after setting all properties.
function editTranslateDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTranslateLeft_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTranslateLeft as text
%        str2double(get(hObject,'String')) returns contents of editTranslateLeft as a double


% --- Executes during object creation, after setting all properties.
function editTranslateLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTranslateRight_Callback(hObject, eventdata, handles)
% hObject    handle to editTranslateRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTranslateRight as text
%        str2double(get(hObject,'String')) returns contents of editTranslateRight as a double


% --- Executes during object creation, after setting all properties.
function editTranslateRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTranslateRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonTranslateUp.
function pushbuttonTranslateUp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% xy = zeros(handles.abc(1),handles.abc(2));
[row col] = find(handles.bwContour(:,:,handles.slice));
row = row - str2num(get(handles.editTranslateUp,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonTranslateDown.
function pushbuttonTranslateDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[row col] = find(handles.bwContour(:,:,handles.slice));
row = row + str2num(get(handles.editTranslateDown,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonTranslateLeft.
function pushbuttonTranslateLeft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[row col] = find(handles.bwContour(:,:,handles.slice));
col = col - str2num(get(handles.editTranslateLeft,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes on button press in pushbuttonTranslateRight.
function pushbuttonTranslateRight_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTranslateRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[row col] = find(handles.bwContour(:,:,handles.slice));
col = col + str2num(get(handles.editTranslateRight,'String'));
tmp = false(size(handles.bwContour(:,:,handles.slice)));
for i = 1:length(row)
    tmp(row(i),col(i)) = 1;
end

cent = [round(mean(row)) round(mean(col))];
set(handles.textCenterLocation,'String',[num2str(cent(1)) ' ' num2str(cent(2))]);

handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function axesIMG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesIMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesIMG


% --- Executes on button press in pushbuttonZoomtoRegion.
function pushbuttonZoomtoRegion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonZoomtoRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    im = imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[]);
    colormap(handles.axesIMG,handles.colormap);
    [~,rect] = imcrop(im);
    
    handles.img = handles.img(round(rect(2)):round(rect(2))+round(rect(4))-1,round(rect(1)):round(rect(1))+round(rect(3))-1,:);
    if isfield(handles,'bwContour')
        handles.bwContour = handles.bwContour(round(rect(2)):round(rect(2))+round(rect(4))-1,round(rect(1)):round(rect(1))+round(rect(3))-1,:);
    end
    %update info as well
    handles.abc = size(handles.img);
    
    handles.info.Height = handles.abc(1);
    handles.info.Width = handles.abc(2);
    handles.info.Rows = handles.abc(1);
    handles.info.Columns = handles.abc(2);
    
    handles.slice = 1;
    handles.abc = size(handles.img);
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    
    % end
    hold off;
    
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end
% --- Executes on button press in pushbuttonDiskMorphological.
function pushbuttonDiskMorphological_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiskMorphological (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(handles.morphological,'Erode') == 1
    handles.img = imerode(handles.img,strel('disk',str2num(get(handles.editDiskSize,'String')),0));
elseif strcmpi(handles.morphological,'Dilate') == 1
    handles.img = imdilate(handles.img,strel('disk',str2num(get(handles.editDiskSize,'String')),0));
end

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

function editDiskSize_Callback(hObject, eventdata, handles)
% hObject    handle to editDiskSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDiskSize as text
%        str2double(get(hObject,'String')) returns contents of editDiskSize as a double

% --- Executes during object creation, after setting all properties.
function editDiskSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDiskSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuCorticalCancellous.
function popupmenuCorticalCancellous_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuCorticalCancellous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuCorticalCancellous contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuCorticalCancellous
str = get(handles.popupmenuCorticalCancellous,'String');
val = get(handles.popupmenuCorticalCancellous,'Value');
switch str{val}
    case 'Cortical'
        handles.analysis = 'Cortical';
    case 'Cancellous'
        handles.analysis = 'Cancellous';
    case 'FractureCallusVascularity'
        handles.analysis = 'FractureCallusVascularity';
    case 'Arterial'
        handles.analysis = 'Arterial';
    case 'MarrowFat'
        handles.analysis = 'MarrowFat';
    case 'TangIVDPMA'
        handles.analysis = 'TangIVDPMA';
    case 'TendonFootprint'
        handles.analysis = 'TendonFootprint';
    case 'MakeGif'
        handles.analysis = 'MakeGif';
    case 'ObjectAndVoids'
        handles.analysis = 'ObjectAndVoids';
    case 'VolumeRender'
        handles.analysis = 'VolumeRender';
    case 'TangIVDPMANotochord'
        handles.analysis = 'TangIVDPMANotochord';
    case 'NeedlePuncture'
        handles.analysis = 'NeedlePuncture';
    case 'DisplacementMap'
        handles.analysis = 'DisplacementMap';
    case 'ShapeAnaylsis'
        handles.analysis = 'ShapeAnalysis';
    case 'NonLocalMeansFilter'
        handles.analysis = 'NonLocalMeansFilter';
    case 'MaskVolume'
        handles.analysis = 'MaskVolume';
    case 'LinearMeasure'
        handles.analysis = 'LinearMeasure';
    case 'RegisterVolumes'
        handles.analysis = 'RegisterVolumes';
    case '2D-Analysis'
        handles.analysis = '2D-Analysis';
    case 'FractureCallus3PtBendBreak'
        handles.analysis = 'FractureCallus3PtBendBreak';
    case 'GuilakKneeSurface'
        handles.analysis = 'GuilakKneeSurface';
    case 'SkeletonizationAnalysis'
        handles.analysis = 'SkeletonizationAnalysis';
    case 'DistanceMap'
        handles.analysis = 'DistanceMap';
    case 'WriteToTiff'
        handles.analysis = 'WriteToTiff';
    case 'WriteToDICOM'
        handles.analysis = 'WriteToDICOM';
    case 'SaveCurrentImage'
        handles.analysis = 'SaveCurrentImage';
    case 'GenerateHistogram'
        handles.analysis = 'GenerateHistogram';
    case 'MakeDatasetIsotropic'
        handles.analysis = 'MakeDatasetIsotropic';
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuCorticalCancellous_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuCorticalCancellous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonRotate90.
function pushbuttonRotate90_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRotate90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    
    handles.img = rot90_3D(handles.img,get(handles.popupmenuRotationAxis,'Value'),1);
    if isfield(handles,'bwContour') == 1
        handles.bwContour = rot90_3D(handles.bwContour,get(handles.popupmenuRotationAxis,'Value'),1);
    end
    
    handles.abc = size(handles.img);
    handles.primitiveCenter(1) = round(handles.abc(1)/2);
    handles.primitiveCenter(2) = round(handles.abc(2)/2);
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in pushbuttonSetLowerThreshold.
function pushbuttonSetLowerThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLowerThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.lowerThreshold = handles.threshold;
set(handles.textLowerThreshold,'String',num2str(handles.lowerThreshold));
guidata(hObject, handles);

% --- Executes on button press in pushbuttonSetUpperThreshold.
function pushbuttonSetUpperThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetUpperThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.upperThreshold = handles.threshold;
set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
guidata(hObject, handles);


% --- Executes on button press in togglebuttonToggleMask
function togglebuttonToggleMask_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonToggleMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonToggleMask
if get(handles.togglebuttonToggleMask,'Value') == 1
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    impixelinfo(handles.axesIMG);
else
    imshow(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),'Parent',handles.axesIMG);
    impixelinfo(handles.axesIMG);
end

guidata(hObject, handles);


function editPrimitiveVertical_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveVertical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPrimitiveVertical as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveVertical as a double
handles.primitiveCenter(2) = str2num(cell2mat(get(handles.editPrimitiveVertical,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveVertical_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveVertical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPrimitiveHorizontal_Callback(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHorizontal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPrimitiveHorizontal as text
%        str2double(get(hObject,'String')) returns contents of editPrimitiveHorizontal as a double
handles.primitiveCenter(1) = str2num(cell2mat(get(handles.editPrimitiveHorizontal,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPrimitiveHorizontal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPrimitiveHorizontal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLoadTXMFile.
function pushbuttonLoadTXMFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadTXMFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    
    if isfield(handles,'img') == 1
        clear handles.img;
    end
    if isfield(handles,'bwContour') == 1
        handles = rmfield(handles,'bwContour');
    end
    
    set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
    
    [fName pName] = uigetfile(fullfile(pwd,'*.txm'),'Please select your TXM file');
    handles.pathstr = [pName fName];
    
    set(handles.textCurrentDirectory,'String',[pName fName]);
    % handles.files = dir([handles.pathstr '\*.txm*']);
    % handles.info = dicominfo([handles.pathstr '\' handles.files(1).name]);
    
    [handles.header handles.headerShort] = txmheader_read8([handles.pathstr]);
    handles.pathstr = pName;
    handles.info = handles.headerShort;
    handles.info.SliceThickness = handles.info.PixelSize;
    handles.info.SliceThickness = handles.info.SliceThickness / 1000;
    handles.info.Height = handles.info.ImageHeight;%may need to be switched with below
    handles.info.Width = handles.info.ImageWidth;
    handles.info.BitDepth = 16;
    handles.info.Format = 'DICOM';
    handles.info.FileName = handles.info.File;
    handles.info.FileSize = handles.info.Height * handles.info.Width * 2^16;
    handles.info.FormatVersion = 3;
    handles.info.ColorType = 'grayscale';
    handles.info.Modality = 'CT';
    handles.info.Manufacturer = 'Zeiss';
    handles.info.InstitutionName = 'Washington University in St. Louis';
    handles.info.PatientName = fName(1:end-4);
    handles.info.KVP = txmdata_read8(handles.header,'Voltage');
    handles.info.DeviceSerialNumber = '8802030299';
    handles.info.BitsAllocated = 16;
    handles.info.BitsStored = 15;
    handles.info.SliceLocation = 20;
    handles.info.ImagePositionPatient = [0;0;handles.info.SliceLocation];
    handles.info.PixelSpacing = [handles.info.SliceThickness;handles.info.SliceThickness];
    
    
    
    handles.img = zeros([handles.headerShort.ImageWidth handles.headerShort.ImageHeight handles.headerShort.NoOfImages],'uint16');
    
    ct=0;
    for i = 1:handles.headerShort.NoOfImages
        ct=ct+1;
        set(handles.textPercentLoaded,'String',num2str(ct/double(handles.headerShort.NoOfImages)));
        drawnow();
        handles.img(:,:,i) = txmimage_read8(handles.header,ct,0,0);
    end
    
    handles.dataMax = max(max(max(handles.img)));
    cameratoolbar('Show');
    
    handles.info.LargestImagePixelValue = max(max(max(handles.img)));
    handles.info.SmallestImagePixelValue = min(min(min(handles.img)));
    
    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    handles.abc = size(handles.img);
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    
    handles.primitiveCenter(1) = round(handles.abc(1)/2);
    handles.primitiveCenter(2) = round(handles.abc(2)/2);
    % handles.bwContour = false(size(handles.img));
    
    handles.upperThreshold = max(max(max(handles.img)));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    handles.hOut = 1;%handles.theMax / 2^16;
    handles.lOut = 0;
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    handles.colormap = 'gray';
    
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
    
    guidata(hObject, handles);
    
    set(gcf,'menubar','figure');
    set(gcf,'toolbar','figure');
    
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in pushbuttonExecuteMorphologicalOperation.
function pushbuttonExecuteMorphologicalOperation_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExecuteMorphologicalOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    
    if strcmp(handles.morphologicalOperation,'Close') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imclose(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imclose(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imclose(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imclose(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Open') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imopen(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imopen(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imopen(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imopen(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Erode') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imerode(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imerode(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imerode(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imerode(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Dilate') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imdilate(handles.bwContour(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imdilate(handles.img(:,:,i),strel('disk',handles.morphologicalRadius,0));
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imdilate(handles.bwContour,true(handles.morphologicalRadius));
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imdilate(handles.img,true(handles.morphologicalRadius));
            end
        end
    elseif strcmp(handles.morphologicalOperation,'Fill') == 1
        if strcmp(handles.morphological2D3D,'2D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                [a b c] = size(handles.bwContour);
                for i = 1:c
                    handles.bwContour(:,:,i) = imfill(handles.bwContour(:,:,i),'holes');
                end
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                [a b c] = size(handles.img);
                for i = 1:c
                    handles.img(:,:,i) = imfill(handles.img(:,:,i),'holes');
                end
            end
        elseif strcmp(handles.morphological2D3D,'3D') == 1
            if strcmp(handles.morphologicalImageMask,'Mask') == 1
                handles.bwContour = imfill(handles.bwContour,'holes');
            elseif strcmp(handles.morphologicalImageMask,'Image') == 1
                handles.img = imfill(handles.img,'holes');
            end
        end
    end
    
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on selection change in popupmenuImageMask.
function popupmenuImageMask_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuImageMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuImageMask contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuImageMask
handles.morphologicalImageMask = cellstr(get(handles.popupmenuImageMask,'String'));
handles.morphologicalImageMask = handles.morphologicalImageMask{get(handles.popupmenuImageMask,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuImageMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuImageMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuMorphologicalOperation.
function popupmenuMorphologicalOperation_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMorphologicalOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMorphologicalOperation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMorphologicalOperation
handles.morphologicalOperation = cellstr(get(handles.popupmenuMorphologicalOperation,'String'));
handles.morphologicalOperation = handles.morphologicalOperation{get(handles.popupmenuMorphologicalOperation,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuMorphologicalOperation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMorphologicalOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2D3D.
function popupmenu2D3D_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2D3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2D3D contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2D3D
handles.morphological2D3D = cellstr(get(handles.popupmenu2D3D,'String'));
handles.morphological2D3D = handles.morphological2D3D{get(handles.popupmenu2D3D,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2D3D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2D3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMorpholgicalRadius_Callback(hObject, eventdata, handles)
% hObject    handle to editMorpholgicalRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMorpholgicalRadius as text
%        str2double(get(hObject,'String')) returns contents of editMorpholgicalRadius as a double
handles.morphologicalRadius = str2num(get(handles.editMorpholgicalRadius,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editMorpholgicalRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMorpholgicalRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderWindowWidth_Callback(hObject, eventdata, handles)
% hObject    handle to sliderWindowWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.editWindowWidth,'String',num2str(get(handles.sliderWindowWidth,'Value')))
handles.windowWidth = get(handles.sliderWindowWidth,'Value');

tmp = handles.img(:,:,handles.slice);
% lIn = min(min(tmp)) / (0.5*2^handles.info.BitDepth);
handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
% hIn = max(max(tmp)) / (0.5*2^handles.info.BitDepth);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

if handles.lOut < 0
    handles.lOut = 0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

% if handles.hOut > handles.lOut
%     tmp = imadjust(tmp,[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]);
%     imshowpair(tmp,handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
%     impixelinfo(handles.axesIMG);
%
% end
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function sliderWindowWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderWindowWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderWindowLocation_Callback(hObject, eventdata, handles)
% hObject    handle to sliderWindowLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.editWindowLocation,'String',num2str(get(handles.sliderWindowLocation,'Value')));
handles.windowLocation = get(handles.sliderWindowLocation,'Value');

tmp = handles.img(:,:,handles.slice);
% lIn = min(min(tmp)) / (0.5*2^handles.info.BitDepth);
handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
% hIn = max(max(tmp)) / (0.5*2^handles.info.BitDepth);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

if handles.lOut < 0
    handles.lOut = 0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

% if handles.hOut > handles.lOut
%     tmp = imadjust(tmp,[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]);
%     imshowpair(tmp,handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
%     impixelinfo(handles.axesIMG);
%
% end


guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function sliderWindowLocation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderWindowLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editWindowWidth_Callback(hObject, eventdata, handles)
% hObject    handle to editWindowWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWindowWidth as text
%        str2double(get(hObject,'String')) returns contents of editWindowWidth as a double
handles.windowWidth = str2num(get(handles.editWindowWidth,'String'));

tmp = handles.img(:,:,handles.slice);
% lIn = min(min(tmp)) / (0.5*2^handles.info.BitDepth);
handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
% hIn = max(max(tmp)) / (0.5*2^handles.info.BitDepth);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

if handles.lOut < 0
    handles.lOut =0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

% if handles.hOut > handles.lOut
%     tmp = imadjust(tmp,[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]);
%     if handles.scale == 0
%         imshowpair(tmp,handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
%     end
%     impixelinfo(handles.axesIMG);
%
% end

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editWindowWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindowWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWindowLocation_Callback(hObject, eventdata, handles)
% hObject    handle to editWindowLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWindowLocation as text
%        str2double(get(hObject,'String')) returns contents of editWindowLocation as a double
handles.windowLocation = str2num(get(handles.editWindowLocation,'String'));

tmp = handles.img(:,:,handles.slice);
% lIn = min(min(tmp)) / (0.5*2^handles.info.BitDepth);
handles.lOut = (handles.windowLocation-0.5*handles.windowWidth) / double(handles.dataMax);
% hIn = max(max(tmp)) / (0.5*2^handles.info.BitDepth);
handles.hOut = (handles.windowLocation+0.5*handles.windowWidth)  / double(handles.dataMax);

if handles.lOut < 0
    handles.lOut = 0;
end

if handles.hOut > 1
    handles.hOut = 1;
end

% if handles.hOut > handles.lOut
%     tmp = imadjust(tmp,[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]);
%     if handles.scale == 0
%         imshowpair(tmp,handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
%         impixelinfo(handles.axesIMG);
%     end
% end

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editWindowLocation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindowLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSetOriginalImage.
function pushbuttonSetOriginalImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetOriginalImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.imgOrig = handles.img;
    
    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    handles.abc = size(handles.img);
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    
    handles.primitiveCenter(1) = round(handles.abc(2)/2);
    handles.primitiveCenter(2) = round(handles.abc(1)/2);
    % handles.bwContourOrig = handles.bwContour;
    % handles.bwContour = false(size(handles.img));
    
    
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end


% --- Executes on button press in pushbuttonRevertImage.
function pushbuttonRevertImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRevertImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.img = handles.imgOrig;
    
    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    handles.abc = size(handles.img);
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    
    handles.primitiveCenter(1) = round(handles.abc(2)/2);
    handles.primitiveCenter(2) = round(handles.abc(1)/2);
    answer = inputdlg('Would you like to reset the contour? If you changed the image size, you must. y or n');
    if strcmpi(answer{1},'y') == 1
        if isfield(handles,'bwContour') == 1
            handles.bwContour = [];
            %         rmfield(handles,'bwContour');
        end
    end
    % handles.bwContour = false(size(handles.img));
    % handles.bwContourOrig = handles.bwContour;
    
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in pushbuttonSetFirstSlice.
function pushbuttonSetFirstSlice_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetFirstSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img = handles.img(:,:,handles.slice:end);

handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
set(handles.editWindowWidth,'String',num2str(handles.windowWidth));

handles.abc = size(handles.img);

handles.windowLocation = round(handles.windowWidth / 2);
set(handles.editWindowLocation,'String',num2str(handles.windowLocation));

handles.primitiveCenter(1) = round(handles.abc(2)/2);
handles.primitiveCenter(2) = round(handles.abc(1)/2);
if isfield(handles,'bwContour')
    handles.bwContour = handles.bwContour(:,:,handles.slice:end);
end
% handles.bwContour = false(size(handles.img));
% handles.bwContourOrig = handles.bwContour;

handles.upperThreshold = max(max(max(handles.img)));
set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));

set(handles.sliderIMG,'Value',1);
set(handles.sliderIMG,'min',1);
set(handles.sliderIMG,'max',handles.abc(3));
set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));

handles.theMax = double(max(max(max(handles.img))));
set(handles.sliderThreshold,'Value',1);
set(handles.sliderThreshold,'min',1);
set(handles.sliderThreshold,'max',handles.theMax);
set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

set(handles.sliderWindowWidth,'Value',1);
set(handles.sliderWindowWidth,'min',1);
set(handles.sliderWindowWidth,'max',handles.theMax);
set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

set(handles.sliderWindowLocation,'Value',1);
set(handles.sliderWindowLocation,'min',1);
set(handles.sliderWindowLocation,'max',handles.theMax);
set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

handles.slice = 1;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonSetLastSlice.
function pushbuttonSetLastSlice_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetLastSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.img = handles.img(:,:,1:handles.slice);

if isfield(handles,'bwContour') == 1
    handles.bwContour = handles.bwContour(:,:,1:handles.slice);
end

handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
set(handles.editWindowWidth,'String',num2str(handles.windowWidth));

handles.abc = size(handles.img);

handles.windowLocation = round(handles.windowWidth / 2);
set(handles.editWindowLocation,'String',num2str(handles.windowLocation));

handles.primitiveCenter(1) = round(handles.abc(2)/2);
handles.primitiveCenter(2) = round(handles.abc(1)/2);
% handles.bwContour = false(size(handles.img));
% handles.bwContourOrig = handles.bwContour;

handles.upperThreshold = max(max(max(handles.img)));
set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));

set(handles.sliderIMG,'Value',1);
set(handles.sliderIMG,'min',1);
set(handles.sliderIMG,'max',handles.abc(3));
set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));

handles.theMax = double(max(max(max(handles.img))));
set(handles.sliderThreshold,'Value',1);
set(handles.sliderThreshold,'min',1);
set(handles.sliderThreshold,'max',handles.theMax);
set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

set(handles.sliderWindowWidth,'Value',1);
set(handles.sliderWindowWidth,'min',1);
set(handles.sliderWindowWidth,'max',handles.theMax);
set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

set(handles.sliderWindowLocation,'Value',1);
set(handles.sliderWindowLocation,'min',1);
set(handles.sliderWindowLocation,'max',handles.theMax);
set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

handles.slice = 1;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonInvertMask.
function pushbuttonInvertMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInvertMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bwContour = ~handles.bwContour;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonCopyMask.
function pushbuttonCopyMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCopyMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.maskCopy = handles.bwContour(:,:,handles.slice);
guidata(hObject, handles);


% --- Executes on button press in pushbuttonPasteMask.
function pushbuttonPasteMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPasteMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = handles.bwContour(:,:,handles.slice);
tmp(find(handles.maskCopy)) = 1;
handles.bwContour(:,:,handles.slice) = tmp;

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonStoreMask.
function pushbuttonStoreMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStoreMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval(['handles.' get(handles.editMaskName,'String') ' = handles.bwContour;']);
guidata(hObject, handles);


function editMaskName_Callback(hObject, eventdata, handles)
% hObject    handle to editMaskName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMaskName as text
%        str2double(get(hObject,'String')) returns contents of editMaskName as a double


% --- Executes during object creation, after setting all properties.
function editMaskName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaskName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateImage(hObject,eventdata,handles)

if isfield(handles,'bwContour') == 0
    imshow(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[]),'Parent',handles.axesIMG);
    colormap(handles.axesIMG,handles.colormap);
else
    imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    %     handles.colormap = 'gray';
    colormap(handles.axesIMG,handles.colormap);
end
impixelinfo(handles.axesIMG);

guidata(hObject, handles);


% --- Executes on button press in pushbuttonSetColorMap.
function pushbuttonSetColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.popupmenuSetColorMap,'String');
handles.colormap = str{get(handles.popupmenuSetColorMap,'Value')};

guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on selection change in popupmenuSetColorMap.
function popupmenuSetColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSetColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSetColorMap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSetColorMap


% --- Executes during object creation, after setting all properties.
function popupmenuSetColorMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSetColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebuttonRobustThickness.
function togglebuttonRobustThickness_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonRobustThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonRobustThickness
if get(handles.togglebuttonRobustThickness,'Value') == 1
    set(handles.togglebuttonRobustThickness,'BackgroundColor',[1 0 0]);
elseif get(handles.togglebuttonRobustThickness,'Value') == 0
    set(handles.togglebuttonRobustThickness,'BackgroundColor',[.94 .94 .94]);
end

guidata(hObject, handles);


% --- Executes on button press in pushbuttonSaveWorkspace.
function pushbuttonSaveWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    save(fullfile(handles.pathstr,'Workspace.mat'),'handles','-v7.3');
    set(handles.textBusy,'String','Not');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end


% --- Executes on button press in pushbuttonLoadWorkspace.
function pushbuttonLoadWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'pathstr')
    [file pathstr] = uigetfile(handles.pathstr,'Select the workspace file to load');
else
    [file pathstr] = uigetfile(pwd,'Select the workspace file to load');
end
if isfield(handles,'gui')
    delete(handles.gui);
end
clear handles;
load(fullfile(pathstr,file));
% guidata(hObject, handles);


% --- Executes on button press in pushbuttonMakeIsotropic.
function pushbuttonMakeIsotropic_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMakeIsotropic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    handles.minVoxelSpacing = min([handles.info.PixelSpacing;handles.info.SliceThickness]);
    R = makeresampler({'linear','linear','linear'},'fill');
    a = handles.info.PixelSpacing(1) / handles.minVoxelSpacing;
    b = handles.info.PixelSpacing(2) / handles.minVoxelSpacing;
    c = handles.info.SliceThickness / handles.minVoxelSpacing;
    T = maketform('affine',[a 0 0; 0 b 0; 0 0 c; 0 0 0]);
    
    handles.info.PixelSpacing(1,1) = handles.minVoxelSpacing;
    handles.info.PixelSpacing(1,2) = handles.minVoxelSpacing;
    handles.info.SliceThickness = handles.minVoxelSpacing;
    [a1 b1 c1] = size(handles.img);
    
    handles.img = tformarray(handles.img,T,R,[1 2 3],[1 2 3], [round(a1*a) round(b1*b) round(c1*c)],[],0);
    
    handles.dataMax = max(max(max(handles.img)));
    
    handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
    set(handles.editWindowWidth,'String',num2str(handles.windowWidth));
    
    
    
    handles.abc = size(handles.img);
    
    handles.windowLocation = round(handles.windowWidth / 2);
    set(handles.editWindowLocation,'String',num2str(handles.windowLocation));
    
    set(handles.editScaleImageSize,'String',num2str(handles.imgScale));
    
    handles.primitiveCenter(1) = round(handles.abc(2)/2);
    handles.primitiveCenter(2) = round(handles.abc(1)/2);
    % handles.bwContour = false(size(handles.img));
    % handles.bwContourOrig = handles.bwContour;
    
    set(handles.textCurrentDirectory,'String',handles.pathstr);
    
    handles.upperThreshold = max(max(max(handles.img)));
    set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));
    
    set(handles.sliderIMG,'Value',1);
    set(handles.sliderIMG,'min',1);
    set(handles.sliderIMG,'max',handles.abc(3));
    set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));
    
    handles.theMax = double(max(max(max(handles.img))));
    handles.hOut = 1;%handles.theMax / 2^15;
    handles.lOut = 0;
    set(handles.sliderThreshold,'Value',1);
    set(handles.sliderThreshold,'min',1);
    set(handles.sliderThreshold,'max',handles.theMax);
    set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowWidth,'Value',1);
    set(handles.sliderWindowWidth,'min',1);
    set(handles.sliderWindowWidth,'max',handles.theMax);
    set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    set(handles.sliderWindowLocation,'Value',1);
    set(handles.sliderWindowLocation,'min',1);
    set(handles.sliderWindowLocation,'max',handles.theMax);
    set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));
    
    % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
    set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));
    updateImage(hObject,eventdata,handles);
    
    set(gcf,'menubar','figure');
    set(gcf,'toolbar','figure');
    
    guidata(hObject, handles);
    %
    % R =
    % % %TO WORK ON
    % % %make a resampler object based on which dimensions are different
    % % if a == b && b == c && c == a
    % %     msgbox('Already isotropic voxel size');
    % % elseif a == b && b ~= c && c == a
    % %
    % % elseif a ~= b && b == c
    % %
    % % elseif a ~= b && b ~= c
    % %
    % % end
    % %
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on button press in pushbuttonLoadMask.
function pushbuttonLoadMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = get(handles.editMaskName,'String');
handles.bwContour = eval(['handles.' answer]);
guidata(hObject, handles);
updateImage(hObject, eventdata, handles);


% --- Executes on button press in pushbuttonUseForContouring.
function pushbuttonUseForContouring_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUseForContouring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    if isfield(handles,'imgOrig') == 0
        handles.imgOrig = handles.img;
    end
    [a b c] = size(handles.img);
    for i = 1:c
        handles.img(:,:,i) = imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)],[]);
    end
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

% --- Executes on selection change in popupmenuFilter.
function popupmenuFilter_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuFilter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuFilter


% --- Executes during object creation, after setting all properties.
function popupmenuFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonExecuteFilter.
function pushbuttonExecuteFilter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExecuteFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 3D Median
% 3D Gaussian
% 3D Mean
% 2D Median
% 2D Gaussian
% 2D Mean
% Local Standard Deviation
% Range
% Entropy
try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    rad = str2num(get(handles.editRadius,'String'));
    weight = str2num(get(handles.editSigma,'String'));
    
    str = get(handles.popupmenuFilter,'String');
    val = get(handles.popupmenuFilter,'Value');
    switch str{val}
        case '3D Median'
            handles.img = uint16(smooth3(handles.img,'box',[rad rad rad]));
        case '3D Gaussian'
            handles.img = imgaussfilt3(handles.img,weight,'FilterSize',rad);
        case '2D Median'
            [a b c] = size(handles.img);
            for i = 1:c
                handles.img(:,:,i) = medfilt2(handles.img(:,:,i),[rad rad]);
            end
        case '2D Gaussian'
            handles.img = imgaussfilt(handles.img,weight,'FilterSize',rad);
        case '2D Mean'
            h = fspecial('average',rad);
            handles.img = imfilter(handles.img,h);
        case 'Local Standard Deviation'
            handles.img = stdfilt(handles.img,true([rad rad rad]));
        case 'Range'
            handles.img = rangefilt(handles.img,true([rad rad rad]));
        case 'Entropy'
            handles.img = entropyfilt(handles.img,true([rad rad rad]));
            
            
    end
    guidata(hObject, handles);
    updateImage(hObject, eventdata, handles);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Execute Analysis function block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function corticalAnalysis(hTimer,eventData,handles,hObject)
    try
            set(handles.textBusy,'String','Busy');
            guidata(hObject, handles);
            drawnow();
            if ~isempty(handles.info.Private_0029_1004)
                [handles.outCortical,handles.outHeaderCortical] = scancoParameterCalculatorCortical(handles.img,handles.bwContour,handles.info,handles.threshold,get(handles.togglebuttonRobustThickness,'Value'));
            end
            [twoDHeader twoDData] = twoDAnalysisSub(handles.img,handles.info,handles.lowerThreshold);
            if exist(fullfile(handles.pathstr,'CorticalResults.txt'),'file') ~= 2
                fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
                for i = 1:length(handles.outHeaderCortical)
                    if i == length(handles.outHeaderCortical)
                        fprintf(fid,'%s\t',handles.outHeaderCortical{i});
                        fprintf(fid,'%s\n','pMOI (mm)');
                    else
                        fprintf(fid,'%s\t',handles.outHeaderCortical{i});
                    end
                end
    %             fprintf(fid,'%s\n','Lower Threshold');
            end
            fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
            for i = 1:length(handles.outCortical)
                if ~ischar(handles.outCortical{i})
                    if i == length(handles.outCortical)
                        fprintf(fid,'%s\t',num2str(handles.outCortical{i}));
                        fprintf(fid,'%s\n',num2str(twoDData(2) + twoDData(3)));
                    else
                        fprintf(fid,'%s\t',num2str(handles.outCortical{i}));
                    end
                else
                    if i == length(handles.outCortical)
                        fprintf(fid,'%s\t',handles.outCortical{i});
                        fprintf(fid,'%s\n',num2str(twoDData(2) + twoDData(3)));
                    else
                        fprintf(fid,'%s\t',handles.outCortical{i});
                    end
                end
            end
            fclose(fid);
            guidata(hObject, handles);
            set(handles.textBusy,'String','Not Busy');
        catch
            set(handles.textBusy,'String','Failed');
    end
    
function [handles] = cancellousAnalysis(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        bw = false(size(handles.img));
        bw(find(handles.img > handles.lowerThreshold)) = 1;
        bw(find(handles.img > handles.upperThreshold)) = 0;
        [handles.outCancellous,handles.outHeaderCancellous] = scancoParameterCalculatorCancellous(bw,handles.bwContour,handles.img,handles.info,get(handles.togglebuttonRobustThickness,'Value'));
        if exist(fullfile(handles.pathstr,'CancellousResults.txt'),'file') ~= 2
            fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'w');
            for i = 1:length(handles.outCancellous)
                if i == length(handles.outCancellous)
                    fprintf(fid,'%s\t',handles.outHeaderCancellous{i});
                    
                else
                    fprintf(fid,'%s\t',handles.outHeaderCancellous{i});
                end
            end
            fprintf(fid,'%s\n','Threshold');
            fclose(fid);
        end
        for i = 1:length(handles.outCancellous)
            fid = fopen(fullfile(handles.pathstr,'CancellousResults.txt'),'a');
            if i == length(handles.outCancellous)
                fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
                fprintf(fid,'%s\n',num2str(handles.lowerThreshold));
            else
                fprintf(fid,'%s\t',num2str(handles.outCancellous{i}));
            end
        end
        fclose(fid);
        guidata(hObject, handles);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = fractureCallusVascularity(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        [handles.outCallus,handles.outHeaderCallus] = scancoParameterCalculatorCancellousCallus(handles.img > handles.threshold,handles.bwContour,handles.img,handles.info);
        
        handles.outHeaderCallus{14} = 'Slices';
        handles.outHeaderCallus{15} = 'Threshold';
        handles.outHeaderCallus{16} = 'Median Filter Radius';
        
        nums1 = 1;%handles.emptyRanges{1};
        [a b c] = size(handles.img);
        nums2 = c;%handles.emptyRanges{end};
        handles.outCallus{14} = [nums1,nums2];
        handles.outCallus{15} = handles.threshold;
        handles.outCallus{16} = handles.radius;
        
        fid = fopen(fullfile(handles.pathstr,'CallusResults.txt'),'a');
        %     if exist([handles.pathstr '\CallusResults.txt']) ~= 2
        for i = 1:length(handles.outCallus)
            if i == length(handles.outCallus)
                fprintf(fid,'%s\n',handles.outHeaderCallus{i});
            else
                fprintf(fid,'%s\t',handles.outHeaderCallus{i});
            end
        end
        %     end
        for i = 1:length(handles.outCallus)
            if i == length(handles.outCallus)
                fprintf(fid,'%s\n',num2str(handles.outCallus{i}));
            else
                fprintf(fid,'%s\t',num2str(handles.outCallus{i}));
            end
        end
        fclose(fid);
        guidata(hObject, handles);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = arterialOlga(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        startSlice = handles.slice;
        endSlice = startSlice + 1049;
        
        calcificationThresh =  21856;%800 * (2^15 / 1000);
        %     img = uint16(smooth3(handles.img(:,:,startSlice:endSlice)));
        level = 2250;
        tissueBW = handles.img > level;
        calcificationBW = handles.img > calcificationThresh;
        tissueBW(calcificationBW) = 0;
        tissueBW = imopen(tissueBW,strel('disk',3,0));
        tissueBW = bwareaopen(tissueBW,20);
        tissueBW = imclose(tissueBW,true(4,4,4));
        tissueBW = bwBiggest(tissueBW);
        calcificationBW(tissueBW) = 0;
        
        shpTissue = shpFromBW(tissueBW,5);
        shpCalcification = shpFromBW(calcificationBW,3);
        
        figure;
        plot(shpTissue,'FaceColor','r','LineStyle','none','FaceAlpha',0.2);
        hold on;
        plot(shpCalcification,'FaceColor','k','LineStyle','none');
        
        savefig(gcf,fullfile(handles.pathstr,'calcificationImage.fig'));
        
        fid = fopen(fullfile(handles.pathstr,'Results.txt'),'w');
        header = {'Path','Arterial Tissue Volume (mm^3)','Calcification Volume (mm^3)','% Calcified','Lower Threshold','Upper Threshold'};
        for j = 1:length(header)
            if j ~= length(header)
                fprintf(fid,'%s\t',header{j});
            else
                fprintf(fid,'%s\n',header{j});
            end
        end
        fprintf(fid,'%s\t',handles.pathstr);
        fprintf(fid,'%s\t',num2str(length(find(tissueBW)) * handles.info.SliceThickness^3));
        fprintf(fid,'%s\t',num2str(length(find(calcificationBW)) * handles.info.SliceThickness^3));
        fprintf(fid,'%s\t',num2str((length(find(calcificationBW)) * handles.info.SliceThickness^3) / (length(find(tissueBW)) * handles.info.SliceThickness^3)));
        fprintf(fid,'%s\t',num2str(level));
        fprintf(fid,'%s\n',num2str(calcificationThresh));
        fclose(fid);
        %     close all;
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = marrowFat(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        handles.img(~handles.bwContour) = 0;
        handles.bwGlobules = handles.img > handles.lowerThreshold;
        handles.bwGlobules(handles.img > handles.upperThreshold) = 0;
        bw = handles.bwGlobules;
        fatVol = length(find(bw)) * handles.info.SliceThickness^3;
        totVol = length(find(handles.bwContour)) * handles.info.SliceThickness^3;
        bw = imerode(bw,true(3,3,3));
        %     StackSlider(bw);
        bw = ~bw;
        D = bwdist(bw);
        D = 1-D;
        Ld = watershed(D);
        %     imshow(label2rgb(Ld))
        mask = imextendedmin(D,1);
        D2 = imimposemin(D,mask);
        Ld2 = watershed(D2);
        bw3 = ~bw;
        bw3(Ld2 == 0) = 0;
        %     bwTmp = imdilate(bw3,true(3,3,3));
        for i = 1:handles.abc(3)
            handles.blended(:,:,i) = imfuse(bw3(:,:,i),handles.img(:,:,i),'blend');
        end
        clear bwTmp;
        cc = bwconncomp(bw3);
        %     figure
        for i = 1:length(cc.PixelIdxList)
            clc
            i/length(cc.PixelIdxList)
            bwTmp = false(size(bw3));
            bwTmp(cc.PixelIdxList{i}) = 1;
            bwTmp = imdilate(bwTmp,true(3,3,3));
            %         figure
            shp = shpFromBW(bwTmp,2);
            %         plot(shp,'LineStyle','none','FaceColor','r');
            % %         plot(shp)
            %         if i == 1
            %             hold on;
            %         end
            %
            %         drawnow;
            %         if i == 1
            %             shp = shpFromBW(resize3DMatrixBW(handles.bwContour,0.3),5);
            %             shp.Points = shp.Points .* (1/0.3);
            %             plot(shp,'FaceColor','b','FaceAlpha',0.3,'LineStyle','none');
            %         end
            
            vols(i) = shp.volume;
            %         vols(i) = vols(i) * handles.info.SliceThickness^3;
            %         vols(i) = length(find(bwTmp)) * handles.info.SliceThickness^3;
            surfArea(i) = shp.surfaceArea;
            %         surfArea(i) = surfArea(i) * handles.info.SliceThickness^3;
            topTerm = pi * (6 * shp.volume / pi)^(2/3);
            sphericity(i) = topTerm / shp.surfaceArea;
        end
        camlight();
        vols = vols .* handles.info.SliceThickness^3;
        meanVols = mean(vols);
        stdVols = std(vols);
        totVol = sum(vols);
        fid = fopen(fullfile(handles.pathstr,'fatVolumeResults.txt'),'a');
        
        fprintf(fid,'%s\t','File Path');
        fprintf(fid,'%s\t','Threshold');
        fprintf(fid,'%s\t','Total Fat Volume');
        fprintf(fid,'%s\t','Number of Globules');
        fprintf(fid,'%s\t','Mean Globule Size');
        fprintf(fid,'%s\t','Standard Deviation of Globule Size');
        fprintf(fid,'%s\t','Mean Globule Sphericity');
        fprintf(fid,'%s\t','Standard Deviation of Globule Sphericity');
        fprintf(fid,'%s\t','Total Medullary Cavity Volume');
        fprintf(fid,'%s\n','Fat Volume Fraction');
        
        fprintf(fid,'%s\t',handles.pathstr);
        fprintf(fid,'%s\t',[num2str(handles.lowerThreshold),' , ',num2str(handles.upperThreshold)]);
        fprintf(fid,'%s\t',num2str(totVol));
        fprintf(fid,'%s\t',num2str(length(vols)));
        fprintf(fid,'%s\t',num2str(meanVols));
        fprintf(fid,'%s\t',num2str(stdVols));
        fprintf(fid,'%s\t',num2str(mean(sphericity)));
        fprintf(fid,'%s\t',num2str(std(sphericity)));
        fprintf(fid,'%s\t',num2str(length(find(handles.bwContour)) * handles.info.SliceThickness^3));
        fprintf(fid,'%s\n',num2str( totVol / (length(find(handles.bwContour)) * handles.info.SliceThickness^3)));
        fclose(fid);
        
        fid = fopen(fullfile(handles.pathstr,'fatVolumeIndividual.txt'),'w');
        for i = 1:length(vols)
            fprintf(fid,'%s\t',num2str(vols(i)));
        end
        fclose(fid);
        
        fid = fopen(fullfile(handles.pathstr,'sphericityIndividual.txt'),'w');
        for i = 1:length(sphericity)
            fprintf(fid,'%s\t',num2str(sphericity(i)));
        end
        fclose(fid);
        
        mkdir(fullfile(handles.pathstr,'overlay images'));

        [a b c] = size(handles.blended);
        for i = 1:c
            pathTemp = fullfile(handles.pathstr,'overlay images');
            fName = ['Image' num2str(i) '.tif'];
            imwrite(handles.blended(:,:,i),fullfile(pathTemp,fName));
        end
        
        StackSlider(handles.blended);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = tangIVDPMA(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        %     bw = handles.img > handles.lowerThreshold;
        %     bw(find(handles.img > handles.upperThreshold)) = 0;
        %     bw = imopen(bw,true(3,3,3));
        %     bw = imclose(bw,true(4,4,4));
        
        %now set up to input two masks, af and total
        
        answer = inputdlg('Please type in the name of the mask representing the NP');
        handles.bwNP = eval(['handles.' answer{1}]);
        answer = inputdlg('Please type in the name of the mask representing the complete disc');
        handles.bwTotal = eval(['handles.' answer{1}]);
        handles.bwAF = handles.bwTotal(~handles.bwNP);
        
        meanTotal = mean(handles.img(handles.bwTotal));
        meanAF = mean(handles.img(handles.bwAF));
        meanNP = mean(handles.img(handles.bwNP));
        
        afVolume = length(find(handles.bwAF)) * handles.info.SliceThickness^3;
        totalVolume = length(find(handles.bwTotal)) * handles.info.SliceThickness^3;
        npVolume = totalVolume - afVolume;
        
        answer = inputdlg('Do you want to generate a picture? y or n');
        if strcmpi(answer{1},'y')
            shp = shpFromBW(handles.bwTotal,3);
            figure;
            plot(shp,'FaceColor','b','LineStyle','none','FaceAlpha',0.3);
            hold on;
            shp = shpFromBW(handles.bwNP,3);
            plot(shp,'FaceColor','r','LineStyle','none');
            camlight();
            saveas(gcf,fullfile(handles.pathstr,'Disc.fig'));
            close all;
        end
        
        fid = fopen(fullfile(handles.pathstr,'TangIVDPMAResults.txt'),'a');
        fprintf(fid,'%s\t','Date Analysis Performed');
        fprintf(fid,'%s\t','DICOM Path');
        fprintf(fid,'%s\t','Total Volume (mm^3)');
        fprintf(fid,'%s\t','AF Volume (mm^3)');
        fprintf(fid,'%s\t','NP Volume (mm^3)');
        fprintf(fid,'%s\t','Lower Threshold');
        fprintf(fid,'%s\t','Upper Threshold');
        fprintf(fid,'%s\t','Mean Total');
        fprintf(fid,'%s\t','Mean AF');
        fprintf(fid,'%s\n','Mean NP');
        
        fprintf(fid,'%s\t',datestr(now));
        fprintf(fid,'%s\t',handles.pathstr);
        fprintf(fid,'%s\t',num2str(totalVolume));
        fprintf(fid,'%s\t',num2str(afVolume));
        fprintf(fid,'%s\t',num2str(npVolume));
        fprintf(fid,'%s\t',num2str(handles.lowerThreshold));
        fprintf(fid,'%s\t',num2str(handles.upperThreshold));
        fprintf(fid,'%s\t',num2str(meanTotal));
        fprintf(fid,'%s\t',num2str(meanAF));
        fprintf(fid,'%s\n',num2str(meanNP));
        fclose(fid);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = tendonFootprint(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        answer = inputdlg('Please type in the name of the mask representing the bone');
        handles.bwBone = eval(['handles.' answer{1}]);
        answer = inputdlg('Please type in the name of the mask representing the tendon');
        handles.bwTendon = eval(['handles.' answer{1}]);
        
        handles.shpBone = shpFromBW(handles.bwBone,3);
        figure
        plot(handles.shpBone);
        title('Surface Reconstruction of Bone');
        handles.shpTendon = shpFromBW(handles.bwTendon,3);
        figure
        plot(handles.shpTendon);
        title('Surface Reconstruction of Tendon');
        figure
        plot(handles.shpBone,'FaceColor','b','LineStyle','none');
        hold on;
        plot(handles.shpTendon,'FaceColor','r','FaceAlpha',0.5,'LineStyle','none');
        title('Combined Plot');
        camlight();
        hold off;
        
        objNo = handles.shpBone.Points;
        objEl = handles.shpBone.boundaryFacets;
        
        volNo = handles.shpTendon.Points;
        volEl = handles.shpTendon.boundaryFacets;
        
        fv.vertices = volNo;
        fv.faces = volEl(:,1:3);
        objFV.vertices = objNo;
        objFV.faces = objEl(:,1:3);
        
        in = inpolyhedron(fv,objFV.vertices);
        
        objFV.vertices = objFV.vertices .* handles.info.SliceThickness;
        fv.vertices = fv.vertices .* handles.info.SliceThickness;
        
        area = 0;
        
        for i = 1:length(objFV.faces)
            nodesMakeFace = objFV.faces(i,1:3);
            areIn = in(nodesMakeFace);
            if length(find(areIn)) == 3
                area = area + triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
                faceColor(i,:) = [255 0 0];
            elseif length(find(areIn)) == 2
                area = area + (2/3) * triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
                faceColor(i,:) = [0 255 0];
            elseif length(find(areIn)) == 1
                area = area + (1/3) * triangleArea3d(objFV.vertices(nodesMakeFace(1),:),objFV.vertices(nodesMakeFace(2),:),objFV.vertices(nodesMakeFace(3),:));
                faceColor(i,:) = [0 0 255];
            else
                faceColor(i,:) = [255 0 255];
            end
        end
        
        stlwrite(fullfile(handles.pathstr,'ColorBinary.stl'),objFV,'mode','binary','facecolor',faceColor);
        stlwrite(fullfile(handles.pathstr,'Ascii.stl'),objFV,'mode','ascii');
        stlwrite(fullfile(handles.pathstr,'Volume.stl'),fv,'mode','ascii');
        
        header = {'DICOM path', 'Area of object contained in volume (mm)'};
        fid = fopen(fullfile(handles.pathstr,'TendonSurfaceArea.txt'),'w');
        fprintf(fid,'%s\t',header{1});
        fprintf(fid,'%s\n',header{2});
        
        fprintf(fid,'%s\t',handles.pathstr);
        fprintf(fid,'%s\n',num2str(area));
        fclose(fid);
        
        guidata(hObject, handles);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = makeGIF(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        [a b c] = size(handles.img);
        filename = fullfile(handles.pathstr,'stack.gif');
        for i = 1:c
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow();
            if i == 1
                imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'LoopCount',Inf,'DelayTime',0.01);
            else
                imwrite(im2uint8(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)])),filename,'WriteMode','append','DelayTime',0.01);
            end
        end
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = linearMeasure(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        imDist = imdistline(handles.axesIMG);
        setLabelVisible(imDist,0);
        h1 = msgbox('Close this box to complete linear measurement');
        while ishandle(h1)
            pos = getPosition(imDist);
            pause(0.1);
        end
        
        pix = pdist(pos,'euclidean');
        pixPhys = pix * handles.info.SliceThickness;
        h1 = msgbox(['Number of pixels = ' num2str(pix) ', physical distance is ' num2str(pixPhys)]);
        while ishandle(h1)
            pause(0.01);
        end
        delete(imDist);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = objectAndVoids(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        bw = false(size(handles.img));
        bw = handles.img > handles.lowerThreshold;
        bw(handles.img > handles.upperThreshold) = 0;
        %     tmp = imerode(handles.bwContour,true(7,7,7));
        tmp = handles.bwContour;
        tmp(bw) = 0;
        bw = tmp;
        clear tmp;
        %     bw = bwareaopen(bw,350);
        shp = shpFromBW(handles.bwContour,4);
        %     shp.Points = shp.Points ./ 0.3;
        figure;
        plot(shp,'LineStyle','none','FaceColor','b','FaceAlpha',0.3);
        hold on;
        shp2 = shpFromBW(bw,3);
        plot(shp2,'LineStyle','none','FaceColor','r');
        camlight();
        axes tight;
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = volumeRender(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        answer = inputdlg('Would you like to use the MATLAB built in volumeRender tool? y/n');
        if strcmpi(answer{1},'y') == 1
            volumeViewer(handles.img);
        else
            
            warning off;
            [a, b c] = size(handles.img);
            figure;
            for i = 1:c
                imshow(imadjust(handles.img(:,:,i),[double(handles.lOut);double(handles.hOut)],[]));
                %         colormap(gcf,handles.colormap);
                drawnow;
                img2(:,:,i) = getimage(gca);
            end
            close(gcf);
            %     try
            %         img2 = gpuArray(img2);
            %     catch
            %     end
            
            [x y z] = ind2sub(size(img2),find(img2));
            
            C = zeros(length(x),1);
            for i = 1:length(x)
                C(i) = double(img2(x(i),y(i),z(i)));
            end
            C = C ./ double(2^8);
            ptCloud = pointCloud([x y z]);
            h = figure;
            ax = pcshow(ptCloud.Location,C,'MarkerSize',15);
            colormap(handles.axesIMG,handles.colormap);
            %     impixelinfo(handles.axesIMG);
            camlight();
        end
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = tangIVDPMANotocord(handles,hObject)
    try
        set(handles.textBusy,'String','Not Busy');
        guidata(hObject, handles);
        drawnow();
        %     bw = handles.img > handles.lowerThreshold;
        %     bw(find(handles.img > handles.upperThreshold)) = 0;
        %     bw = imopen(bw,true(3,3,3));
        %     bw = imclose(bw,true(4,4,4));
        
        %now set up to input two masks, af and total
        
        answer = inputdlg('Please type in the name of the mask representing the NP');
        handles.bwNP = eval(['handles.' answer{1}]);
        answer = inputdlg('Please type in the name of the mask representing the complete disc');
        handles.bwTotal = eval(['handles.' answer{1}]);
        handles.bwAF = false(size(handles.img));
        handles.bwAF = handles.bwTotal;
        handles.bwAF(handles.bwNP) = 0;
        %     handles.bwAF = bwBiggest(handles.bwAF);
        img = handles.img;
        img(~handles.bwNP) = 0;
        [a b c] = size(img);
        handles.bwNC = img > handles.lowerThreshold;
        
        %clear img;
        
        meanTotal = mean(handles.img(handles.bwTotal));
        meanAF = mean(handles.img(handles.bwAF));
        meanNP = mean(handles.img(handles.bwNP));
        meanNC = mean(handles.img(handles.bwNC));
        
        afVolume = length(find(handles.bwAF)) * handles.info.SliceThickness^3;
        totalVolume = length(find(handles.bwTotal)) * handles.info.SliceThickness^3;
        npVolume = totalVolume - afVolume;
        ncVolume = length(find(handles.bwNC)) * handles.info.SliceThickness^3;
        
        %     afArea = shpFromBW(handles.bwAF,3);
        %     afArea = afArea.surfaceArea * handles.info.SliceThickness^2;
        %     totalArea = shpFromBW(handles.bwTotal,3);
        %     totalArea = totalArea.surfaceArea * handles.info.SliceThickness^2;
        %     npArea = shpFromBW(handles.bwNP,3);
        %     npArea = npArea.surfaceArea * handles.info.SliceThickness^2;
        ncArea = shpFromBW(handles.bwNC,3);
        ncArea = ncArea.surfaceArea * handles.info.SliceThickness^2;
        
        
        answer = inputdlg('Do you want to generate a picture? y or n');
        if strcmpi(answer{1},'y')
            shp = shpFromBW(resize3DMatrixBW(handles.bwTotal,0.5),3);
            figure;
            plot(shp,'FaceColor','b','LineStyle','none','FaceAlpha',0.2);
            hold on;
            shp = shpFromBW(resize3DMatrixBW(handles.bwNP,0.5),3);
            plot(shp,'FaceColor','r','LineStyle','none','FaceAlpha',0.4);
            shp = shpFromBW(resize3DMatrixBW(handles.bwNC,0.5),3);
            plot(shp,'FaceColor','c','LineStyle','none');
            camlight();
            saveas(gcf,fullfile(handles.pathstr,'Disc.fig'));
            %         close all;
        end
        
        fid = fopen(fullfile(handles.pathstr,'TangIVDPMANotochordResults.txt'),'a');
        fprintf(fid,'%s\t','Date Analysis Performed');
        fprintf(fid,'%s\t','DICOM Path');
        fprintf(fid,'%s\t','Total Volume (mm^3)');
        fprintf(fid,'%s\t','AF Volume (mm^3)');
        fprintf(fid,'%s\t','NP Volume (mm^3)');
        fprintf(fid,'%s\t','NC Volume (mm^3)');
        %     fprintf(fid,'%s\t','Total Area (mm^2)');
        %     fprintf(fid,'%s\t','AF Area (mm^2)');
        %     fprintf(fid,'%s\t','NP Area (mm^2)');
        fprintf(fid,'%s\t','NC Area (mm^2)');
        fprintf(fid,'%s\t','Lower Threshold');
        %     fprintf(fid,'%s\t','Upper Threshold');
        fprintf(fid,'%s\t','Mean Total');
        fprintf(fid,'%s\t','Mean AF');
        fprintf(fid,'%s\t','Mean NP');
        fprintf(fid,'%s\n','Mean NC');
        
        fprintf(fid,'%s\t',datestr(now));
        fprintf(fid,'%s\t',handles.pathstr);
        fprintf(fid,'%s\t',num2str(totalVolume));
        fprintf(fid,'%s\t',num2str(afVolume));
        fprintf(fid,'%s\t',num2str(npVolume));
        fprintf(fid,'%s\t',num2str(ncVolume));
        %     fprintf(fid,'%s\t',num2str(totalArea));
        %     fprintf(fid,'%s\t',num2str(afArea));
        %     fprintf(fid,'%s\t',num2str(npArea));
        fprintf(fid,'%s\t',num2str(ncArea));
        fprintf(fid,'%s\t',num2str(handles.lowerThreshold));
        %     fprintf(fid,'%s\t',num2str(handles.upperThreshold));
        fprintf(fid,'%s\t',num2str(meanTotal));
        fprintf(fid,'%s\t',num2str(meanAF));
        fprintf(fid,'%s\t',num2str(meanNP));
        fprintf(fid,'%s\n',num2str(meanNC));
        fclose(fid);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = needlePuncture(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        answer(1) = inputdlg('Please indicate the name of the mask representing the full bone');
        answer(2) = inputdlg('Please indicate the name of the mask representing the needle hole');
        
        handles.bwBone = eval(['handles.' answer{1}]);
        handles.bwNeedleHole = eval(['handles.' answer{2}]);
        
        handles.bwBone = smooth3(handles.bwBone);
        handles.bwNeedleHole = smooth3(handles.bwNeedleHole);
        
        shp1 = shpFromBW(handles.bwBone,3);
        shp2 = shpFromBW(handles.bwNeedleHole,3);
        
        figure;
        plot(shp1,'FaceColor','w','LineStyle','none','FaceAlpha',0.4);
        hold on;
        plot(shp2,'FaceColor','r','LineStyle','none','FaceAlpha',0.8);
        camlight();
        title(['Bone and puncture for ' handles.pathstr]);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = displacementMap(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        [file pathstr] = uigetfile('Please select the saved workspace file containing the "fixed" image to compare to');
        handles2 = load(fullfile(pathstr,file),'handles');
        close gcf;
        handles.imgFixed = handles2.handles.img;
        clear handles2;
        handles.imgOrig = handles.img;
        %normalize to max value first
        handles.img = imhistmatch(handles.img,handles.imgFixed);
        
        %     handles.img = handles.img(:,:,1:50);
        %     handles.imgFixed = handles.imgFixed(:,:,1:50);
        
        [handles.DisplacementEstimation,handles.movingReg] = imregdemons(handles.img,handles.imgFixed);
        
        [a b c] = size(handles.img);
        for i = 1:c
            movingFixed(:,:,i) = imfuse(handles.imgFixed(:,:,i),handles.img(:,:,i),'blend');
        end
        StackSlider(movingFixed);
        
        for i = 1:c
            movingFixedDisplacement{i} = imfuse(movingFixed(:,:,i),handles.DisplacementEstimation(:,:,i));
        end
        
        
        
        handles.img = handles.DisplacementEstimation;
        handles.img = handles.img - min(min(min(handles.img)));
        
        handles.info.PixelSpacing(1,1) = handles.info.SliceThickness;
        handles.info.PixelSpacing(1,2) = handles.info.SliceThickness;
        
        
        guidata(hObject, handles);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = shapeAnalysis(handles,hObject)
    cc = bwconncomp(handles.bwContour);
    for i = 1:length(cc.PixelIdxList)
        bw = false(size(handles.bwContour));
        bw(cc.PixelIdxList{i}) = 1;
        
        %fit ellipsoid to objects in the mask in order to use the axes for
        %calculations
        [x y z] = ind2sub(size(bw),find(bw));
        [center(i), radii{i}, evecs{i}, v{i}] = ellipsoid_fit([x y z]);
        
        %aspect ratio
        aspectRatio(i) = min(radii) / max(radii);
        
        %sphericity
        shp = shpFromBW(bw,3);
        V = volume(shp);
        A = surfaceArea(shp);
        As = (36*pi*V^2)^(1/3);
        sphericity(i) = As/A;
        
        %Waviness - need a bit more reading
        
        
    end
    
function [handles] = maskVolume(handles,hObject)
    len = length(find(handles.bwContour));
    vol = len * handles.info.SliceThickness^3;
    h = msgbox(['The volume of this mask is ' num2str(vol) 'mm^3']);
    
function [handles] = registerVolumes(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        RegisterVolumes();
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = twoDAnalysis(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        fid = fopen(fullfile(handles.pathstr,'2DResults.txt'),'a');
        fprintf(fid,'%s\t','Date Analyzed');
        fprintf(fid,'%s\t','Measurement');
        
        fprintf(fid,'%s\t','Area by slice');
        fprintf(fid,'%s\t','Mean Density by Slice');
        fprintf(fid,'%s\t','Standard Deviation of Density by Slice');
        fprintf(fid,'%s\t','Min Density by Slice');
        fprintf(fid,'%s\t','Max Density by Slice');
        
        fprintf(fid,'%s\t','Mean Area');
        fprintf(fid,'%s\t','Standard Deviation of Area');
        fprintf(fid,'%s\t','Min Area');
        fprintf(fid,'%s\t','Max Area');
        fprintf(fid,'%s\t','Mean Density');
        fprintf(fid,'%s\t','Standard Deviation of Density');
        fprintf(fid,'%s\t','Min Density');
        fprintf(fid,'%s\n','Max Density');
        
        fprintf(fid,'%s\t',datestr(now));
        fprintf(fid,'%s\t',handles.pathstr);
        
        handles.imgDensity = calculateDensityFromDICOM(handles.info,handles.img);
        
        [a b c] = size(handles.bwContour);
        for i = 1:c
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow();
            area(i) = bwarea(handles.bwContour(:,:,i)) * handles.info.SliceThickness^2;
            tmp = handles.imgDensity(:,:,i);
            meanIntens(i) = mean(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1]));
            stdIntens(i) = std(double(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1])));
            minIntens(i) = min(double(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1])));
            maxIntens(i) = max(double(reshape(tmp(handles.bwContour(:,:,i)),[length(find(handles.bwContour(:,:,i))) 1])));
        end
        
        meanArea = mean(area);
        minArea = min(area);
        maxArea = max(area);
        stdArea = std(area);
        meanIntensity = mean(handles.imgDensity(handles.bwContour));
        stdIntensity = std(double(handles.imgDensity(handles.bwContour)));
        minIntensity = min(double(handles.imgDensity(handles.bwContour)));
        maxIntensity = max(double(handles.imgDensity(handles.bwContour)));
        
        for i = 1:c
            if i == 1
                fprintf(fid,'%s\t',num2str(area(i)));
                fprintf(fid,'%s\t',num2str(meanIntens(i)));
                fprintf(fid,'%s\t',num2str(stdIntens(i)));
                fprintf(fid,'%s\t',num2str(minIntens(i)));
                fprintf(fid,'%s\t',num2str(maxIntens(i)));
                fprintf(fid,'%s\t',num2str(meanArea));
                fprintf(fid,'%s\t',num2str(stdArea));
                fprintf(fid,'%s\t',num2str(minArea));
                fprintf(fid,'%s\t',num2str(maxArea(i)));
                fprintf(fid,'%s\t',num2str(meanIntensity));
                fprintf(fid,'%s\t',num2str(stdIntensity));
                fprintf(fid,'%s\t',num2str(minIntensity));
                fprintf(fid,'%s\n',num2str(maxIntensity));
            else
                fprintf(fid,'%s\t','');
                fprintf(fid,'%s\t','');
                fprintf(fid,'%s\t',num2str(area(i)));
                fprintf(fid,'%s\t',num2str(meanIntens(i)));
                fprintf(fid,'%s\t',num2str(stdIntens(i)));
                fprintf(fid,'%s\t',num2str(minIntens(i)));
                fprintf(fid,'%s\n',num2str(maxIntens(i)));
            end
        end
        
        fclose(fid);
        
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = fractureCallus3PtBendBreak(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        fid = fopen(fullfile(handles.pathstr,'FractureCallus3PtBendBreakResults.txt'),'a');
        fprintf(fid,'%s\t','Date Analyzed');
        fprintf(fid,'%s\t','Measurement');
        fprintf(fid,'%s\t','Number of Slices');
        fprintf(fid,'%s\t','Voxel Size');
        
        fprintf(fid,'%s\t','Callus Volume');
        fprintf(fid,'%s\t','Callus Bone Volume');
        fprintf(fid,'%s\t','Callus Bone Volume Fraction');
        fprintf(fid,'%s\t','Callus Volumetric Bone Mineral Density');
        fprintf(fid,'%s\t','Cortical Bone Volume');
        fprintf(fid,'%s\t','Cortical Bone Volume Fraction of Callus');
        fprintf(fid,'%s\n','Cortical Tissue Mineral Density');
        
        fprintf(fid,'%s\t',datestr(now));
        fprintf(fid,'%s\t',handles.pathstr);
        [a b c] = size(handles.img);
        fprintf(fid,'%s\t',num2str((c)));
        
        
        handles.img(~handles.bwContour) = 0;
        
        %convert pixels to physical units when writing out
        %do callus math
        handles.bwTmp = false(size(handles.img));
        handles.bwTmp(handles.img > handles.lowerThreshold) = 1; 
        [handles.imgDensity ~] = calculateDensityFromDICOM(handles.info,handles.img);
        handles.imgDensity(~handles.bwTmp) = 0;
        handles.callusMeanVolumetricDensity = mean(handles.imgDensity(handles.bwTmp));
        handles.callusBoneVolume = length(find(handles.bwTmp));
        handles.callusVolume = length(find(handles.bwContour));
        handles.callusBoneVolumeFraction = length(find(handles.bwTmp)) / length(find(handles.bwContour));
        
        %do cortical math
        handles.imgDensity = calculateDensityFromDICOM(handles.info,handles.img);
        handles.bwTmp = false(size(handles.img));
        handles.bwTmp(handles.img > handles.upperThreshold) = 1;
        handles.corticalTissueMineralDensity = mean(handles.imgDensity(handles.bwTmp));
        handles.corticalBoneVolume = length(find(handles.bwTmp));
        handles.corticalBoneVolumeFractionOfCallus = length(find(handles.bwTmp)) / length(find(handles.bwContour));
        
        fprintf(fid,'%s\t',num2str(handles.info.SliceThickness));
        fprintf(fid,'%s\t',num2str(handles.callusVolume * handles.info.SliceThickness^3));
        fprintf(fid,'%s\t',num2str(handles.callusBoneVolume * handles.info.SliceThickness^3));
        fprintf(fid,'%s\t',num2str(handles.callusBoneVolumeFraction));
        fprintf(fid,'%s\t',num2str(handles.callusMeanVolumetricDensity));
        fprintf(fid,'%s\t',num2str(handles.corticalBoneVolume * handles.info.SliceThickness^3));
        fprintf(fid,'%s\t',num2str(handles.corticalBoneVolumeFractionOfCallus));
        fprintf(fid,'%s\n',num2str(handles.corticalTissueMineralDensity));
        
        fclose(fid);
        
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = guilakKneeSurface(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        [handles.outCortical,handles.outHeaderCortical] = scancoParameterCalculatorCortical(handles.img,handles.bwContour,handles.info,handles.threshold,get(handles.togglebuttonRobustThickness,'Value'));
        if exist(fullfile(handles.pathstr,'CorticalResults.txt'),'file') ~= 2
            fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
            for i = 1:length(handles.outHeaderCortical)
                if i == length(handles.outHeaderCortical)
                    fprintf(fid,'%s\n',handles.outHeaderCortical{i});
                else
                    fprintf(fid,'%s\t',handles.outHeaderCortical{i});
                end
            end
%             fprintf(fid,'%s\n','Lower Threshold');
        end
        fid = fopen(fullfile(handles.pathstr,'CorticalResults.txt'),'a');
        for i = 1:length(handles.outCortical)
            if ~ischar(handles.outCortical{i})
                if i == length(handles.outCortical)
                    fprintf(fid,'%s\n',num2str(handles.outCortical{i}));
                else
                    fprintf(fid,'%s\t',num2str(handles.outCortical{i}));
                end
            else
                if i == length(handles.outCortical)
                    fprintf(fid,'%s\n',handles.outCortical{i});
                else
                    fprintf(fid,'%s\t',handles.outCortical{i});
                end
            end
        end
        fclose(fid);
        guidata(hObject, handles);
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function handles = loadTifStack(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        drawnow();
        pathstr = uigetdir(pwd,'Please select the folder containing your stack of TIF (or TIFF) images');
        files = dir(fullfile(pathstr,'*.tif*'));
        [file pth] = uigetfile('*.*', 'Select a DICOM file to use as a template or cancel to continue with dummy metadata');
        if file ~= 0
            info = dicominfo(fullfile(pth,file));
        else
            info.SliceThickness = 1;
        end
        handles.info = info;


        if length(files) > 1
            iminfo = imfinfo(fullfile(pathstr,files(1).name));
            for i = 1:length(files)
                handles.img(:,:,i) = imread(fullfile(pathstr,files(i).name));
                set(handles.textPercentLoaded,'String',num2str(i/length(files)));
                drawnow();            
            end
        elseif length(files) == 1
            iminfo = imfinfo(fullfile(pathstr,files(1).name));
            numImages = numel(iminfo);
            for i = 1:numImages
                handles.img(:,:,i) = imread(fullfile(pathstr,files(1).name),i);
                set(handles.textPercentLoaded,'String',num2str(i/numImages));
                drawnow();
            end
        end
        handles.img = uint16(handles.img);
        handles.img = handles.img .* (((2^16) - 1)/((2^iminfo(1).BitDepth) - 1 ));
        
        handles.pathstr = pathstr;
        
        
            
        cameratoolbar('Show');
    
        handles.dataMax = max(max(max(handles.img)));
    
        handles.windowWidth = max(max(max(handles.img))) - min(min(min(handles.img)));
        set(handles.editWindowWidth,'String',num2str(handles.windowWidth));

        handles.abc = size(handles.img);

        handles.windowLocation = round(handles.windowWidth / 2);
        set(handles.editWindowLocation,'String',num2str(handles.windowLocation));

        set(handles.editScaleImageSize,'String',num2str(handles.imgScale));

        handles.primitiveCenter(1) = round(handles.abc(2)/2);
        handles.primitiveCenter(2) = round(handles.abc(1)/2);

        set(handles.textCurrentDirectory,'String',handles.pathstr);

        handles.upperThreshold = max(max(max(handles.img)));
        set(handles.textUpperThreshold,'String',num2str(handles.upperThreshold));

        set(handles.sliderIMG,'Value',1);
        set(handles.sliderIMG,'min',1);
        set(handles.sliderIMG,'max',handles.abc(3));
        set(handles.sliderIMG,'SliderStep',[1,1]/(handles.abc(3)-1));

        handles.theMax = double(max(max(max(handles.img))));
        handles.hOut = 1;%handles.theMax / 2^15;
        handles.lOut = 0;
        set(handles.sliderThreshold,'Value',1);
        set(handles.sliderThreshold,'min',1);
        set(handles.sliderThreshold,'max',handles.theMax);
        set(handles.sliderThreshold,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

        set(handles.sliderWindowWidth,'Value',1);
        set(handles.sliderWindowWidth,'min',1);
        set(handles.sliderWindowWidth,'max',handles.theMax);
        set(handles.sliderWindowWidth,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

        set(handles.sliderWindowLocation,'Value',1);
        set(handles.sliderWindowLocation,'min',1);
        set(handles.sliderWindowLocation,'max',handles.theMax);
        set(handles.sliderWindowLocation,'SliderStep',[1,round(handles.theMax/1000)] / (handles.theMax));

        % imshowpair(imadjust(handles.img(:,:,handles.slice),[double(handles.lOut);double(handles.hOut)],[double(0);double(1)]),handles.bwContour(:,:,handles.slice),'blend','Parent',handles.axesIMG);
        set(handles.textVoxelSize,'String',num2str(handles.info.SliceThickness));

        set(gcf,'menubar','figure');
        set(gcf,'toolbar','figure');
        
        set(handles.textBusy,'String','Not Busy');
    
%         guidata(hObject, handles);
            
    catch
        set(handles.textBusy,'String','Failed');
    end

function [handles] = skeletonizationAnalysis(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        drawnow();
        
        %generates uncorrected skeleton
        handles.bwSkeleton = Skeleton3D(handles.bwContour);
        [handles.A handles.node handles.link] = Skel2Graph3D(handles.bwSkeleton,str2num(get(handles.editRadius,'String')));
        [w l h] = size(handles.bwSkeleton);
        handles.bwSkeleton = Graph2Skel3D(handles.node,handles.link,w,l,h);
        
        hfig = figure;
        set(hfig,'Visible','off')
        shp = shpFromBW(handles.bwContour,2);
        plot(shp,'FaceColor','w','FaceAlpha',0.3,'LineStyle','none');
        camlight();
        hold on;
        handles.bwDist = bwdist(~handles.bwContour);
        handles.bwDist(~handles.bwSkeleton) = 0;
        handles = reduceDistanceMap(handles,hObject);
        [r c v] = ind2sub(size(handles.bwDist),find(handles.bwDist));
        xyzUlt = [r c v];
        for i = 1:length(xyzUlt)
            rads(i) = handles.bwDist(xyzUlt(i,1),xyzUlt(i,2),xyzUlt(i,3));%find xyz coords of the local maxima
        end
        [rads I] = sort(rads,'ascend');
        xyzUlt = xyzUlt(I,:);
        [x y z] = sphere();
        Y = discretize(rads,64);
        cmap = jet(64);
        for i = 1:length(rads)
            set(handles.textPercentLoaded,'String',num2str(i/length(rads)));
            drawnow();
            surf((x*rads(i)+xyzUlt(i,1)),(y*rads(i)+xyzUlt(i,2)),(z*rads(i)+xyzUlt(i,3)),'LineStyle','none','FaceColor',cmap(Y(i),:));
            axis tight;
            drawnow();
        end
        hold off;
        saveas(hfig,fullfile(handles.pathstr,'SkeletonizedFigure.fig'));
        
        for i = 1:length(handles.link)
            clear px py pz;
            out(i).nodes = [handles.link(i).n1,handles.link(i).n2];
            out(i).nodeLocs(1,:) = [handles.node(handles.link(i).n1).comx,handles.node(handles.link(i).n1).comy,handles.node(handles.link(i).n1).comz];
            out(i).nodeLocs(2,:) = [handles.node(handles.link(i).n2).comx,handles.node(handles.link(i).n2).comy,handles.node(handles.link(i).n2).comz];
            for k = 1:length(handles.link(i).point)
                [px(k) py(k) pz(k)] = ind2sub(size(handles.bwSkeleton),handles.link(i).point(k));
            end
            out(i).points = [px' py' pz'];
            for k = 1:length(out(i).points(:,1))
                out(i).rads(k) = double(handles.bwDist(out(i).points(k,1),out(i).points(k,2),out(i).points(k,3)));
            end
            out(i).rads = out(i).rads(find(out(i).rads));
            %convert to physical units
            out(i).nodeLocs = out(i).nodeLocs .* handles.info.SliceThickness;
            px = px  .* handles.info.SliceThickness;
            py = py  .* handles.info.SliceThickness;
            pz = pz  .* handles.info.SliceThickness;
            out(i).points = out(i).points  .* handles.info.SliceThickness;
            out(i).rads = out(i).rads  .* handles.info.SliceThickness;
%           %calculate length of snake
            for k = 1:length(px)
                if k == 1
                    out(i).length = 0;
                else
                    out(i).length = out(i).length + sqrt((px(k) - px(k-1))^2 + (py(k) - py(k-1))^2 + (pz(k) - pz(k-1))^2);
                end
            end
        end
        
        

        outHeader = {'File','Date','Nodes','Node Locations','Link Length','Mean Link Radius','STD Link Radius','Link Points'};
        fid = fopen(fullfile(handles.pathstr,'SkeletonizationResults.txt'),'w');
        for i = 1:length(outHeader)
            if i ~= length(outHeader)
                fprintf(fid,'%s\t',outHeader{i});
            else
                fprintf(fid,'%s\n',outHeader{i});
            end
        end
        
        for i = 1:length(out)
            if ~isempty(out(i).rads)
                fprintf(fid,'%s\t',handles.pathstr);
                fprintf(fid,'%s\t',datestr(now));
                fprintf(fid,'%s\t',[num2str(out(i).nodes(1)) ',' num2str(out(i).nodes(2))]);
                for k = 1:length(out(i).nodeLocs(:,1))
                    if k ~= length(out(i).nodeLocs(:,1))
                        fprintf(fid,'%s',[num2str(out(i).nodeLocs(k,:)) ';']);
                    else
                        fprintf(fid,'%s\t',num2str(out(i).nodeLocs(k,:)));
                    end
                end
                fprintf(fid,'%s\t',num2str(out(i).length));
                fprintf(fid,'%s\t',num2str(mean(out(i).rads)));
                fprintf(fid,'%s\t',num2str(std(out(i).rads)));
                for k = 1:length(out(i).points)
                    if k ~= length(out(i).points)
                        fprintf(fid,'%s',[num2str(out(i).points(k,:)) ';']);
                    else
                        fprintf(fid,'%s\n',num2str(out(i).points(k,:)));
                    end
                end
                
            end
        end
        fclose(fid);    


%         %corrects skeleton to join sections within a user-specified
%         %distance
%         handles.bwDist = bwdist(handles.bwContour);
%         handles.bwDist(handles.bwContour) = max(max(max(handles.bwDist)));
        
        
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    
function [handles] = distanceMap(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        drawnow();
        
        handles.bwDist = bwdist(handles.bwContour);
        handles.imgOrig = handles.img;
        handles.img = uint16(handles.bwDist);
        
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
        
function writeToTiff(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        drawnow();
        mkdir(fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']));
        zers = '000000';
        [a b c] = size(handles.img);
        for i = 1:c
            slice = num2str(i);
            len = length(slice);
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow();
            pathTmp = fullfile(handles.pathstr,[handles.DICOMPrefix 'TIF']);
            fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.tif'];
            imwrite(handles.img(:,:,i),fullfile(pathTmp,fName));
        end
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end
    

function [handles] = reduceDistanceMap(handles,hObject)
    try
        set(handles.textBusy,'String','Busy');
        drawnow();
        maxRad = max(max(max(handles.bwDist)));
        
        %pad array to account for radius
        handles.bwDist = padarray(handles.bwDist,[double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2) double(2*ceil(maxRad)+2)]);
        
        initLen = length(find(handles.bwDist));
        [x y z] = ind2sub(size(handles.bwDist),find(handles.bwDist));
        [aa bb cc] = size(handles.bwDist);
        handles.bwDistReshaped = reshape(handles.bwDist,[aa*bb*cc,1]);
        [handles.bwDistSorted I]= sort(handles.bwDistReshaped,'descend');
        [handles.bwDistSorted] = handles.bwDistSorted(find(handles.bwDistSorted));
        [x2 y2 z2] = ind2sub(size(handles.bwDist),I(1:length(handles.bwDistSorted)));
       

        for i = 1:length(x2)
            if mod(i,50) == 0 || i == length(x2)
                set(handles.textPercentLoaded,'String',num2str(i/length(x2)));
                drawnow(); 
            end
            if handles.bwDist(x2(i),y2(i),z2(i)) > 0

                radToTest = handles.bwDist(x2(i),y2(i),z2(i));

                bw3 = false(size(handles.bwDist));
%                 bw3(x2(i),y2(i),z2(i)) = 1;
%                  bw3 = imdilate(bw3,true([2*ceil(maxRad)+1,2*ceil(maxRad)+1,2*ceil(maxRad)+1]));
                bw3(((x2(i)-(2*ceil(maxRad)+1)):(x2(i)+(2*ceil(maxRad)+1))),...
                    ((y2(i)-(2*ceil(maxRad)+1)):(y2(i)+(2*ceil(maxRad)+1))),...
                    ((z2(i)-(2*ceil(maxRad)+1)):(z2(i)+(2*ceil(maxRad)+1)))) = 1;
                [a1 b1 c1] = ind2sub(size(bw3),find(bw3));

                radsTesting = handles.bwDist(bw3);

                ds = sqrt((a1-x2(i)).^2 + (b1-y2(i)).^2 + (c1-z2(i)).^2);%location of cube - location of radius
                rirj = radToTest + radsTesting;

                inds = rirj >= ds;% find spheres that intersect
                [thisMax I] = max(radsTesting(inds));
                inds = [a1(inds),b1(inds),c1(inds)];
                if radToTest >= thisMax
                    inds2 = inds == [x2(i),y2(i),z2(i)];
                    for j = 1:length(inds2)
                        if inds2(j,1) == 1 && inds2(j,2) == 1 && inds2(j,3) == 1
                            inds(j,:) = [];
                        end
                    end
                else
                    inds(I,:) = [];
                end
                for j = 1:length(inds)
                    handles.bwDist(inds(j,1),inds(j,2),inds(j,3)) = 0;
                end

            end

        end
        
        %remove padding
        handles.bwDist = handles.bwDist((2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2),...
            (2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2),...
            (2*ceil(maxRad)+2):end-(2*ceil(maxRad)+2));
 
        set(handles.textBusy,'String','Not Busy');
    catch
        set(handles.textBusy,'String','Failed');
    end


% --- Executes on selection change in popupmenuMaskComponents.
function popupmenuMaskComponents_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuMaskComponents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuMaskComponents contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuMaskComponents


% --- Executes during object creation, after setting all properties.
function popupmenuMaskComponents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuMaskComponents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPopulateMaskComponents.
function pushbuttonPopulateMaskComponents_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPopulateMaskComponents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    set(handles.textBusy,'String','Busy');
    handles.cc = bwconncomp(handles.bwContour);
    for i = 1:length(handles.cc.PixelIdxList)
        connCompInd{i} = num2str(i);
        set(handles.textPercentLoaded,'String',num2str(i/length(handles.cc.PixelIdxList)));
        drawnow(); 
    end
    set(handles.popupmenuMaskComponents,'String',connCompInd);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
catch
    set(handles.textBusy,'String','Failed');
end

function writeCurrentImageStackToDICOM(handles,hObject)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    [a b c] = size(handles.img);
    
    zers = '00000';
    handles.info.Rows = a;
    handles.info.Columns = b;
    handles.info.InstitutionName = 'Washington University in St. Louis';
    handles.info.SliceThickness = handles.info.SliceThickness / handles.imgScale;
    handles.info.Height = a;
    handles.info.Width = b;
    handles.info.PixelSpacing = [handles.info.SliceThickness;handles.info.SliceThickness];
    handles.info.PixelSpacing = handles.info.PixelSpacing .* handles.imgScale;
    handles.info.StudyDescription = handles.DICOMPrefix;
    
    
    %for ZEISS scans
    if ~isempty(strfind(handles.info.Manufacturer,'Zeiss'))
        mkdir(fullfile(handles.pathstr, handles.DICOMPrefix));
        tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
        tmp = dicominfo(fullfile(pwd,'ZeissDICOMTemplate.dcm'));%read info from a known working Zeiss DICOM
        tmp2 = tmp;
        for i = 1:c
            tmp2.FileName = [handles.DICOMPrefix zers(1:end - length(num2str(i))) num2str(i) '.dcm'];
            tmp2.Rows = handles.info.Rows;
            tmp2.Columns = handles.info.Columns;
            tmp2.InstitutionName = handles.info.InstitutionName;
            tmp2.SliceThickness = handles.info.SliceThickness;
            tmp2.Height = handles.info.Height;
            tmp2.Width = handles.info.Width;
            tmp2.PixelSpacing = handles.info.PixelSpacing;
            tmp2.StudyDescription = handles.info.StudyDescription;
            tmp2.KVP = handles.info.KVP;
            zers2 = '000000';
            slice = num2str(i);
            len = length(slice);
            tmp2.MediaStorageSOPInstanceUID = ['1.2.826.0.1.3680043.8.435.3015486693.35541.' zers(1:end-len) num2str(i)];
            tmp2.SOPInstanceUID = tmp2.MediaStorageSOPInstanceUID;
            tmp2.PatientName.FamilyName = handles.DICOMPrefix;
            tmp2.ImagePositionPatient(3) = tmp2.ImagePositionPatient(3) + tmp2.SliceThickness;
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow(); 
            fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),tmp2);
        end
    elseif ~isempty(strfind(handles.info.Manufacturer,'SCANCO'))
        mkdir(fullfile(handles.pathstr,handles.DICOMPrefix));
        tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
        %sort out info struct for writing; dicomwrite won't write private fields
        tmp = handles.info;
        if isfield(tmp,'Private_0029_1000')%identifies as Scanco original DICOM file
            handles.info.ReferringPhysicianName.FamilyName = num2str(tmp.Private_0029_1004);%will be slope for density conversion
            handles.info.ReferringPhysicianName.GivenName = num2str(tmp.Private_0029_1005);%intercept
            handles.info.ReferringPhysicianName.MiddleName = num2str(tmp.Private_0029_1000);%scaling
            handles.info.ReferringPhysicianName.NamePrefix = num2str(tmp.Private_0029_1006);%u of water
        end
        for i = 1:c
            if i == 1
                info = handles.info;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
            else
                info.SliceLocation = info.SliceLocation + info.SliceThickness;
                info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
                %         info.MediaStorageSOPInstanceUID = num2str(str2num(info.MediaStorageSOPInstanceUID) + 1);
                %         info.SOPInstanceUID = num2str(str2num(info.SOPInstanceUID) + 1);
                
            end
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow(); 
            fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),info);
        end
    else
        mkdir(fullfile(handles.pathstr,handles.DICOMPrefix))
        tmpDir = fullfile(handles.pathstr,handles.DICOMPrefix);
        %sort out info struct for writing; dicomwrite won't write private fields
        tmp = handles.info;
        for i = 1:c
            if i == 1
                info = handles.info;
                info.SliceLocation = 1;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i) '.dcm']);
            else
                info.SliceLocation = info.SliceLocation + info.SliceThickness;
                info.ImagePositionPatient = info.ImagePositionPatient + info.SliceThickness;
                info.FileName = fullfile(handles.pathstr,[handles.DICOMPrefix zers(1:end-length(num2str(i))) num2str(i)  '.dcm']);
                %         info.MediaStorageSOPInstanceUID = num2str(str2num(info.MediaStorageSOPInstanceUID) + 1);
                %         info.SOPInstanceUID = num2str(str2num(info.SOPInstanceUID) + 1);
                
            end
            set(handles.textPercentLoaded,'String',num2str(i/c));
            drawnow(); 
            fName = [handles.DICOMPrefix '-' zers(1:end-length(num2str(i))) num2str(i)  '.dcm'];
            dicomwrite(handles.img(:,:,i),fullfile(tmpDir,fName),info);
        end
        
    end
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end


function saveCurrentImage(handles,hObject)

try
    set(handles.textBusy,'String','Busy');
    guidata(hObject, handles);
    drawnow();
    outFile = fullfile(handles.pathstr,[get(handles.editDICOMPrefix,'String') '.tif']);
    imwrite(getimage(handles.axesIMG),outFile);
    set(handles.textBusy,'String','Not Busy');
    guidata(hObject, handles);
    drawnow();
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end

function generateHistogram(handles,hObject)

    try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        [a b c] = size(handles.img);
        img = reshape(handles.img,[1,a*b*c]);
        figure;
        histogram(img(find(img > 0)),320);
        set(handles.textBusy,'String','Not Busy');
        guidata(hObject, handles);
        drawnow();
    catch
        set(handles.textBusy,'String','Failed');
        guidata(hObject, handles);
        drawnow();
    end


% --- Executes on button press in pushbuttonSetMaskByClicking.
function pushbuttonSetMaskByClicking_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMaskByClicking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
        set(handles.textBusy,'String','Busy');
        guidata(hObject, handles);
        drawnow();
        [x y] = getpts(handles.axesIMG);
        z(1:length(x),1) = handles.slice;
        pt = round([y x z]);%points to use to select mask component
        cc = bwconncomp(handles.bwContour);
        removeFlag = zeros(length(cc.PixelIdxList),length(pt(:,1)));
        for i = 1:length(cc.PixelIdxList)
            [idxx idxy idxz] = ind2sub(size(handles.bwContour),cc.PixelIdxList{i});
            idx = [idxx idxy idxz];
            for k = 1:length(pt(:,1))
               if length(find(ismember(pt(k,:),idx,'rows'))) == 0
                   removeFlag(i,k) = 1;
               end
            end
            set(handles.textPercentLoaded,'String',num2str(i/length(cc.PixelIdxList)));
            drawnow(); 
        end
        
        for i = 1:length(removeFlag)
            if sum(removeFlag(i,:)) == length(removeFlag(i,:))
                handles.bwContour(cc.PixelIdxList{i}) = 0;
            end
        end
        
        updateImage(hObject,eventdata,handles);
        
        set(handles.textBusy,'String','Not Busy');
        guidata(hObject, handles);
        drawnow();
        
catch
    set(handles.textBusy,'String','Failed');
    guidata(hObject, handles);
    drawnow();
end