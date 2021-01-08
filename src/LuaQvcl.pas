unit LuaQvcl;

interface

Uses Classes, Types, Controls,
  {$IF Defined(LUA54)}
    Lua54
  {$ELSEIF Defined(LUA53)}
    Lua53
  {$ELSE}
    LuaPas
  {$ENDIF}
;

function SetDebugMode(L: Plua_State): Integer; cdecl;

procedure QvclDebugMessage(text: String; addText:String='');

implementation

Uses
//LuaProperties, Lua, SysUtils, ExtCtrls, Graphics, Windows, LMessages;
Lua, Dialogs;

var IsDebugMode : Boolean = False;

// ***********************************************
function SetDebugMode(L: Plua_State): Integer; cdecl;
begin
  CheckArg(L, 1);
  IsDebugMode := lua_toboolean(L, 1);
  Result := 0;
end;

procedure QvclDebugMessage(text: String; addText:String='');
begin
  if NOT IsDebugMode then
    Exit;

  if (addText <> '') then begin
    text := text + ' (' + addText + ')';
  end;
  MessageDlg('QVcl Debug:'+#10#13+text, mtInformation, [mbOk], 0);
end;



end.
