%this code here will draw an interactive picture of a house
%Criterions could be found in course moodle under project part 1B

%REMARKS:
%Global Variables:
%SelectedHandle - [Patch handle] - contains object of interest (selected one)

%UserData on Graphics
%PrimeFig.UserData - [Bool] - "Mouse Down" - 1 if mouse is pressed down, 0 otherwise
%PrimeAx.UserData.ItemsPlaced - [Text handle] - amount of furnitures set in
%room 
%PrimeAx.UserData.Foundations - [Struct of numeric values] - witholds information of walls,
%floor and ceiling of the house

%Parent Tree:
%Object(Patch)<Transformation(Furniture)<Axies<Figure
%first child of a transformation is always the red/black box

%Rationatl:
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

%additional:
%there is no DrawingCB function in this code, as furnitures are not being
%redrawn per use of transforamtion by this code - the Transformation Matrix is
%updated instead.

%46 functions devided into catagories
%---------------------------------------------
%Boot
function AlonSpinner_Project1B()
%Booting function - clear/closeall/clc
%will build house (see BuildHouse function)

%For code person to decide if he wants these on or not.
clear
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

global SelectedHandle

%--------Initialize Window-----------%

%adjust created figure to monitor:
ScreenSize=get(0,'ScreenSize');
figureH=0.7*ScreenSize(4);
figureW=2*figureH;
figureL=(ScreenSize(3)-figureW)/2;
figureB=(ScreenSize(4)-figureH)/2;
PrimeFig=figure('Position',[figureL,figureB,figureW,figureH],...
    'name','AlonSpinner 305184335','Pointer','hand','color',CustomColors('ClayOrange'));

%create axies
PrimeAx=axes('units','normalized','position',[0,0,1,1],...
    'Xlim',[0,2],'Ylim',[0 1],'HitTest','off','Visible','off'); 
%fix aspect ratio
daspect([1,1,1]);

%---------- CallBack inputs ---------%
set(PrimeFig,'KeyPressFcn',@KeyBoardCB);
set(PrimeFig,'WindowButtonDownFcn',@MouseDownCB);
set(PrimeFig,'WindowButtonMotionFcn',@MouseMoveCB);
set(PrimeFig,'WindowButtonUpFcn',@MouseUpCB);

%--------- Create Initial status------%
BuildStructureFoundations(PrimeAx);
BuildStorage(PrimeAx);

%Initalizing Items Placed in room counter
PrimeAx.UserData.ItemsPlaced=text(0.02,0.975,'Items Placed: 0','FontSize',12);

%initalize SelectedHandle
SelectedHandle=hgtransform;

%initalize PrimeFig.UserData
PrimeFig.UserData=0;
end

%Main Drawings functions
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

%-----Transformation-----%
%set Parent.Matrix for later
%Furnitures that are not Mirrors are set to be infront of mirrors by
%translation in Z
if ~strcmp(ObjectName,'Mirror')
    FTrans.Matrix(3,4)=+1;
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
%ObjectBound is a vector of [L,B,W,H] coordinates
%Box Color

%Output:
%Draws a surrounding lined box around the bounding box and returns the
%handle. if color isnt declared, box will be red
% "Dist" is the space between two parallel lines of these boxes

if nargin==1
    BoxColor='Red';
end

Dist=0.1*ObjectBound(3);
XFrame=ObjectBound(1)+[-Dist,ObjectBound(3)+Dist,ObjectBound(3)+Dist,-Dist,-Dist];
YFrame=ObjectBound(2)+[-Dist,-Dist,ObjectBound(4)+Dist,ObjectBound(4)+Dist,-Dist];
BoxHandle=line(PrimeAx,XFrame,YFrame,'color',CustomColors(BoxColor),'LineWidth',2);
end
function ItemsPlacedAmount(N,PrimeAx)
%Input:
%N - Numeric. Amount of items in room
%PrimeAx - prime axies of game

%Output:
%Updates ItemsPlaced text in figure (amount of furniture in room)

%Obtain text handle
TextHandle=PrimeAx.UserData.ItemsPlaced;

%update text handle
TextHandle.String=['Items Placed: ',num2str(N)];
end
function [CVector]=CustomColors(Cname)
%Input:
%CustomColors - string containing color name

%Output:
%CVector - numeric vector reperesting input color

switch Cname
    case 'White'
        CVector=[1,1,1];
    case 'Red'
        CVector=[1,0,0];
    case 'Green'
        CVector=[0,1,0];
    case 'Blue'
        CVector=[0,0,1];
    case 'Yellow'
        CVector=[1,1,0];
    case 'GrayBlue'
        CVector=[0, 0.4470, 0.7410];
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
%Will draw the walls, floor, ceiling and patition.
%Will place foundation variable in UserData of PrimeAx
%"Foundations" - ParitionL,WallW,CeilW,FloorW,WhitePatchW

%initalie PrimeAx UserData
Foundations.PartitionL=1.4; %Partition Left
Foundations.WallW=0.01; %Wall Width
Foundations.WhitePatchW=0.05; %White Patch Width
Foundations.CeilW=0.01; %Ceilling Width
Foundations.FloorW=0.05; %Floor Width
PrimeAx.UserData.Foundations=Foundations;

