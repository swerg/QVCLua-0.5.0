{$DEFINE HASCANVAS}
unit LuaBevel;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateBevel(L: Plua_State): Integer; cdecl;
type
    TLuaBevel = class(TBevel)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaBevel.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function BevelGetCanvas(L: Plua_State): Integer; cdecl;
var lBevel:TLuaBevel;
begin
  lBevel := TLuaBevel(GetLuaObject(L, 1));
  lBevel.LuaCanvas.ToTable(L, -1, lBevel.Canvas);
  result := 1;
end;
{$ENDIF}
procedure BevelToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', BevelGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateBevel(L: Plua_State): Integer; cdecl;
var
  lBevel:TLuaBevel;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lBevel := TLuaBevel.Create(Parent);
  lBevel.Parent := TWinControl(Parent);
  lBevel.LuaCtl := TLuaControl.Create(lBevel,L,@BevelToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lBevel),-1)
  else
     lBevel.Name := Name;
  {$IFDEF HASCANVAS}
  if (lBevel.InheritsFrom(TCustomControl) or lBevel.InheritsFrom(TGraphicControl) or
	  lBevel.InheritsFrom(TLCLComponent)) then
    lBevel.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  BevelToTable(L, -1, lBevel);
  Result := 1;
end;
end.
