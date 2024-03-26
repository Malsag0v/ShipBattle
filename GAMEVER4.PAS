program game;

uses Graph, Objects, Drivers, Views, Menus, Dialogs, App, Crt;

const
  cmNewGame = 101;
  cmNewDialog = 102;
  cmGraph = 103;
  cmCloseGraph = 104;
  FieldSize = 10;
  CellSize = 30;


type
  DialogData = record
    RadioButtonData: Word;
  end;

type GameField = array[1..FieldSize, 1..FieldSize] of integer;
type GameFieldEdges = array[1..FieldSize] of char;


  PGameDisplay = ^TGameDisplay;
  TGameDisplay = object(TBackGround)
    procedure Draw; virtual;
  end;

  TMyApp = object(TApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure NewDialog;
    procedure InitGame;
    procedure GamePole(var Field, Field2: GameField; var FieldNumbers, FieldLetters: GameFieldEdges);
    procedure GraphicOnOff;
  end;

  PDemoDialog = ^TDemoDialog;
  TDemoDialog = object(TDialog)
  end;

var
  DemoDialogData: DialogData;
  GraphicMode: Boolean;
  i, j, x, y: integer;
  ch,sh:char;
  Field: GameField;
  Field2: GameField;
  FieldNumbers:GameFieldEdges;
  FieldLetters:GameFieldEdges;
  

procedure InitGraphic;
var Driver, Mode: Integer;
begin
  Driver := VGA;
  Mode := VGAHi;
  InitGraph(Driver, Mode, 'C:\TP\BGI');
end;

{ TGameDisplay }
procedure TGameDisplay.Draw;
begin
  inherited Draw;
end;

{ TMyApp }
procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNewDialog: NewDialog;
      cmGraph: GraphicOnOff;
	  cmNewGame: GamePole(Field, Field2, FieldNumbers, FieldLetters);
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TMyApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~M~enu', hcNoContext, NewMenu(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      NewItem('~N~ew game', 'Alt-N', kbAltN, cmNewGame, hcNoContext,
      NewItem('~S~ettings', 'Alt-S', kbAltS, cmNewDialog, hcNoContext,
      NewItem('~I~nit Graph', 'F5', kbF5, cmGraph, hcNoContext,
      nil))))), nil))));
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F4~ New game', kbF4, cmNewGame,
      NewStatusKey('~Alt-S~ Settings', kbAltS, cmNewDialog,
      NewStatusKey('~F5~ Graphic', kbF5, cmGraph,
      nil))))),
    nil)
  ));
end;

procedure TMyApp.NewDialog;
var
  Bruce: PView;
  Dialog: PDemoDialog;
  R: TRect;
  C: Word;
begin
  R.Assign(20, 6, 42, 16);
  Dialog := New(PDemoDialog, Init(R, 'Settings'));
  with Dialog^ do
  begin
    R.Assign(2, 3, 20, 6);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~E~asy level',
      NewSItem('~N~ormal level',
      NewSItem('~H~ard level',
      nil)))
    ));
    Insert(Bruce);
    R.Assign(5, 2, 16, 3);
    Insert(New(PLabel, Init(R, 'Difficulty', Bruce)));
    R.Assign(2, 7, 8, 9);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(9, 7, 19, 9);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(DemoDialogData);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(DemoDialogData);
  Dispose(Dialog, Done);
end;

procedure TMyApp.InitGame;
var
  R: TRect;
  GameWindow: PGameDisplay;
begin
  R.Assign(2, 2, 78, 23);
  GameWindow := New(PGameDisplay, Init(R, char(0)));
  Insert(GameWindow);
end;


procedure GamefieldInit(var Field, Field2: GameField);
var i, j, x, y: Integer;
begin
  for i := 1 to FieldSize do
    for j := 1 to FieldSize do
      Field[i, j] := 0;

  for x := 1 to FieldSize do
    for y := 1 to FieldSize do
      Field2[x, y] := 0;
end;


procedure  TMyApp.GamePole(var Field, Field2: GameField ; var FieldNumbers, FieldLetters: GameFieldEdges);
var i, j, x, y: integer;
	ch, sh:char;
begin
if GraphicMode then begin
	line(315, 20, 315, getmaxy);
	line(0,340,getmaxx, 340);
	ch:='a';
	sh:='1';
  for i := 1 to FieldSize do begin
	FieldNumbers[i]:= sh; 
	FieldLetters[i]:= ch;
	sh:=succ(sh);
	ch:=succ(ch);
	OutTextXY(i*CellSize-15, 20, FieldLetters[i]);
	OutTextXY(10, i*CellSize-15, FieldNumbers[i]);
    for j := 1 to FieldSize do
      if Field[i, j] = 0 then
        rectangle((j) * CellSize, (i) * CellSize, (j+1) * CellSize, (i+1) * CellSize);
		OutTextXY(120, 10, 'Your Field');
  end;
  	ch:='a';
	sh:='1';
  for x := 1 to FieldSize do begin
	FieldNumbers[i]:= sh; 
	FieldLetters[i]:= ch;
	sh:=succ(sh);
	ch:=succ(ch);
	OutTextXY((x+11)*CellSize-15, 20, FieldLetters[i]);
	OutTextXY(632, (x)*CellSize+15, FieldNumbers[i]);
    for y := 1 to FieldSize do
      if Field2[x, y] = 0 then
        rectangle((y+11) * CellSize, (x) * CellSize, (y+12) * CellSize, (x+1) * CellSize);
		OutTextXY(450, 10, 'Enemy Field');
end;
end;
end;


{procedure FillPole(var Field:GameField);
var
begin
end;}

procedure TMyApp.GraphicOnOff;
var MyApp:TMyApp;
begin

  if GraphicMode then begin
	CloseGraph;
        TMyApp.Done;
        TMyApp.Init;
	end
  else
	begin
    InitGraphic;
    GamefieldInit(Field,Field2);
    GamePole(Field, Field2, FieldNumbers, FieldLetters);
	end;
  GraphicMode := not GraphicMode;
end;



var
  MyApp: TMyApp;

begin
  with DemoDialogData do
  begin
    RadioButtonData := 2;
  end;
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.