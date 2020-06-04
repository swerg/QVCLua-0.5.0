unit LuaEdit;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateEdit(L: Plua_State): Integer; cdecl;
type
    TLuaEdit = class(TEdit)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaEdit.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function EditGetCanvas(L: Plua_State): Integer; cdecl;
var lEdit:TLuaEdit;
begin
  lEdit := TLuaEdit(GetLuaObject(L, 1));
  lEdit.LuaCanvas.ToTable(L, -1, lEdit.Canvas);
  result := 1;
end;
{$ENDIF}
procedure EditToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', EditGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateEdit(L: Plua_State): Integer; cdecl;
var
  lEdit:TLuaEdit;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lEdit := TLuaEdit.Create(Parent);
  lEdit.Parent := TWinControl(Parent);
  lEdit.LuaCtl := TLuaControl.Create(lEdit,L,@EditToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lEdit),-1)
  else
     lEdit.Name := Name;
  {$IFDEF HASCANVAS}
  if (lEdit.InheritsFrom(TCustomControl) or lEdit.InheritsFrom(TGraphicControl) or
	  lEdit.InheritsFrom(TLCLComponent)) then
    lEdit.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  EditToTable(L, -1, lEdit);
  Result := 1;
end;
end.
