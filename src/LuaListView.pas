{$DEFINE HASCANVAS}
unit LuaListView;
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateListView(L: Plua_State): Integer; cdecl;
type

    TLuaListView = class(TListView)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS} LuaCanvas: TLuaCanvas; {$ENDIF}
        public
            destructor Destroy; override;
    end;

    // forward
    procedure ListItemsToTable(L:Plua_State; Index:Integer; Sender:TObject);
    procedure ListColumsToTable(L:Plua_State; Index:Integer; Sender:TObject);

implementation
Uses LuaProperties, Lua, LCLClasses;

destructor TLuaListView.Destroy;
var i:Integer;
begin
  {$IFDEF HASCANVAS} if (LuaCanvas<>nil) then LuaCanvas.Free; {$ENDIF}
  if Assigned(Columns) and (Columns.Count>0) then
    for i:=Columns.Count-1 downto 0 do
      Columns.Items[i].Free;
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

function AddNewItem(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  newItem: TListItem;
begin
  CheckArg(L, 1);
  lItems := TListItems(GetLuaObject(L, 1));
  newItem := lItems.Add;
  lua_pushtable_object(L, newItem, -1);
  Result := 1;
end;

function AddColumn(L: Plua_State): Integer; cdecl;
var
  lColumns: TListColumns;
  newColumn: TListColumn;
begin
  CheckArg(L, 1);
  lColumns := TListColumns(GetLuaObject(L, 1));
  newColumn := lColumns.Add;
  lua_pushtable_object(L, newColumn, -1);
  Result := 1;
end;

function AddItem(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  newItem: TListItem;
begin
  CheckArg(L, 2);
  lItems := TListItems(GetLuaObject(L, 1));
  newItem := TListItem(GetLuaObject(L, 2));
  lItems.AddItem(newItem);
  Result := 0;
end;

function BeginUpdate(L: Plua_State): Integer; cdecl;
var
  lList: TLuaListView;
begin
  CheckArg(L, 1);
  lList := TLuaListView(GetLuaObject(L, 1));
  lList.BeginUpdate;
  Result := 0;
end;

function EndUpdate(L: Plua_State): Integer; cdecl;
var
  lList: TLuaListView;
begin
  CheckArg(L, 1);
  lList := TLuaListView(GetLuaObject(L, 1));
  lList.EndUpdate;
  Result := 0;
end;

function Clear(L: Plua_State): Integer; cdecl;
var
  lList: TLuaListView;
begin
  CheckArg(L, 1);
  lList := TLuaListView(GetLuaObject(L, 1));
  lList.Clear;
  Result := 0;
end;

function Delete(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  idx: Integer;
begin
  CheckArg(L, 2);
  lItems := TListItems(GetLuaObject(L, 1));
  idx := trunc(lua_tonumber(L,2));
  lItems.Delete(idx);
  Result := 0;
end;

function Exchange(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  idx,idx2: Integer;
begin
  CheckArg(L, 3);
  lItems := TListItems(GetLuaObject(L, 1));
  idx := trunc(lua_tonumber(L,2));
  idx2 := trunc(lua_tonumber(L,3));
  lItems.Exchange(idx,idx2);
  Result := 0;
end;

function Move(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  fromidx,toidx: Integer;
begin
  CheckArg(L, 3);
  lItems := TListItems(GetLuaObject(L, 1));
  fromidx := trunc(lua_tonumber(L,2));
  toidx := trunc(lua_tonumber(L,3));
  lItems.Move(fromidx,toidx);
  Result := 0;
end;

function IndexOf(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  AItem : TListItem;
begin
  CheckArg(L, 2);
  lItems := TListItems(GetLuaObject(L, 1));
  AItem := TListItem(GetLuaObject(L, 2));
  lua_pushnumber(L, lItems.IndexOf(AItem));
  Result := 1;
end;

function Insert(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  idx: Integer;
  newItem : TListItem;
begin
  CheckArg(L, 2);
  lItems := TListItems(GetLuaObject(L, 1));
  idx := trunc(lua_tonumber(L,2));
  newItem := lItems.Insert(idx);
  lua_pushtable_object(L, newItem, -1);
  Result := 1;
end;

function InsertItem(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  AItem : TListItem;
  idx: Integer;
begin
  CheckArg(L, 3);
  lItems := TListItems(GetLuaObject(L, 1));
  AItem := TListItem(GetLuaObject(L, 2));
  idx := trunc(lua_tonumber(L,3));
  lItems.InsertItem(AItem, idx);
  Result := 0;
end;

function GetItem(L: Plua_State): Integer; cdecl;
var
  lItems: TListItems;
  AItem : TListItem;
  idx: Integer;
begin
  CheckArg(L, 2);
  lItems := TListItems(GetLuaObject(L, 1));
  idx := trunc(lua_tonumber(L,2));
  AItem := lItems.Item[idx];
  lua_pushtable_object(L, AItem, -1);
  Result := 1;
end;

function GetItems(L: Plua_State): Integer; cdecl;
var lList: TLuaListView;
begin
  CheckArg(L, 1);
  lList := TLuaListView(GetLuaObject(L, 1));
  ListItemsToTable(L,-1, TListItems(lList.Items));
  Result := 1;
end;

function GetColumnItem(L: Plua_State): Integer; cdecl;
var
  lItems: TListColumns;
  AItem : TListColumn;
  idx: Integer;
begin
  CheckArg(L, 2);
  lItems := TListColumns(GetLuaObject(L, 1));
  idx := trunc(lua_tonumber(L,2));
  AItem := lItems.Items[idx];
  lua_pushtable_object(L, AItem, -1);
  Result := 1;
end;

function GetColumns(L: Plua_State): Integer; cdecl;
var lList: TLuaListView;
begin
  CheckArg(L, 1);
  lList := TLuaListView(GetLuaObject(L, 1));
  ListColumsToTable(L,-1, TListColumns(lList.Columns));
  Result := 1;
end;

procedure ListColumsToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);

  LuaSetTableFunction(L, Index, 'Add', AddColumn);
  LuaSetTableFunction(L, Index, 'GetItem', GetColumnItem);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

procedure ListItemsToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetTableFunction(L, Index, 'Add', AddNewItem);
  LuaSetTableFunction(L, Index, 'AddItem', AddItem);
  LuaSetTableFunction(L, Index, 'Delete', Delete);
  LuaSetTableFunction(L, Index, 'Exchange', Exchange);
  LuaSetTableFunction(L, Index, 'Move', Move);
  LuaSetTableFunction(L, Index, 'IndexOf', IndexOf);
  LuaSetTableFunction(L, Index, 'Insert', Insert);
  LuaSetTableFunction(L, Index, 'InsertItem', InsertItem);

  // property Item[const AIndex: Integer]: TListItem read GetItem write SetItem; default;
  LuaSetTableFunction(L, Index, 'GetItem', GetItem);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

procedure ListViewToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  // LuaSetTableFunction(L, Index, 'AddItem', AddItem);
  LuaSetTableFunction(L, Index, 'BeginUpdate', BeginUpdate);
  LuaSetTableFunction(L, Index, 'EndUpdate', EndUpdate);
  LuaSetTableFunction(L, Index, 'Clear', Clear);
  LuaSetTableFunction(L, Index, 'GetItems', GetItems);
  LuaSetTableFunction(L, Index, 'GetColumns', GetColumns);
  (*
    function FindCaption(StartIndex: Integer; Value: string;
                     Partial, Inclusive, Wrap: Boolean;
                     PartStart: Boolean = True): TListItem;
    function FindData(const AData: Pointer): TListItem; overload;
    function FindData(StartIndex: Integer; Value: Pointer;  Inclusive, Wrap: Boolean): TListItem; overload;
    function GetEnumerator: TListItemsEnumerator;
*)
  
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
