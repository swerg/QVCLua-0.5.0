unit LuaFindDialog;

interface

uses
  Classes, SysUtils, LuaControl, Dialogs, LuaPas;

  type
    TLuaFindDialog = class(TFindDialog)
       LuaCtl: TLuaControl;
    end;

    TLuaReplaceDialog = class(TReplaceDialog)
       LuaCtl: TLuaControl;
    end;

function CreateFindDialog(L: Plua_State): Integer; cdecl;
function CreateReplaceDialog(L: Plua_State): Integer; cdecl;

implementation

Uses Lua, LuaProperties;

function FindExecute(L: Plua_State): Integer; cdecl;
var
  fd: TLuaFindDialog;
begin
  CheckArg(L, 1);
  fd := TLuaFindDialog(GetLuaObject(L, 1));
  lua_pushboolean(L, fd.Execute);
  Result := 1;
end;

function FindCloseDialog(L: Plua_State): Integer; cdecl;
var
  fd: TLuaFindDialog;
begin
  CheckArg(L, 1);
  fd := TLuaFindDialog(GetLuaObject(L, 1));
  fd.CloseDialog;
  Result := 0;
end;

function FindClose(L: Plua_State): Integer; cdecl;
var
  fd: TLuaFindDialog;
begin
  CheckArg(L, 1);
  fd := TLuaFindDialog(GetLuaObject(L, 1));
  fd.Close;
  Result := 0;
end;

procedure FindToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Execute', @FindExecute);
  LuaSetTableFunction(L, Index, 'CloseDialog', @FindCloseDialog);
  LuaSetTableFunction(L, Index, 'Close', @FindClose);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

function CreateFindDialog(L: Plua_State): Integer; cdecl;
var
  fd:TLuaFindDialog;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  fd := TLuaFindDialog.Create(Parent);
  fd.LuaCtl := TLuaControl.Create(fd,L,@FindToTable);
  fd.Options:= [frDown];
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(fd),-1)
  else 
     fd.Name := Name;
  FindToTable(L, -1, fd);
  Result := 1;
end;

// ******************************************************************

function ReplaceExecute(L: Plua_State): Integer; cdecl;
var
  fd: TLuaReplaceDialog;
begin
  CheckArg(L, 1);
  fd := TLuaReplaceDialog(GetLuaObject(L, 1));
  lua_pushboolean(L,fd.Execute);
  Result := 1;
end;

function ReplaceCloseDialog(L: Plua_State): Integer; cdecl;
var
  fd: TLuaReplaceDialog;
begin
  CheckArg(L, 1);
  fd := TLuaReplaceDialog(GetLuaObject(L, 1));
  fd.CloseDialog;
  Result := 0;
end;

function ReplaceClose(L: Plua_State): Integer; cdecl;
var
  fd: TLuaReplaceDialog;
begin
  CheckArg(L, 1);
  fd := TLuaReplaceDialog(GetLuaObject(L, 1));
  fd.Close;
  Result := 0;
end;

procedure ReplaceToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Execute', @ReplaceExecute);
  LuaSetTableFunction(L, Index, 'CloseDialog', @ReplaceCloseDialog);
  LuaSetTableFunction(L, Index, 'Close', @ReplaceClose);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

function CreateReplaceDialog(L: Plua_State): Integer; cdecl;
var
  fd:TLuaReplaceDialog;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  fd := TLuaReplaceDialog.Create(Parent);
  fd.LuaCtl := TLuaControl.Create(fd,L,@ReplaceToTable);
  fd.Options:= [frDown];
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(fd),-1)
  else 
     fd.Name := Name;
  ReplaceToTable(L, -1, fd);
  Result := 1;
end;

end.

