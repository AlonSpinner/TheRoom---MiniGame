%this code here will draw an interactive picture of a house
%Criterions could be found in course moodle under project part 1 and 2

%REMARKS:
%DO NOT USE TRACKPAD. IT CANT REGISTER TOGTHER WITH KEYBOARD CLICKS

%-------------UserData on Graphics
%SelectedHandle - [Patch handle] - contains patch of interest (selected one)
%PrimeFig.UserData - [Bool] - "Mouse Down" - 1 if mouse is pressed down, 0 otherwise
%PrimeAx.UserData.ItemsPlaced - [Text handle] - amount of furnitures set in
%room 
%PrimeAx.UserData.Foundations - [Struct of numeric values] - witholds information of walls,
%floor and ceiling of the house
%PrimeAx.UserData.Edges - [numeric vector 1X3] - 1 if all edges shown, 2 if none, 3 if only
%box edges
%PrimeAx.UserData.TextItemsPlaced - [Text handle] manifests in SubAx
%PrimeAx.UserData.TextView - [Text handle] manifests in SubAx
%PrimeAx.UserData.TextProj - [Text handle] manifests in SubAx
%PrimeAx.UserData.TextCameraLock - [Text handle] manifests in SubAx
%PrimeAx.UserData.TextEdges - [Text handle] manifests in SubAx
%-------------

%-------------Parent Tree:
%Furniture - Object(Patch)<Transformation(Furniture)<Axies<Figure
%first child of a transformation is always the red/black box
%PrimeFig.Children=[PrimeAx;SubAx] - first child is PrimeAx
%-------------

%-------------Rationatl:
%Game window size is adapted to the monitor
%SelectedHandle obtained by gco (returns patch object) or keyboard input
%Each furniture is reperesented by a Transformation with a given DisplayName, and a
%frame
%Red frame - room furniture, Black frame - storage furniture
%Selected room furniture is recognised by a visible frame
%User input orianted actions are implimented only on selected furniture
%(no deletion and recreation of axies/figure are done)
%in order to check for limitations on furniture placement, the code
%knows to look through all room transformations (pointed out by a red frame)
%ItemsPlaced is updated after each deletion/setting of furniture
%It is done by: length(All the room furnitures)
%PrimeAx graphics holds all text handles that manifest in SubAx
%-------------

%----------------additional:
%there is no DrawingCB as taught in classroom. 
%In this code, furnitures are not being redrawn per use of transforamtion - the Transformation Matrix is
%updated instead.
%-------------

%60+ functions devided into catagories
%---------------------------------------------
%Boot
function AlonSpinner_Project2()
%Booting function - clear/closeall/clc
%will build house (see BuildHouse function)

%For code person to decide if he wants these on or not.
close all
clc

BuildHouse;
end

%initalizing
function BuildHouse
%Output:
%Create a figure with internal axes: x=[0 2],y=[0 1]
%house will be built in x=[0 2],y=[0 0.95]
%Build Foundations: Floor,Walls,Ceilling,Partition and Text labels
%Build Storage: Table,Couch,Mirror,Lamp,BookShelf
%creates ItemsPlaced global variable struct which holds both numeric value and
%a handle for the text
%Initalize global variable SelecctedHandle

%------Initialize Window
%adjust created figure to monitor:
ScreenSize=get(0,'ScreenSize');
figureH=0.7*ScreenSize(4);
figureW=2*figureH;
figureL=(ScreenSize(3)-figureW)/2;
figureB=(ScreenSize(4)-figureH)/2;
PrimeFig=figure('Position',[figureL,figureB,figureW,figureH],...
    'name','AlonSpinner 305184335','Pointer','hand','color',...
    CustomColors('White'),'ToolBar','none','MenuBar','none','numbertitle','off');

%------create axies
SubAx=axes('units','normalized','position',[0,0,1,1],...
    'Xlim',[0,2],'Ylim',[0 1],'Xtick',[],'Ytick',[],'HitTest','off','color',CustomColors('BlueGray')); 
PrimeAx=axes('units','normalized','Position',[0.1,0.1,0.8,0.8],...
    'Xlim',[0,2],'Ylim',[0 1],'Zlim',[0 1.5],'Xtick',[],'Ytick',[],'Ztick',[],...
    'HitTest','off','color',CustomColors('ClayOrange'));

%fix aspect ratio
daspect(PrimeAx,[1,1,1]);
daspect(SubAx,[1,1,1]);
%------

%------CallBack inputs
set(PrimeFig,'KeyPressFcn',@KeyBoardCB);
set(PrimeFig,'WindowButtonDownFcn',@MouseDownCB);
set(PrimeFig,'WindowButtonMotionFcn',@MouseMoveCB);
set(PrimeFig,'WindowButtonUpFcn',@MouseUpCB);
%------

%initalize PrimeFig.UserData
PrimeFig.UserData=0; %0 for mouse up and 1 for mouse down

%-----initalize PrimeAx.UserData
%SelectedHandle 
%creates a deleted handle. is important for TabFurniture function
PrimeAx.UserData.SelectedHandle=hgtransform;
delete(PrimeAx.UserData.SelectedHandle);

%Proj
Proj.Type={'Orthographic','Perspective'}; %cell of strings. rotates via circshift
Proj.View='Camera'; %[char], of values:'Isometric','Top','Right','Camera'
Proj.CameraLock=0; %[Bool] - 1 = locked camera: cant move with arrows
Proj.Phi=-45; %[degree]
Proj.Theta=90-35.26439; %[degree]
Proj.R=3.3; %[radius of camera] %HAS TO BE SET THIS WAY FOR ISOMETRIC PRESPECTIVE TO FIT
Proj.CameraMemory=[]; %initalize
PrimeAx.UserData.Proj=Proj; %Set Proj struct into User Data

%Foundations
Foundations.PartitionL=1.4; %Partition Left
Foundations.WallW=0; %Wall Width
Foundations.CeilW=0; %Ceilling Width
Foundations.FloorW=0.05; %Floor Width
PrimeAx.UserData.Foundations=Foundations; %Set Foundations struct in User Data

%Edges
PrimeAx.UserData.Edges=[1,2,3];

%space between SubAx texts coordinates on Y axis
TextSpace=0.035; 

%TextItemsPlaced - set text on SubAx
TextItemsPlaced=text(0.02,0.975,'Items Placed: 0','FontSize',12,'Parent',SubAx);
PrimeAx.UserData.TextItemsPlaced=TextItemsPlaced; %Set TextItemsPlaced text handle in User Data

%TextView- set text on SubAx
%IMPORTANT: INITAL TEXT IS SET TO ISOMETRIC, BUT INITAL VIEW IS SET TO CAMERA
TextView=text(0.02,0.975-TextSpace,'View Type: Isometric','FontSize',12,'Parent',SubAx);
PrimeAx.UserData.TextView=TextView; %Set TextView text handle in User Data

%TextProj - set text on SubAx
TextProj=text(0.02,0.975-2*TextSpace,'Projection Type: Orthographic','FontSize',12,'Parent',SubAx);
PrimeAx.UserData.TextProj=TextProj; %Set TextEdges text handle in User Data

%TextCameraLock - set text on SubAx
TextCameraLock=text(0.02,0.975-3*TextSpace,'Camera Lock: No','FontSize',12,'Parent',SubAx);
PrimeAx.UserData.TextCameraLock=TextCameraLock; %Set TextEdges text handle in User Data

%TextEdges - set text on SubAx
TextEdges=text(0.02,0.975-4*TextSpace,'Edges Shown: All','FontSize',12,'Parent',SubAx);
PrimeAx.UserData.TextEdges=TextEdges; %Set TextEdges text handle in User Data
%------

%Text: "Press H for Help" - set text on SubAx
text(1.75,0.975,'Press H for Help','FontSize',12,'Parent',SubAx);

%Set inital projection
SetProjection(PrimeAx);
 
%Build Structure and storage furnitures
BuildStructureFoundations(PrimeAx);
BuildStorage(PrimeAx);
end

%Projection
function SetProjection(PrimeAx)
%Input: PrimeAx - axes of main picture
%Output: ReSets projections and camera orientiation depending on parameters
%set in PrimeAx

%Obtain Proj struct
Proj=PrimeAx.UserData.Proj;

%Set projection type
set(PrimeAx,'Projection',Proj.Type{1});

%set up the camera
RoomCenterX=mean(PrimeAx.XLim);
RoomCenterY=mean(PrimeAx.YLim);
RoomCenterZ=mean(PrimeAx.ZLim);
CamX=Proj.R*sind(Proj.Theta)*sind(Proj.Phi)+RoomCenterX; 
CamY=Proj.R*cosd(Proj.Theta)+RoomCenterY; 
CamZ=Proj.R*sind(Proj.Theta)*cosd(Proj.Phi)+RoomCenterZ;
UpX=-cosd(Proj.Theta)*sind(Proj.Phi);
UpY=sind(Proj.Theta);
UpZ=-cosd(Proj.Theta)*cosd(Proj.Phi);
set(PrimeAx,'CameraPosition',[CamX,CamY,CamZ],'CameraTarget',[RoomCenterX RoomCenterY RoomCenterZ],...
    'CameraUpVector',[UpX,UpY,UpZ],'CameraViewAngle',40);
end

%Lighting - NOT BEING USED:
function SetLight(PrimeAx,Position)
%Input: 
%PrimeAx - main axis of game
%Position - [numeric vector 1x3] - position XYZ of light

%Output:
%set local light in inputed position 

LightColor='Yellow';

light(PrimeAx,'Position',Position,'Color',CustomColors(LightColor),'Style','infinite');
end
function Position=FindLightPosition(LampTrans)
%Input:
%LampTrans - hgtransform

