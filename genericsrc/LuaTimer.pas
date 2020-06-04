unit LuaTimer;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateTimer(L: Plua_State): Integer; cdecl;
type
    TLuaTimer = class(TTimer)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaTimer.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function TimerGetCanvas(L: Plua_State): Integer; cdecl;
var lTimer:TLuaTimer;
begin
  lTimer := TLuaTimer(GetLuaObject(L, 1));
  lTimer.LuaCanvas.ToTable(L, -1, lTimer.Canvas);
  result := 1;
end;
{$ENDIF}
procedure TimerToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', TimerGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateTimer(L: Plua_State): Integer; cdecl;
var
  lTimer:TLuaTimer;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lTimer := TLuaTimer.Create(Parent);
  
  lTimer.LuaCtl := TLuaControl.Create(lTimer,L,@TimerToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lTimer),-1)
  else
     lTimer.Name := Name;
  {$IFDEF HASCANVAS}
  if (lTimer.InheritsFrom(TCustomControl) or lTimer.InheritsFrom(TGraphicControl) or
	  lTimer.InheritsFrom(TLCLComponent)) then
    lTimer.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  TimerToTable(L, -1, lTimer);
  Result := 1;
end;
end.
