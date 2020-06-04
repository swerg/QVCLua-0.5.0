unit LuaMemo;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateMemo(L: Plua_State): Integer; cdecl;
type
    TLuaMemo = class(TMemo)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaMemo.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function MemoGetCanvas(L: Plua_State): Integer; cdecl;
var lMemo:TLuaMemo;
begin
  lMemo := TLuaMemo(GetLuaObject(L, 1));
  lMemo.LuaCanvas.ToTable(L, -1, lMemo.Canvas);
  result := 1;
end;
{$ENDIF}
procedure MemoToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);

  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', MemoGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateMemo(L: Plua_State): Integer; cdecl;
var
  lMemo:TLuaMemo;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lMemo := TLuaMemo.Create(Parent);
  lMemo.Parent := TWinControl(Parent);
  lMemo.LuaCtl := TLuaControl.Create(lMemo,L,@MemoToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lMemo),-1)
  else
     lMemo.Name := Name;
  {$IFDEF HASCANVAS}
  if (lMemo.InheritsFrom(TCustomControl) or lMemo.InheritsFrom(TGraphicControl) or
	  lMemo.InheritsFrom(TLCLComponent)) then
    lMemo.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  MemoToTable(L, -1, lMemo);
  Result := 1;
end;
end.
