unit LuaTable;

{$mode delphi}

interface

uses
  Classes, SysUtils, Lua, LuaPas;

procedure InitTotableFunc(L: Plua_State);

implementation

uses TypInfo;

// TStrings
procedure ToStrings(L: Plua_State; lStrings: TStrings);
var i:Integer;
begin
    lua_newtable(L);
    if Assigned(lStrings) then
    for i:= 0 to lStrings.Count-1 do begin
      lua_pushnumber(L,i+1);
      lua_pushstring(L,pchar(lStrings[i]));
      lua_rawset(L,-3);
    end;
end;

function ToLuaTable(L: Plua_State): Integer; cdecl;
var obj: TObject;
begin
     obj := GetLuaObject(L, 1);
     if obj.InheritsFrom(TStrings) then
        ToStrings(L, TStrings(obj))
     else
        lua_pushstring(L,'lua-->totable');
     Result := 1;
end;

procedure InitTotableFunc(L: Plua_State);
begin
     lua_pushcfunction(L, ToLuaTable);
     lua_setglobal(L, 'totable');
end;

end.

