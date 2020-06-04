unit LuaCalcEdit;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateCalcEdit(L: Plua_State): Integer; cdecl;
type
    TLuaCalcEdit = class(TCalcEdit)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaCalcEdit.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function CalcEditGetCanvas(L: Plua_State): Integer; cdecl;
var lCalcEdit:TLuaCalcEdit;
begin
  lCalcEdit := TLuaCalcEdit(GetLuaObject(L, 1));
  lCalcEdit.LuaCanvas.ToTable(L, -1, lCalcEdit.Canvas);
  result := 1;
end;
{$ENDIF}
procedure CalcEditToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', CalcEditGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateCalcEdit(L: Plua_State): Integer; cdecl;
var
  lCalcEdit:TLuaCalcEdit;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lCalcEdit := TLuaCalcEdit.Create(Parent);
  lCalcEdit.Parent := TWinControl(Parent);
  lCalcEdit.LuaCtl := TLuaControl.Create(lCalcEdit,L,@CalcEditToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lCalcEdit),-1)
  else
     lCalcEdit.Name := Name;
  {$IFDEF HASCANVAS}
  if (lCalcEdit.InheritsFrom(TCustomControl) or lCalcEdit.InheritsFrom(TGraphicControl) or
	  lCalcEdit.InheritsFrom(TLCLComponent)) then
    lCalcEdit.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  CalcEditToTable(L, -1, lCalcEdit);
  Result := 1;
end;
end.
