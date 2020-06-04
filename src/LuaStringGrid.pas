unit LuaStringGrid;

interface

Uses Classes, Types, Controls, Contnrs, LuaPas, LuaControl, Forms, Grids, StdCtrls, TypInfo, LuaCanvas,
Graphics;  ///QVCL

function CreateStringGrid(L: Plua_State): Integer; cdecl;

type
    PLuaStringGridCellAttr = ^TLuaStringGridCellAttr;
    TLuaStringGridCellAttr = record
        Color: TColor;
        IsSetColor: Boolean;
    end;

	TLuaStringGrid = class(TStringGrid)
          LuaCtl: TLuaControl;
          LuaCanvas: TLuaCanvas;
           protected
             function GetCellAttr(ACol, ARow: Integer): PLuaStringGridCellAttr;
             procedure DoPrepareCanvas(aCol,aRow:Integer; aState: TGridDrawState); override;
           public
             destructor Destroy; override;
             procedure SetCellColor(ACol, ARow: Integer; const AValue: TColor);
     end;
// ***********************************************
implementation

Uses LuaStrings, LuaProperties, Lua, Dialogs;


function Clear(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  c,cf,r :Integer;
begin
  CheckArg(L, 1);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  c := lStringGrid.ColCount;
  cf := lStringGrid.FixedCols;
  r := lStringGrid.FixedRows;
  lStringGrid.Clear;
  lStringGrid.RowCount := r;
  lStringGrid.FixedRows := r;
  lStringGrid.ColCount := c;
  lStringGrid.FixedCols := cf;
  Result := 0;
end;

function DrawCell(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  c,r:Integer;
  rect:TRect;
  aState:TGridDrawState;
begin
  CheckArg(L, 5);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  c := trunc(lua_tonumber(L,2));
  r := trunc(lua_tonumber(L,3));
  rect := LuaGetRect(L,4);
  aState := TGridDrawState(GetEnumValue(TypeInfo(TGridDrawState),lua_tostring(L,5)));
  lStringGrid.defaultdrawcell(c,r,rect,aState);
  Result := 0;
end;


function CellsGet(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  c,r :Integer;
begin
  CheckArg(L, 3);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  c := trunc(lua_tonumber(L,2));
  r := trunc(lua_tonumber(L,3));
  lua_pushstring(L,pchar(lStringGrid.Cells[c,r]));
  Result := 1;
end;

function CellsSet(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  c,r :Integer;
begin
  CheckArg(L, 4);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  c := trunc(lua_tonumber(L,2));
  r := trunc(lua_tonumber(L,3));
  lStringGrid.Cells[c,r] := AnsiToUtf8(lua_tostring(L,4));
  Result := 0;
end;

function SetCellColor(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  c,r :Integer;
begin
  CheckArg(L, 4, 'SetCellColor');
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  c := trunc(lua_tonumber(L,2));
  r := trunc(lua_tonumber(L,3));
  lStringGrid.SetCellColor(c,r,TColor(lua_tointeger(L,4)));
  Result := 0;
end;

function ColsGet(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  i,n :Integer;
begin
  CheckArg(L, 2);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  n := trunc(lua_tonumber(L,2));
  lua_newtable(L);
  for i:= 0 to lStringGrid.Cols[n].Count-1 do begin
    lua_pushnumber(L,i);
    lua_pushstring(L,pchar(lStringGrid.Cols[n][i]));
    lua_rawset(L,-3);
  end;
  Result := 1;
end;

function RowsGet(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  i,n :Integer;
begin
  CheckArg(L, 2);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  n := trunc(lua_tonumber(L,2));
  lua_newtable(L);
  for i:= 0 to lStringGrid.Rows[n].Count-1 do begin
    lua_pushnumber(L,i+1); // lua_table
    lua_pushstring(L,pchar(lStringGrid.Rows[n][i]));
    lua_rawset(L,-3);
  end;
  Result := 1;
end;

function CellRectGet(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  c,r :Integer;
  Rect : TRect;
begin
  CheckArg(L, 3);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  c := trunc(lua_tonumber(L,2));
  r := trunc(lua_tonumber(L,3));
  Rect := lStringGrid.CellRect(c,r);
  lua_newtable(L);
  lua_pushliteral(L,'Left');
  lua_pushnumber(L,Rect.Left);  
  lua_rawset(L,-3); 
  lua_pushliteral(L,'Top');
  lua_pushnumber(L,Rect.Top);  
  lua_rawset(L,-3);
  lua_pushliteral(L,'Right');
  lua_pushnumber(L,Rect.Right);  
  lua_rawset(L,-3);
  lua_pushliteral(L,'Bottom');
  lua_pushnumber(L,Rect.Bottom);  
  lua_rawset(L,-3);    
  // lua_pushnumber(L,4);
  // lua_pushliteral(L,'n');
  // lua_rawset(L,-3);
  Result := 1;
end;

function GetSelectedCell(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  c,r :Integer;
  Rect : TRect;
begin
  CheckArg(L, 1);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  c := lStringGrid.Selection.TopLeft.x;
  r := lStringGrid.Selection.TopLeft.y;
  Rect := lStringGrid.CellRect(c,r);
  lua_pushnumber(L,c);
  lua_pushnumber(L,r);
  Result := 2;
end;

function GetMouseToCell(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  X,Y,c,r :Integer;
begin
  CheckArg(L, 3);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  X := trunc(lua_tonumber(L,2));
  Y := trunc(lua_tonumber(L,3));
  lStringGrid.MouseToCell(X, Y, c, r);
  lua_pushnumber(L,c);
  lua_pushnumber(L,r);
  Result := 2;
end;

function SetColWidth(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  n,i,w :Integer;
begin
  n := lua_gettop(L);
  if (n=2) and lua_istable(L,2) then begin
     lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));  
     lua_pushnil(L);
     i := 0;
     while (lua_next(L, n) <> 0) do begin
        lStringGrid.ColWidths[i] := trunc(lua_tonumber(L,-1));
        lua_pop(L, 1);
        inc(i);
     end;
  end
  else begin
    CheckArg(L, 3);
    lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
    i := trunc(lua_tonumber(L,2));
    w := trunc(lua_tonumber(L,3));
    if i=0 then
       lStringGrid.DefaultColWidth := w
    else
       lStringGrid.ColWidths[i] := w;
  end;
  Result := 0;
end;

function SetRowHeight(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  i,h :Integer;
begin
  CheckArg(L, 3);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  i := trunc(lua_tonumber(L,2));
  h := trunc(lua_tonumber(L,3));
  if i=0 then
     lStringGrid.DefaultRowHeight := h
  else
     lStringGrid.RowHeights[i] := h;
  Result := 0;
end;

function SetRowData(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  i,r :Integer;
begin
    CheckArg(L, 3);
//    lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
    r := trunc(lua_tonumber(L,2));
    if lua_istable(L,3) then begin
     lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
     lua_pushnil(L);
     i := 0;
     while (lua_next(L, 3) <> 0) do begin
        lStringGrid.Cells[i,r] := AnsiToUtf8(lua_tostring(L,-1));
        lua_pop(L, 1);
        inc(i);
     end;
  end;
  Result := 0;
end;

function SetColData(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  i,c :Integer;
begin
    CheckArg(L, 3);
//    lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
    c := trunc(lua_tonumber(L,2));
    if lua_istable(L,3) then begin
     lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
     lua_pushnil(L);
     i := 0;
     while (lua_next(L, 3) <> 0) do begin
        lStringGrid.Cells[c,i] := AnsiToUtf8(lua_tostring(L,-1));
        lua_pop(L, 1);
        inc(i);
     end;
  end;
  Result := 0;
end;


procedure StringGridColumsToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function LoadColParamsFromTable(L:Plua_State; LGridCol:TGridColumn):Boolean;
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
           if lua_istable(L,-1) and (TObject(GetInt64Prop(LGridCol,lua_tostring(L, -2)))<>nil) then begin
              SetPropertiesFromLuaTable(L,TObject(GetInt64Prop(LGridCol,lua_tostring(L, -2))),-1);
           end
           else begin
               PInfo := GetPropInfo(LGridCol.ClassInfo,lua_tostring(L, -2));
               if PInfo<>nil then
                  SetProperty(L, -1, TComponent(LGridCol), PInfo);
               // Todo error
           end;
           lua_pop(L, 1);
     end;
   end;
end;

function SetColParams(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  LGridCol: TGridColumn;
  n,i :Integer;
begin
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  n := lua_gettop(L);
  if ((n=3) and (lua_isnumber(L,2))) then begin
     if lua_istable(L,-1) then begin
          LGridCol := lStringGrid.Columns[trunc(lua_tonumber(L,2))];
          LoadColParamsFromTable(L,LGridCol);
          inc(i);
     end;
  end else begin
      lua_pushnil(L);
      i:=0;
      while (lua_next(L, n) <> 0) do begin      // menuitems
        if lua_istable(L,-1) then begin
          LGridCol := lStringGrid.Columns.Add;
          LoadColParamsFromTable(L,LGridCol);
          inc(i);
        end;
        lua_pop(L, 1);
      end;
  end;
  Result := 0;
end;

function GetColumns(L: Plua_State): Integer; cdecl;
var lStringGrid:TLuaStringGrid;
begin
  CheckArg(L, 1);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  StringGridColumsToTable(L,-1, TStringGrid(lStringGrid.Columns));
  Result := 1;
end;


function AddCol(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  LGridCol: TGridColumn;
  n,i :Integer;
begin
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  n := lua_gettop(L);
  LGridCol := lStringGrid.Columns.Add;
  SetPropertiesFromLuaTable(L,LGridCol,-1);
  if ((n=3) and (lua_isnumber(L,2))) then begin
     LGridCol.Index:= trunc(lua_tonumber(L,2));
  end;
  Result := 0;
end;

function AddRow(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  n,i,r,c:Integer;
begin
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  n := lua_gettop(L);
  lStringGrid.RowCount:=lStringGrid.RowCount+1;
  // insert?
  if (lua_isnumber(L,2)) then begin
     i:= trunc(lua_tonumber(L,2));
     for r := lStringGrid.RowCount-1 downto i do
         lStringGrid.Rows[r] := lStringGrid.Rows[r-1];
     for c:= lStringGrid.FixedCols to lStringGrid.ColCount-1 do
         lStringGrid.Cells[c,i] := '';
     lua_pushnumber(L, i);
  end else
     lua_pushnumber(L, lStringGrid.RowCount-1);
  Result := 1;
end;

function DeleteColRow(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
begin
  CheckArg(L,3);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  lStringGrid.DeleteColRow(lua_toboolean(L,2),trunc(lua_tonumber(L,3)));
  Result := 0;
end;

function SortColRow(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
begin
  CheckArg(L,3);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  lStringGrid.SortColRow(lua_toboolean(L,2),trunc(lua_tonumber(L,3)));
  Result := 0;
end;

function GridSaveToFile(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  fn:String;
begin
  CheckArg(L,2);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  lStringGrid.SaveOptions:= [soDesign, soAttributes, soContent];   
  lStringGrid.SaveToFile(lua_tostring(L,2));
  Result := 0;
end;

function GridLoadFromFile(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  fn:String;
begin
  CheckArg(L,2);
  lStringGrid := TLuaStringGrid(GetLuaObject(L, 1));
  lStringGrid.LoadFromFile(lua_tostring(L,2));
  lStringGrid.Refresh;
  Result := 0;
end;

function GridGetCanvas(L: Plua_State): Integer; cdecl;
var lC:TLuaStringGrid;
begin
  lC := TLuaStringGrid(GetLuaObject(L, 1));
  lC.LuaCanvas.ToTable(L, -1, lC.Canvas);
  result := 1;
end;


destructor TLuaStringGrid.Destroy;
begin
  if (LuaCanvas<>nil) then LuaCanvas.Free;
  inherited Destroy;
end;

procedure TLuaStringGrid.DoPrepareCanvas(aCol,aRow:Integer; aState: TGridDrawState);
var
    CellAttr:PLuaStringGridCellAttr;
begin
    CellAttr := GetCellAttr(ACol, ARow);
    if CellAttr.IsSetColor then
       Canvas.Brush.Color := CellAttr.Color;
    inherited;
end;

function TLuaStringGrid.GetCellAttr(ACol, ARow: Integer): PLuaStringGridCellAttr;

  procedure CrealCellAttr(attr: PLuaStringGridCellAttr);
  begin
      attr.Color := Self.Color;
      attr.IsSetColor := False;
  end;

var
  C: PCellProps;
begin
  C:= FGrid.Celda[aCol,aRow];
  if C<>nil then begin
    if C^.Attr=nil then begin
      C^.Attr:=new(PLuaStringGridCellAttr);
      CrealCellAttr(C^.Attr);
    end;
  end else begin
      New(C);
      C^.Attr:=new(PLuaStringGridCellAttr);
      CrealCellAttr(C^.Attr);
      C^.Data:=nil;
      C^.Text:=nil;
      FGrid.Celda[aCol,aRow]:=C;
  end;

  Result := C^.Attr;
end;

procedure TLuaStringGrid.SetCellColor(ACol, ARow: Integer; const AValue: TColor);
var
  CellAttr:PLuaStringGridCellAttr;
begin
  CellAttr := GetCellAttr(ACol, ARow);
  if CellAttr.Color <> AValue then begin
      CellAttr.Color := AValue;
      CellAttr.IsSetColor := True;
      InvalidateCell(ACol, ARow);
      Modified := True;
  end;
end;


procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);

  LuaSetTableFunction(L, Index, 'Clear', @Clear);
  LuaSetTableFunction(L, Index, 'GetCell', @CellsGet);
  LuaSetTableFunction(L, Index, 'SetCell', @CellsSet);
  LuaSetTableFunction(L, Index, 'SetCellColor', @SetCellColor);
  LuaSetTableFunction(L, Index, 'DrawCell', @DrawCell);
  LuaSetTableFunction(L, Index, 'ColToTable', @ColsGet);
  LuaSetTableFunction(L, Index, 'LoadColFromTable', @SetColData);
  LuaSetTableFunction(L, Index, 'RowToTable', @RowsGet);
  LuaSetTableFunction(L, Index, 'LoadRowFromTable', @SetRowData);
  LuaSetTableFunction(L, Index, 'CellRect', @CellRectGet);
  LuaSetTableFunction(L, Index, 'MouseToCell', @GetMouseToCell);
  LuaSetTableFunction(L, Index, 'SelectedCell', @GetSelectedCell);
  LuaSetTableFunction(L, Index, 'SetRowHeight', @SetRowHeight);
  LuaSetTableFunction(L, Index, 'SetColWidth', @SetColWidth);
  LuaSetTableFunction(L, Index, 'SetColParams', @SetColParams);
  LuaSetTableFunction(L, Index, 'GetColumns', @GetColumns);
  LuaSetTableFunction(L, Index, 'AddCol', @AddCol);
  LuaSetTableFunction(L, Index, 'AddRow', @AddRow);
  LuaSetTableFunction(L, Index, 'DeleteColRow', @DeleteColRow);
  LuaSetTableFunction(L, Index, 'SortColRow', @SortColRow);
  LuaSetTableFunction(L, Index, 'SaveToFile',@GridSaveToFile);
  LuaSetTableFunction(L, Index, 'LoadFromFile',@GridLoadFromFile);
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', GridGetCanvas);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);

end;

function CreateStringGrid(L: Plua_State): Integer; cdecl;
var
  lStringGrid:TLuaStringGrid;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lStringGrid := TLuaStringGrid.Create(Parent);
  lStringGrid.Parent := TWinControl(Parent);
  lStringGrid.LuaCtl := TLuaControl.Create(lStringGrid,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lStringGrid),-1)
  else 
     lStringGrid.Name := Name;
  if (lStringGrid.InheritsFrom(TCustomControl) or lStringGrid.InheritsFrom(TGraphicControl)) then
    lStringGrid.LuaCanvas := TLuaCanvas.Create;
  ToTable(L, -1, lStringGrid);
  Result := 1;
end;


end.
