{$DEFINE HASCANVAS}
unit LuaSplitter;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateSplitter(L: Plua_State): Integer; cdecl;
type
    TLuaSplitter = class(TSplitter)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaSplitter.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function SplitterGetCanvas(L: Plua_State): Integer; cdecl;
var lSplitter:TLuaSplitter;
begin
  lSplitter := TLuaSplitter(GetLuaObject(L, 1));
  lSplitter.LuaCanvas.ToTable(L, -1, lSplitter.Canvas);
  result := 1;
end;
{$ENDIF}
procedure SplitterToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', SplitterGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateSplitter(L: Plua_State): Integer; cdecl;
var
  lSplitter:TLuaSplitter;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lSplitter := TLuaSplitter.Create(Parent);
  lSplitter.Parent := TWinControl(Parent);
  lSplitter.LuaCtl := TLuaControl.Create(lSplitter,L,@SplitterToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lSplitter),-1)
  else
     lSplitter.Name := Name;
  {$IFDEF HASCANVAS}
  if (lSplitter.InheritsFrom(TCustomControl) or lSplitter.InheritsFrom(TGraphicControl) or
	  lSplitter.InheritsFrom(TLCLComponent)) then
    lSplitter.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  SplitterToTable(L, -1, lSplitter);
  Result := 1;
end;
end.
