unit LuaProgressBar;

interface

Uses Classes, Controls, Contnrs, LuaPas, LuaControl, Forms, ComCtrls, TypInfo;

function CreateProgressBar(L: Plua_State): Integer; cdecl;

type
	TLuaProgressBar = class(TProgressBar)
	   LuaCtl: TLuaControl;
    end;

// ***********************************************
implementation

Uses LuaProperties, Lua;

function DoStepIt(L: Plua_State): Integer; cdecl;
var
  lProgressBar:TLuaProgressBar;
begin
  CheckArg(L, 1);
  lProgressBar := TLuaProgressBar(GetLuaObject(L, 1));
  lProgressBar.StepIt;
  Result := 0;
end;

// ***********************************************
// LUA ProgressBar Events
// ***********************************************
procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  // LuaSetTableFunction(L, Index, 'Image', ControlGlyph);
  LuaSetTableFunction(L, index, 'StepIt', DoStepIt);

  //lua_pushnumber(L,4);
  //lua_pushliteral(L,'n');
  //lua_rawset(L,-3);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);

end;

function CreateProgressBar(L: Plua_State): Integer; cdecl;
var
  lProgressBar:TLuaProgressBar;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lProgressBar := TLuaProgressBar.Create(Parent);
  lProgressBar.Parent := TWinControl(Parent);
  lProgressBar.LuaCtl := TLuaControl.Create(lProgressBar,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lProgressBar),-1)
  else 
     lProgressBar.Name := Name;
  ToTable(L, -1, lProgressBar);
  Result := 1;
end;


end.
