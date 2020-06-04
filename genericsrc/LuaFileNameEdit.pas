unit LuaFileNameEdit;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateFileNameEdit(L: Plua_State): Integer; cdecl;
type
    TLuaFileNameEdit = class(TFileNameEdit)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaFileNameEdit.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function FileNameEditGetCanvas(L: Plua_State): Integer; cdecl;
var lFileNameEdit:TLuaFileNameEdit;
begin
  lFileNameEdit := TLuaFileNameEdit(GetLuaObject(L, 1));
  lFileNameEdit.LuaCanvas.ToTable(L, -1, lFileNameEdit.Canvas);
  result := 1;
end;
{$ENDIF}
procedure FileNameEditToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', FileNameEditGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateFileNameEdit(L: Plua_State): Integer; cdecl;
var
  lFileNameEdit:TLuaFileNameEdit;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lFileNameEdit := TLuaFileNameEdit.Create(Parent);
  lFileNameEdit.Parent := TWinControl(Parent);
  lFileNameEdit.LuaCtl := TLuaControl.Create(lFileNameEdit,L,@FileNameEditToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lFileNameEdit),-1)
  else
     lFileNameEdit.Name := Name;
  {$IFDEF HASCANVAS}
  if (lFileNameEdit.InheritsFrom(TCustomControl) or lFileNameEdit.InheritsFrom(TGraphicControl) or
	  lFileNameEdit.InheritsFrom(TLCLComponent)) then
    lFileNameEdit.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  FileNameEditToTable(L, -1, lFileNameEdit);
  Result := 1;
end;
end.