%Build Partition
PartitionW=0.005;
DrawPartition(PrimeAx,Foundations.PartitionL,PartitionW);

%Build Walls
DrawWalls(PrimeAx,Foundations.WallW)

%Draw the white Patch atop the room
DrawWhitePatch(PrimeAx,Foundations.WhitePatchW);

%Build Ceiling
DrawCeiling(PrimeAx,Foundations.CeilW);

%Build Floor
DrawFloor(PrimeAx,Foundations.FloorW);

%Text: "Room"
text(PrimeAx,0.02,1-Foundations.WhitePatchW-Foundations.CeilW-0.02,'Room','FontSize',15)

%Text: "Storage"
text(PrimeAx,Foundations.PartitionL+0.02,1-Foundations.WhitePatchW-Foundations.CeilW-0.02,'Storage','FontSize',15)

%Text: "Press H for Help"
text(PrimeAx,1.75,1-0.5*Foundations.WhitePatchW,'Press H for Help','FontSize',12);
end
function DrawWhitePatch(PrimeAx,WhitePatchW)
%Input:
%FloorW - Width of floor

%Output:
%Draws the white patch onto house

%Color Choice
WhitePatchColor='White';

%Draw Floor
XPatch=[0,2,2,0];
YPatch=[1-WhitePatchW,1-WhitePatchW,1,1];
patch(PrimeAx,XPatch,YPatch,CustomColors(WhitePatchColor),'PickableParts','no','LineStyle','none');
end
function DrawFloor(PrimeAx,FloorW)
%Input:
%FloorW - Width of floor

%Output:
%Draws the Floor onto house

%Color Choice
FloorColor='DuskOrange';

%Draw Floor
XFloor=[0,2,2,0];
YFloor=FloorW*[1,1,0,0];
patch(PrimeAx,XFloor,YFloor,CustomColors(FloorColor),'PickableParts','no','LineStyle','none');
end
function DrawCeiling(PrimeAx,CeilW)
%Input:
%CeilW - Width of ceiling

%Output:
%Draws the ceiling onto house

Foundations=PrimeAx.UserData.Foundations;

%Color Choice
CeilColor='DuskOrange';

%Draw Ceiling
XCeil=[0,2,2,0];
YCeil=1-Foundations.WhitePatchW-CeilW*[1,1,0,0];
patch(PrimeAx,XCeil,YCeil,CustomColors(CeilColor),'PickableParts','no','LineStyle','none');
end
function DrawWalls(PrimeAx,WallW)
%Input:
%WallW - Width of walls

%Output:
%Draws the walls onto house

%Color Choice
WallColor='DuskOrange';

%Left Wall
XWallsLeft=[0,WallW,WallW,0];
YWallsLeft=[0,0,1,1];
patch(PrimeAx,XWallsLeft,YWallsLeft,CustomColors(WallColor),'PickableParts','no','LineStyle','none');

%Right Wall
XWallsRight=2+WallW*[-1,0,0,-1];
YWallsRight=[0,0,1,1];
patch(PrimeAx,XWallsRight,YWallsRight,CustomColors(WallColor),'PickableParts','no','LineStyle','none');
end
function DrawPartition(PrimeAx,PartitionL,PartitionW)
%Input:
%PartitionL - X coordinate of partition center
%PartitionW - Width of partition

%Output:
%Draws the partition onto house

%Color Choice
PartColor='Black';

%Draw Partition
XPart=PartitionL+PartitionW*[0,1,1,0];
YPart=[0,0,0.95,0.95];
patch(PrimeAx,XPart,YPart,CustomColors(PartColor),'PickableParts','no','LineStyle','none');
end
function BuildStorage(PrimeAx)
%will draw all the storage objects

%Obtain room Foundations
Foundations=PrimeAx.UserData.Foundations;

%Build Table
STableBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.03;0.2;0.2];
DrawingFurniture(PrimeAx,'Table',STableBound,'Black');

%Build Couch
SCouchBound=[Foundations.PartitionL+0.37;Foundations.FloorW+0.10;0.17;0.20];
DrawingFurniture(PrimeAx,'Couch',SCouchBound,'Black');
%Build Mirror
SMirrorBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.4;0.08;0.25];
DrawingFurniture(PrimeAx,'Mirror',SMirrorBound,'Black');

%Build Lamp
SLampBound=[Foundations.PartitionL+0.3;Foundations.FloorW+0.60;+0.2;0.25];
DrawingFurniture(PrimeAx,'Lamp',SLampBound,'Black');

%Build BookShelf
SBookShelfBound=[Foundations.PartitionL+0.28;Foundations.FloorW+0.36;0.2;0.15];
DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound,'Black');
end
function RoomExample_1(PrimeAx)
%Will draw an example for a room and update ItemsPlaced accordingly

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%Build Lamp1
LampBound1=[1 ;0.35;0.39;0.6-Foundations.CeilW];
Lamphandle1=DrawingFurniture(PrimeAx,'Lamp',LampBound1);
Lamphandle1.Children(1).Visible='Off';

