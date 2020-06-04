unit LuaXMLConfig;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, XMLCfg;
function CreateXMLConfig(L: Plua_State): Integer; cdecl;
type
    TLuaXMLConfig = class(TXMLConfig)
        LuaCtl: TLuaControl;
    end;
implementation
Uses LuaProperties, Lua;

function SetValue(L: Plua_State): Integer; cdecl;
var 
	lXMLConfig:TLuaXMLConfig;
	path,val:String;
begin
	result := 0;
	lXMLConfig := TLuaXMLConfig(GetLuaObject(L, 1));
	path := lua_tostring(L,2);
	if lua_isnil(L,3) then 
		val := ''
	else
		val := lua_tostring(L,3);
	lXMLConfig.SetValue(path,val);
end;

function GetValue(L: Plua_State): Integer; cdecl;
var 
	lXMLConfig:TLuaXMLConfig;
	path,val:String;
begin
	result := 1;
	lXMLConfig := TLuaXMLConfig(GetLuaObject(L, 1));
	path := lua_tostring(L,2);
        if lua_isnil(L,3) then
	   val := ''
	else
	    val := lua_tostring(L,3);
	lua_pushstring(L, pchar(lXMLConfig.GetValue(path,val)));
end;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetTableFunction(L, Index, 'SetValue', SetValue);
  LuaSetTableFunction(L, Index, 'GetValue', GetValue);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateXMLConfig(L: Plua_State): Integer; cdecl;
var
  lXMLConfig:TLuaXMLConfig;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lXMLConfig := TLuaXMLConfig.Create(Parent);
  lXMLConfig.LuaCtl := TLuaControl.Create(lXMLConfig,L,@ToTable); 
  lXMLConfig.StartEmpty:=false;
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lXMLConfig),-1)
  else 
     lXMLConfig.Name := Name;
  ToTable(L, -1, lXMLConfig);
  Result := 1;
end;
end.
