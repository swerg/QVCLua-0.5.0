unit LuaButton;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas
{QVCL},customdrawn_common, customdrawncontrols;
function CreateButton(L: Plua_State): Integer; cdecl;
type
    TLuaButton = class(TCDButton)///QVCL class(TButton)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaButton.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ButtonGetCanvas(L: Plua_State): Integer; cdecl;
var lButton:TLuaButton;
begin
  lButton := TLuaButton(GetLuaObject(L, 1));
  lButton.LuaCanvas.ToTable(L, -1, lButton.Canvas);
  result := 1;
end;
{$ENDIF}
procedure ButtonToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ButtonGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateButton(L: Plua_State): Integer; cdecl;
var
  lButton:TLuaButton;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lButton := TLuaButton.Create(Parent);
  lButton.Parent := TWinControl(Parent);
  lButton.LuaCtl := TLuaControl.Create(lButton,L,@ButtonToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lButton),-1)
  else
     lButton.Name := Name;
  {$IFDEF HASCANVAS}
  if (lButton.InheritsFrom(TCustomControl) or lButton.InheritsFrom(TGraphicControl) or
	  lButton.InheritsFrom(TLCLComponent)) then
    lButton.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ButtonToTable(L, -1, lButton);
  Result := 1;
end;
end.
