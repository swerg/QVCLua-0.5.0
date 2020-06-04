unit LuaFileDialog;

interface

uses
  Classes, SysUtils, LuaControl, Dialogs, LuaPas;

  type
    TLuaOpenDialog = class(TOpenDialog)
       LuaCtl: TLuaControl;
    end;

    TLuaSaveDialog = class(TSaveDialog)
       LuaCtl: TLuaControl;
    end;

    TLuaSelectDirectoryDialog = class(TSelectDirectoryDialog)
       LuaCtl: TLuaControl;
    end;

    TLuaColorDialog = class(TColorDialog)
       LuaCtl: TLuaControl;
    end;

    TLuaFontDialog = class(TFontDialog)
       LuaCtl: TLuaControl;
    end;

function CreateOpenDialog(L: Plua_State): Integer; cdecl;
function CreateSaveDialog(L: Plua_State): Integer; cdecl;
function CreateSelectDirectoryDialog(L: Plua_State): Integer; cdecl;
function CreateColorDialog(L: Plua_State): Integer; cdecl;
function CreateFontDialog(L: Plua_State): Integer; cdecl;


implementation

Uses LuaProperties, Lua, Typinfo;

function OpenExecute(L: Plua_State): Integer; cdecl;
var
  d: TLuaOpenDialog;
  i: Integer;
begin
  d := TLuaOpenDialog(GetLuaObject(L, 1));
  if lua_istable(L, 2) then
     SetPropertiesFromLuaTable(L,d,2);
  if d.Execute then begin
    if d.Files.Count > 1 then begin
      lua_newtable(L);
      for i:= 0 to d.Files.Count-1 do begin
        lua_pushnumber(L,i+1);
        lua_pushstring(L,pchar(d.Files[i]));
        lua_rawset(L,-3);
      end;
    end else
      lua_pushstring(L,pchar(d.FileName))
  end
  else begin
    lua_pushnil(L);
  end;
  Result := 1;
end;

procedure OpenToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Execute', @OpenExecute);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

function SaveExecute(L: Plua_State): Integer; cdecl;
var
  d: TLuaSaveDialog;
  i: Integer;
begin
  d := TLuaSaveDialog(GetLuaObject(L, 1));
  if lua_istable(L, 2) then
     SetPropertiesFromLuaTable(L,d,2);
  if d.Execute then begin
    if d.Files.Count > 1 then begin
      lua_newtable(L);
      for i:= 0 to d.Files.Count-1 do begin
        lua_pushnumber(L,i+1);
        lua_pushstring(L,pchar(d.Files[i]));
        lua_rawset(L,-3);
      end;
    end else
      lua_pushstring(L,pchar(d.FileName))
  end
  else
    lua_pushnil(L);
  Result := 1;
end;

procedure SaveToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Execute', @SaveExecute);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

function SelectDirectoryExecute(L: Plua_State): Integer; cdecl;
var
  d: TLuaSelectDirectoryDialog;
  i: Integer;
begin
  d := TLuaSelectDirectoryDialog(GetLuaObject(L, 1));
  if lua_istable(L, 2) then
     SetPropertiesFromLuaTable(L,d,2);
  if d.Execute then begin
    if d.Files.Count > 1 then begin
      lua_newtable(L);
      for i:= 0 to d.Files.Count-1 do begin
        lua_pushnumber(L,i+1);
        lua_pushstring(L,pchar(d.Files[i]));
        lua_rawset(L,-3);
      end;
    end else
      lua_pushstring(L,pchar(d.FileName))
  end
  else
    lua_pushnil(L);
  Result := 1;
end;

procedure SelectDirectoryToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Execute', @SelectDirectoryExecute);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;


function ColorExecute(L: Plua_State): Integer; cdecl;
var
  d: TLuaColorDialog;
