unit LuaRadioGroup;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateRadioGroup(L: Plua_State): Integer; cdecl;
type
    TLuaRadioGroup = class(TRadioGroup)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaRadioGroup.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function RadioGroupGetCanvas(L: Plua_State): Integer; cdecl;
var lRadioGroup:TLuaRadioGroup;
begin
  lRadioGroup := TLuaRadioGroup(GetLuaObject(L, 1));
  lRadioGroup.LuaCanvas.ToTable(L, -1, lRadioGroup.Canvas);
  result := 1;
end;
{$ENDIF}
procedure RadioGroupToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', RadioGroupGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateRadioGroup(L: Plua_State): Integer; cdecl;
var
  lRadioGroup:TLuaRadioGroup;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lRadioGroup := TLuaRadioGroup.Create(Parent);
  lRadioGroup.Parent := TWinControl(Parent);
  lRadioGroup.LuaCtl := TLuaControl.Create(lRadioGroup,L,@RadioGroupToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lRadioGroup),-1)
  else
     lRadioGroup.Name := Name;
  {$IFDEF HASCANVAS}
  if (lRadioGroup.InheritsFrom(TCustomControl) or lRadioGroup.InheritsFrom(TGraphicControl) or
	  lRadioGroup.InheritsFrom(TLCLComponent)) then
    lRadioGroup.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  RadioGroupToTable(L, -1, lRadioGroup);
  Result := 1;
end;
end.
