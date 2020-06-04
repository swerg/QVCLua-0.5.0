unit LuaStream;

interface

Uses ExtCtrls, Controls, Classes,
     LuaPas,
     LuaControl;

function CreateStream(L: Plua_State): Integer; cdecl;

type
	TLuaStream = class(TMemoryStream)
            L:Plua_State;
        published
            property Position: Int64 read GetPosition write SetPosition;
            property Size: Int64 read GetSize write SetSize64;
        end;

implementation

Uses Lua, LuaProperties, TypInfo;

// ************ STREAM ******************** //

function LoadStreamFromFile(L: Plua_State): Integer; cdecl;
var lStream:TLuaStream;
begin
  CheckArg(L, 2);
  lStream := TLuaStream(GetLuaObject(L, 1));
  try
      lStream.LoadFromFile(lua_tostring(L,2));
      lStream.Position := 0;
      lua_pushnumber(L,lStream.Size);
  except
      lua_pushnil(L);
  end;
  result := 1;
end;

function SaveStreamToFile(L: Plua_State): Integer; cdecl;
var lStream:TLuaStream;
begin
  CheckArg(L, 2);
  lStream := TLuaStream(GetLuaObject(L, 1));
  try
      if (lStream<>nil) then begin
         lStream.Position := 0;
         lStream.SaveToFile(lua_tostring(L,2));
         lua_pushnumber(L,lStream.Size);
      end;
  except
      lua_pushnil(L);
  end;
  result := 1;
end;

function StreamGet(L: Plua_State): Integer; cdecl;
var
  lStream:TLuaStream;
begin
  CheckArg(L, 1);
  lStream := TluaStream(GetLuaObject(L, 1));
  if (lStream<>nil) then begin
     lStream.Position := 0;
     lua_pushlightuserdata(L,lStream);
  end else
     lua_pushnil(L);
  Result := 1;
end;

function StreamFree(L: Plua_State): Integer; cdecl;
var
  lStream:TLuaStream;
begin
  CheckArg(L, 1);
  lStream := TluaStream(GetLuaObject(L, 1));
  if lStream <> nil then
     lStream.Free;
  LuaSetTableClear(L, 1);
  Result := 0;
end;

function StreamGetPos(L: Plua_State): Integer; cdecl;
var
  lStream:TLuaStream;
begin
  CheckArg(L, 1);
  lStream := TluaStream(GetLuaObject(L, 1));
  if (lStream<>nil) then begin
     lua_pushnumber(L,lStream.Position);
  end else
     lua_pushnil(L);
  Result := 1;
end;

function StreamSetPos(L: Plua_State): Integer; cdecl;
var
  lStream:TLuaStream;
  pos: Int64;
begin
  CheckArg(L, 2);
  lStream := TluaStream(GetLuaObject(L, 1));
  pos := Int64(lua_tonumber(L, 2));
  if (lStream<>nil) then
     lStream.Position := pos;
  Result := 0;
end;

function StreamGetSize(L: Plua_State): Integer; cdecl;
var
  lStream:TLuaStream;
begin
  CheckArg(L, 1);
  lStream := TluaStream(GetLuaObject(L, 1));
  if (lStream<>nil) then begin
     lua_pushnumber(L,lStream.Size);
  end else
     lua_pushinteger(L,0);
  Result := 1;
end;

function StreamSetSize(L: Plua_State): Integer; cdecl;
var
  lStream:TLuaStream;
  size: Int64;
begin
  CheckArg(L, 2);
  lStream := TluaStream(GetLuaObject(L, 1));
  size := Int64(lua_toNumber(L, 2));
  if (lStream<>nil) then
     lStream.Size := size;
  Result := 0;
end;

function CreateStream(L: Plua_State): Integer; cdecl;
var
  lStream:TLuaStream;
  Index: Integer;
begin
  lStream := TLuaStream.Create;
  Index := -1;
  lua_newtable(L);
  LuaSetTableLightUserData(L, Index, HandleStr, Pointer(lStream));
  LuaSetTableFunction(L, index, 'LoadFromFile', LoadStreamFromFile);
  LuaSetTableFunction(L, index, 'SaveToFile', SaveStreamToFile);
  LuaSetTableFunction(L, index, 'Get', StreamGet);
  LuaSetTableFunction(L, index, 'GetPosition', StreamGetPos);
  LuaSetTableFunction(L, index, 'SetPosition', StreamSetPos);
  LuaSetTableFunction(L, index, 'GetSize', StreamGetSize);
  LuaSetTableFunction(L, index, 'SetSize', StreamSetSize);
  LuaSetTableFunction(L, index, 'Free', StreamFree);
  Result := 1;
end;

end.
