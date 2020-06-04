unit LuaEditButton;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateEditButton(L: Plua_State): Integer; cdecl;
type
    TLuaEditButton = class(TEditButton)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaEditButton.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function EditButtonGetCanvas(L: Plua_State): Integer; cdecl;
var lEditButton:TLuaEditButton;
begin
  lEditButton := TLuaEditButton(GetLuaObject(L, 1));
  lEditButton.LuaCanvas.ToTable(L, -1, lEditButton.Canvas);
  result := 1;
end;
{$ENDIF}
procedure EditButtonToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetTableFunction(L, index, 'GetGlyph', ControlGetGlyph);
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', EditButtonGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateEditButton(L: Plua_State): Integer; cdecl;
var
  lEditButton:TLuaEditButton;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lEditButton := TLuaEditButton.Create(Parent);
  lEditButton.Parent := TWinControl(Parent);
  lEditButton.LuaCtl := TLuaControl.Create(lEditButton,L,@EditButtonToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lEditButton),-1)
  else
     lEditButton.Name := Name;
  {$IFDEF HASCANVAS}
  if (lEditButton.InheritsFrom(TCustomControl) or lEditButton.InheritsFrom(TGraphicControl) or
	  lEditButton.InheritsFrom(TLCLComponent)) then
    lEditButton.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  EditButtonToTable(L, -1, lEditButton);
  Result := 1;
end;
end.
