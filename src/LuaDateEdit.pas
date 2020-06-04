unit LuaDateEdit;	
interface
Uses Classes, Controls, EditBtn, Buttons, Forms, TypInfo, LuaPas, LuaControl;
function CreateDateEdit(L: Plua_State): Integer; cdecl;
type
    TLuaDateEdit = class(TDateEdit)
        LuaCtl: TLuaControl;
      published
        property Date;
        property Text;
    end;
implementation
Uses LuaProperties, Lua;
procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateDateEdit(L: Plua_State): Integer; cdecl;
var
  lDateEdit:TLuaDateEdit;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lDateEdit := TLuaDateEdit.Create(Parent);
  lDateEdit.Parent := TWinControl(Parent);
  lDateEdit.LuaCtl := TLuaControl.Create(lDateEdit,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lDateEdit),-1)
  else 
     lDateEdit.Name := Name;
  ToTable(L, -1, lDateEdit);
  Result := 1;
end;
end.