%Build Lamp2
LampBound2=[0.1 ;0.35;0.2;0.6-Foundations.CeilW];
Lamphandle2=DrawingFurniture(PrimeAx,'Lamp',LampBound2);
Lamphandle2.Children(1).Visible='Off';

%Build Table
TableBound=[1.05;Foundations.FloorW;0.3;0.2;];
Tablehandle=DrawingFurniture(PrimeAx,'Table',TableBound);
Tablehandle.Children(1).Visible='Off';

%Build Mirror
SMirrorBound=[0.3;Foundations.FloorW+0.05;0.1;0.3];
Mirrorhandle=DrawingFurniture(PrimeAx,'Mirror',SMirrorBound);
Mirrorhandle.Children(1).Visible='Off';

%Build Couch1
SCouchBound=[0.08;Foundations.FloorW;0.2;0.2];
Couchhandle1=DrawingFurniture(PrimeAx,'Couch',SCouchBound);
Couchhandle1.Children(1).Visible='Off';

%Build Couch2
SCouchBound=[0.8;Foundations.FloorW;0.2;0.2];
Couchhandle2=DrawingFurniture(PrimeAx,'Couch',SCouchBound);
Couchhandle2.Children(1).Visible='Off';

%Build BookShelf1
SBookShelfBound1=[0.7;Foundations.FloorW+0.25;0.2;0.15];
BookShelfhandle1=DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound1);
BookShelfhandle1.Children(1).Visible='Off';

%Build BookShelf2
SBookShelfBound2=[0.45;Foundations.FloorW+0.25;0.2;0.15];
BookShelfhandle2=DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound2);
BookShelfhandle2.Children(1).Visible='Off';

%Build BookShelf3
SBookShelfBound3=[0.45;Foundations.FloorW+0.45;0.2;0.15];
BookShelfhandle3=DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound3);
BookShelfhandle3.Children(1).Visible='Off';

%Build BookShelf4
SBookShelfBound4=[0.7;Foundations.FloorW+0.45;0.2;0.15];
BookShelfhandle4=DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound4);
BookShelfhandle4.Children(1).Visible='Off';

%Build BookShelf5
SBookShelfBound5=[0.45;Foundations.FloorW+0.65;0.2;0.15];
BookShelfhandle5=DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound5);
BookShelfhandle5.Children(1).Visible='Off';

%Build BookShelf6
SBookShelfBound6=[0.7;Foundations.FloorW+0.65;0.2;0.15];
BookShelfhandle6=DrawingFurniture(PrimeAx,'BookShelf',SBookShelfBound6);
BookShelfhandle6.Children(1).Visible='Off';


%Update ItemsPlaced
ItemsPlacedAmount(12,PrimeAx);
end
function HelpUser
%Input:
%none

%Output:
%Creates help dialog box for user

msg=sprintf(['Welcome to the game\n\n',...
    'In this game you will place furnitures from the storage in the room\n',...
    'Selecting and setting is done in two ways:\n\n',...
    'Using the Mouse - click and drop\n\n',...
    'Using the Keyboard:\n',...
    'Numbers "0,3,5,8,9" build furnitures. Try em out to learn which is which\n',...
    'Enter/Return - sets furniture in place\n',...
    'Arrowkeys - drag furniture in corresponding direction\n',...
    '" < " , " > " - rotate furniture left and right\n',...
    '" + " , " - " - scale furniture up or down\n',...
    '"delete" - deletes currently selected furniture\n',...
    '"tab" - Switch between furnitures set in room\n\n',...
    'In addition:\n',...  
    '" r " - reset room\n',...
    '" c " - cheat mode\n',...
    '" esc " - closes game\n\n',...
    'Hint: You can also combine mouse and keyboard controls']);
title='Game rules';
helpdlg(msg,title);
end

%Drawing furniture
function [TableTrans]=DrawTable(PrimeAx,TableBound)
%Input:
%TableBound - numeric array with [L,B,W,H] coordinates

%Output:
%Draws Table onto house.
%Returns that handle of the transformation

%Create Transformation handle
TableTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
TableColor='NicePurple';

%Width of Leg
LegWidth=0.1*TableBound(3);

%Draw Table
XTable=TableBound(1)+[0,LegWidth,LegWidth,TableBound(3)-LegWidth,TableBound(3)-LegWidth,TableBound(3),TableBound(3),0];
YTable=TableBound(2)+[0,0,TableBound(4)-1.5*LegWidth,TableBound(4)-1.5*LegWidth,0,0,TableBound(4),TableBound(4)];
patch(PrimeAx,XTable,YTable,CustomColors(TableColor),'Parent',TableTrans,'LineStyle','none');

set(TableTrans,'DisplayName','Table');
end
function [CouchTrans]=DrawCouch(PrimeAx,CouchBound)
%Input:
%CouchBound - numeric array with [L,B,W,H] coordinates

%Output:
%Draws couch onto house.
%output Transformation handle

% preallocate
CouchTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
CouchColor='CouchRed';
CouchStandColor='GrayBlue';

