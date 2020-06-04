program vcluapp;

{$i vcldef.inc}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, SysUtils, Dialogs,
  {$i vcl.inc}

{$R *.res}

function luaopen_vcl(L: Plua_State): Integer; cdecl;
begin
  luaL_openlib(L, LUA_VCL_LIBNAME, @vcl_lib, 0);
  lua_pushliteral (L, '_COPYRIGHT');
  lua_pushliteral (L, 'Copyright (C) 2006,2014 Hi-Project Ltd., 2014,2015 QVCLua www.quik2dde.ru');
  lua_settable (L, -3);
  lua_pushliteral (L, '_DESCRIPTION');
  {$IFDEF LUA52}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLUA (5.2) based on VCLua');
  {$ELSE}
     lua_pushliteral (L, 'QVCLua Visual Controls for QLUA (5.1) based on VCLua');
  {$ENDIF}
  lua_settable (L, -3);
  lua_pushliteral (L, '_NAME');
  lua_pushliteral (L, 'QVCLua');
  lua_settable (L, -3);
  lua_pushliteral (L, '_VERSION');
  lua_pushliteral (L, '0.5.0');
  lua_settable (L, -3);

  InitTotableFunc(L);

  result := 1;
end;

var luaScript, err: String;
    L: Plua_State;

function CreateMainForm(L: Plua_State): Integer; cdecl;
var
  lForm:TLuaForm;
begin
  Application.CreateForm(LuaForm.TLuaForm, lForm);
  lForm.Name := 'MainForm';
  lForm.LuaCtl := TLuaControl.Create(lForm,L, @LuaForm.ToTable);
  Randomize;
  lForm.LuaCanvas := TLuaCanvas.Create;
  lForm.Position:=poScreenCenter;
  Result := 0;
end;

begin
  RequireDerivedFormResource := False;
  Application.Initialize;
  if Application.HasOption('f','file') then
    luaScript := Application.GetOptionValue('f','file')
  else
    luaScript := ChangeFileExt(Application.ExeName, '.lua');
  if (FileExists(luaScript)) then begin
     // start LUA
     L := luaL_newstate();
     luaL_openlibs(L);
     luaopen_vcl(L);
     CreateMainForm(L);
     // execute lua script
     if (luaL_loadfile(L, PChar(luaScript)) <> 0) then begin
         lua_gettop(L);
         err := lua_tostring(L,-1);
         ShowMessage(err);
     end;
     if (lua_pcall(L, 0, LUA_MULTRET, 0) <> 0) then begin
         lua_gettop(L);
         err := lua_tostring(L,-1);
         ShowMessage(err);
     end;
  end else begin
     ShowMessage(luaScript+' not found!');
  end;

end.