%Output:
%Position - [numeric vector 1x3] - position XYZ of light

%Obtain Bounding Box
Box=LampTrans.Children(1);
X=Box.XData;
Y=Box.YData;
Z=Box.ZData;

%Obtain initail position
Position=[mean2(X),min(min(Y))-eps,mean2(Z),1];

%Transform
Position=LampTrans.Matrix*Position';

%Return Value
Position=(Position(1:3))';
end

%Prevelant use Drawings functions
function [FTrans]=DrawingFurniture(PrimeAx,ObjectName,ObjectBound,BoxColor)
%Input:
%ObjectName - string of the name of object to be drawn
%ObjectBound - numeric array with [L,B,W,H] coordinates
%BoxColor - string of the name with which the box should be colored

%Output
%Draws Called item in specified location by ObjectBound
%Will draw a box around object. red - room, black-storage
%Will set drawn furniture with a transformation matrix for later use
%Will alert coder if Item asked to draw is not in store
%HandleGroup - handlegroup representing the furniture just drawn

%Parent Tree:
%Object<Transformation<Axies

%-----Drawing furniture-----%

switch ObjectName
    case 'Table'
        FTrans=DrawTable(PrimeAx,ObjectBound);
    case 'Couch'
        FTrans=DrawCouch(PrimeAx,ObjectBound);
    case 'Mirror'
        FTrans=DrawMirror(PrimeAx,ObjectBound);
    case 'Lamp'
        FTrans=DrawLamp(PrimeAx,ObjectBound);
    case 'BookShelf'
        FTrans=DrawBookShelf(PrimeAx,ObjectBound);
    otherwise
        errordlg([ObjectName,' is not in store']);
end

%-----Edge Setup----%
%if user decided edges should be off, create furniture with invisble edges
if PrimeAx.UserData.Edges(1)~=1
    for i=1:length(FTrans.Children)
        FTrans.Children(i).EdgeAlpha=0;
    end
end

%-----Box Setup-----%
%Draw box and set HandleGroup as parent
if nargin<4
    BoxColor='Red'; %if color isnt declared,it will be set to red
end
Box=DrawBox(PrimeAx,ObjectBound,BoxColor);
Box.Parent=FTrans;
end
function [BoxHandle]=DrawBox(PrimeAx,ObjectBound,BoxColor)
%Input:
%PrimeAx - prime axies of game
%object bound is [L,B,D,W,H,T] ~
%[left,buttom,depth,width,height,thickness]
%BoxColor - color of edges of box

%Output:
%Draws a surrounding lined box around the bounding box and returns the
%handle. if color isnt declared, box will be red
% "Dist" is the space between two parallel lines of these boxes

%set FaceColor
FaceColor='none';

%Enlarge ObjectBound
BoxDist=ObjectBound(4:6)*0.1;
ObjectBound(4:6)=ObjectBound(4:6)+BoxDist;
ObjectBound(1:3)=ObjectBound(1:3)-0.5*BoxDist;

BoxHandle=DrawCube(PrimeAx,ObjectBound,BoxColor,FaceColor);
BoxHandle.LineWidth=2;
BoxHandle.DisplayName='Box';
end
function [CVector]=CustomColors(CName)
%Input:
%CustomColors - string containing color name

%Output:
%CVector - numeric vector reperesting input color

switch CName
    case 'White'
        CVector=[1,1,1];
    case 'Red'
        CVector=[1,0,0];
    case 'Pink'
        CVector=[1,0.4,0.5];
    case 'Green'
        CVector=[0,1,0];
    case 'Blue'
        CVector=[0,0,1];
    case 'Yellow'
        CVector=[1,1,0];
    case 'BlueGray'
        CVector=[0.7, 0.9, 0.95];
    case 'Silver'
        CVector=[0.85,0.85,0.85];
    case 'ClayOrange'
        CVector=[0.7500, 0.4250, 0.1980];
    case 'DuskOrange'
        CVector=[0.9290, 0.6940, 0.1250];
    case 'NicePurple'
        CVector=[0.4940, 0.1840, 0.5560];
    case 'LightGreen'
        CVector=[0.4660, 0.6740, 0.1880];
    case 'LightBlue'
        CVector=[0.3010, 0.7450, 0.9330];
    case 'CouchRed'
        CVector=[0.6350, 0.0780, 0.1840];
    case 'DarkGreen'
        CVector=[0.05, 0.2, 0];
    case 'Black'
        CVector=[0, 0, 0];
    otherwise
        CVector=[0, 0, 0];
end
end

%Drawing for house setup
function BuildStructureFoundations(PrimeAx)
%Input:
%none

%Output:
%Will draw floor, partition.

%Obtain Foundations struct from UserData
Foundations=PrimeAx.UserData.Foundations;

%Build Partition
DrawPartition(PrimeAx,Foundations.PartitionL,Foundations.FloorW);

%Build Floor
DrawFloor(PrimeAx,Foundations.FloorW);

%Build Scene Bounding Box
DrawBoundingBox(PrimeAx);

%----Current desicion: no need to label room and storage
% %Text: "Room"
% text(PrimeAx,0.02,1-Foundations.CeilW-0.02,'Room','FontSize',15)
% 
% %Text: "Storage"
% text(PrimeAx,Foundations.PartitionL+0.02,1-Foundations.CeilW-0.02,'Storage','FontSize',15)
end
function DrawFloor(PrimeAx,FloorW)
%Input:
%FloorW - Width of floor

%Output:
%Draws the Floor onto house

%Color Choice
FloorColor='DuskOrange';

%Draw Floor
XFloor=PrimeAx.XLim;
YFloor=[0,FloorW];
ZFloor=PrimeAx.ZLim;
FloorBound=[XFloor(1);YFloor(1);ZFloor(1);XFloor(2)-XFloor(1);YFloor(2)-YFloor(1);ZFloor(2)-ZFloor(1)];
FloorHandle=DrawCube(PrimeAx,FloorBound,'Black',FloorColor);
FloorHandle.PickableParts='no';
end
function DrawPartition(PrimeAx,PartitionL,FloorW)
%Input:
%PartitionL - X coordinate of partition center
%PartitionW - Width of partition

%Output:
%Draws the partition onto house

%Color Choice
PartitionColor='Black';

%Draw Floor
X=PartitionL*ones(1,4);
Y=[FloorW,PrimeAx.YLim(2),PrimeAx.YLim(2),FloorW];
Z=[PrimeAx.ZLim(1),PrimeAx.ZLim(1),PrimeAx.ZLim(2),PrimeAx.ZLim(2)];
V=[X;Y;Z]';
F=1:4;
PartitionHandle=patch('Faces',F,'Vertices',V,'Parent',PrimeAx,'Facecolor',CustomColors(PartitionColor));
PartitionHandle.PickableParts='no';
PartitionHandle.FaceAlpha=0.2;
PartitionHandle.DisplayName='Partition';
end
function DrawBoundingBox(PrimeAx)
Xlim=PrimeAx.XLim;
Ylim=PrimeAx.YLim;
Zlim=PrimeAx.ZLim;
SceneBound=[Xlim(1),Ylim(1),Zlim(1),Xlim(2)-Xlim(1),Ylim(2)-Ylim(1),Zlim(2)-Zlim(1)];
SceneHandle=DrawCube(PrimeAx,SceneBound,'Black','none');
%set as box with specific tag so edges will all always be displayed
SceneHandle.DisplayName='SceneBound';
SceneHandle.LineWidth=2;
end
function BuildStorage(PrimeAx)
%will draw all the storage objects

%Obtain room Foundations
Foundations=PrimeAx.UserData.Foundations;

%Build Table
STableBound=[Foundations.PartitionL+0.2;Foundations.FloorW+0.15;0.5;0.2;0.2;0.2];
STableTrans=DrawingFurniture(PrimeAx,'Table',STableBound,'Black');
RotateY(STableTrans,+pi/1.5);
RotateZ(STableTrans,-pi/18)

%Build BookShelf
SBookShelfBound=[Foundations.PartitionL+0.28;Foundations.FloorW+0.36;0.1;0.2;0.15;0.05];
SBookShelfTrans=DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound,'Black');
RotateY(SBookShelfTrans,+pi/1.5);

%Build Mirror
SMirrorBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.4;0.3;0.08;0.25;0.01];
SMirrorTrans=DrawingFurniture(PrimeAx,'Mirror',SMirrorBound,'Black');
RotateY(SMirrorTrans,+pi/2.5);
RotateZ(SMirrorTrans,-pi/12)

%Build Couch
SCouchBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.08;1;0.4;0.20;0.17];
SCouchTrans=DrawingFurniture(PrimeAx,'Couch',SCouchBound,'Black');
RotateY(SCouchTrans,pi/24);
RotateZ(SCouchTrans,pi/12)

%Build Lamp
SLampBound=[Foundations.PartitionL+0.2;Foundations.FloorW+0.45;0.6;0.3;0.4;0.3];
SLampTrans=DrawingFurniture(PrimeAx,'Lamp',SLampBound,'Black');
end
function RoomExample_1(PrimeAx)
%Input: PrimeAx - main axis of game

%Output:
%Will draw an example for a room and update ItemsPlaced accordingly

%Obtain Foundations
Foundations=PrimeAx.UserData.Foundations;

%Obtain room measurements
XRoom=[PrimeAx.XLim(1),Foundations.PartitionL];
% YRoom=PrimeAx.YLim;
ZRoom=PrimeAx.ZLim;

%-----Tables
Table1A=0.08;
Table1Bound=[mean(XRoom)-Table1A/2;Foundations.FloorW;mean(ZRoom)-Table1A/2;...
    Table1A;Table1A;Table1A];
