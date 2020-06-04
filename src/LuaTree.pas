unit LuaTree;

{$mode Delphi}{$H+}

interface

Uses LuaPas,LuaControl,ComCtrls,Controls,Classes,Types,LuaCanvas, DOM,  lazutf8;

function CreateTreeView(L: Plua_State): Integer; cdecl;

type

    TLuaTreeView = class(TTreeView)
       LuaCtl: TLuaControl;
       LuaCanvas: TLuaCanvas;
       private
          FDoc: TXMLDocument;
       public
          destructor Destroy; override;
    end;


// forward
function LoadTreeFromLuaTable(L: Plua_State; idx:Integer; PN:TLuaTreeView; TI:TTreeNode):Boolean;
procedure TreeNodeToTable(L:Plua_State; Index:Integer; Sender:TObject);

implementation

Uses Forms, SysUtils, Lua, LuaImageList, LuaProperties, fileutil, XMLRead;

procedure lua_pushstring(L : Plua_State; const s : WideString); overload;
begin
  lua_pushstring(L, PChar(UTF16toUTF8(s)));
end;

// **************************************************************

function BeginUpdate(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
begin
  CheckArg(L, 1);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  lTree.BeginUpdate;
  Result := 0;
end;

function EndUpdate(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
begin
  CheckArg(L, 1);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  lTree.EndUpdate;
  Result := 0;
end;

function ClearTree(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
begin
  CheckArg(L, 1);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  if lTree <> nil then
    lTree.Items.Clear;
  Result := 0;
end;

function DeleteFromTree(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN:TTreeNode;
begin
  CheckArg(L, 2);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  TN := lTree.Items[trunc(lua_tonumber(L,2))];
  if TN <> nil then
    TN.Delete;
  Result := 0;
end;

function GetSelected(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  i:Integer;
begin
  CheckArg(L, 1);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  if (lTree <> nil) and Assigned(lTree.Selected)  then begin
      lua_newtable(L);
      for i:=0 to lTree.Selected.Count-1 do begin
          lua_pushnumber(L, i + 1);
          TreeNodeToTable(L,-1, lTree.Selections[i] );
          lua_rawset(L,-3);
      end;
  end else
    lua_pushnil(L);
  Result := 1;
end;

function GetNode(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN: TTreeNode;
begin
  CheckArg(L, 2);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  try
  TN := lTree.Items[trunc(lua_tonumber(L,2))];
  except
  end;
  if (Assigned(TN)) then begin
    TreeNodeToTable(L,-1,TN)
  end else
    lua_pushnil(L);
  Result := 1;
end;

function GetChildNodes(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN: TTreeNode;
  i:Integer;
begin
  CheckArg(L, 2);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  try
     TN := lTree.Items[trunc(lua_tonumber(L,2))];
  except
  end;
  if (Assigned(TN)) then begin
    lua_newtable(L);
    for i:= 0 to TN.Count-1 do begin
        lua_pushnumber(L, i + 1);
        TreeNodeToTable(L,-1, TN.Items[i] );
        lua_rawset(L,-3);
    end;
  end else
    lua_pushnil(L);
  Result := 1;
end;

function LoadTreeFromLuaTable(L: Plua_State; idx:Integer; PN:TLuaTreeView; TI:TTreeNode):Boolean;
var m: Integer;
    key,val:String;
    P:Pointer;
    NewTI:TTreeNode; 
begin
  result := false;
  if lua_istable(L,idx) then begin
     m := lua_gettop(L);
     result := true;
     lua_pushnil(L);
     while (lua_next(L, m) <> 0) do begin
         if lua_istable(L,-1) and lua_isnumber(L,-2) then begin
            if TI = nil then begin
               TI := PN.Items.AddChild(nil,'');
               TI.ImageIndex := -1;
               TI.SelectedIndex := -1;
            end;
            newTI := PN.Items.AddChild(TI,'');
            LoadTreeFromLuaTable(L,-1,PN,newTI);
         end else begin
            if TI = nil then begin
               TI := PN.Items.AddChild(TI,'');
               TI.ImageIndex := -1;
               TI.SelectedIndex := -1;
            end;
            key := lua_tostring(L, -2);
            val := lua_tostring(L, -1);
            if uppercase(key) = 'DATA' then  begin
              TI.Data := lua_topointer(L,-1);
            end else begin
              LuaSetControlProperty(L, TComponent(TI), key, -1);  // value on top
            end;

            (*
            else if uppercase(key) = 'TEXT' then begin
              TI.Text := lua_tostring(L, -1);
            end
            else if uppercase(key) = 'IMAGE' then begin
              TI.ImageIndex := trunc(lua_tonumber(L, -1)-1);
              if TI.SelectedIndex = -1 then
                TI.SelectedIndex := TI.ImageIndex;
            end
            else if uppercase(key) = 'SELECTED' then begin
              TI.SelectedIndex := trunc(lua_tonumber(L, -1)-1);
            end
            *)
         end;
         lua_pop(L, 1);
     end;
  end;
end;

function AddToTree(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN,SN:TTreeNode;
  n: Integer;
begin
  n := lua_gettop(L);
  CheckArg(L, 3);
  lTree := TLuaTreeView(GetLuaObject(L, 1));

  // insert as root or add node
  if (lua_isnil(L,2)) then begin
     SN := nil;
  end else begin
     SN := lTree.Items[trunc(lua_tonumber(L,2))];
  end;
  TN := lTree.Items.AddChild(SN,'');
  // load from table or set text
  if lua_istable(L,3) then begin
        LoadTreeFromLuaTable(L,3,lTree,TN)
  end else begin
        TN.Text := lua_tostring(L,3);
  end;
  lua_pushnumber(L,TN.AbsoluteIndex);
  Result := 1;
end;

function SetItems(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TI:TTreeNode;  
  n:Integer;
begin
  CheckArg(L, 2);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  n := lua_gettop(L);
  if lua_istable(L,2) then begin
     lua_pushnil(L);
     while (lua_next(L, n) <> 0) do begin
        LoadTreeFromLuaTable(L,n,lTree,nil);
        lua_pop(L, 1);
     end;
  end;
  result := 0;
end;

function GetItemData(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN: TTreeNode;
begin
  CheckArg(L, 2);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  TN := lTree.Items[trunc(lua_tonumber(L,2))];
  lua_pushlightuserdata(L,TN.Data);
  Result := 1;
end;

function SetItemData(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN: TTreeNode;
  P:Pointer;
begin
  CheckArg(L, 3);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  TN := lTree.Items[trunc(lua_tonumber(L,2))];
  TN.Data := lua_topointer(L,3);
  Result := 0;
end;

function GetDOMNode(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  Node:TDOMNode;
//  s:WideString;
  n:integer;

function DOMnodetotable(TTN:TDOMNode):Integer;
var i:Integer;
begin
    if Assigned(TTN.Attributes) then begin
       lua_pushliteral(L, 'Attr');
       lua_newtable(L);
       for i:=0 to TTN.Attributes.Length-1 do begin
          // lua_pushliteral(L, 'Name');
          lua_pushstring(L, TTN.Attributes[i].NodeName);
          // lua_rawset(L,-3);
          // lua_pushliteral(L, 'Value');
          lua_pushstring(L, TTN.Attributes[i].NodeValue);
          lua_rawset(L,-3);
        end;
       lua_rawset(L,-3);
    end;
    result := i;
end;

begin
  CheckArg(L, 2);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  n := trunc(lua_tonumber(L,2));
  if Assigned(lTree.Items[n]) then
     Node:=TDOMNode(lTree.Items[n].Data);
  if (Assigned(Node)) then
  begin
        lua_newtable(L);
        lua_pushliteral(L, 'Name');
        lua_pushstring(L, Node.NodeName);
        lua_rawset(L,-3);
        lua_pushliteral(L, 'Value');
        lua_pushstring(L, Node.NodeValue);
        lua_rawset(L,-3);
        n := DomNodeToTable(Node);
        // if (n=0) then lua_pushnil(L);

  end else
      lua_pushnil(L);
  Result := 1;
end;

function SetTreeImages(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TI:TLuaImageList;
begin
  CheckArg(L, 2);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  TI := TLuaImageList(GetLuaObject(L, 2));
  lTree.Images := TI;
  Result := 0;
end;

function SetNodeImage(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN: TTreeNode;
  P:Pointer;
begin
  CheckArg(L, 3);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  TN := lTree.Items[trunc(lua_tonumber(L,2))];
  TN.ImageIndex := trunc(lua_tonumber(L,3));
  Result := 0;
end;

function SetNodeSelectedImage(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  TN: TTreeNode;
  P:Pointer;
begin
  CheckArg(L, 3);
  lTree := TLuaTreeView(GetLuaObject(L, 1));
  TN := lTree.Items[trunc(lua_tonumber(L,2))];
  TN.SelectedIndex := trunc(lua_tonumber(L,3));
  Result := 0;
end;

function TreeSaveToFile(L: Plua_State): Integer; cdecl;
var
  lT:TLuaTreeView;
  fn:String;
begin
  CheckArg(L,2);
  lT := TLuaTreeView(GetLuaObject(L, 1));
  lT.SaveToFile(lua_tostring(L,2));
  Result := 0;
end;

function TreeLoadFromFile(L: Plua_State): Integer; cdecl;
var
  lT:TLuaTreeView;
  fn:String;
begin
  CheckArg(L,2);
  lT := TLuaTreeView(GetLuaObject(L, 1));
  lT.LoadFromFile(lua_tostring(L,2));
  Result := 0;
end;

// **********************************************************************************
// XML
// **********************************************************************************

function ParseXML(L: Plua_State): Integer; cdecl;

var lC:TLuaTreeView;
    sux: Boolean;

procedure DoFill(AOwner:TTreeNode; Node:TDOMNode);
var
  i: integer;
  AItem:TTreeNode;
begin
  if not Assigned(Node) then exit;
  for i:=0 to Node.ChildNodes.Count - 1 do
  begin
    AItem:=lC.Items.AddChild(AOwner, Node.ChildNodes[i].NodeName);
    AItem.Data:=Node.ChildNodes[i];
    if not Assigned(lC.Selected) then
      lC.Selected:=AItem;
    DoFill(AItem, Node.ChildNodes[i]);
  end;
end;

var b: TStringStream;
    s: String;
begin
  sux := false;
  CheckArg(L,2);
  lC := TLuaTreeView(GetLuaObject(L, 1));
  s := String(lua_tostring(L,2));
  if Assigned(lC.FDoc) then lC.FDoc.Free;
  if FileExistsUTF8(s) then begin
     try
       ReadXMLFile(lC.FDoc, UTF8ToSys(s));
       sux := true;
     except
       FreeAndNil(lC.FDoc);
     end;
  end else begin
     try
       b := TStringStream.Create(s);
       b.WriteBuffer(Pointer(s)^,Length(s));
       b.Seek(0,0);
       ReadXMLFile(lC.FDoc, b);
       b.Free;
       sux := true;
     except
       FreeAndNil(lC.FDoc);
     end;
  end;
  if Assigned(lC.FDoc) then begin
      lC.Selected:=nil;
      lC.Items.BeginUpdate;
      lC.Items.Clear;
      DoFill(nil, lC.FDoc);
      lC.Items.EndUpdate;
  end;
  lua_pushboolean(L,sux);
  Result := 1;
end;

function TreeGetCanvas(L: Plua_State): Integer; cdecl;
var lC:TLuaTreeView;
begin
  lC := TLuaTreeView(GetLuaObject(L, 1));
  lC.LuaCanvas.ToTable(L, -1, lC.Canvas);
  result := 1;
end;


destructor TLuaTreeView.Destroy;
begin
  if (LuaCanvas<>nil) then LuaCanvas.Free;
  if Assigned(FDoc) then FDoc.Free;
  inherited Destroy;
end;

procedure TreeNodeToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);

  LuaSetTableFunction(L, Index, 'BeginUpdate', BeginUpdate);
  LuaSetTableFunction(L, Index, 'EndUpdate', EndUpdate);

  LuaSetTableFunction(L, Index, 'Selected', GetSelected);
  LuaSetTableFunction(L, Index, 'Get', GetNode);
  LuaSetTableFunction(L, Index, 'GetChildNodes', GetChildNodes);

  LuaSetTableFunction(L, Index, 'GetData', GetItemData);
  LuaSetTableFunction(L, Index, 'SetData', SetItemData);
  LuaSetTableFunction(L, Index, 'GetDOMNode', GetDOMNode);

  LuaSetTableFunction(L, Index, 'Clear', ClearTree);

  LuaSetTableFunction(L, Index, 'Add', AddToTree);
  LuaSetTableFunction(L, Index, 'Delete', DeleteFromTree);

  LuaSetTableFunction(L, Index, 'SaveToFile',@TreeSaveToFile);
  LuaSetTableFunction(L, Index, 'LoadFromFile',@TreeLoadFromFile);

  LuaSetTableFunction(L, Index, 'LoadXML',@ParseXML);

  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', TreeGetCanvas);

  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

function CreateTreeView(L: Plua_State): Integer; cdecl;
var
  lTree:TLuaTreeView;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lTree := TLuaTreeView.Create(Parent);
  lTree.Parent := TWinControl(Parent);
  lTree.LuaCtl := TLuaControl.Create(lTree,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lTree),-1)
  else 
     lTree.Name := Name;
  if (lTree.InheritsFrom(TCustomControl) or lTree.InheritsFrom(TGraphicControl)) then
    lTree.LuaCanvas := TLuaCanvas.Create;
  ToTable(L, -1, lTree);
  Result := 1;
end;

end.
