unit LuaToolBar;

interface

Uses Classes, Controls, Contnrs, LuaPas, LuaControl, Forms, ComCtrls, TypInfo, LuaCanvas;

function CreateToolBar(L: Plua_State): Integer; cdecl;
function CreateToolButton(L: Plua_State): Integer; cdecl;

procedure ToolButtonToTable(L:Plua_State; Index:Integer; Sender:TObject);

type

    TLuaToolBar = class(TToolBar)
          LuaCtl: TLuaControl;
          LuaCanvas: TLuaCanvas;
           public
             destructor Destroy; override;
    end;

    TLuaToolButton = class(TToolButton)
          LuaCtl: TLuaControl;
          LuaCanvas: TLuaCanvas;
           public
             destructor Destroy; override;
    end;

// ***********************************************
implementation

Uses LuaProperties, Lua;

function AddButton(L: Plua_State): Integer; cdecl;
var
  lTB:TLuaToolBar;
  TB:TLuaToolButton;
begin
  CheckArg(L, 2);
  lTB := TLuaToolBar(GetLuaObject(L, -2));
  TB := TLuaToolButton(GetLuaObject(L, -1));
  TB.SetToolBar(lTB);
  lua_pushNumber(L,TB.Index);
  Result := 1;
end;

function RemoveButton(L: Plua_State): Integer; cdecl;
var
  lTB:TLuaToolBar;
  i:Integer;
begin
  CheckArg(L, 2);
  lTB := TLuaToolBar(GetLuaObject(L, -2));
  i := Trunc(lua_tonumber(L, -1));
  lTB.Buttons[i].Free;
  Result := 0;
end;

function FindButton(L: Plua_State): Integer; cdecl;
var
  lTB:TLuaToolBar;
  TB:TLuaToolButton;
  fb:String;
  i:Integer;
begin
  CheckArg(L, 2);
  Result := 1;
  lTB := TLuaToolBar(GetLuaObject(L, -2));
  fb := lua_tostring(L, -1);
  for i:= 0 to lTB.ButtonCount-1 do begin
      if (lTB.Buttons[i].name=fb) then begin
         ToolButtonToTable(L, -1, lTB.Buttons[i]);
         exit;
      end;
  end;
  lua_pushnil(L);
end;

function LoadButtonFromTable(L:Plua_State; TB:TLuaToolButton):Boolean;
var
   n:Integer;
   PInfo: PPropInfo;
begin
   Result := False;
   if lua_istable(L,-1) then begin
     n := lua_gettop(L);
     result := true;
     lua_pushnil(L);
     while (lua_next(L, n) <> 0) do begin
           if lua_istable(L,-1) and (TObject(GetInt64Prop(TB,lua_tostring(L, -2)))<>nil) then begin
              SetPropertiesFromLuaTable(L,TObject(GetInt64Prop(TB,lua_tostring(L, -2))),-1);
           end
           else begin
               PInfo := GetPropInfo(TB.ClassInfo,lua_tostring(L, -2));
               SetProperty(L, -1, TComponent(TB), PInfo);
           end;
           lua_pop(L, 1);
     end;
   end;
end;

function LoadToolBar(L: Plua_State): Integer; cdecl;
var
//  Parent :TComponent;
  Name:String;
  lTB:TLuaToolBar;
  TB:TLuaToolButton;
  n,m:Integer;
begin
  // Parent := nil;
  n := lua_gettop(L);
  if (n=2) then begin
       lTB := TLuaToolBar(GetLuaObject(L,-2));
       n := lua_gettop(L);
       lua_pushnil(L);
       while (lua_next(L, n) <> 0) do begin      // menuitems
         if lua_istable(L,-1) then begin
           TB := TLuaToolButton.Create(lTB);
           TB.Parent := TWinControl(lTB);
           TB.SetToolBar(lTB);
           TB.LuaCtl := TLuaControl.Create(TB,L,@ToolButtonToTable);
           LoadButtonFromTable(L,TB);
           // SetPropertiesFromLuaTable(L,TB,-1);
         end;
         lua_pop(L, 1);
        end;
  end;
  Result := 0;
end;

function ToolBarGetCanvas(L: Plua_State): Integer; cdecl;
var lC:TLuaToolBar;
begin
  lC := TLuaToolBar(GetLuaObject(L, 1));
  lC.LuaCanvas.ToTable(L, -1, lC.Canvas);
  result := 1;
end;

function ToolButtonGetCanvas(L: Plua_State): Integer; cdecl;
var lC:TLuaToolButton;
begin
  lC := TLuaToolButton(GetLuaObject(L, 1));
  lC.LuaCanvas.ToTable(L, -1, lC.Canvas);
  result := 1;
end;

// ***********************************************
// LUA ToolBar Events
// ***********************************************
procedure ToolBarToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);

  LuaSetTableFunction(L, Index, 'Add', @AddButton);
  LuaSetTableFunction(L, Index, 'Remove', @RemoveButton);
  LuaSetTableFunction(L, Index, 'Find', @FindButton);
  LuaSetTableFunction(L, Index, 'LoadFromTable', @LoadToolBar);
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ToolBarGetCanvas);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);

end;

procedure ToolButtonToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ToolButtonGetCanvas);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

destructor TLuaToolBar.Destroy;
begin
  if (LuaCanvas<>nil) then LuaCanvas.Free;
  inherited Destroy;
end;

destructor TLuaToolButton.Destroy;
begin
  if (LuaCanvas<>nil) then LuaCanvas.Free;
  inherited Destroy;
end;

function CreateToolBar(L: Plua_State): Integer; cdecl;
var
  lToolBar:TLuaToolBar;
  Parent:TComponent;
  Name:String;
  n:Integer;
begin
  GetControlParents(L,Parent,Name);
  lToolBar := TLuaToolBar.Create(Parent);
  lToolBar.Parent := TWinControl(Parent);
  lToolBar.LuaCtl := TLuaControl.Create(lToolBar,L,@ToolBarToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lToolBar),-1)
  else 
     lToolBar.Name := Name;
  if (lToolBar.InheritsFrom(TCustomControl) or lToolBar.InheritsFrom(TGraphicControl)) then
    lToolBar.LuaCanvas := TLuaCanvas.Create;
  ToolBarToTable(L, -1, lToolBar);
  Result := 1;
end;

function CreateToolButton(L: Plua_State): Integer; cdecl;
var
  lTB:TLuaToolButton;
  Parent:TComponent;
  Name:String;
  n:Integer;
begin
  GetControlParents(L,Parent,Name);
  lTB := TLuaToolButton.Create(Parent);
  lTB.Parent := TWinControl(Parent);
  lTB.LuaCtl := TLuaControl.Create(lTB,L,@ToolButtonToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lTB),-1)
  else 
     lTB.Name := Name;
  if (lTB.InheritsFrom(TCustomControl) or lTB.InheritsFrom(TGraphicControl)) then
    lTB.LuaCanvas := TLuaCanvas.Create;
  ToolButtonToTable(L, -1, lTB);
  Result := 1;
end;

end.