Table1Trans=DrawingFurniture(PrimeAx,'Table',Table1Bound);
Table1Trans.Children(1).Visible='off';

Table2A=0.15;
Table2Bound=[mean(XRoom)-Table2A/2;Foundations.FloorW;mean(ZRoom)-Table2A/2;...
    Table2A;Table2A;Table2A];
Table2Trans=DrawingFurniture(PrimeAx,'Table',Table2Bound);
Table2Trans.Children(1).Visible='off';

Table3A=0.25;
Table3Bound=[mean(XRoom)-Table3A/2;Foundations.FloorW;mean(ZRoom)-Table3A/2;...
    Table3A;Table3A;Table3A];
Table3Trans=DrawingFurniture(PrimeAx,'Table',Table3Bound);
Table3Trans.Children(1).Visible='off';

Table4A=0.4;
Table4Bound=[mean(XRoom)-Table4A/2;Foundations.FloorW;mean(ZRoom)-Table4A/2;...
    Table4A;Table4A;Table4A];
Table4Trans=DrawingFurniture(PrimeAx,'Table',Table4Bound);
Table4Trans.Children(1).Visible='off';

Table5A=0.6;
Table5Bound=[mean(XRoom)-Table5A/2;Foundations.FloorW;mean(ZRoom)-Table5A/2;...
    Table5A;Table5A;Table5A];
Table5Trans=DrawingFurniture(PrimeAx,'Table',Table5Bound);
Table5Trans.Children(1).Visible='off';

Table6A=0.9;
Table6Bound=[mean(XRoom)-Table6A/2;Foundations.FloorW;mean(ZRoom)-Table6A/2;...
    Table6A;Table6A;Table6A];
Table6Trans=DrawingFurniture(PrimeAx,'Table',Table6Bound);
Table6Trans.Children(1).Visible='off';
%------

%Update ItemsPlaced
TextItemsPlaced(6,PrimeAx);
end

%Drawing furniture
function [TableTrans]=DrawTable(PrimeAx,TableBound)
%Input:
%PrimeAx - main axis of game
%TableBound - numeric array with [L,B,D,W,H,T] coordinates

%Output:
%Draws Table onto house.
%Returns that handle of the transformation

%Create Transformation handle
TableTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
TableColor='NicePurple';

%------Draw Table
%Table Top
TopBound=TableBound;
TopBound(2)=TopBound(2)+0.8*TableBound(5);
TopBound(5)=0.2*TableBound(5);
Top=DrawCube(PrimeAx,TopBound,'Black',TableColor);
Top.Parent=TableTrans;

%------Table Legs
LegsR=0.05*mean([TableBound(4),TableBound(6)]);
LegsH=0.8*TableBound(5);
LegsFaceAmount=8;

%Leg1
Leg1Pos=[TableBound(1)+0.1*TableBound(4);TableBound(2);TableBound(3)+0.1*TableBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,TableColor);
Leg1Handle.Parent=TableTrans;

%Leg2
Leg1Pos=[TableBound(1)+0.1*TableBound(4);TableBound(2);TableBound(3)+0.9*TableBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,TableColor);
Leg1Handle.Parent=TableTrans;

%Leg3
Leg1Pos=[TableBound(1)+0.9*TableBound(4);TableBound(2);TableBound(3)+0.1*TableBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,TableColor);
Leg1Handle.Parent=TableTrans;

%Leg4
Leg1Pos=[TableBound(1)+0.9*TableBound(4);TableBound(2);TableBound(3)+0.9*TableBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,TableColor);
Leg1Handle.Parent=TableTrans;
%------
%------

set(TableTrans,'DisplayName','Table');
end
function [BookShelfTrans]=DrawBookShelf(PrimeAx,BookShelfBound)
%Input:
%PrimeAx - main axis of game
%BookShelfBound - numeric array with [L,B,W,H] coordinates

%Output:
%Draws mirror onto house.
%if in storage the bookshelf will surrounded by a black lined box

%preallocate
BookShelfTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
ShelfColor='DarkGreen';
Book1Color='Blue';
Book2Color='Red';
Book3Color='Yellow';

%Draw Shelf
ShelfBound=BookShelfBound;
ShelfBound(5)=0.2*BookShelfBound(5);
Shelf=DrawCube(PrimeAx,ShelfBound,'Black',ShelfColor);
Shelf.Parent=BookShelfTrans;

%-------Books
BookW=0.1*BookShelfBound(4);
BookH=0.7*BookShelfBound(5);
BookD=BookShelfBound(6);

%Draw Book1
Book1Pos=[BookShelfBound(1);BookShelfBound(2)+ShelfBound(5);BookShelfBound(3)];
Book1Bound=[Book1Pos;BookW;BookH;BookD];
Book1Handle=DrawCube(PrimeAx,Book1Bound,'Black',Book1Color);
Book1Handle.Parent=BookShelfTrans;

%Draw Book2
Book2Pos=[BookShelfBound(1)+BookW;BookShelfBound(2)+ShelfBound(5);BookShelfBound(3)];
Book2Bound=[Book2Pos;BookW;BookH;BookD];
Book2Handle=DrawCube(PrimeAx,Book2Bound,'Black',Book2Color);
Book2Handle.Parent=BookShelfTrans;

%Draw Book3
Book3Pos=[BookShelfBound(1)+2*BookW;BookShelfBound(2)+ShelfBound(5);BookShelfBound(3)];
Book3Bound=[Book3Pos;BookW;BookH;BookD];
Book3Handle=DrawCube(PrimeAx,Book3Bound,'Black',Book3Color);
Book3Handle.Parent=BookShelfTrans;
%-------

set(BookShelfTrans,'DisplayName','BookShelf');
end
function [CouchTrans]=DrawCouch(PrimeAx,CouchBound)
%Input:
%PrimeAx - main axis of game
%CouchBound - numeric array with [L,B,D,W,H,T] coordinates

%Output:
%Draws couch onto house.
%output Transformation handle of couch

% preallocate
CouchTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
CouchColor='CouchRed';
CouchLegsColor='Pink';

%------Draw Couch
%Draw Couch Body
CBodyBound=CouchBound;
CBodyBound(2)=CouchBound(2)+0.2*CouchBound(5);
CBodyBound(5)=0.8*CouchBound(5);
CouchBodyHandle=DrawLShape(PrimeAx,CBodyBound,CouchColor);
CouchBodyHandle.Parent=CouchTrans;

%------Table Legs
LegsR=0.05*mean([CouchBound(4),CouchBound(6)]);
LegsH=0.2*CouchBound(5);
LegsFaceAmount=8;

%Leg1
Leg1Pos=[CouchBound(1)+0.1*CouchBound(4);CouchBound(2);CouchBound(3)+0.1*CouchBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,CouchLegsColor);
Leg1Handle.Parent=CouchTrans;

%Leg2
Leg1Pos=[CouchBound(1)+0.1*CouchBound(4);CouchBound(2);CouchBound(3)+0.9*CouchBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,CouchLegsColor);
Leg1Handle.Parent=CouchTrans;

%Leg3
Leg1Pos=[CouchBound(1)+0.9*CouchBound(4);CouchBound(2);CouchBound(3)+0.1*CouchBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,CouchLegsColor);
Leg1Handle.Parent=CouchTrans;

%Leg4
Leg1Pos=[CouchBound(1)+0.9*CouchBound(4);CouchBound(2);CouchBound(3)+0.9*CouchBound(6)];
Leg1Bound=[Leg1Pos;LegsR;LegsH];
Leg1Handle=DrawCylinder(PrimeAx,Leg1Bound,LegsFaceAmount,CouchLegsColor);
Leg1Handle.Parent=CouchTrans;
%------
%------

set(CouchTrans,'DisplayName','Couch');
end
function [MirrorTrans]=DrawMirror(PrimeAx,MirrorBound)
%Input:
%PrimeAx - main axis of game
%MirrorBound - numeric array with [L,B,D,W,H,T] coordinates

%Output:
%Draws mirror onto house.
%output transformation handle

%preallocate
MirrorTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
MirrorColor='LightBlue';
TorusColor='Silver';

%Find Center of Gravity
CG=[MirrorBound(1)+0.5*MirrorBound(4);MirrorBound(2)+0.5*MirrorBound(5);MirrorBound(3)+0.5*MirrorBound(6)];

%--------Draw Mirror
DiskBound=[CG;0.5*MirrorBound(4);0.5*MirrorBound(5)];
Mirror=DrawDisk(PrimeAx,DiskBound,MirrorColor);
Mirror.Parent=MirrorTrans;

%Draw Torus
TorusBound=[CG;0.5*MirrorBound(4);0.5*MirrorBound(5);0.5*MirrorBound(6)];
TorusHandle=DrawTorus(PrimeAx,TorusBound,TorusColor);
TorusHandle.Parent=MirrorTrans;

set(MirrorTrans,'DisplayName','Mirror');
end
function [LampTrans]=DrawLamp(PrimeAx,LampBound)
%Input:
%PrimeAx - main axis of game
%LampBound - numeric array with [L,B,D,W,H,T] coordinates

%Output:
%Draws lamp onto house.

%preallocate
LampTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
LampColor='LightGreen';
LampLineColor='Yellow';

%Draw Lamp Body
TrapezoidBound=LampBound;
TrapezoidBound(5)=0.3*LampBound(5); %H
TrapezoidHandle=DrawTrapezoid(PrimeAx,TrapezoidBound,LampColor);
TrapezoidHandle.Parent=LampTrans;