begin
  d := TLuaColorDialog(GetLuaObject(L, 1));
  if lua_istable(L, 2) then
     SetPropertiesFromLuaTable(L,d,2);
  if d.Execute then
     lua_pushnumber(L,d.Color)
  else
    lua_pushnil(L);
  Result := 1;
end;

procedure ColorToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Execute', @ColorExecute);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

function FontExecute(L: Plua_State): Integer; cdecl;
var
  d: TLuaFontDialog;
begin
  d := TLuaFontDialog(GetLuaObject(L, 1));
  if lua_istable(L, 2) then
     SetPropertiesFromLuaTable(L,d,2);
  if d.Execute then begin
     lua_newtable(L);
     lua_pushliteral(L,'Color');
     lua_pushnumber(L,d.Font.Color);
     lua_rawset(L,-3);
     lua_pushliteral(L,'Height');
     lua_pushnumber(L,d.Font.Height);
     lua_rawset(L,-3);
     lua_pushliteral(L,'Name');
     lua_pushstring(L,pchar(d.Font.Name));
     lua_rawset(L,-3);
     lua_pushliteral(L,'Orientation');
     lua_pushnumber(L,d.Font.Orientation);
     lua_rawset(L,-3);
     lua_pushliteral(L,'Pitch');
     lua_pushstring(L,pchar(GetEnumProp(d.font,'Pitch')));
     lua_rawset(L,-3);
     lua_pushliteral(L,'Quality');
     lua_pushstring(L,pchar(GetEnumProp(d.font,'Quality')));
     lua_rawset(L,-3);
     lua_pushliteral(L,'Size');
     lua_pushnumber(L,d.Font.Size);
     lua_rawset(L,-3);
     lua_pushliteral(L,'Style');
     lua_pushstring(L,pchar(GetSetProp(d.font,'Style',true)));
     lua_rawset(L,-3);
  end
  else
    lua_pushnil(L);
  Result := 1;
end;

procedure FontToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Execute', @FontExecute);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

// ******************************************************************

function CreateOpenDialog(L: Plua_State): Integer; cdecl;
var
  fd:TLuaOpenDialog;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  fd := TLuaOpenDialog.Create(Parent);
  fd.LuaCtl := TLuaControl.Create(fd,L,@OpenToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(fd),-1)
  else
     fd.Name := Name;
  OpenToTable(L, -1, fd);
  Result := 1;
end;

function CreateSaveDialog(L: Plua_State): Integer; cdecl;
var
  fd:TLuaSaveDialog;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  fd := TLuaSaveDialog.Create(Parent);
  fd.LuaCtl := TLuaControl.Create(fd,L,@SaveToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(fd),-1)
  else 
     fd.Name := Name;
  SaveToTable(L, -1, fd);
  Result := 1;
end;

function CreateSelectDirectoryDialog(L: Plua_State): Integer; cdecl;
var
  fd:TLuaSelectDirectoryDialog;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  fd := TLuaSelectDirectoryDialog.Create(Parent);
  fd.LuaCtl := TLuaControl.Create(fd,L,@SelectDirectoryToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(fd),-1)
  else 
     fd.Name := Name;
  SelectDirectoryToTable(L, -1, fd);
  Result := 1;
end;

function CreateColorDialog(L: Plua_State): Integer; cdecl;
var
  fd:TLuaColorDialog;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  fd := TLuaColorDialog.Create(Parent);
  fd.LuaCtl := TLuaControl.Create(fd,L,@ColorToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(fd),-1)
  else 
     fd.Name := Name;
  ColorToTable(L, -1, fd);
  Result := 1;
end;

function CreateFontDialog(L: Plua_State): Integer; cdecl;
var
  fd:TLuaFontDialog;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  fd := TLuaFontDialog.Create(Parent);
  fd.LuaCtl := TLuaControl.Create(fd,L,@FontToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(fd),-1)
  else 
     fd.Name := Name;
  FontToTable(L, -1, fd);
  Result := 1;
end;

end.

