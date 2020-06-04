unit LuaStatusBar;

interface

Uses Classes, Controls, Contnrs, LuaPas, LuaControl, Forms, ComCtrls, TypInfo;

function CreateStatusBar(L: Plua_State): Integer; cdecl;

type
    TLuaStatusBar = class(TStatusBar)
          LuaCtl: TLuaControl;
     end;

// ***********************************************

implementation

Uses LuaProperties, Lua, Dialogs, LuaForm;

function StatusbarAdd(L: Plua_State): Integer; cdecl;
var
  lStatusBar: TLuaStatusBar;
  PanelIndex : Integer;
begin
  CheckArg(L, 3);
  lStatusBar := TLuaStatusBar(GetLuaObject(L, 1));
  lStatusBar.SimplePanel := False;  
  lStatusBar.Panels.BeginUpdate;
  PanelIndex := lStatusBar.Panels.Count - 1;
  try
      lStatusBar.Panels.Add;
      Inc(PanelIndex);
      lStatusBar.Panels.Items[PanelIndex].Width := trunc(lua_tonumber(L,2));
      lStatusBar.Panels.Items[PanelIndex].Text := lua_tostring(L,3);
  finally
      lStatusBar.Panels.EndUpdate;
  end;
  lua_pushnumber(L,PanelIndex+1);
  Result := 1;
end;

function StatusbarInsert(L: Plua_State): Integer; cdecl;
var
  lStatusBar: TLuaStatusBar;
  P: TStatusPanel;
begin
  CheckArg(L, 4);
  lStatusBar := TLuaStatusBar(GetLuaObject(L, 1));
  lStatusBar.SimplePanel := False;
  lStatusBar.Panels.BeginUpdate;
  try
  (*
      P := lStatusBar.Panels.Insert(trunc(lua_tonumber(L,2))-1);
      P.Width := trunc(lua_tonumber(L,3));
      P.Text := lua_tostring(L,4);
*)
  finally
      lStatusBar.Panels.EndUpdate;
  end;
  Result := 0;
end;

function StatusbarUpdate(L: Plua_State): Integer; cdecl;
var
  lStatusBar: TLuaStatusBar;
  P: TStatusPanel;
begin
  CheckArg(L, 3);
  lStatusBar := TLuaStatusBar(GetLuaObject(L, 1));
  lStatusBar.Panels.BeginUpdate;
  try
      if lStatusBar.Panels.Count = 0 then begin
        lStatusBar.SimplePanel := True;
        lStatusBar.SimpleText := lua_tostring(L,3);
      end
      else begin
        P := lStatusBar.Panels.Items[(trunc(lua_tonumber(L,2))-1)];
        P.Text := lua_tostring(L,3);
      end;
  finally
      lStatusBar.Panels.EndUpdate;
  end;
  Result := 0;
end;

function StatusbarDelete(L: Plua_State): Integer; cdecl;
var
  lStatusBar: TStatusBar;
begin
  CheckArg(L, 2);
  lStatusBar := TLuaStatusBar(GetLuaObject(L, 1));
  lStatusBar.Panels.Delete(Trunc(lua_tonumber(L,2))-1);
  if lStatusBar.Panels.Count = 0 then
     lStatusBar.SimplePanel := True;
  Result := 0;
end;

function StatusbarClear(L: Plua_State): Integer; cdecl;
var
  lStatusBar: TStatusBar;
begin
  CheckArg(L, 1);
  lStatusBar := TLuaStatusBar(GetLuaObject(L, 1));
  lStatusBar.Panels.Clear;
  Result := 0;
end;

function StatusbarCount(L: Plua_State): Integer; cdecl;
var
  lStatusBar: TStatusBar;
begin
  CheckArg(L, 1);
  lStatusBar := TLuaStatusBar(GetLuaObject(L, 1));
  lua_pushnumber(L, Trunc(lStatusBar.Panels.Count));
  Result := 1;
end;

function StatusbarRefresh(L: Plua_State): Integer; cdecl;
var
  lStatusBar: TStatusBar;
begin
  CheckArg(L, 1);
  lStatusBar := TLuaStatusBar(GetLuaObject(L, 1));
  lStatusBar.Repaint;
  Result := 0;
end;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
 
  LuaSetTableFunction(L, Index, 'Add', StatusbarAdd);
  LuaSetTableFunction(L, Index, 'Insert', StatusbarInsert);
  LuaSetTableFunction(L, Index, 'Update', StatusbarUpdate);
  LuaSetTableFunction(L, Index, 'Delete', StatusbarDelete);
  LuaSetTableFunction(L, Index, 'Clear', StatusbarClear);
  LuaSetTableFunction(L, Index, 'Count', StatusbarCount);
  LuaSetTableFunction(L, Index, 'Refresh', StatusbarRefresh);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateStatusBar(L: Plua_State): Integer; cdecl;
var
  lStatusBar:TLuaStatusBar;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lStatusBar := TLuaStatusBar.Create(Parent);
  lStatusBar.Parent := TWinControl(Parent);
  lStatusBar.LuaCtl := TLuaControl.Create(lStatusBar,L,@Totable);
  lStatusBar.SimplePanel := True;
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lStatusBar),-1)
  else 
     lStatusBar.Name := Name;
  ToTable(L, -1, lStatusBar);
  Result := 1;
end;

end.