%Draw Line
CylinderBound([1,3])=LampBound([1,3])+0.5*LampBound([4,6]); %L,D
CylinderBound(2)=LampBound(2)+0.3*LampBound(5); %B
CylinderBound(4)=0.025*LampBound(4); %R
CylinderBound(5)=0.7*LampBound(5); %H;
CylinderHandle=DrawCylinder(PrimeAx,CylinderBound,12,LampLineColor);
CylinderHandle.Parent=LampTrans;

set(LampTrans,'DisplayName','Lamp');
end

%Drawing Shapes (3D Patch)
function CubeHandle=DrawCube(PrimeAx,CubeBound,EdgeColor,FaceColor)
%INPUT: 
%PrimeAx - main axis of game
%CubeBound -6 element vector [L,B,D,W,H,T]
%EdgeColor - name of edge color
%Facecolor - name of face color or 'none'

%OUTPUT: CubeHandle - a handle of the patch drawn

%Initialize cube parameters
%8 vertices and 6 faces
X=[0,1,1,0,0,1,1,0]*CubeBound(4)+CubeBound(1);
Y=[0,0,1,1,0,0,1,1]*CubeBound(5)+CubeBound(2);
Z=[0,0,0,0,1,1,1,1]*CubeBound(6)+CubeBound(3);

F=[1,2,3,4;
    5,6,7,8;
    1,2,6,5;
    2,3,7,6;
    3,4,8,7;
    1,4,8,5];

V=[X;Y;Z]';

%Create patch and obtain handle with/without facecolor
if strcmp(FaceColor,'none')
    CubeHandle=patch('Faces',F,'Vertices',V,'FaceColor','none','Parent',PrimeAx);
else
    CubeHandle=patch('Faces',F,'Vertices',V,'FaceColor',CustomColors(FaceColor),'Parent',PrimeAx);
end

%set Edge color to cube
if strcmp(EdgeColor,'none')
    set(CubeHandle,'edgecolor','none');
else
    set(CubeHandle,'edgecolor',CustomColors(EdgeColor));
end
end
function CylinderHandle=DrawCylinder(PrimeAx,CylinderBound,FaceAmount,FaceColor)
%INPUT: 
%PrimeAx - main axis of game
%CylinderBound -5 element vector [L,B,D,R,H]
%FaceAmount - numeric, amount of faces on cylinder
%Facecolor - name of face color or 'none'

%OUTPUT: CylinderHandle - a handle of the patch drawn

%REMARK:
%main axis of cylinde will passs through [L,B,D]~[X,Y,Z] and be paralell to
%Y

%Create basic cylinder and obtain XYZ 
[X,Z,Y]=cylinder(CylinderBound(4),FaceAmount); %cyliner function builds main axis on Z
X=X+CylinderBound(1);
Z=Z+CylinderBound(3);
Y=Y*CylinderBound(5)+CylinderBound(2);

%Draw cylinder and obtain handle
CylinderHandle=patch(surf2patch(X,Y,Z),'Parent',PrimeAx);
CylinderHandle.FaceColor=CustomColors(FaceColor);
end
function TrapezoidHandle=DrawTrapezoid(PrimeAx,TrapezoidBound,FaceColor)
%INPUT: 
%PrimeAx - main axis of game
%CubeBound -6 element vector [L,B,D,W,H,T]
%Facecolor - name of face color for CusomColors

%OUTPUT: TrapezoidHandle - a handle of the patch drawn

%Trapezoid Parameters
%8 vertcies, 6 faces
a=1; %base rib
phi=60; %angle
d=a/(sqrt(2)*tand(phi)); %distance accomidator to top ribs (not top rib length!)

X=[0,a,a,0,d,a-d,a-d,d]*TrapezoidBound(4)+TrapezoidBound(1);
Y=[0,0,0,0,a,a,a,a]*TrapezoidBound(5)+TrapezoidBound(2);
Z=[0,0,a,a,d,d,a-d,a-d]*TrapezoidBound(6)+TrapezoidBound(3);
F=[1,2,3,4;
    5,6,7,8;
    1,2,6,5;
    2,3,7,6;
    3,4,8,7;
    1,4,8,5;];
V=[X;Y;Z]';

%Create patch and obtain handle
TrapezoidHandle=patch('Faces',F,'Vertices',V,'FaceColor',CustomColors(FaceColor),'Parent',PrimeAx);
end
function LShapeHandle=DrawLShape(PrimeAx,LShapeBound,FaceColor)
%INPUT: 
%PrimeAx - main axis of game
%CubeBound -6 element vector [L,B,D,W,H,T]
%Facecolor - name of face color for CusomColors

%OUTPUT: LShapeHandle - a handle of the patch drawn

%LShape Parameters
%12 vertcies, 8 faces

a=1;    % ------1------        
b=0.4;  % 0.4         |
c=0.3;  % -------| 0.3|

X=[0,0,0,0,0,0,a,a,a,a,a,a]*LShapeBound(4)+LShapeBound(1);
Y=[0,0,b,b,a,a,0,0,b,b,a,a]*LShapeBound(5)+LShapeBound(2);
Z=[0,a,a,c,c,0,0,a,a,c,c,0]*LShapeBound(6)+LShapeBound(3);
F=[1,2,3,4,5,6;
    7,8,9,10,11,12;
    1,2,8,7,1,2;
    2,3,9,8,2,3;
    3,4,10,9,3,4;
    3,4,10,9,3,4;
    4,5,11,10,4,5;
    5,6,12,11,5,6;
    1,6,12,7,1,6];
V=[X;Y;Z]';

%Create patch and obtain handle
LShapeHandle=patch('Faces',F,'Vertices',V,'FaceColor',CustomColors(FaceColor),'Parent',PrimeAx);
LShapeHandle.FaceColor=CustomColors(FaceColor);
end
function DiskHandle=DrawDisk(PrimeAx,DiskBound,FaceColor)
%INPUT: 
%PrimeAx - main axis of game
%DiskBound -6 element vector [X0,Y0,Z0,Rx,Ry]
%Facecolor - name of face color for CusomColors

%OUTPUT: DiskHandle - a handle of the patch drawn

%"time vector" to run elipse on
t=linspace(0,2*pi,36);  %36 points

%Create verticies and faces vectors
X=DiskBound(1)+DiskBound(4)*cos(t);
Y=DiskBound(2)+DiskBound(5)*sin(t);
Z=DiskBound(3)*ones(1,length(t));

V=[X;Y;Z]'; %NX3 matrix
F=1:length(t); %row vector of all points

%remark: for 2D planes patch does not require color input
DiskHandle=patch('Faces',F,'Vertices',V,'FaceColor',CustomColors(FaceColor),'Parent',PrimeAx);
end
function TorusHandle=DrawTorus(PrimeAx,TorusBound,FaceColor)
%INPUT: 
%PrimeAx - main axis of game
%CylinderBound -5 element vector [X0,Y0,Z0,Rx,Ry,r]
%Facecolor - name of face color or 'none'

%OUTPUT: TorusHandle - a handle of the patch drawn

%REMARK: Code taken from mathworks help page. Thanks WWW
%updated by me.. 

%Obtain radii
Rx=TorusBound(4);
Ry=TorusBound(5);
r=TorusBound(6);

%Create angles to run on
th=linspace(0,2*pi,6); 
phi=linspace(0,2*pi,18);

% we convert our vectors phi and th to [m x n] matrices with meshgrid command:
[Phi,Th]=meshgrid(phi,th); 

% now we generate m x n matrices for x,y,z according to eqn of torus
X=(Rx+r.*cos(Th)).*cos(Phi)+TorusBound(1);
Y=(Ry+r.*cos(Th)).*sin(Phi)+TorusBound(2);
Z=r.*sin(Th)+TorusBound(3);

%create TorusHandle
TorusHandle=patch(surf2patch(X,Y,Z),'Parent',PrimeAx); %create the patch handle
TorusHandle.FaceColor=CustomColors(FaceColor); %change color
end

%SubAx Texting
function TextItemsPlaced(N,PrimeAx)
%Input:
%N - Numeric. Amount of items in room
%PrimeAx - prime axies of game

%Output:
%Updates ItemsPlaced text in figure (amount of furniture in room)

%Obtain text handle
TextHandle=PrimeAx.UserData.TextItemsPlaced;

%update text handle
TextHandle.String=['Items Placed: ',num2str(N)];
end
function TextViewType(PrimeAx)
%Input:
%PrimeAx - prime axies of game

%Output:
%Updates TextViewType text in figure

%Obtain text handle
TextHandle=PrimeAx.UserData.TextView;

%Obtain View
View=PrimeAx.UserData.Proj.View;

%update text handle
TextHandle.String=['View Type: ',View];
end
function TextProjType(PrimeAx)
%Input:
%PrimeAx - prime axies of game

%Output:
%Updates TextProj text in figure

%Obtain text handle
TextHandle=PrimeAx.UserData.TextProj;

%Obtain View
Projection=PrimeAx.UserData.Proj.Type{1};

%update text handle
TextHandle.String=['Projection Type: ',Projection];
end
function TextCameraLock(PrimeAx)
%Input:
%PrimeAx - prime axies of game

%Output:
%Updates TextProj text in figure

%Obtain text handle
TextHandle=PrimeAx.UserData.TextCameraLock;

%Obtain locking status
CameraLock=PrimeAx.UserData.Proj.CameraLock;

%update text handle
if CameraLock
    TextHandle.String='Camera Lock: Yes';
else
    TextHandle.String='Camera Lock: No';
end

end
function TextEdges(PrimeAx)
%Output:
%Updates TextEdges text in figure

%Obtain text handle
TextHandle=PrimeAx.UserData.TextEdges;

