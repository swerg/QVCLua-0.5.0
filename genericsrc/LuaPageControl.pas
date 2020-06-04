unit LuaPageControl;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreatePageControl(L: Plua_State): Integer; cdecl;
type
    TLuaPageControl = class(TPageControl)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaPageControl.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function PageControlGetCanvas(L: Plua_State): Integer; cdecl;
var lPageControl:TLuaPageControl;
begin
  lPageControl := TLuaPageControl(GetLuaObject(L, 1));
  lPageControl.LuaCanvas.ToTable(L, -1, lPageControl.Canvas);
  result := 1;
end;
{$ENDIF}
procedure PageControlToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', PageControlGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreatePageControl(L: Plua_State): Integer; cdecl;
var
  lPageControl:TLuaPageControl;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lPageControl := TLuaPageControl.Create(Parent);
  lPageControl.Parent := TWinControl(Parent);
  lPageControl.LuaCtl := TLuaControl.Create(lPageControl,L,@PageControlToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lPageControl),-1)
  else
     lPageControl.Name := Name;
  {$IFDEF HASCANVAS}
  if (lPageControl.InheritsFrom(TCustomControl) or lPageControl.InheritsFrom(TGraphicControl) or
	  lPageControl.InheritsFrom(TLCLComponent)) then
    lPageControl.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  PageControlToTable(L, -1, lPageControl);
  Result := 1;
end;
end.
