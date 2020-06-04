unit LuaFileListBox;	
interface
Uses Classes, Controls, FileCtrl, TypInfo, LuaPas, LuaControl;
function CreateFileListBox(L: Plua_State): Integer; cdecl;
type
    TLuaFileListBox = class(TFileListBox)
          LuaCtl: TLuaControl;
        published
          property Drive default ' ';
          property FileName;
          property Items;
    end;
implementation
Uses LuaProperties, Lua;
procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateFileListBox(L: Plua_State): Integer; cdecl;
var
  lFileListBox:TLuaFileListBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lFileListBox := TLuaFileListBox.Create(Parent);
  lFileListBox.Parent := TWinControl(Parent);
  lFileListBox.LuaCtl := TLuaControl.Create(lFileListBox,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lFileListBox),-1)
  else
     lFileListBox.Name := Name;
  ToTable(L, -1, lFileListBox);
  Result := 1;
end;
end.
