unit LuaSpinEdit;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateSpinEdit(L: Plua_State): Integer; cdecl;
type
    TLuaSpinEdit = class(TSpinEdit)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaSpinEdit.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function SpinEditGetCanvas(L: Plua_State): Integer; cdecl;
var lSpinEdit:TLuaSpinEdit;
begin
  lSpinEdit := TLuaSpinEdit(GetLuaObject(L, 1));
  lSpinEdit.LuaCanvas.ToTable(L, -1, lSpinEdit.Canvas);
  result := 1;
end;
{$ENDIF}
procedure SpinEditToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', SpinEditGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateSpinEdit(L: Plua_State): Integer; cdecl;
var
  lSpinEdit:TLuaSpinEdit;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lSpinEdit := TLuaSpinEdit.Create(Parent);
  lSpinEdit.Parent := TWinControl(Parent);
  lSpinEdit.LuaCtl := TLuaControl.Create(lSpinEdit,L,@SpinEditToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lSpinEdit),-1)
  else
     lSpinEdit.Name := Name;
  {$IFDEF HASCANVAS}
  if (lSpinEdit.InheritsFrom(TCustomControl) or lSpinEdit.InheritsFrom(TGraphicControl) or
	  lSpinEdit.InheritsFrom(TLCLComponent)) then
    lSpinEdit.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  SpinEditToTable(L, -1, lSpinEdit);
  Result := 1;
end;
end.
