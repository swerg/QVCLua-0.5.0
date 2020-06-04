unit LuaRadioButton;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateRadioButton(L: Plua_State): Integer; cdecl;
type
    TLuaRadioButton = class(TRadioButton)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaRadioButton.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function RadioButtonGetCanvas(L: Plua_State): Integer; cdecl;
var lRadioButton:TLuaRadioButton;
begin
  lRadioButton := TLuaRadioButton(GetLuaObject(L, 1));
  lRadioButton.LuaCanvas.ToTable(L, -1, lRadioButton.Canvas);
  result := 1;
end;
{$ENDIF}
procedure RadioButtonToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', RadioButtonGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateRadioButton(L: Plua_State): Integer; cdecl;
var
  lRadioButton:TLuaRadioButton;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lRadioButton := TLuaRadioButton.Create(Parent);
  lRadioButton.Parent := TWinControl(Parent);
  lRadioButton.LuaCtl := TLuaControl.Create(lRadioButton,L,@RadioButtonToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lRadioButton),-1)
  else
     lRadioButton.Name := Name;
  {$IFDEF HASCANVAS}
  if (lRadioButton.InheritsFrom(TCustomControl) or lRadioButton.InheritsFrom(TGraphicControl) or
	  lRadioButton.InheritsFrom(TLCLComponent)) then
    lRadioButton.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  RadioButtonToTable(L, -1, lRadioButton);
  Result := 1;
end;
end.
