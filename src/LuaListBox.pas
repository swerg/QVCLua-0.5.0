unit LuaListBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateListBox(L: Plua_State): Integer; cdecl;
type
    TLuaListBox = class(TListBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaListBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ListBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lListBox:TLuaListBox;
begin
  lListBox := TLuaListBox(GetLuaObject(L, 1));
  lListBox.LuaCanvas.ToTable(L, -1, lListBox.Canvas);
  result := 1;
end;
{$ENDIF}

function BeginUpdateBounds(L: Plua_State): Integer; cdecl;
var lListBox:TLuaListBox;
begin
  CheckArg(L, 1);
  lListBox := TLuaListBox(GetLuaObject(L, 1));
  lListBox.BeginUpdateBounds;
  Result := 0;
end;

function EndUpdateBounds(L: Plua_State): Integer; cdecl;
var lListBox:TLuaListBox;
begin
  CheckArg(L, 1);
  lListBox := TLuaListBox(GetLuaObject(L, 1));
  lListBox.EndUpdateBounds;
  Result := 0;
end;

function ItemAtPos(L: Plua_State): Integer; cdecl;
var lListBox:TLuaListBox;
    p:TPoint;
begin
  CheckArg(L, 3);
  lListBox := TLuaListBox(GetLuaObject(L, 1));
  p.x := trunc(lua_tonumber(L,2));
  p.y := trunc(lua_tonumber(L,3));
  lua_pushnumber(L,lListBox.ItemAtPos(p, lua_toboolean(L,4)));
  Result := 1;
end;

function SelectedIndex(L: Plua_State): Integer; cdecl;
var lListBox:TLuaListBox;
    i,n:Integer;
begin
  CheckArg(L, 1);
  lListBox := TLuaListBox(GetLuaObject(L, 1));
  lua_newtable(L);
  n := 1;
  for i:=0 to lListBox.Count-1 do begin
      if lListBox.Selected[i] then begin
         lua_pushnumber(L,n);
         lua_pushnumber(L,i);
         lua_rawset(L,-3);
         inc(n);
      end;
  end;
  Result := 1;
end;

function Selected(L: Plua_State): Integer; cdecl;
var lListBox:TLuaListBox;
    i,n:Integer;
begin
  CheckArg(L, 1);
  lListBox := TLuaListBox(GetLuaObject(L, 1));
  lua_newtable(L);
  n := 1;
  for i:=0 to lListBox.Count-1 do begin
      if lListBox.Selected[i] then begin
         lua_pushnumber(L,n);
         lua_pushstring(L,pchar( lListBox.Items[i]));
         lua_rawset(L,-3);
         inc(n);
      end;
  end;
  Result := 1;
end;

procedure ListBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetTableFunction(L, Index, 'BeginUpdateBounds', BeginUpdateBounds);
  LuaSetTableFunction(L, Index, 'EndUpdateBounds', EndUpdateBounds);
  LuaSetTableFunction(L, Index, 'ItemAtPos', ItemAtPos);
  LuaSetTableFunction(L, Index, 'GetSelectedItems', Selected);
  LuaSetTableFunction(L, Index, 'GetSelectedIndexes', SelectedIndex);
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ListBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateListBox(L: Plua_State): Integer; cdecl;
var
  lListBox:TLuaListBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lListBox := TLuaListBox.Create(Parent);
  lListBox.Parent := TWinControl(Parent);
  lListBox.LuaCtl := TLuaControl.Create(lListBox,L,@ListBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lListBox),-1)
  else
     lListBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lListBox.InheritsFrom(TCustomControl) or lListBox.InheritsFrom(TGraphicControl) or
	  lListBox.InheritsFrom(TLCLComponent)) then
    lListBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ListBoxToTable(L, -1, lListBox);
  Result := 1;
end;
end.
