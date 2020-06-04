unit LuaIdleTimer;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateIdleTimer(L: Plua_State): Integer; cdecl;
type
    TLuaIdleTimer = class(TIdleTimer)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaIdleTimer.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function IdleTimerGetCanvas(L: Plua_State): Integer; cdecl;
var lIdleTimer:TLuaIdleTimer;
begin
  lIdleTimer := TLuaIdleTimer(GetLuaObject(L, 1));
  lIdleTimer.LuaCanvas.ToTable(L, -1, lIdleTimer.Canvas);
  result := 1;
end;
{$ENDIF}
procedure IdleTimerToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', IdleTimerGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateIdleTimer(L: Plua_State): Integer; cdecl;
var
  lIdleTimer:TLuaIdleTimer;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lIdleTimer := TLuaIdleTimer.Create(Parent);
  
  lIdleTimer.LuaCtl := TLuaControl.Create(lIdleTimer,L,@IdleTimerToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lIdleTimer),-1)
  else
     lIdleTimer.Name := Name;
  {$IFDEF HASCANVAS}
  if (lIdleTimer.InheritsFrom(TCustomControl) or lIdleTimer.InheritsFrom(TGraphicControl) or
	  lIdleTimer.InheritsFrom(TLCLComponent)) then
    lIdleTimer.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  IdleTimerToTable(L, -1, lIdleTimer);
  Result := 1;
end;
end.
