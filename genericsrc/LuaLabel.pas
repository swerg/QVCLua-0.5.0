{$DEFINE HASCANVAS}
unit LuaLabel;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateLabel(L: Plua_State): Integer; cdecl;
type
    TLuaLabel = class(TLabel)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaLabel.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function LabelGetCanvas(L: Plua_State): Integer; cdecl;
var lLabel:TLuaLabel;
begin
  lLabel := TLuaLabel(GetLuaObject(L, 1));
  lLabel.LuaCanvas.ToTable(L, -1, lLabel.Canvas);
  result := 1;
end;
{$ENDIF}
procedure LabelToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', LabelGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateLabel(L: Plua_State): Integer; cdecl;
var
  lLabel:TLuaLabel;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lLabel := TLuaLabel.Create(Parent);
  lLabel.Parent := TWinControl(Parent);
  lLabel.LuaCtl := TLuaControl.Create(lLabel,L,@LabelToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lLabel),-1)
  else
     lLabel.Name := Name;
  {$IFDEF HASCANVAS}
  if (lLabel.InheritsFrom(TCustomControl) or lLabel.InheritsFrom(TGraphicControl) or
	  lLabel.InheritsFrom(TLCLComponent)) then
    lLabel.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  LabelToTable(L, -1, lLabel);
  Result := 1;
end;
end.
