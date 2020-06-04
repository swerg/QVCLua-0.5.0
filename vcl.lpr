library vcl;

{$mode Delphi}{$H+}
{$i vcldef.inc}

{$R *.res}

uses
  Classes, SysUtils,
  Interfaces, InterfaceBase,
  Forms, Controls, Graphics, Dialogs,
  {$i vcl.inc}

function luaopen_qvcl(L: Plua_State): Integer; cdecl;
begin
  luaL_openlib(L, LUA_VCL_LIBNAME, @vcl_lib, 0);
  lua_pushliteral (L, '_COPYRIGHT');
  lua_pushliteral (L, 'Copyright (C) 2006,2014 Hi-Project Ltd., 2013,2014 QVCLua www.quik2dde.ru');
  lua_settable (L, -3);
  lua_pushliteral (L, '_DESCRIPTION');
  {$IFDEF LUA52}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLua in QUIK (5.2) based on VCLua');
  {$ELSE}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLua in QUIK (5.1) based on VCLua');
  {$ENDIF}
  lua_settable (L, -3);
  lua_pushliteral (L, '_NAME');
  lua_pushliteral (L, 'QVCLua');
  lua_settable (L, -3);
  lua_pushliteral (L, '_VERSION');
  lua_pushliteral (L, '0.5.0-rev.1b4');
  lua_settable (L, -3);

  InitTotableFunc(L);

  result := 1;
end;

exports luaopen_qvcl;

end.
