unit LuaFloatSpinEdit;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateFloatSpinEdit(L: Plua_State): Integer; cdecl;
type
    TLuaFloatSpinEdit = class(TFloatSpinEdit)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaFloatSpinEdit.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function FloatSpinEditGetCanvas(L: Plua_State): Integer; cdecl;
var lFloatSpinEdit:TLuaFloatSpinEdit;
begin
  lFloatSpinEdit := TLuaFloatSpinEdit(GetLuaObject(L, 1));
  lFloatSpinEdit.LuaCanvas.ToTable(L, -1, lFloatSpinEdit.Canvas);
  result := 1;
end;
{$ENDIF}
procedure FloatSpinEditToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', FloatSpinEditGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateFloatSpinEdit(L: Plua_State): Integer; cdecl;
var
  lFloatSpinEdit:TLuaFloatSpinEdit;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lFloatSpinEdit := TLuaFloatSpinEdit.Create(Parent);
  lFloatSpinEdit.Parent := TWinControl(Parent);
  lFloatSpinEdit.LuaCtl := TLuaControl.Create(lFloatSpinEdit,L,@FloatSpinEditToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lFloatSpinEdit),-1)
  else
     lFloatSpinEdit.Name := Name;
  {$IFDEF HASCANVAS}
  if (lFloatSpinEdit.InheritsFrom(TCustomControl) or lFloatSpinEdit.InheritsFrom(TGraphicControl) or
	  lFloatSpinEdit.InheritsFrom(TLCLComponent)) then
    lFloatSpinEdit.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  FloatSpinEditToTable(L, -1, lFloatSpinEdit);
  Result := 1;
end;
end.
