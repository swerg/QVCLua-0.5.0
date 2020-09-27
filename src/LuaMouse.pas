unit LuaMouse;

interface

Uses Classes, Controls, Contnrs,
  {$IFDEF LUA53}
    Lua53
  {$ELSE}
    LuaPas
  {$ENDIF}
  , Forms, ExtCtrls, TypInfo;

function GetCursorPos(L: Plua_State): Integer; cdecl;

// ***********************************************
implementation

Uses LuaControl, LuaProperties, Lua;

function GetCursorPos(L: Plua_State): Integer; cdecl;
begin
  lua_pushnumber(L,Mouse.CursorPos.X);
  lua_pushnumber(L,Mouse.CursorPos.Y);
  Result := 2;
end;

end.