%Draw Couch Body
XCouch=CouchBound(1)+[0,CouchBound(3),CouchBound(3),0.4*CouchBound(3),0.4*CouchBound(3),0];
YCouch=CouchBound(2)+0.1*CouchBound(4)+[0,0,0.3*CouchBound(4),0.3*CouchBound(4),0.9*CouchBound(4),0.9*CouchBound(4)];
patch(PrimeAx,XCouch,YCouch,CustomColors(CouchColor),'Parent',CouchTrans,'LineStyle','none');

%Drawing Left Leg
XCouchLeg1=CouchBound(1)+[0,0.1*CouchBound(3),0.1*CouchBound(3),0];
YCouchLeg1=CouchBound(2)+[0,0,0.1*CouchBound(4),0.1*CouchBound(4)];
patch(PrimeAx,XCouchLeg1,YCouchLeg1,CustomColors(CouchStandColor),'Parent',CouchTrans,'LineStyle','none');

%Draw Right Leg
XCouchLeg2=CouchBound(1)+CouchBound(3)+[-0.1*CouchBound(3),0,0,-0.1*CouchBound(3)];
YCouchLeg2=CouchBound(2)+[0,0,0.1*CouchBound(4),0.1*CouchBound(4)];
patch(PrimeAx,XCouchLeg2,YCouchLeg2,CustomColors(CouchStandColor),'Parent',CouchTrans,'LineStyle','none');

set(CouchTrans,'DisplayName','Couch');
end
function [MirrorTrans]=DrawMirror(PrimeAx,MirrorBound)
%Input:
%MirrorBound - numeric array with [L,B,W,H] coordinates

%Output:
%Draws mirror onto house.
%output transformation handle

%preallocate
MirrorTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
MirrorColor='LightBlue';

%Find Center of Gravity
CG=[MirrorBound(1)+0.5*MirrorBound(3);MirrorBound(2)+0.5*MirrorBound(4)];

%"time vector" to run elipse on
t=0:0.1:2*pi;

%Draw Mirror
XMirror=CG(1)+0.5*MirrorBound(3)*cos(t);
YMirror=CG(2)+0.5*MirrorBound(4)*sin(t);
patch(PrimeAx,XMirror,YMirror,CustomColors(MirrorColor),'Parent',MirrorTrans,'LineStyle','none');

set(MirrorTrans,'DisplayName','Mirror');
end
function [LampTrans]=DrawLamp(PrimeAx,LampBound)
%Input:
%LampBound - numeric array with [L,B,W,H] coordinates

%Output:
%Draws lamp onto house.

%preallocate
LampTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
LampColor='LightGreen';
LampLineColor='Yellow';

%Draw Lamp Body
XLamp=LampBound(1)+[0,LampBound(3),0.9*LampBound(3),0.1*LampBound(3)];
YLamp=LampBound(2)+[0,0,0.2*LampBound(4),0.2*LampBound(4)];
patch(PrimeAx,XLamp,YLamp,CustomColors(LampColor),'Parent',LampTrans,'LineStyle','none');

%Draw Line
XLine=LampBound(1)+0.5*LampBound(3)+0.01*LampBound(3)*[-1,1,1,-1];
YLine=LampBound(2)+0.2*LampBound(4)+0.8*LampBound(4)*[0,0,1,1];
patch(PrimeAx,XLine,YLine,CustomColors(LampLineColor),'Parent',LampTrans,'LineStyle','none');

set(LampTrans,'DisplayName','Lamp');
end
function [BookShelfTrans]=DrawBookShelf(PrimeAx,BookShelfBound)
%Input:
%BookShelfBound - numeric array with [L,B,W,H] coordinates

%Output:
%Draws mirror onto house.
%if in storage the bookshelf will surrounded by a black lined box

%preallocate
BookShelfTrans=hgtransform('Parent',PrimeAx,'Matrix',eye(4));

%Color Choice
BookShelfColor='DarkGreen';
Book1Color='Blue';
Book2Color='Red';
Book3Color='Yellow';

%Draw Shelf
XBookShelf=BookShelfBound(1)+BookShelfBound(3)*[0,1,1,0];
YBookShelf=BookShelfBound(2)+0.3*BookShelfBound(4)*[0,0,1,1];
patch(XBookShelf,YBookShelf,CustomColors(BookShelfColor),'Parent',BookShelfTrans,'LineStyle','none');

%Width of books
BookW=0.1*BookShelfBound(3);

%Height of books
BookH=0.7*BookShelfBound(4);

%Draw Book1
XBook1=BookShelfBound(1)+BookW*[0,1,1,0];
YBook1=BookShelfBound(2)+0.3*BookShelfBound(4)+BookH*[0,0,1,1];
patch(PrimeAx,XBook1,YBook1,CustomColors(Book1Color),'Parent',BookShelfTrans,'LineStyle','none');

%Draw Book2
XBook2=BookShelfBound(1)+BookW+BookW*[0,1,1,0];
YBook2=BookShelfBound(2)+0.3*BookShelfBound(4)+BookH*[0,0,1,1];
patch(PrimeAx,XBook2,YBook2,CustomColors(Book2Color),'Parent',BookShelfTrans,'LineStyle','none');

