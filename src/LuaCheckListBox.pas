unit LuaCheckListBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateCheckListBox(L: Plua_State): Integer; cdecl;
type
    TLuaCheckListBox = class(TCheckListBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaCheckListBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function CheckListBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox;
begin
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lCheckListBox.LuaCanvas.ToTable(L, -1, lCheckListBox.Canvas);
  result := 1;
end;
{$ENDIF}

function BeginUpdateBounds(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox;
begin
  CheckArg(L, 1);
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lCheckListBox.BeginUpdateBounds;
  Result := 0;
end;

function EndUpdateBounds(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox;
begin
  CheckArg(L, 1);
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lCheckListBox.EndUpdateBounds;
  Result := 0;
end;

function ItemAtPos(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox;
    p:TPoint;
begin
  CheckArg(L, 3);
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  p.x := trunc(lua_tonumber(L,2));
  p.y := trunc(lua_tonumber(L,3));
  lua_pushnumber(L,lCheckListBox.ItemAtPos(p, lua_toboolean(L,4)));
  Result := 1;
end;

function SelectedIndex(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox;
    i,n:Integer;
begin
  CheckArg(L, 1);
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lua_newtable(L);
  n := 1;
  for i:=0 to lCheckListBox.Count-1 do begin
      if lCheckListBox.Selected[i] then begin
         lua_pushnumber(L,n);
         lua_pushnumber(L,i);
         lua_rawset(L,-3);
         inc(n);
      end;
  end;
  Result := 1;
end;

function Selected(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox;
    i,n:Integer;
begin
  CheckArg(L, 1);
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lua_newtable(L);
  n := 1;
  for i:=0 to lCheckListBox.Count-1 do begin
      if lCheckListBox.Selected[i] then begin
         lua_pushnumber(L,n);
         lua_pushstring(L,pchar( lCheckListBox.Items[i]));
         lua_rawset(L,-3);
         inc(n);
      end;
  end;
  Result := 1;
end;

function Checked(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox; i,n:Integer;
begin
  CheckArg(L, 1);
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lua_newtable(L);
  n := 1;
  for i:= 0 to lCheckListBox.Count-1 do begin
    if lCheckListBox.Checked[i] then begin
       lua_pushnumber(L,n);
       lua_pushstring(L,pchar( lCheckListBox.Items[i]));
       lua_rawset(L,-3);
       inc(n);
    end;
  end;
  Result := 1;
end;

function Toggle(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox; i:Integer;
begin
  CheckArg(L, 2);
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lCheckListBox.Toggle(Trunc(lua_tonumber(L,2)));
  Result := 0;
end;

function Enabled(L: Plua_State): Integer; cdecl;
var lCheckListBox:TCheckListBox; i:Integer;
begin
  Result := 0;
  lCheckListBox := TCheckListBox(GetLuaObject(L, 1));
  if lua_gettop(L) = 3 then
       lCheckListBox.ItemEnabled[Trunc(lua_tonumber(L,2))] := lua_toboolean(L,3)
  else begin
       Result := 1;
       lua_pushboolean(L,lCheckListBox.ItemEnabled[Trunc(lua_tonumber(L,2))]);
  end;
end;


procedure CheckListBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetTableFunction(L, Index, 'BeginUpdateBounds', BeginUpdateBounds);
  LuaSetTableFunction(L, Index, 'EndUpdateBounds', EndUpdateBounds);
  LuaSetTableFunction(L, Index, 'ItemAtPos', ItemAtPos);
  LuaSetTableFunction(L, Index, 'GetSelectedItems', Selected);
  LuaSetTableFunction(L, Index, 'GetSelectedIndexes', SelectedIndex);
  LuaSetTableFunction(L, Index, 'GetCheckedItems', Checked);
  LuaSetTableFunction(L, Index, 'Toggle', Toggle);
  LuaSetTableFunction(L, Index, 'Enabled', Enabled);
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', CheckListBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateCheckListBox(L: Plua_State): Integer; cdecl;
var
  lCheckListBox:TLuaCheckListBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lCheckListBox := TLuaCheckListBox.Create(Parent);
  lCheckListBox.Parent := TWinControl(Parent);
  lCheckListBox.LuaCtl := TLuaControl.Create(lCheckListBox,L,@CheckListBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lCheckListBox),-1)
  else
     lCheckListBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lCheckListBox.InheritsFrom(TCustomControl) or lCheckListBox.InheritsFrom(TGraphicControl) or
	  lCheckListBox.InheritsFrom(TLCLComponent)) then
    lCheckListBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  CheckListBoxToTable(L, -1, lCheckListBox);
  Result := 1;
end;
end.
