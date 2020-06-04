unit LuaCheckGroup;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateCheckGroup(L: Plua_State): Integer; cdecl;
type
    TLuaCheckGroup = class(TCheckGroup)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaCheckGroup.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function CheckGroupGetCanvas(L: Plua_State): Integer; cdecl;
var lCheckGroup:TLuaCheckGroup;
begin
  lCheckGroup := TLuaCheckGroup(GetLuaObject(L, 1));
  lCheckGroup.LuaCanvas.ToTable(L, -1, lCheckGroup.Canvas);
  result := 1;
end;
{$ENDIF}
procedure CheckGroupToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', CheckGroupGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateCheckGroup(L: Plua_State): Integer; cdecl;
var
  lCheckGroup:TLuaCheckGroup;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lCheckGroup := TLuaCheckGroup.Create(Parent);
  lCheckGroup.Parent := TWinControl(Parent);
  lCheckGroup.LuaCtl := TLuaControl.Create(lCheckGroup,L,@CheckGroupToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lCheckGroup),-1)
  else
     lCheckGroup.Name := Name;
  {$IFDEF HASCANVAS}
  if (lCheckGroup.InheritsFrom(TCustomControl) or lCheckGroup.InheritsFrom(TGraphicControl) or
	  lCheckGroup.InheritsFrom(TLCLComponent)) then
    lCheckGroup.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  CheckGroupToTable(L, -1, lCheckGroup);
  Result := 1;
end;
end.
