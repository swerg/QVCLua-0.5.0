unit LuaListBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateListBox(L: Plua_State): Integer; cdecl;
type
    TLuaListBox = class(TListBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaListBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ListBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lListBox:TLuaListBox;
begin
  lListBox := TLuaListBox(GetLuaObject(L, 1));
  lListBox.LuaCanvas.ToTable(L, -1, lListBox.Canvas);
  result := 1;
end;
{$ENDIF}
procedure ListBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  SetStringList3Methods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ListBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateListBox(L: Plua_State): Integer; cdecl;
var
  lListBox:TLuaListBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lListBox := TLuaListBox.Create(Parent);
  lListBox.Parent := TWinControl(Parent);
  lListBox.LuaCtl := TLuaControl.Create(lListBox,L,@ListBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lListBox),-1)
  else
     lListBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lListBox.InheritsFrom(TCustomControl) or lListBox.InheritsFrom(TGraphicControl) or
	  lListBox.InheritsFrom(TLCLComponent)) then
    lListBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ListBoxToTable(L, -1, lListBox);
  Result := 1;
end;
end.
