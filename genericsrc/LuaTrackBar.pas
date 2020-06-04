unit LuaTrackBar;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateTrackBar(L: Plua_State): Integer; cdecl;
type
    TLuaTrackBar = class(TTrackBar)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaTrackBar.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function TrackBarGetCanvas(L: Plua_State): Integer; cdecl;
var lTrackBar:TLuaTrackBar;
begin
  lTrackBar := TLuaTrackBar(GetLuaObject(L, 1));
  lTrackBar.LuaCanvas.ToTable(L, -1, lTrackBar.Canvas);
  result := 1;
end;
{$ENDIF}
procedure TrackBarToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', TrackBarGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateTrackBar(L: Plua_State): Integer; cdecl;
var
  lTrackBar:TLuaTrackBar;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lTrackBar := TLuaTrackBar.Create(Parent);
  lTrackBar.Parent := TWinControl(Parent);
  lTrackBar.LuaCtl := TLuaControl.Create(lTrackBar,L,@TrackBarToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lTrackBar),-1)
  else
     lTrackBar.Name := Name;
  {$IFDEF HASCANVAS}
  if (lTrackBar.InheritsFrom(TCustomControl) or lTrackBar.InheritsFrom(TGraphicControl) or
	  lTrackBar.InheritsFrom(TLCLComponent)) then
    lTrackBar.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  TrackBarToTable(L, -1, lTrackBar);
  Result := 1;
end;
end.