%Draw Book3
XBook3=BookShelfBound(1)+2*BookW+BookW*[0,1,1,0];
YBook3=BookShelfBound(2)+0.3*BookShelfBound(4)+BookH*[0,0,1,1];
patch(PrimeAx,XBook3,YBook3,CustomColors(Book3Color),'Parent',BookShelfTrans,'LineStyle','none');

set(BookShelfTrans,'DisplayName','BookShelf');
end

%Transformations
function Translate(FTrans,Tx,Ty)
%Input:
%handlegroup -  usualy pointed by SelectedHandle
%Tx- trasnlate by Tx on X axis [numeric]
%Ty- translate by Ty on Y axis [numeric]

%Output:
%translated drawn object on main axies

%Parent Tree:
%Object<Transformation<Axies

%build transformation
T=makehgtform('translate',[Tx,Ty,0]);

%excute function
FTrans.Matrix=T*FTrans.Matrix;
end
function Rotate(FTrans,Theta)
%Input:
%handlegroup -  usualy pointed by SelectedHandle
%Theta- Rotate drawn object by theta [numeric]

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
Translate(FTrans,-T(1),-T(2))

%build transformation
R=makehgtform('zrotate',Theta+eps); %eps makes sure that you cant rotate back to zero

%Rotate
FTrans.Matrix=R*FTrans.Matrix;

%move back to position
Translate(FTrans,T(1),T(2))
end
function Scale(FTrans,Sx,Sy)
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
Translate(FTrans,-T(1),-T(2))

%build transformation
S=makehgtform('scale',[Sx,Sy,1]);

%Scale
FTrans.Matrix=S*FTrans.Matrix;

%move back to position
Translate(FTrans,T(1),T(2))
end

%Check Handles Status
function Bool=GraphicsPlaceHolder(GraphicsHandle)
%check handle validity
%Returns 1 if it's a placeholder/empty, and 0 otherwise
if ~isvalid(GraphicsHandle)
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

if strcmp(PatchHandle.Parent.Type,'hgtransform')&&(GraphicsPlaceHolder(PatchHandle)==false)
    Bool=true;
else
    Bool=false;
end
end
function Bool=KillZone(FTrans)
%Input:
%FTrans, pointed by global var selected handle

%Output
%Bool - 1 if parts of seleced furniture are not in room
%       0 if all the parts of selected furniture inside the room

%Obtain Axis
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%Define the room (room for killzone is expanded by eps in all directions)
xv=[Foundations.WallW-eps;Foundations.PartitionL+eps;Foundations.PartitionL+eps;Foundations.WallW-eps];
yv=[Foundations.FloorW-eps;Foundations.FloorW-eps;1-Foundations.WhitePatchW-Foundations.CeilW+eps;1-Foundations.WhitePatchW-Foundations.CeilW+eps];

%Obtain PrimeAxies verticies
[xp,yp]=FurniturePrimeVertices(FTrans);

%build vector of points in room and out (represented by 1 and 0)
in=inpolygon(xp,yp,xv,yv);

if any(in==0) %Outside room
    Bool=1;
else %Inside room
    Bool=0;
end
end
function Bool=FurnitureInAir(FTrans)
%Input:
%Handlegroup, pointed by global var selected handle

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
%Handlegroup, pointed by global var selected handle

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

if any((1-Foundations.WhitePatchW-Foundations.CeilW)-yp<eps)
    Bool=0;
else
    Bool=1;
end
end
function Bool=FurnitureRotated(FTrans)
%Input
%Handlegroup, pointed by global var selected handle

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
function Bool=TwoFurnitureCollision(FTrans1,FTrans2)
%Input:
%HandleGroup1,HandleGroup2 - furniture HandleGroups

%Output:
%Bool - 1 if furnitures intersect, 0 otherwise (by definitions in moodle)

%Parent Tree:
%Object<Transformation<Axies

%runs on all releveant children and checks for patch intersections
Bool=0;

%If both furnitures dont live in the same plane, return with bool=0
if FTrans1.Matrix(3,4)~=FTrans2.Matrix(3,4)
    return
end

for i=2:length(FTrans1.Children)
    [xp1,yp1]=PatchPrimeVertices(FTrans1.Children(i));
    for j=2:length(FTrans2.Children)
        [xp2,yp2]=PatchPrimeVertices(FTrans2.Children(j));
        intersection=polyxpoly(xp1,yp1,xp2,yp2);
        if ~isempty(intersection)
            Bool=1;
        end
    end
end
end
function Bool=RoomFurnitureCollision(FTrans,PrimeFig)
%Input
%FTrans - pointed by global var selected handle
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
%handleGroup pointed out by Selected object
%PrimeFig - PrimeFig inputed so we can use error figures

%Output:
%Will update ItemsPlaced
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
    if ~isequal(FTrans.Children(1).Color,[1 0 0])||~strcmp(FTrans.Children(1).Visible,'on')
        return
    end
end

%furniture in killzone
if KillZone(FTrans)
    %Create Default Transformation matricies to compare with
    FurnitureDefTrans=eye(4);
    MirrorDefTrans=eye(4);
    FurnitureDefTrans(3,4)=1; %cant obtain this transformation from user input
    
    %Compare with default Transformation matricies
    %if furniture (mirror or otherwise) was moved from created spot, bring up a message
    if ~isequal(FTrans.Matrix,FurnitureDefTrans)&&~isequal(FTrans.Matrix,MirrorDefTrans)
        questdlg(sprintf('Furniture was not set in its entirety in room\ntry again'),'Mom says:','Okay','Okay');
    end
    
    %Delete object and return from funciton - no need to continue through
    DeleteFTrans(FTrans,PrimeFig);
    return
    
