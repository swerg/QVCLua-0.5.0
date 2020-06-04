library vcl;

{$mode Delphi}{$H+}
{$i vcldef.inc}

{$R *.res}

uses
  Classes, SysUtils,
  Interfaces, InterfaceBase,
  Forms, Controls, Graphics, Dialogs,
  {$i vcl.inc}

function luaopen_vcl(L: Plua_State): Integer; cdecl;
begin
  luaL_openlib(L, LUA_VCL_LIBNAME, @vcl_lib, 0);
  lua_pushliteral (L, '_COPYRIGHT');
  lua_pushliteral (L, 'Copyright (C) 2006,2014 Hi-Project Ltd.');
  lua_settable (L, -3);
  lua_pushliteral (L, '_DESCRIPTION');
  {$IFDEF LUA52}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLua in QUIK (5.2)');
  {$ELSE}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLua in QUIK (5.1)');
  {$ENDIF}
  lua_settable (L, -3);
  lua_pushliteral (L, '_NAME');
  lua_pushliteral (L, 'QVCLua');
  lua_settable (L, -3);
  lua_pushliteral (L, '_VERSION');
  lua_pushliteral (L, '0.5.0-r1');
  lua_settable (L, -3);

  InitTotableFunc(L);

  result := 1;
end;

exports luaopen_vcl;

end.