%Obtain Edges
EdgeType=PrimeAx.UserData.Edges(1);
%update text handle
switch EdgeType
    case 1
        TextHandle.String='Edges Shown: All';
    case 2
        TextHandle.String='Edges Shown: Boxes';
    case 3
        TextHandle.String='Edges Shown: None';
end

end
function HelpUser
%Input:
%none

%Output:
%Creates help dialog box for user

msg=sprintf(['Welcome to the game\n\n',...
    'In this game you will place furnitures from the storage in the room\n',...
    'Selecting and setting is done in two ways:\n\n',...
    'Using the Mouse (NOT TRACKPAD) - drag and drop\n\n',...
    'Using the Keyboard:\n\n',...
    'Furniture Manipulation:\n',...
    'Numbers "0,3,5,8,9" build furnitures. Try em out to learn which is which\n',...
    'Enter/Return - sets furniture in place\n',...
    'Arrowkeys - drag furniture in X/Y direction\n',...
    '" t "/" y " - drag furniture in Z direction\n',...
    '" PageUp "/" PageDown " - Same as " t ", " y "\n',...
    '" < " , " > " - rotate furniture on Z axis\n',...
    '" f ", " g " - rotate furniture on Y axis\n',...
    '" + " , " - " - scale furniture up or down\n',...
    '"delete" - deletes currently selected furniture\n',...
    '"tab" - Switch between furnitures set in room <--- GOOD TO KNOW\n\n',...
    'Camera Manipulation\n',...
    '" p " - changes projection type\n',...
    '" u " - changes view of camera to Top/Front and locks/unlocks camera movement\n',...
    '" i " - changes view of camera to Isometric and locks/unlocks camera movement\n',...
    '" e " - removes/adds edges to scene\n',...
    '" x ", " z " - zoom in and out\n',...
    ' " w ", " s "," a ", " d " - rotate camera (adheres to camera lock)\n\n',...
    'In addition:\n',...  
    '" r " - reset room\n',...
    '" c " - cheat mode\n',...
    '" esc " - closes game\n\n',...
    'Hints:\n',...
    'You can also combine mouse and keyboard controls\n',...
    'Toggeling between Front/Top/Isometeric while camera is locked is possible']);
title='Game rules';
helpdlg(msg,title);
end

%Transformations
function Translate(FTrans,Tx,Ty,Tz)
%Input:
%handlegroup -  usualy pointed by SelectedHandle
%Tx- trasnlate by Tx on X axis [numeric]
%Ty- translate by Ty on Y axis [numeric]

%Output:
%translated drawn object on main axies

%Parent Tree:
%Object<Transformation<Axies

%build transformation
T=makehgtform('translate',[Tx,Ty,Tz]);

%excute function
FTrans.Matrix=T*FTrans.Matrix;
end
function RotateZ(FTrans,Theta)
%Input:
%handlegroup -  usualy pointed by SelectedHandle
%Theta- Rotate drawn object by theta [numeric radians]

%Output:
%Rotate object around its geomtreic center by angle Theta[rad]

%Note:
%+eps is added to each rotation so rotation back to zero would be
%impossible.

%Parent Tree:
%Object<Transformation<Axies

%find geometric center
CG=ObtainCG(FTrans);

%get Transaltion vector
T=FTrans.Matrix*CG;

%move to origin
Translate(FTrans,-T(1),-T(2),-T(3))

%build transformation
R=makehgtform('zrotate',Theta+eps); %eps makes sure that you cant rotate back to zero

%Rotate
FTrans.Matrix=R*FTrans.Matrix;

%move back to position
Translate(FTrans,T(1),T(2),T(3))
end
function RotateY(FTrans,Phi)
%Input:
%handlegroup -  usualy pointed by SelectedHandle
%Phi- Rotate drawn object by Phi [numeric]

%Output:
%Rotate object around its geomtreic center by angle Phi[rad]

%Note:
%+eps is added to each rotation so rotation back to zero would be
%impossible.

%Parent Tree:
%Object<Transformation<Axies

%find geometric center
CG=ObtainCG(FTrans);

%get Transaltion vector
T=FTrans.Matrix*CG;

%move to origin
Translate(FTrans,-T(1),-T(2),-T(3))

%build transformation
R=makehgtform('yrotate',Phi+eps); %eps makes sure that you cant rotate back to zero

%Rotate
FTrans.Matrix=R*FTrans.Matrix;

%move back to position
Translate(FTrans,T(1),T(2),T(3))
end
function Scale(FTrans,Sx,Sy,Sz)
%Input:
%handlegroup -  usualy pointed by SelectedHandle
%Sx- Scale drawn object X-wise by Sx [numeric]
%Sy - Scale drawn object Y-wise by Sy [numeric]

%Output:
%translated drawn object on main axies

%Parent Tree:
%Object<Transformation<Axies

%find geometric center
CG=ObtainCG(FTrans);

%get Transaltion vector
T=FTrans.Matrix*CG;

%move to origin
Translate(FTrans,-T(1),-T(2),-T(3))

%build transformation
S=makehgtform('scale',[Sx,Sy,Sz]);

%Scale
FTrans.Matrix=S*FTrans.Matrix;

%move back to position
Translate(FTrans,T(1),T(2),T(3))
end

%Check Handles Status
function Bool=GraphicsPlaceHolder(GraphicsHandle)
%check handle validity
%Returns 1 if it's a placeholder/empty, and 0 otherwise
if strcmp(class(GraphicsHandle),'matlab.graphics.GraphicsPlaceholder')||~isvalid(GraphicsHandle)
    Bool=true;
else %object currently living in figure
    Bool=false;
end
end
function Bool=Child2Transformation(PatchHandle)
%Input:
%handle, usualy gco

%Output:
%1 if handle is a child of a handle group, 0 otherwise

%if handle is not empty, check if it has a parent that is a Group
if GraphicsPlaceHolder(PatchHandle)
    return
end

if strcmp(PatchHandle.Parent.Type,'hgtransform')
    Bool=true;
else
    Bool=false;
end
end
function Bool=KillZone(FTrans)
%Input:
%FTrans - hgtransform, pointed by global var selected handle

%Output
%Bool - 1 if parts of seleced furniture are not in room
%       0 if all the parts of selected furniture inside the room

%Obtain Axis
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%Define the room (room for killzone is expanded by eps in all directions)
x0=PrimeAx.XLim(1);
y0=PrimeAx.YLim(1);
yf=PrimeAx.YLim(2);
z0=PrimeAx.ZLim(1);
zf=PrimeAx.ZLim(2);
xv=[x0+Foundations.WallW-eps;Foundations.PartitionL+eps;...
    Foundations.PartitionL+eps;Foundations.WallW-eps];
yv=[y0+Foundations.FloorW-eps;y0+Foundations.FloorW-eps;...
    yf-Foundations.CeilW+eps;yf-Foundations.CeilW+eps];
zv=[z0+Foundations.WallW-eps;z0+Foundations.WallW-eps;...
    zf-Foundations.WallW+eps;zf-Foundations.WallW+eps];

%Obtain PrimeAxies verticies
[xp,yp,zp]=FurniturePrimeVertices(FTrans);

%build vector of points in room and out (represented by 1 and 0)
inXY=inpolygon(xp,yp,xv,yv);
inXZ=inpolygon(xp,zp,xv,zv);

if any(inXY==0)||any(inXZ==0) %Outside room
    Bool=1;
else %Inside room
    Bool=0;
end
end
function Bool=FurnitureInAir(FTrans)
%Input:
%FTrans - hgtransform, pointed by global var selected handle

%Output:
%Bool - 1 if the furniture lies in air, 0 otherwise
%   0 means the furniture has at least 1 vertex on the floor

%Parent Tree:
%Object(Patch)<HandleGroup<Transformation<Axies<Figure

%Obtain PrimeAx
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%obtain y ordinates of verticies in PrimeAxies
[~,yp]=FurniturePrimeVertices(FTrans);

if any(yp-Foundations.FloorW<eps)
    Bool=0;
else
    Bool=1;
end
end
function Bool=FurnitureNotHooked(FTrans)
%Input:
%FTrans - hgtransform, pointed by global var selected handle

%Output:
%Bool - 1 if the furniture is not hooked onto ceiling, 0 otherwise
%   0 means the furniture has at least 1 vertex on the ceiling

%Parent Tree:
%Object(Patch)<HandleGroup<Transformation<Axies<Figure

%Obtain PrimeAx
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%obtain y ordinates of verticies in PrimeAxies
[~,yp]=FurniturePrimeVertices(FTrans);

if any((1-Foundations.CeilW)-yp<eps)
    Bool=0;
else
    Bool=1;
end
end
function Bool=FurnitureZRotated(FTrans)
%Input
%FTrans - hgtransform, pointed by global var selected handle

%Outout:
%Bool - 1 if furniture has been rotated by user. 0 otherwises

%Parent Tree:
%Object<Transformation<Axies

M=FTrans.Matrix;

%Check rotation by one order in transformation matrix
if M(2,1)~=0
    Bool=1;
else
    Bool=0;
end
end
function Bool=FurnitureYRotated(FTrans)
%Input
%FTrans - hgtransform, pointed by global var selected handle

%Outout:
%Bool - 1 if furniture has been rotated by user. 0 otherwises

%Parent Tree:
%Object<Transformation<Axies

M=FTrans.Matrix;

%Check rotation by one order in transformation matrix
if M(3,1)~=0
    Bool=1;
else
    Bool=0;
end
end
function Bool=TwoFurnitureCollision(FTrans1,FTrans2)
%Input:
%FTrans1,2 - hgtransforms representing two furnitures

%Output:
%Bool - 1 if furnitures intersect, 0 otherwise (by definitions in moodle)