else %was set in room
    FTrans.Children(1).Visible='Off';
end

%Table/Couch in air and wasnt rotated
if ((strcmp(FTrans.DisplayName,'Table')||...
        strcmp(FTrans.DisplayName,'Couch'))...
        &&FurnitureInAir(FTrans)&&~FurnitureRotated(FTrans))
    questdlg('The Furniture has dropped to the floor','Mom says:','Okay','Okay');
    Bring2Ground(FTrans)
end

%Lamp in air and wasnt rotated
if (strcmp(FTrans.DisplayName,'Lamp')&&...
        FurnitureNotHooked(FTrans)&&~FurnitureRotated(FTrans))
    questdlg('An Electrition came and hooked the lamp onto the ceiling','Mom says:','Okay','Okay');
    Bring2Ceiling(FTrans)
end

%Furniture Collision
if RoomFurnitureCollision(FTrans,PrimeFig)
    questdlg(sprintf('Furnitures are in collision\ntry again'),'Mom says:','Okay','Okay');
    DeleteFTrans(FTrans,PrimeFig);
    return %object is dead, no need to continue through
end

%Update ItemsPlaced
RoomHandleGroups=FindRoomFurnitures(PrimeFig);
PrimeAx=PrimeFig.Children(1);
ItemsPlacedAmount(length(RoomHandleGroups),PrimeAx);
end
function CG=ObtainCG(FTrans)
%Input:
%FTrans, pointed by global var selected handle

%Output:
%vector 1x4 that describes the CG of FTrans in space. [x,y,0,1]

Box=FTrans.Children(1);
CGx=mean(Box.XData(1:end-1)); %1:end-1 as line needs 5 vertices to close a box
CGy=mean(Box.YData(1:end-1)); %1:end-1 as line needs 5 vertices to close a box
CG=[CGx;CGy;0;1];
end
function DeleteFTrans(FTrans,PrimeFig)
%Input:
%FTrans, pointed by global var selected handle
%PrimeFig - PrimeFig inputed so we can use error figures

%Output:
%Deletes the handle with its entire handle group
%updates ItemsPlaced (after deleting!)

%Parent Tree:
%Object(Patch)<HandleGroup<Transformation<Axies<Figure

delete(FTrans);

%Update ItemsPlaced
RoomHandleGroups=FindRoomFurnitures(PrimeFig);
PrimeAx=PrimeFig.Children(1);
ItemsPlacedAmount(length(RoomHandleGroups),PrimeAx);
end
function [RoomFTrans]=FindRoomFurnitures(PrimeFig)
%Input:
%PrimeFig - figure to find objects in

%finds all ObjectGroups with red box (=in room)
%Outputs those ObjectGroups in the form of an array
%(empty array if none exist)

%Parent Tree:
%Object(Patch)<HandleGroup<Transformation<Axies<Figure

RedBoxes=findobj(PrimeFig,'Color',[1 0 0]);
RoomFTrans=gobjects(length(RedBoxes),1); %Preallocate
for i=1:length(RedBoxes)
    RoomFTrans(i)=RedBoxes(i).Parent;
end
end
function ClearRoom(PrimeFig)
%input:
%PrimeFig - figure to find objects in

%deletes all furniture in room and updates ItemsPlaced
%via DeleteHandleGroup fcn

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
function [xp,yp]=FurniturePrimeVertices(FTrans)
%Input:
%FTrans, pointed by global var selected handle

%Output
%xp - Numeric Column Vector. X ordinates of furniture by Prime Axies
%yp - Numeric Column Vector. Y ordinates of furniture by Prime Axies

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

%Obtain all verticies that define the selected furniture
%Initalize...but dont preallocate
xp=[];
yp=[];
for i=2:length(FTrans.Children)
    [xpi,ypi]=PatchPrimeVertices(FTrans.Children(i));
    xp=[xp;xpi];
    yp=[yp;ypi];
end

end
function [xp,yp]=PatchPrimeVertices(PatchHandle)
%Input:
%PatchHandle - child of furniture HandleGroup

%Output
%xp - Numeric Column Vector. X ordinates of furniture by Prime Axies
%yp - Numeric Column Vector. Y ordinates of furniture by Prime Axies

%Parent Tree:
%Object(Patch)<Transformation<Axies<Figure

%Obtain all verticies that define the selected patch
xq=PatchHandle.Vertices(:,1);
yq=PatchHandle.Vertices(:,2);

%Reorginize verticies into column vectors [x;y;0;1]
Points=[xq';yq';zeros(1,length(xq));ones(1,length(yq))];

%Multiply verticies by thier transformation matrix
Points=PatchHandle.Parent.Matrix*Points;

%obtain xp,yp who describe the patch as seen in the primary axies
xp=Points(1,:)';
yp=Points(2,:)';
end
function Bring2Ground(FTrans)
%Input
%FTrans, pointed by global var selected handle

