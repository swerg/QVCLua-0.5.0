unit LuaListView;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateListView(L: Plua_State): Integer; cdecl;
type
    TLuaListView = class(TListView)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaListView.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ListViewGetCanvas(L: Plua_State): Integer; cdecl;
var lListView:TLuaListView;
begin
  lListView := TLuaListView(GetLuaObject(L, 1));
  lListView.LuaCanvas.ToTable(L, -1, lListView.Canvas);
  result := 1;
end;
{$ENDIF}
procedure ListViewToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  SetAnchorMethods(L,Index,Sender);
  SetStringListMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ListViewGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateListView(L: Plua_State): Integer; cdecl;
var
  lListView:TLuaListView;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lListView := TLuaListView.Create(Parent);
  lListView.Parent := TWinControl(Parent);
  lListView.LuaCtl := TLuaControl.Create(lListView,L,@ListViewToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lListView),-1)
  else
     lListView.Name := Name;
  {$IFDEF HASCANVAS}
  if (lListView.InheritsFrom(TCustomControl) or lListView.InheritsFrom(TGraphicControl) or
	  lListView.InheritsFrom(TLCLComponent)) then
    lListView.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ListViewToTable(L, -1, lListView);
  Result := 1;
end;
end.