%Parent Tree:
%Object<Transformation<Axies

%runs on all releveant children and checks for patch intersections
Bool=0;

for i=2:length(FTrans1.Children)
    [xp1,yp1,zp1]=PatchPrimeVertices(FTrans1.Children(i));
    for j=2:length(FTrans2.Children)
        [xp2,yp2,zp2]=PatchPrimeVertices(FTrans2.Children(j));
        intersectionXY=polyxpoly(xp1,yp1,xp2,yp2); %returns intersection points
        intersectionXZ=polyxpoly(xp1,zp1,xp2,zp2);
        intersectionZY=polyxpoly(zp1,yp1,zp2,yp2);
        BoolXY=~isempty(intersectionXY); %1 if intersects 0 otherwise
        BoolXZ=~isempty(intersectionXZ);
        BoolZY=~isempty(intersectionZY);
        if (BoolXY&&BoolXZ)||(BoolXY&&BoolZY)||(BoolXZ&&BoolZY) %goes through all pairings 
            Bool=1;
        end
    end
end
end
function Bool=RoomFurnitureCollision(FTrans,PrimeFig)
%Input
%FTrans - hgtransform pointed by global var selected handle
%PrimeFig - figure. is inputed to use FindRoomObjectGroups

%Outout:
%Bool - 1 if furniture is in collision with another furniture in the room
%(By definitions in moodle)

%Parent Tree:
%Object<Transformation<Axies

%initalize
Bool=0;
Collisions=0;

%Obtain all Room HandleGroups
RoomHandleGroups=FindRoomFurnitures(PrimeFig);

%Create a string array of DisplayNames that belong to RoomHandleGroups
RoomDisplayNames=cell(length(RoomHandleGroups),1);
for i=1:length(RoomHandleGroups)
    RoomDisplayNames{i}=RoomHandleGroups(i).DisplayName;
end

%search for collisions
for i=1:length(RoomHandleGroups)
    Collisions=Collisions+TwoFurnitureCollision(FTrans,RoomHandleGroups(i));
end

%Furniture will always colide with itself
Collisions=Collisions-1;

if Collisions>0
    Bool=1;
end
end

%Manage Transormation Handles
function SetSelectedFurniture(SelectedHandle,PrimeFig)
%Input:
%SelectedHandle - patch - pointed out gco or keyboard inputs
%PrimeFig - PrimeFig inputed so we can use error figures

%Output:
%Will update ItemsPlaced
%Will update lighting depending on Lamps setup
%if object is in killzone:
%   will notify user and delete

%if table/couch is set horizontally but in air:
%   will notify user and set to ground

%if Lamp is set horizontally but not on ceiling:
%   will notify user and set to ceiling

%if furniture was placed atop another furniture
%   will notify user and delete

%if furniture is properly placed:
%   will turn the frame invisible

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

%Check if selected handle is valid and belongs to an unset selected
%furniture. if not, return
if (GraphicsPlaceHolder(SelectedHandle))%if SelectedHandle is empty
    return
elseif ~Child2Transformation(SelectedHandle) %if not furniture, return
        return
else
    FTrans=SelectedHandle.Parent; %obtain funiture transformation handle
    %if furniture does not have a red visible box, return
    if ~isequal(FTrans.Children(1).EdgeColor,[1 0 0])||~strcmp(FTrans.Children(1).Visible,'on')
        return
    end
end

%furniture in killzone
if KillZone(FTrans)
    DeleteFTrans(FTrans,PrimeFig);
    return   
else %was set in room
    FTrans.Children(1).Visible='Off';
end

%Table/Couch in air and wasnt rotated
if (strcmp(FTrans.DisplayName,'Table')||...
        strcmp(FTrans.DisplayName,'Couch'))...
        &&FurnitureInAir(FTrans)&&~FurnitureZRotated(FTrans)
%     questdlg('The Furniture has dropped to the floor','Mom says:','Okay','Okay');
    Bring2Ground(FTrans)
end

%Lamp in air and wasnt rotated
if strcmp(FTrans.DisplayName,'Lamp')&&...
        FurnitureNotHooked(FTrans)&&~FurnitureZRotated(FTrans)
%     questdlg('An Electrition came and hooked the lamp onto the ceiling','Mom says:','Okay','Okay');
    Bring2Ceiling(FTrans)
end

%BookShelf/Mirror are not on walls with normal Z and were not rotated
if (strcmp(FTrans.DisplayName,'BookShelf')||...
        strcmp(FTrans.DisplayName,'Mirror'))...
        &&~FurnitureYRotated(FTrans)
%             questdlg('The Furniture was attached to a wall','Mom says:','Okay','Okay');
            Bring2ZWall(FTrans);
end

%Furniture Collision
if RoomFurnitureCollision(FTrans,PrimeFig)
%     questdlg(sprintf('Furnitures are in collision\ntry again'),'Mom says:','Okay','Okay');
    DeleteFTrans(FTrans,PrimeFig);
    return %object is dead, no need to continue through
end

%Update ItemsPlaced
RoomHandleGroups=FindRoomFurnitures(PrimeFig);
PrimeAx=PrimeFig.Children(1);
TextItemsPlaced(length(RoomHandleGroups),PrimeAx);
end
function CG=ObtainCG(FTrans)
%Input:
%FTrans - hgtransform, pointed by global var selected handle

%Output:
%vector 1x4 that describes the CG of FTrans in space. [x,y,0,1]

Box=FTrans.Children(1);
CGx=mean(Box.XData(1:end-1)); %1:end-1 as line needs 5 vertices to close a box
CGy=mean(Box.YData(1:end-1));
CGz=mean(Box.ZData(1:end-1));
CG=[CGx;CGy;CGz;1];
end
function DeleteFTrans(FTrans,PrimeFig)
%Input:
%FTrans - hgtransform, pointed by global var selected handle
%PrimeFig - PrimeFig inputed so we can use error figures

%Output:
%Deletes the handle with its entire handle group
%updates ItemsPlaced (after deleting!)

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

delete(FTrans);

%Update ItemsPlaced
RoomHandleGroups=FindRoomFurnitures(PrimeFig);
PrimeAx=PrimeFig.Children(1);
TextItemsPlaced(length(RoomHandleGroups),PrimeAx);
end
function [RoomFTrans]=FindRoomFurnitures(PrimeFig)
%Input:
%PrimeFig - figure to find objects in

%finds all FTrans with red box (=in room)
%Outputs those FTrans in the form of an array
%(empty array if none exist)

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

RedBoxes=findobj(PrimeFig,'EdgeColor',[1 0 0]);
RoomFTrans=gobjects(length(RedBoxes),1); %Preallocate
for i=1:length(RedBoxes)
    RoomFTrans(i)=RedBoxes(i).Parent;
end
end
function ClearRoom(PrimeFig)
%input:
%PrimeFig - figure to find objects in

%deletes all furniture in room and updates ItemsPlaced
%via DeleteFTrans fcn

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

%deletes all objects that belong to room
RoomHandleGroups=FindRoomFurnitures(PrimeFig);
for i=1:length(RoomHandleGroups)
    DeleteFTrans(RoomHandleGroups(i),PrimeFig)
end
end
function RedBoxesOff(PrimeFig)
%Input:
%PrimeFig - main figure to find the red boxes in

%Output:
%turns all the boxes who belong to room furniture invisible
[RoomHandleGroups]=FindRoomFurnitures(PrimeFig);
for i=1:length(RoomHandleGroups)
    if strcmp(RoomHandleGroups(i).Children(1).Visible,'on')
        RoomHandleGroups(i).Children(1).Visible='off';
    end
end
end
function [xp,yp,zp]=FurniturePrimeVertices(FTrans)
%Input:
%FTrans - hgtransform pointed by global var selected handle

%Output
%xp,yp,zp - Numeric Column Vectors. X/Y/Z ordinates of furniture by Prime Axies

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

%Obtain all verticies that define the selected furniture
%Initalize...but dont preallocate
xp=[];
yp=[];
zp=[];
for i=2:length(FTrans.Children)
    [xpi,ypi,zpi]=PatchPrimeVertices(FTrans.Children(i));
    xp=[xp;xpi];
    yp=[yp;ypi];
    zp=[zp;zpi];
end

end
function [xp,yp,zp]=PatchPrimeVertices(PatchHandle)
%Input:
%PatchHandle - child of furniture HandleGroup

%Output
%xp,yp,zp - Numeric Column Vectors. X/Y/Z ordinates of furniture by Prime Axies

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

%Reorginize verticies into column vectors [x;y;z;1]
Points=[PatchHandle.Vertices,ones(length(PatchHandle.Vertices),1)];

%Multiply verticies by thier transformation matrix
Points=PatchHandle.Parent.Matrix*Points';

%obtain xp,yp,zp who describe the patch as seen in the primary axies
xp=Points(1,:)';
yp=Points(2,:)';
zp=Points(3,:)';
end
function Bring2Ground(FTrans)
%Input
%FTrans - hgtransform, pointed by global var selected handle

%Output:
%Trasnlates object so at least 1 vertex is touching the ground

%Parent Tree:
%Object<Transformation<Axies

%Obtain PrimeAx
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

[~,yp,~]=FurniturePrimeVertices(FTrans);
Translate(FTrans,0,-min(yp)+PrimeAx.YLim(1)+Foundations.FloorW,0);
end
function Bring2Ceiling(FTrans)
%Input
%FTrans - hgtransform, pointed by global var selected handle

%Output:
%Trasnlates object so at least 1 vertex is touching the ceiling

%Parent Tree:
%Object<Transformation<Axies

%Obtain room axis
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

