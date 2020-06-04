unit LuaCheckBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateCheckBox(L: Plua_State): Integer; cdecl;
type
    TLuaCheckBox = class(TCheckBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaCheckBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function CheckBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lCheckBox:TLuaCheckBox;
begin
  lCheckBox := TLuaCheckBox(GetLuaObject(L, 1));
  lCheckBox.LuaCanvas.ToTable(L, -1, lCheckBox.Canvas);
  result := 1;
end;
{$ENDIF}
procedure CheckBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', CheckBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateCheckBox(L: Plua_State): Integer; cdecl;
var
  lCheckBox:TLuaCheckBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lCheckBox := TLuaCheckBox.Create(Parent);
  lCheckBox.Parent := TWinControl(Parent);
  lCheckBox.LuaCtl := TLuaControl.Create(lCheckBox,L,@CheckBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lCheckBox),-1)
  else
     lCheckBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lCheckBox.InheritsFrom(TCustomControl) or lCheckBox.InheritsFrom(TGraphicControl) or
	  lCheckBox.InheritsFrom(TLCLComponent)) then
    lCheckBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  CheckBoxToTable(L, -1, lCheckBox);
  Result := 1;
end;
end.
