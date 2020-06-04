{$DEFINE HASCANVAS}
unit LuaShape;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateShape(L: Plua_State): Integer; cdecl;
type
    TLuaShape = class(TShape)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaShape.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ShapeGetCanvas(L: Plua_State): Integer; cdecl;
var lShape:TLuaShape;
begin
  lShape := TLuaShape(GetLuaObject(L, 1));
  lShape.LuaCanvas.ToTable(L, -1, lShape.Canvas);
  result := 1;
end;
{$ENDIF}
procedure ShapeToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ShapeGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateShape(L: Plua_State): Integer; cdecl;
var
  lShape:TLuaShape;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lShape := TLuaShape.Create(Parent);
  lShape.Parent := TWinControl(Parent);
  lShape.LuaCtl := TLuaControl.Create(lShape,L,@ShapeToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lShape),-1)
  else
     lShape.Name := Name;
  {$IFDEF HASCANVAS}
  if (lShape.InheritsFrom(TCustomControl) or lShape.InheritsFrom(TGraphicControl) or
	  lShape.InheritsFrom(TLCLComponent)) then
    lShape.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ShapeToTable(L, -1, lShape);
  Result := 1;
end;
end.
