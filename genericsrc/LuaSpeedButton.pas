unit LuaSpeedButton;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateSpeedButton(L: Plua_State): Integer; cdecl;
type
    TLuaSpeedButton = class(TSpeedButton)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaSpeedButton.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function SpeedButtonGetCanvas(L: Plua_State): Integer; cdecl;
var lSpeedButton:TLuaSpeedButton;
begin
  lSpeedButton := TLuaSpeedButton(GetLuaObject(L, 1));
  lSpeedButton.LuaCanvas.ToTable(L, -1, lSpeedButton.Canvas);
  result := 1;
end;
{$ENDIF}
procedure SpeedButtonToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetTableFunction(L, index, 'GetGlyph', ControlGetGlyph);
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', SpeedButtonGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateSpeedButton(L: Plua_State): Integer; cdecl;
var
  lSpeedButton:TLuaSpeedButton;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lSpeedButton := TLuaSpeedButton.Create(Parent);
  lSpeedButton.Parent := TWinControl(Parent);
  lSpeedButton.LuaCtl := TLuaControl.Create(lSpeedButton,L,@SpeedButtonToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lSpeedButton),-1)
  else
     lSpeedButton.Name := Name;
  {$IFDEF HASCANVAS}
  if (lSpeedButton.InheritsFrom(TCustomControl) or lSpeedButton.InheritsFrom(TGraphicControl) or
	  lSpeedButton.InheritsFrom(TLCLComponent)) then
    lSpeedButton.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  SpeedButtonToTable(L, -1, lSpeedButton);
  Result := 1;
end;
end.
