unit LuaPropertyGrid;

interface

Uses Classes, Types, Controls, LuaPas, LuaControl, RTTIGrids, Dialogs;

function CreatePropertyGrid(L: Plua_State): Integer; cdecl;

type
     TLuaPropertyGrid = class(TTIPropertyGrid)
            LuaCtl: TLuaControl;
            private
              fOnLuaModified_Func: TLuaCFunction;
              Procedure DoOnModified(Sender:TObject);
            published
              // PropertyGrid
              property OnPropertyChange: TLuaCFunction read fOnLuaModified_Func write fOnLuaModified_Func;

     end;
// ***********************************************

implementation

Uses LuaProperties, Lua;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);

end;

Procedure TLuaPropertyGrid.DoOnModified(Sender:TObject);
var LL: Plua_State;
    EventFunc:TLuaCFunction;
begin
   LL := LuaCtl.L;
   EventFunc := fOnLuaModified_Func;
   if (EventFunc<>0) and CheckEvent(LL, Sender, EventFunc) then begin
     ToTable(LL, -1, Sender);
     lua_pushlightuserdata(LL, TLuaPropertyGrid(Sender).TIObject);
     DoCall(LL,2);
   end;
end;

function CreatePropertyGrid(L: Plua_State): Integer; cdecl;
var
  lPGrid:TLuaPropertyGrid;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lPGrid := TLuaPropertyGrid.Create(Parent);
  lPGrid.Parent := TWinControl(Parent);
  lPGrid.LuaCtl := TLuaControl.Create(lPGrid,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lPGrid),-1)
  else
     lPGrid.Name := Name;
  ToTable(L, -1, lPGrid);
  lPGrid.OnModified := lpGrid.DoOnModified;
  Result := 1;
end;


end.
