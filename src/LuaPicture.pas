unit LuaPicture;

interface

Uses ExtCtrls, Controls, Classes,
     LuaPas, Lua, LuaProperties,
     Graphics;

type
	TLuaPicture = class(TPicture)
          public
            L:Plua_State;
            procedure ToTable(LL:Plua_State; Index:Integer; Sender:TObject);
        end;

implementation

Uses TypInfo;

procedure TLuaPicture.ToTable(LL:Plua_State; Index:Integer; Sender:TObject);
begin
  L := LL;
  lua_newtable(L);
  LuaSetTableLightUserData(L, Index, HandleStr, Pointer(GetInt64Prop(Sender,'Picture')));
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

end.

