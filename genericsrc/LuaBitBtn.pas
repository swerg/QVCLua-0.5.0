unit LuaBitBtn;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateBitBtn(L: Plua_State): Integer; cdecl;
type
    TLuaBitBtn = class(TBitBtn)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLuaBitBtn.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function BitBtnGetCanvas(L: Plua_State): Integer; cdecl;
var lBitBtn:TLuaBitBtn;
begin
  lBitBtn := TLuaBitBtn(GetLuaObject(L, 1));
  lBitBtn.LuaCanvas.ToTable(L, -1, lBitBtn.Canvas);
  result := 1;
end;
{$ENDIF}
procedure BitBtnToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  LuaSetTableFunction(L, index, 'GetGlyph', ControlGetGlyph);
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', BitBtnGetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function CreateBitBtn(L: Plua_State): Integer; cdecl;
var
  lBitBtn:TLuaBitBtn;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lBitBtn := TLuaBitBtn.Create(Parent);
  lBitBtn.Parent := TWinControl(Parent);
  lBitBtn.LuaCtl := TLuaControl.Create(lBitBtn,L,@BitBtnToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lBitBtn),-1)
  else
     lBitBtn.Name := Name;
  {$IFDEF HASCANVAS}
  if (lBitBtn.InheritsFrom(TCustomControl) or lBitBtn.InheritsFrom(TGraphicControl) or
	  lBitBtn.InheritsFrom(TLCLComponent)) then
    lBitBtn.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  BitBtnToTable(L, -1, lBitBtn);
  Result := 1;
end;
end.
