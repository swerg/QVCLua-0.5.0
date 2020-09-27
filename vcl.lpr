library vcl;

{$mode Delphi}{$H+}
{$i vcldef.inc}

{$R *.res}

uses
  Classes, SysUtils,
  Interfaces, InterfaceBase,
  Forms, Controls, Graphics, Dialogs, fileinfo,
  {$i vcl.inc}

function luaopen_qvcl(L: Plua_State): Integer; cdecl;
var
   FileVerInfo: TFileVersionInfo;
begin
  // luaL_openlib is deprecated
  {$IFDEF LUA53}
     luaL_newlibtable(l, @vcl_lib);
     luaL_setfuncs(l, @vcl_lib, 0);
  {$ELSE}
     luaL_openlib(L, LUA_VCL_LIBNAME, @vcl_lib, 0);
  {$ENDIF}

  FileVerInfo:=TFileVersionInfo.Create(nil);
  try
  FileVerInfo.ReadFileInfo;

  lua_pushliteral (L, '_COPYRIGHT');
  lua_pushliteral (L, PChar(FileVerInfo.VersionStrings.Values['LegalCopyright']));
  lua_settable (L, -3);
  lua_pushliteral (L, '_DESCRIPTION');
  {$IF Defined(LUA53)}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLua in QUIK (Lua 5.3, Win64) based on VCLua');
  {$ELSEIF Defined(LUA52)}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLua in QUIK (--) based on VCLua');
  {$ELSE}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLua in QUIK (Lua 5.1, Win32) based on VCLua');
  {$ENDIF}
  lua_settable (L, -3);
  lua_pushliteral (L, '_NAME');
  lua_pushliteral (L, PChar(FileVerInfo.VersionStrings.Values['ProductName']));
  lua_settable (L, -3);
  lua_pushliteral (L, '_VERSION');
  lua_pushliteral (L, PChar(FileVerInfo.VersionStrings.Values['ProductVersion'] + ', build:' + FileVerInfo.VersionStrings.Values['FileVersion']));
  lua_settable (L, -3);

  finally
    FileVerInfo.Free;
  end;

  InitTotableFunc(L);

  result := 1;
end;

exports luaopen_qvcl;

end.
