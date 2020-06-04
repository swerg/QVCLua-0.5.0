unit LuaStaticText;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateStaticText(L: Plua_State): Integer; cdecl;
type
    TLuaStaticText = class(TStaticText)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaStaticText.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function StaticTextGetCanvas(L: Plua_State): Integer; cdecl;
var lStaticText:TLuaStaticText;
begin
  lStaticText := TLuaStaticText(GetLuaObject(L, 1));
  lStaticText.LuaCanvas.ToTable(L, -1, lStaticText.Canvas);
  result := 1;
end;
{$ENDIF}
procedure StaticTextToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', StaticTextGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateStaticText(L: Plua_State): Integer; cdecl;
var
  lStaticText:TLuaStaticText;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lStaticText := TLuaStaticText.Create(Parent);
  lStaticText.Parent := TWinControl(Parent);
  lStaticText.LuaCtl := TLuaControl.Create(lStaticText,L,@StaticTextToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lStaticText),-1)
  else
     lStaticText.Name := Name;
  {$IFDEF HASCANVAS}
  if (lStaticText.InheritsFrom(TCustomControl) or lStaticText.InheritsFrom(TGraphicControl) or
	  lStaticText.InheritsFrom(TLCLComponent)) then
    lStaticText.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  StaticTextToTable(L, -1, lStaticText);
  Result := 1;
end;
end.
