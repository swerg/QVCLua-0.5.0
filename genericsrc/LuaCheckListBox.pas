unit LuaCheckListBox;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateCheckListBox(L: Plua_State): Integer; cdecl;
type
    TLuaCheckListBox = class(TCheckListBox)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaCheckListBox.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function CheckListBoxGetCanvas(L: Plua_State): Integer; cdecl;
var lCheckListBox:TLuaCheckListBox;
begin
  lCheckListBox := TLuaCheckListBox(GetLuaObject(L, 1));
  lCheckListBox.LuaCanvas.ToTable(L, -1, lCheckListBox.Canvas);
  result := 1;
end;
{$ENDIF}
procedure CheckListBoxToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  SetStringListMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', CheckListBoxGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateCheckListBox(L: Plua_State): Integer; cdecl;
var
  lCheckListBox:TLuaCheckListBox;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lCheckListBox := TLuaCheckListBox.Create(Parent);
  lCheckListBox.Parent := TWinControl(Parent);
  lCheckListBox.LuaCtl := TLuaControl.Create(lCheckListBox,L,@CheckListBoxToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lCheckListBox),-1)
  else
     lCheckListBox.Name := Name;
  {$IFDEF HASCANVAS}
  if (lCheckListBox.InheritsFrom(TCustomControl) or lCheckListBox.InheritsFrom(TGraphicControl) or
	  lCheckListBox.InheritsFrom(TLCLComponent)) then
    lCheckListBox.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  CheckListBoxToTable(L, -1, lCheckListBox);
  Result := 1;
end;
end.
