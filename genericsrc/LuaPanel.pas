{$DEFINE HASCANVAS}
unit LuaPanel;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreatePanel(L: Plua_State): Integer; cdecl;
type
    TLuaPanel = class(TPanel)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaPanel.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function PanelGetCanvas(L: Plua_State): Integer; cdecl;
var lPanel:TLuaPanel;
begin
  lPanel := TLuaPanel(GetLuaObject(L, 1));
  lPanel.LuaCanvas.ToTable(L, -1, lPanel.Canvas);
  result := 1;
end;
{$ENDIF}
procedure PanelToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', PanelGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreatePanel(L: Plua_State): Integer; cdecl;
var
  lPanel:TLuaPanel;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lPanel := TLuaPanel.Create(Parent);
  lPanel.Parent := TWinControl(Parent);
  lPanel.LuaCtl := TLuaControl.Create(lPanel,L,@PanelToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lPanel),-1)
  else
     lPanel.Name := Name;
  {$IFDEF HASCANVAS}
  if (lPanel.InheritsFrom(TCustomControl) or lPanel.InheritsFrom(TGraphicControl) or
	  lPanel.InheritsFrom(TLCLComponent)) then
    lPanel.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  PanelToTable(L, -1, lPanel);
  Result := 1;
end;
end.
