{$DEFINE HASCANVAS}
unit LuaScrollBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateScrollBox(L: Plua_State): Integer; cdecl;
type
    TLuaScrollBox = class(TScrollBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaScrollBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ScrollBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lScrollBox:TLuaScrollBox;
begin
  lScrollBox := TLuaScrollBox(GetLuaObject(L, 1));
  lScrollBox.LuaCanvas.ToTable(L, -1, lScrollBox.Canvas);
  result := 1;
end;
{$ENDIF}
procedure ScrollBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ScrollBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateScrollBox(L: Plua_State): Integer; cdecl;
var
  lScrollBox:TLuaScrollBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lScrollBox := TLuaScrollBox.Create(Parent);
  lScrollBox.Parent := TWinControl(Parent);
  lScrollBox.LuaCtl := TLuaControl.Create(lScrollBox,L,@ScrollBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lScrollBox),-1)
  else
     lScrollBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lScrollBox.InheritsFrom(TCustomControl) or lScrollBox.InheritsFrom(TGraphicControl) or
	  lScrollBox.InheritsFrom(TLCLComponent)) then
    lScrollBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ScrollBoxToTable(L, -1, lScrollBox);
  Result := 1;
end;
end.
