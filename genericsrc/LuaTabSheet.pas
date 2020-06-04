unit LuaTabSheet;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateTabSheet(L: Plua_State): Integer; cdecl;
type
    TLuaTabSheet = class(TTabSheet)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaTabSheet.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function TabSheetGetCanvas(L: Plua_State): Integer; cdecl;
var lTabSheet:TLuaTabSheet;
begin
  lTabSheet := TLuaTabSheet(GetLuaObject(L, 1));
  lTabSheet.LuaCanvas.ToTable(L, -1, lTabSheet.Canvas);
  result := 1;
end;
{$ENDIF}
procedure TabSheetToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', TabSheetGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateTabSheet(L: Plua_State): Integer; cdecl;
var
  lTabSheet:TLuaTabSheet;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lTabSheet := TLuaTabSheet.Create(Parent);
  lTabSheet.Parent := TWinControl(Parent);
  lTabSheet.LuaCtl := TLuaControl.Create(lTabSheet,L,@TabSheetToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lTabSheet),-1)
  else
     lTabSheet.Name := Name;
  {$IFDEF HASCANVAS}
  if (lTabSheet.InheritsFrom(TCustomControl) or lTabSheet.InheritsFrom(TGraphicControl) or
	  lTabSheet.InheritsFrom(TLCLComponent)) then
    lTabSheet.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  TabSheetToTable(L, -1, lTabSheet);
  Result := 1;
end;
end.