%Output:
%Trasnlates object so at least 1 vertex is touching the ground

%Parent Tree:
%Object<Transformation<Axies

%Obtain PrimeAx
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

[~,yp]=FurniturePrimeVertices(FTrans);
Translate(FTrans,0,-min(yp)+Foundations.FloorW);
end
function Bring2Ceiling(FTrans)
%Input
%FTrans, pointed by global var selected handle

%Output:
%Trasnlates object so at least 1 vertex is touching the ceiling

%Parent Tree:
%Object<Transformation<Axies

%Obtain room axis
PrimeAx=FTrans.Parent;

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

[~,yp]=FurniturePrimeVertices(FTrans);
Translate(FTrans,0,-max(yp)+1-Foundations.WhitePatchW-Foundations.CeilW);
end
function FTrans=NextRoomFurniture(FTrans,PrimeFig)
%Input:
%PrimeFig - main figure to find the red boxes in
%FTrans, pointed by global var selected handle

SelectedFurniture=FTrans; %Obtain SelectedFurniture
RoomHandleGroups=FindRoomFurnitures(PrimeFig); %Obtain room furnitures
Index=(RoomHandleGroups==SelectedFurniture); %find index of selected furniture in roomHG
ShiftedRoomHandleGroups=circshift(RoomHandleGroups,1); %obtain next furniture in roomHG
FTrans=ShiftedRoomHandleGroups(Index);
end

%CallBacks
function KeyBoardCB(PrimeFig,event)
%if user clicked on an object, executes user's keyboard inputs intent
%outputs for user keyboard inputs are as specified in task moodle and in
    %comments 
%most switch cases end with return so furniture won't be set if not asked
%   for it

%Parent Tree:
%Object<Transformation<Axies

global SelectedHandle 

%Obtain PrimeAx
PrimeAx=PrimeFig.Children(1);

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%for general keyboard inputs
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
        SetSelectedFurniture(SelectedHandle,PrimeFig);
        if ~isvalid(SelectedHandle) %if furntiure was deleted in SetSelectedFurniture          
            RoomFTrans=FindRoomFurnitures(PrimeFig); %Find all room furnitures
            if isempty(RoomFTrans) %if no furnitures are in room
                return
            else %obtain first furniture in RoomFTrans for the sake of it
            PreviousFurniture=RoomFTrans(1);
            end
        else
            PreviousFurniture=SelectedHandle.Parent; %get HandleGroup of previous furniture
        end
        FTrans=NextRoomFurniture(PreviousFurniture,PrimeFig); %Handle of new furniture
        SelectedHandle=FTrans.Children(2); %define SelectedHandle as patch for functionatlity
        FTrans.Children(1).Visible='on'; %turns the redbox frame visiblity on
end

%for selected room funiture:
if ~GraphicsPlaceHolder(SelectedHandle) %checks SelectedHandle isnt empty
    if Child2Transformation(SelectedHandle) %checks if furniture
        FTrans=SelectedHandle.Parent; %obtain funiture group object
        if isequal(FTrans.Children(1).Color,[1 0 0])&&strcmp(FTrans.Children(1).Visible,'on')
            %checks if room furniture and if box is visible (=selected)
            drag=0.04; %translate factor
            angle=pi/12; %rotate factor
            size=0.05; %scale factor
            switch event.Key
                case 'comma' %Rotate Left
                    Rotate(FTrans,angle);
                case 'period' %Rotate Right
                    Rotate(FTrans,-angle);
                case 'leftarrow' %Translate Left
                    Translate(FTrans,-drag,0);
                case 'rightarrow' %Translate Right
                    Translate(FTrans,drag,0);
                case 'uparrow' %Translate Up
                    Translate(FTrans,0,drag);
                case 'downarrow' %Translate Down
                    Translate(FTrans,0,-drag);
                case 'equal' %Scale Up
                    Scale(FTrans,1+size,1+size);
                case 'hyphen' %Scale Down
                    Scale(FTrans,1-size,1-size);
                case 'delete' %Delete Furniture
                    DeleteFTrans(FTrans,PrimeFig)
                case 'return' %Set Furniture
                    SetSelectedFurniture(SelectedHandle,PrimeFig);
            end
        end
    end
end

%for building new furnitures
switch event.Key
    case '0' %Build Table
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        TableBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.03;0.2;0.2];
        TableGroup=DrawingFurniture(PrimeAx,'Table',TableBound);
        SelectedHandle=TableGroup.Children(end); %SelectedHandle needs to be a patch object
    case '5' %Build Couch
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        CouchBound=[Foundations.PartitionL+0.37;Foundations.FloorW+0.10;0.17;0.20];
        CouchGroup=DrawingFurniture(PrimeAx,'Couch',CouchBound);
        SelectedHandle=CouchGroup.Children(end); %SelectedHandle needs to be a patch object
    case '3' %Build Mirror
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        MirrorBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.4;0.08;0.25];
        MirrorGroup=DrawingFurniture(PrimeAx,'Mirror',MirrorBound);
        SelectedHandle=MirrorGroup.Children(end); %SelectedHandle needs to be a patch object
    case '8' %Build Lamp
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        LampBound=[Foundations.PartitionL+0.3;Foundations.FloorW+0.60;+0.2;0.25];
        LampGroup=DrawingFurniture(PrimeAx,'Lamp',LampBound);
        SelectedHandle=LampGroup.Children(end); %SelectedHandle needs to be a patch object
    case '9' %Build BookShelf
        SetSelectedFurniture(SelectedHandle,PrimeFig); %set previous object if exists
        BookShelfBound=[Foundations.PartitionL+0.28;Foundations.FloorW+0.36;0.2;0.15];
        BookShelfGroup=DrawingFurniture(PrimeAx,'BookShelf',BookShelfBound);
        SelectedHandle=BookShelfGroup.Children(end); %SelectedHandle needs to be a patch object
