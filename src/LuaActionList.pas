unit LuaActionList;	

interface

Uses Classes, Controls, ComCtrls, ExtCtrls, Buttons, Forms, StdCtrls, Spin, ActnList, TypInfo, LuaPas, LuaControl;

function CreateActionList(L: Plua_State): Integer; cdecl;
function CreateAction(L: Plua_State): Integer; cdecl;

type
    TLuaActionList = class(TActionList)
        LuaCtl: TLuaControl;
    end;

    TLuaAction = class(TAction)
        LuaCtl: TLuaControl;
    end;

implementation

Uses LuaProperties, Lua, SysUtils, LCLProc;

// Action

procedure ActionToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateAction(L: Plua_State): Integer; cdecl;
var
  lAction:TLuaAction;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lAction := TLuaAction.Create(Parent);
  lAction.LuaCtl := TLuaControl.Create(lAction,L,@ActionToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lAction),-1)
  else 
     lAction.Name := Name;
  ActionToTable(L, -1, lAction);
  Result := 1;
end;

function NewAction(L: Plua_State; List:TLuaActionList): TLuaAction;
var
  lAction:TLuaAction;
begin
  lAction := TLuaAction.Create(List);
  lAction.LuaCtl := TLuaControl.Create(lAction,L,@ActionToTable);
  lAction.ActionList := List;
  Result := lAction;
end;

// ActionList

function LoadFromLuaTable(L: Plua_State): Integer; cdecl;
var n,m: Integer;
    lActionList:TLuaActionList;
    lAction: TLuaAction;
    PInfo: PPropInfo;
begin
  result := 0;
  lActionList := TLuaActionList(GetLuaObject(L, 1));
  if lua_istable(L,-1) then begin
     n := lua_gettop(L);
     lua_pushnil(L);
     while (lua_next(L, n) <> 0) do begin
         if lua_istable(L,-1) then begin
            lAction := NewAction(L,lActionList);
            m := lua_gettop(L);
            lua_pushnil(L);
            while (lua_next(L, m) <> 0) do begin

              PInfo := GetPropInfo(TComponent(lAction).ClassInfo,lua_tostring(L, -2));
              if PInfo <> nil then begin
              try
  	          SetProperty(L, -1, lAction, PInfo);
              except
            	  break;
              end;
              end else
                  LuaError(L,'Action property not found!',lua_tostring(L, -2));

              // Still bug in  LuaProperties
              if (UpperCase(lua_tostring(L,-2))='SHORTCUT') then
                  lAction.ShortCut := TextToShortCut(lua_tostring(L,-1));

               lua_pop(L, 1);
            end;
         end;
         lua_pop(L, 1);
     end;
  end;
end;

function GetAction(L: Plua_State): Integer; cdecl;
var
    lActionList:TLuaActionList;
    lAction: TLuaAction;
    n: Integer;
    s: String;
begin
  result := 1;
  lActionList := TLuaActionList(GetLuaObject(L, 1));
  if (lua_isnumber(L,2)) then begin
      ActionToTable(L, -1, lActionList.Actions[trunc(lua_tonumber(L,2))-1]);
  end else if (lua_isstring(L,2)) then begin
      ActionToTable(L, -1, lActionList.ActionByName(lua_tostring(L,2)));
  end else
      lua_pushnil(L);
end;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);

  LuaSetTableFunction(L, index, 'LoadFromTable', LoadFromLuaTable);
  LuaSetTableFunction(L, index, 'Get', GetAction);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateActionList(L: Plua_State): Integer; cdecl;
var
  lActionList:TLuaActionList;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);	
  lActionList := TLuaActionList.Create(Parent);
  lActionList.LuaCtl := TLuaControl.Create(lActionList,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lActionList),-1)
  else 
     lActionList.Name := Name;
	 
  ToTable(L, -1, lActionList);
  Result := 1;
end;

end.
