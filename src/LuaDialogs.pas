unit LuaDialogs;

interface

Uses LuaPas, Controls, Dialogs, Sysutils;

function LuaShowMessage(L: Plua_State): Integer; cdecl;
function LuaMessageDlg(L: Plua_State): Integer; cdecl;


implementation

Uses Lua, Typinfo;

// ***********************************************
function LuaShowMessage(L: Plua_State): Integer; cdecl;
begin
  ShowMessage(AnsiToUTF8(lua_tostring(L,-1)));
  Result := 0;
end;

procedure AddToButtonSet(var BSet:TMsgDlgButtons; But:String);
begin
    Include(BSet,TMsgDlgBtn(GetEnumValue(TypeInfo(TMsgDlgBtn),But)));
end;

// mtConfirmation
// mtInformation
// mtError
function LuaMessageDlg(L: Plua_State): Integer; cdecl;
var
  res: Integer;
  Mdb: TMsgDlgButtons;
  n:   Integer;
  Caption: String;
  Msg: String;
  MsgType: TMsgDlgType;
  Param_msg, Param_type, Param_btn: Integer;
begin
    try
  n := lua_gettop(L);
  if (n < 3) OR (n > 4) then
  begin
    LuaError(L, 'MessageDlg() function should be called with 3 or 4 parameters');
    Result := 0;
  end
  else
  begin
    if n = 4 then
    begin
      Caption := AnsiToUTF8(lua_tostring(L,1));
      Param_msg := 2;
      Param_type := 3;
      Param_btn := 4;
    end
    else
    begin
      Param_msg := 1;
      Param_type := 2;
      Param_btn := 3;
    end;
    Msg := AnsiToUTF8(lua_tostring(L,Param_msg));
    MsgType := TMsgDlgType(GetEnumValue(TypeInfo(TMsgDlgType),lua_tostring(L,Param_type)));
    Mdb := [];
    if lua_istable(L,Param_btn) then begin
       lua_pushnil(L);
       while (lua_next(L, n) <> 0) do begin
          AddToButtonSet(Mdb,lua_tostring(L, -1));
          lua_pop(L, 1);
       end;
    end else
      AddToButtonSet(Mdb,lua_tostring(L,Param_btn));

    if n = 4 then
      res := MessageDlg( Caption, Msg, MsgType, Mdb, 0 )
    else
      res := MessageDlg( Msg, MsgType, Mdb, 0 );
    lua_pushstring(L,pchar(ButtonResult[res]));
    Result := 1;
  end;

    except
//      LuaError(L, 'MessageDlg() function should called with 3 or 4 parameters');
      on e: Exception do
      begin
      lua_pushstring(L,pchar('@@@' + e.Message));
      lua_error(L);
      Result := 0;
      end
    end;
end;

end.
