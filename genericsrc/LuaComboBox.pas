unit LuaComboBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateComboBox(L: Plua_State): Integer; cdecl;
type
    TLuaComboBox = class(TComboBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaComboBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ComboBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lComboBox:TLuaComboBox;
begin
  lComboBox := TLuaComboBox(GetLuaObject(L, 1));
  lComboBox.LuaCanvas.ToTable(L, -1, lComboBox.Canvas);
  result := 1;
end;
{$ENDIF}
procedure ComboBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ComboBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateComboBox(L: Plua_State): Integer; cdecl;
var
  lComboBox:TLuaComboBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lComboBox := TLuaComboBox.Create(Parent);
  lComboBox.Parent := TWinControl(Parent);
  lComboBox.LuaCtl := TLuaControl.Create(lComboBox,L,@ComboBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lComboBox),-1)
  else
     lComboBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lComboBox.InheritsFrom(TCustomControl) or lComboBox.InheritsFrom(TGraphicControl) or
	  lComboBox.InheritsFrom(TLCLComponent)) then
    lComboBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ComboBoxToTable(L, -1, lComboBox);
  Result := 1;
end;
end.
