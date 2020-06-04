unit LuaDirectoryEdit;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateDirectoryEdit(L: Plua_State): Integer; cdecl;
type
    TLuaDirectoryEdit = class(TDirectoryEdit)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaDirectoryEdit.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function DirectoryEditGetCanvas(L: Plua_State): Integer; cdecl;
var lDirectoryEdit:TLuaDirectoryEdit;
begin
  lDirectoryEdit := TLuaDirectoryEdit(GetLuaObject(L, 1));
  lDirectoryEdit.LuaCanvas.ToTable(L, -1, lDirectoryEdit.Canvas);
  result := 1;
end;
{$ENDIF}
procedure DirectoryEditToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', DirectoryEditGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateDirectoryEdit(L: Plua_State): Integer; cdecl;
var
  lDirectoryEdit:TLuaDirectoryEdit;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lDirectoryEdit := TLuaDirectoryEdit.Create(Parent);
  lDirectoryEdit.Parent := TWinControl(Parent);
  lDirectoryEdit.LuaCtl := TLuaControl.Create(lDirectoryEdit,L,@DirectoryEditToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lDirectoryEdit),-1)
  else
     lDirectoryEdit.Name := Name;
  {$IFDEF HASCANVAS}
  if (lDirectoryEdit.InheritsFrom(TCustomControl) or lDirectoryEdit.InheritsFrom(TGraphicControl) or
	  lDirectoryEdit.InheritsFrom(TLCLComponent)) then
    lDirectoryEdit.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  DirectoryEditToTable(L, -1, lDirectoryEdit);
  Result := 1;
end;
end.
