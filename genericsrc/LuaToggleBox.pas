unit LuaToggleBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateToggleBox(L: Plua_State): Integer; cdecl;
type
    TLuaToggleBox = class(TToggleBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaToggleBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ToggleBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lToggleBox:TLuaToggleBox;
begin
  lToggleBox := TLuaToggleBox(GetLuaObject(L, 1));
  lToggleBox.LuaCanvas.ToTable(L, -1, lToggleBox.Canvas);
  result := 1;
end;
{$ENDIF}
procedure ToggleBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ToggleBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateToggleBox(L: Plua_State): Integer; cdecl;
var
  lToggleBox:TLuaToggleBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lToggleBox := TLuaToggleBox.Create(Parent);
  lToggleBox.Parent := TWinControl(Parent);
  lToggleBox.LuaCtl := TLuaControl.Create(lToggleBox,L,@ToggleBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lToggleBox),-1)
  else
     lToggleBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lToggleBox.InheritsFrom(TCustomControl) or lToggleBox.InheritsFrom(TGraphicControl) or
	  lToggleBox.InheritsFrom(TLCLComponent)) then
    lToggleBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ToggleBoxToTable(L, -1, lToggleBox);
  Result := 1;
end;
end.