end
end
function MouseDownCB(PrimeFig,~)
%when object is clicked:
%if a previous furniture was selected but not set, it will set it
%all object groups will have thier red boxes invisible
%if clicked object is a patch of a furniture, its red box will become visible
%if clicked furniture is in storage, a new room furniture will be drawn
%ontop the storage unit

%Parent Tree:
%Object<Transformation<Axies
%first child of object group is always the red/black box

global SelectedHandle

%Obtain PrimeAx
PrimeAx=PrimeFig.Children(1);

%Obtain room foundations
Foundations=PrimeAx.UserData.Foundations;

%Set Mouse Down
PrimeFig.UserData=1;

%set previous furniture if existed
SetSelectedFurniture(SelectedHandle,PrimeFig);

%Obtain new selected furniture through child patch
SelectedHandle=gco;

RedBoxesOff(PrimeFig); %clears all red boxes showing

%check if new selected furniture is valid, and if so, act on it.
if GraphicsPlaceHolder(SelectedHandle)==0 %checks SelectedHandle isnt empty
    if Child2Transformation(SelectedHandle) %check if furniture
        FTrans=SelectedHandle.Parent; %obtain funiture group object
        if isequal(FTrans.Children(1).Color,[1 0 0]) %checks if room furniture
            SelectedHandle.Parent.Children(1).Visible='On'; %selects object - turns red box visible
        else %furniture is in storage
            switch FTrans.DisplayName
                
                case 'Table'
                    %Build Table
                    TableBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.03;0.2;0.2];
                    TableGroup=DrawingFurniture(PrimeAx,'Table',TableBound);
                    SelectedHandle=TableGroup.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'Couch'
                    %Build Couch
                    CouchBound=[Foundations.PartitionL+0.37;Foundations.FloorW+0.10;0.17;0.20];
                    CouchGroup=DrawingFurniture(PrimeAx,'Couch',CouchBound);
                    SelectedHandle=CouchGroup.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'Mirror'
                    %Build Mirror
                    MirrorBound=[Foundations.PartitionL+0.1;Foundations.FloorW+0.4;0.08;0.25];
                    MirrorGroup=DrawingFurniture(PrimeAx,'Mirror',MirrorBound);
                    SelectedHandle=MirrorGroup.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'Lamp'
                    %Build Lamp
                    LampBound=[Foundations.PartitionL+0.3;Foundations.FloorW+0.60;+0.2;0.25];
                    LampGroup=DrawingFurniture(PrimeAx,'Lamp',LampBound);
                    SelectedHandle=LampGroup.Children(end); %SelectedHandle needs to be a patch object
                    
                case 'BookShelf'
                    %Build BookShelf
                    BookShelfBound=[Foundations.PartitionL+0.28;Foundations.FloorW+0.36;0.2;0.15];
                    BookShelfGroup=DrawingFurniture(PrimeAx,'BookShelf',BookShelfBound);
                    SelectedHandle=BookShelfGroup.Children(end); %SelectedHandle needs to be a patch object
            end
        end
    end
end
end
function MouseMoveCB(PrimeFig,~)
global SelectedHandle
%Checks if PrimeFig.UserData=1, and if so, translate furniture into current cursor
%position

if ~PrimeFig.UserData
    return
end

%Obtain PrimeAx
PrimeAx=PrimeFig.Children(1);

%Check if selected handle is valid and belongs to an unset selected
%furniture. if not, return
if (GraphicsPlaceHolder(SelectedHandle))%checks SelectedHandle isnt empty
    return
elseif ~Child2Transformation(SelectedHandle) %checks if furniture
        return
else
    FTrans=SelectedHandle.Parent; %obtain funiture group object
    if ~isequal(FTrans.Children(1).Color,[1 0 0])||~strcmp(FTrans.Children(1).Visible,'on')
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
Translate(FTrans,-T(1),-T(2))

%Obtain position of cursor
CursorPos = get(PrimeAx,'CurrentPoint'); %2by2 Matrix. first row describes current location
%Translate furniture to new location
Translate(FTrans,CursorPos(1,1),CursorPos(1,2))

%Refresh
drawnow;
end
function MouseUpCB(PrimeFig,~)
global SelectedHandle
%Unset Mouse Down
PrimeFig.UserData=0;

%Set furniture
SetSelectedFurniture(SelectedHandle,PrimeFig);
end