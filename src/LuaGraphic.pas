unit LuaGraphic;

interface

Uses ExtCtrls, Controls, Classes,
     LuaPas, Lua, LuaProperties,
     Graphics;

type
	TLuaGraphic = class(TGraphic)
          public
            L:Plua_State;
            procedure ToTable(LL:Plua_State; Index:Integer; Sender:TObject);
        end;

implementation

Uses TypInfo;

procedure TLuaGraphic.ToTable(LL:Plua_State; Index:Integer; Sender:TObject);
begin
  L := LL;
  lua_newtable(L);
  LuaSetTableLightUserData(L, Index, HandleStr, Pointer(Sender));
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

end.