[~,yp,~]=FurniturePrimeVertices(FTrans);
Translate(FTrans,0,-max(yp)+PrimeAx.YLim(2)-Foundations.CeilW,0);
end
function Bring2ZWall(FTrans)
%Input
%FTrans - hgtransform, pointed by global var selected handle

%Output:
%Trasnlates object so at least 1 vertex is touching Z orianted walls
%object will be translated to closest wall

%Parent Tree:
%Object<Transformation<Axies

%Obtain PrimeAx
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

Zlim=PrimeAx.ZLim;
[~,~,zp]=FurniturePrimeVertices(FTrans);
if min(zp)>mean(Zlim) %if minimum!!
    Translate(FTrans,0,0,-max(zp)+Zlim(2)-Foundations.WallW);
else
    Translate(FTrans,0,0,-min(zp)+Zlim(1)+Foundations.WallW);
end
end
function FTrans=NextRoomFurniture(FTrans,PrimeFig)
%Input:
%PrimeFig - main figure to find the red boxes in
%FTrans - hgtransform, pointed by global var selected handle

SelectedFurniture=FTrans; %Obtain SelectedFurniture
RoomHandleGroups=FindRoomFurnitures(PrimeFig); %Obtain room furnitures
Index=(RoomHandleGroups==SelectedFurniture); %find index of selected furniture in roomHG
ShiftedRoomHandleGroups=circshift(RoomHandleGroups,1); %obtain next furniture in roomHG
FTrans=ShiftedRoomHandleGroups(Index);
end
function TabFurniture(PrimeFig)
%Input: PrimeFig - main figure of game
%Output: switch selectedhandle between room selected furnitures
%if no room furnitures exist, do nothing.

%Obtain SelectedHandle
PrimeAx=PrimeFig.Children(1);
SelectedHandle=PrimeAx.UserData.SelectedHandle;

SetSelectedFurniture(SelectedHandle,PrimeFig);
if GraphicsPlaceHolder(SelectedHandle)%if furntiure was deleted in SetSelectedFurniture or never existed
    RoomFTrans=FindRoomFurnitures(PrimeFig); %Find all room furnitures
    if isempty(RoomFTrans) %if no furnitures are in room
        return
    else %obtain first furniture in RoomFTrans for the sake of it
        PreviousFurniture=RoomFTrans(1);
    end
else
    PreviousFurniture=SelectedHandle.Parent; %get Trans of previous furniture
end
FTrans=NextRoomFurniture(PreviousFurniture,PrimeFig); %Handle of new furniture
PrimeAx.UserData.SelectedHandle=FTrans.Children(2); %define SelectedHandle as patch for functionatlity
FTrans.Children(1).Visible='on'; %turns the redbox frame visiblity on
end

%CallBacks
function KeyBoardCB(PrimeFig,event)
%if user clicked on an object, executes user's keyboard inputs intent
%outputs for user keyboard inputs are as specified in task moodle and in
    %comments 

%Parent Tree:
%Object<Transformation<Axies

%Obtain PrimeAx
PrimeAx=PrimeFig.Children(1);

%Obtain SelectedHandle
SelectedHandle=PrimeAx.UserData.SelectedHandle;

%% for general inputs
switch event.Key
    case 'escape' %Close PrimeFig
        close(PrimeFig);
        
    case 'c' %Cheat code - build example room
        ClearRoom(PrimeFig);
        RoomExample_1(PrimeAx);
        
    case 'r' %delete all room furnitures
        ClearRoom(PrimeFig);
        
    case 'h' %ask for help
        HelpUser;
        
    case 'tab' %switch room selected furnitures
        TabFurniture(PrimeFig);
        
    case 'e' %Remove edges from all nonBoxes
        PrimeAx.UserData.Edges=circshift(PrimeAx.UserData.Edges,1,2); %3->2->1->3
        switch PrimeAx.UserData.Edges(1)
            case 1 %turns on all edges that are not related to boxes (ignore SceneBound and Parition)
                Patches=findobj(PrimeFig,'Type','Patch','-not','DisplayName','Box',...
                    '-not','DisplayName','SceneBound','-not','DisplayName','Partition');
            case 2 %turns on all black boxes
                Patches=findobj(PrimeFig,'Type','Patch','DisplayName','Box',...
                    'EdgeColor',[0,0,0]);
            case 3 %turns off all black edges (ignore SceneBound and partition)
                Patches=findobj(PrimeFig,'Type','Patch','EdgeColor',[0,0,0],...
                    '-not','DisplayName','SceneBound','-not','DisplayName','Partition');
        end
        for i=1:length(Patches)
            Patches(i).EdgeAlpha=double(~Patches(i).EdgeAlpha);
        end
        TextEdges(PrimeAx);
end
%% for projections
switch event.Key  
    case 'w' %moves camera up
        if PrimeAx.UserData.Proj.CameraLock %camera is locked, return
            return
        end
        PrimeAx.UserData.Proj.View='Camera';
        PrimeAx.UserData.Proj.Theta=PrimeAx.UserData.Proj.Theta-5;
        
        %Update Camera memory
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        SetProjection(PrimeAx);
        TextViewType(PrimeAx);
        
    case 's' %moves camera down
        if PrimeAx.UserData.Proj.CameraLock %camera is locked, return
            return
        end
        PrimeAx.UserData.Proj.View='Camera';
        PrimeAx.UserData.Proj.Theta=PrimeAx.UserData.Proj.Theta+5;
        
        %Update Camera memory
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        SetProjection(PrimeAx);
        TextViewType(PrimeAx);
        
    case 'a' %moves camera left
        if PrimeAx.UserData.Proj.CameraLock %camera is locked, return
            return
        end
        PrimeAx.UserData.Proj.Phi=PrimeAx.UserData.Proj.Phi-5;
        PrimeAx.UserData.Proj.View='Camera';
        
        %Update Camera memory
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        SetProjection(PrimeAx);
        TextViewType(PrimeAx);
        
    case 'd' %moves camera right
        if PrimeAx.UserData.Proj.CameraLock %camera is locked, return
            return
        end
        PrimeAx.UserData.Proj.Phi=PrimeAx.UserData.Proj.Phi+5;
        PrimeAx.UserData.Proj.View='Camera';
        
        %Update Camera memory
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        SetProjection(PrimeAx);
        TextViewType(PrimeAx);
        
    case 'x' %zoom in
        PrimeAx.UserData.Proj.R=PrimeAx.UserData.Proj.R-0.1;
        
        %Update Camera memory
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        SetProjection(PrimeAx);
        
    case 'z' %zoom out
        PrimeAx.UserData.Proj.R=PrimeAx.UserData.Proj.R+0.1;
        
        %Update Camera memory
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        SetProjection(PrimeAx);
        
    case 'u' %change camera to Top/Front view or return to camera
        %by pressing u, goes through Front->Top->Camera(back to)
        
        %If no memory is in store, create one
        if isempty( PrimeAx.UserData.Proj.CameraMemory)
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        %update camera memory if view was set to camera
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        switch PrimeAx.UserData.Proj.View
            case 'Front' %If it was Front, set it to Top
                PrimeAx.UserData.Proj.View='Top';
                PrimeAx.UserData.Proj.Phi=0;
                PrimeAx.UserData.Proj.Theta=0;
                SetProjection(PrimeAx);
            case 'Top' %If it was set Top, set it back to camera by memory
                PrimeAx.UserData.Proj=PrimeAx.UserData.Proj.CameraMemory;
                SetProjection(PrimeAx);
            otherwise  % update memory, lock camera and make it Front
                PrimeAx.UserData.Proj.CameraLock=1;
                PrimeAx.UserData.Proj.View='Front';
                PrimeAx.UserData.Proj.Phi=0;
                PrimeAx.UserData.Proj.Theta=90;
                SetProjection(PrimeAx);
        end
        
        %Update texts
        TextViewType(PrimeAx);
        TextCameraLock(PrimeAx);
        
    case 'i' %change projection to Isometric and back
        
        %If no memory is in store, create one
        if isempty( PrimeAx.UserData.Proj.CameraMemory)
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        %update camera memory if view was set to camera
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        switch PrimeAx.UserData.Proj.View
            case 'Isometric' %If it was set to Isometric, set it back to camera by memory
                PrimeAx.UserData.Proj=PrimeAx.UserData.Proj.CameraMemory;
                SetProjection(PrimeAx);
            otherwise %if wasnt set to isometeric, set it.
                PrimeAx.UserData.Proj.CameraLock=1;
                PrimeAx.UserData.Proj.View='Isometric';
                PrimeAx.UserData.Proj.Type={'Orthographic','Perspective'};
                PrimeAx.UserData.Proj.Phi=-45;
                PrimeAx.UserData.Proj.Theta=90-35.26439;
                SetProjection(PrimeAx);
        end
                
        %Update texts
        TextViewType(PrimeAx);
        TextCameraLock(PrimeAx);
        TextProjType(PrimeAx);
        
    case 'p' %change projection type
        %camera is locked and view is isometric, return
        if PrimeAx.UserData.Proj.CameraLock && strcmp(PrimeAx.UserData.Proj.View,'Isometric')
            return
        end
        %change projection type
        PrimeAx.UserData.Proj.Type=circshift(PrimeAx.UserData.Proj.Type,1);
        
        %Update memory
        if strcmp(PrimeAx.UserData.Proj.View,'Camera')
            PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        end
        
        %update projection
        SetProjection(PrimeAx);
        TextProjType(PrimeAx);
        
    case 'o'
        %camera is locked or was yet to be set, return
        if PrimeAx.UserData.Proj.CameraLock
            return
        end
        
        %Obtain memory
        PrimeAx.UserData.Proj=PrimeAx.UserData.Proj.CameraMemory;
        
        %set view to camera
        PrimeAx.UserData.Proj.View='Camera';
        
        %Update Memory
        PrimeAx.UserData.Proj.CameraMemory=PrimeAx.UserData.Proj;
        
        %update projection
        SetProjection(PrimeAx);        
