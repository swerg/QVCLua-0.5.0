unit LuaGroupBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateGroupBox(L: Plua_State): Integer; cdecl;
type
    TLuaGroupBox = class(TGroupBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaGroupBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function GroupBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lGroupBox:TLuaGroupBox;
begin
  lGroupBox := TLuaGroupBox(GetLuaObject(L, 1));
  lGroupBox.LuaCanvas.ToTable(L, -1, lGroupBox.Canvas);
  result := 1;
end;
{$ENDIF}
procedure GroupBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', GroupBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateGroupBox(L: Plua_State): Integer; cdecl;
var
  lGroupBox:TLuaGroupBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lGroupBox := TLuaGroupBox.Create(Parent);
  lGroupBox.Parent := TWinControl(Parent);
  lGroupBox.LuaCtl := TLuaControl.Create(lGroupBox,L,@GroupBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lGroupBox),-1)
  else
     lGroupBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lGroupBox.InheritsFrom(TCustomControl) or lGroupBox.InheritsFrom(TGraphicControl) or
	  lGroupBox.InheritsFrom(TLCLComponent)) then
    lGroupBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  GroupBoxToTable(L, -1, lGroupBox);
  Result := 1;
end;
end.