end
%% for selected room funiture manipulation
if ~GraphicsPlaceHolder(SelectedHandle) %checks SelectedHandle isnt empty
    if Child2Transformation(SelectedHandle) %checks if furniture
        FTrans=SelectedHandle.Parent; %obtain funiture group object
        if isequal(FTrans.Children(1).EdgeColor,[1 0 0])&&strcmp(FTrans.Children(1).Visible,'on')
            %checks if room furniture and if box is visible (=selected)
            drag=0.04; %translate factor
            angle=pi/12; %rotate factor
            size=0.05; %scale factor
            switch event.Key
                case 'comma' %Rotate Z anti clockwise
                    RotateZ(FTrans,angle);
                case 'period' %Rotate Z clockwise
                    RotateZ(FTrans,-angle);
                case 'f' %rotate Y clockwise
                    RotateY(FTrans,-angle);
                case 'g' %Rotate Y counte clockwise
                    RotateY(FTrans,+angle);
                case 'leftarrow' %Translate -X
                    Translate(FTrans,-drag,0,0);
                case 'rightarrow' %Translate +X
                    Translate(FTrans,drag,0,0);
                case 'uparrow' %Translate +Y
                    Translate(FTrans,0,drag,0);
                case 'downarrow' %Trasnlate -Y
                    Translate(FTrans,0,-drag,0);
                case 'pagedown' %Translate +Z
                    Translate(FTrans,0,0,+drag); 
                case 'pageup' %Translate -Z
                    Translate(FTrans,0,0,-drag);
                case 't' %translate -Z
                    Translate(FTrans,0,0,-drag);
                case 'y' %translate +Z
                    Translate(FTrans,0,0,+drag);
                case 'equal' %Scale Up
                    Scale(FTrans,1+size,1+size,1+size);
                case 'hyphen' %Scale Down
                    Scale(FTrans,1-size,1-size,1-size);
                case 'delete' %Delete Furniture
                    DeleteFTrans(FTrans,PrimeFig)
                case 'return' %Set Furniture
                    SetSelectedFurniture(SelectedHandle,PrimeFig);
            end
        end
    end
end
%% for building new furnitures
switch event.Key
    case '0' %Build Table
        Foundations=PrimeAx.UserData.Foundations; %Obtain room foundations
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        TableBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.1;0.5;0.2;0.2;0.2];
        TableF=DrawingFurniture(PrimeAx,'Table',TableBound);
        PrimeAx.UserData.SelectedHandle=TableF.Children(end); %SelectedHandle needs to be a patch object
    case '5' %Build Couch
        Foundations=PrimeAx.UserData.Foundations; %Obtain room foundations
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        %Build Couch
        CouchBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.08;1;0.4;0.20;0.17];
        CouchTrans=DrawingFurniture(PrimeAx,'Couch',CouchBound);
        PrimeAx.UserData.SelectedHandle=CouchTrans.Children(end); %SelectedHandle needs to be a patch object
    case '3' %Build Mirror
        Foundations=PrimeAx.UserData.Foundations; %Obtain room foundations
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        MirrorBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.4;0.3;0.08;0.25;0.01];
        MirrorTrans=DrawingFurniture(PrimeAx,'Mirror',MirrorBound);
        PrimeAx.UserData.SelectedHandle=MirrorTrans.Children(end); %SelectedHandle needs to be a patch object
    case '8' %Build Lamp
        Foundations=PrimeAx.UserData.Foundations; %Obtain room foundations
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        LampBound=[Foundations.PartitionL+0.2;Foundations.FloorW+0.45;0.6;0.3;0.4;0.3];
        LampTrans=DrawingFurniture(PrimeAx,'Lamp',LampBound);
        PrimeAx.UserData.SelectedHandle=LampTrans.Children(end); %SelectedHandle needs to be a patch object
    case '9' %Build BookShelf
        Foundations=PrimeAx.UserData.Foundations; %Obtain room foundations
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        BookShelffBound=[Foundations.PartitionL+0.28;Foundations.FloorW+0.36;0.1;0.2;0.15;0.05];
        BookShelfTrans=DrawingFurniture(PrimeAx,'BookShelf',BookShelffBound);
        PrimeAx.UserData.SelectedHandle=BookShelfTrans.Children(end); %SelectedHandle needs to be a patch object
end
end
function MouseDownCB(PrimeFig,~)
%Output:
%when object is clicked:
%if a previous furniture was selected but not set, it will set it
%all object groups will have thier red boxes invisible
%if clicked object is a patch of a furniture, its red box will become visible
%if clicked furniture is in storage, a new room furniture will be drawn
%ontop the storage unit
%will update PrimeAx.UserData.MouseDown:=1

%Parent Tree:
%Object<Transformation<Axies
%first child of object group is always the red/black box

%Obtain PrimeAx
PrimeAx=PrimeFig.Children(1);

%Obtain SelectedHandle
SelectedHandle=PrimeAx.UserData.SelectedHandle;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%Set Mouse Down
PrimeFig.UserData=1;

%set previous furniture if existed
SetSelectedFurniture(SelectedHandle,PrimeFig);

%Obtain new selected furniture through child patch
SelectedHandle=gco;
PrimeAx.UserData.SelectedHandle=SelectedHandle;

RedBoxesOff(PrimeFig); %clears all red boxes showing

%check if new selected furniture is valid, and if so, act on it.
if GraphicsPlaceHolder(SelectedHandle)==0 %checks SelectedHandle isnt empty
    if Child2Transformation(SelectedHandle) %check if furniture
        FTrans=SelectedHandle.Parent; %obtain funiture group object
        if isequal(FTrans.Children(1).EdgeColor,[1 0 0]) %checks if room furniture
            SelectedHandle.Parent.Children(1).Visible='On'; %selects object - turns red box visible
        else %furniture is in storage
            switch FTrans.DisplayName
                
                case 'Table'
                  %Build Table
                  STableBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.1;0.5;0.2;0.2;0.2];
                  TableTrans=DrawingFurniture(PrimeAx,'Table',STableBound);
                  PrimeAx.UserData.SelectedHandle=TableTrans.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'Couch'
                    %Build Couch
                    CouchBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.08;1;0.4;0.20;0.17];
                    CouchTrans=DrawingFurniture(PrimeAx,'Couch',CouchBound);
                    PrimeAx.UserData.SelectedHandle=CouchTrans.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'Mirror'
                    %Build Mirror
                    MirrorBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.4;0.3;0.08;0.25;0.01];
                    MirrorTrans=DrawingFurniture(PrimeAx,'Mirror',MirrorBound);
                    PrimeAx.UserData.SelectedHandle=MirrorTrans.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'Lamp'
                    %Build Lamp
                    LampBound=[Foundations.PartitionL+0.2;Foundations.FloorW+0.45;0.6;0.3;0.4;0.3];
                    LampTrans=DrawingFurniture(PrimeAx,'Lamp',LampBound);
                    PrimeAx.UserData.SelectedHandle=LampTrans.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'BookShelf'
                    %Build BookShelf
                    BookShelffBound=[Foundations.PartitionL+0.28;Foundations.FloorW+0.36;0.1;0.2;0.15;0.05];
                    BookShelfTrans=DrawingFurniture(PrimeAx,'BookShelf',BookShelffBound);
                    PrimeAx.UserData.SelectedHandle=BookShelfTrans.Children(end); %SelectedHandle needs to be a patch object
            end
        end
    end
end
end
function MouseMoveCB(PrimeFig,~)
%Checks if PrimeFig.UserData.MouseDown=1, and if so, translate furniture into current cursor
%position

if ~PrimeFig.UserData
    return
end

%Obtain PrimeAx
PrimeAx=PrimeFig.Children(1);

%Obtain SelectedHandle
SelectedHandle=PrimeAx.UserData.SelectedHandle;


%Check if selected handle is valid and belongs to an unset selected
%furniture. if not, return
if (GraphicsPlaceHolder(SelectedHandle))%checks SelectedHandle isnt empty
    return
elseif ~Child2Transformation(SelectedHandle) %checks if furniture
        return
else
    FTrans=SelectedHandle.Parent; %obtain funiture group object
    if ~isequal(FTrans.Children(1).EdgeColor,[1 0 0])||~strcmp(FTrans.Children(1).Visible,'on')
        return
    end
end

%Obtain furniture
FTrans=SelectedHandle.Parent;

%Obtain current location of CG
CG=ObtainCG(FTrans);

%get Transaltion vector
T=FTrans.Matrix*CG;
%move to origin
Translate(FTrans,-T(1),-T(2),-T(3))

%Obtain position of cursor
CursorPos =get(PrimeAx,'CurrentPoint'); %2by3 Matrix.
CursorPos=mean(CursorPos,1); %rows describe front and back hits
%Translate furniture to new location
Translate(FTrans,CursorPos(1),CursorPos(2),CursorPos(3));

%Refresh
drawnow;
end
function MouseUpCB(PrimeFig,~)
%Output:
%Set selected furniture
%Update PrimeAx.UserData.MouseDown:=0;


%Obtain SelectedHandle
PrimeAx=PrimeFig.Children(1);
SelectedHandle=PrimeAx.UserData.SelectedHandle;

%Unset Mouse Down
PrimeFig.UserData=0;

%Set furniture
SetSelectedFurniture(SelectedHandle,PrimeFig);
end