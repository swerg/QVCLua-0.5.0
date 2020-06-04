unit LuaForm;

interface

Uses Classes, Types, Controls, LuaPas, LuaControl, Forms, TypInfo, InterfaceBase,
     Dialogs, LuaCanvas;

function CreateForm(L: Plua_State): Integer; cdecl;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);

type
	TLuaForm = class(TForm)
           LuaCtl: TLuaControl;
           LuaCanvas: TLuaCanvas;
           public
             destructor Destroy; override;
        end;


implementation

Uses
LuaProperties, Lua, SysUtils, ExtCtrls, Graphics, Windows, LMessages;

var SaveAppHandle : THandle;

// ***********************************************
function FormShow(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
begin
  CheckArg(L, 1);
  lForm := TLuaForm(GetLuaObject(L, 1));
  lForm.Show;
  Result := 0;
end;

function FormShowModal(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
  res: Integer;
begin
  CheckArg(L, 1);
  lForm := TLuaForm(GetLuaObject(L, 1));
  res := lForm.ShowModal;
  lua_pushstring(L,pchar(ButtonResult[res]));
  Result := 1;
end;

function FormHide(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
begin
  CheckArg(L, 1);
  lForm := TLuaForm(GetLuaObject(L, 1));
  lForm.Hide;
  Result := 0;
end;

function FormShowOnTop(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
begin
  CheckArg(L, 1);
  lForm := TLuaForm(GetLuaObject(L, 1));
  lForm.ShowOnTop;
  Result := 0;
end;

function FormSendToBack(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
begin
  CheckArg(L, 1);
  lForm := TLuaForm(GetLuaObject(L, 1));
  lForm.SendToBack;
  Result := 0;
end;

function FormClose(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
begin
  CheckArg(L, 1);
  lForm := TLuaForm(GetLuaObject(L, 1));
  lForm.Close;
  Result := 0;
end;

function FormRelease(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
begin
  if CheckArg(L, 1) then
  begin
  lForm := TLuaForm(GetLuaObject(L, 1));
  Windows.PostMessage(lForm.Handle, CM_RELEASE, 0, 0);
  end;
  Result := 0;
end;

function FormGC(L: Plua_State): Integer; cdecl;
var
  lForm: TLuaForm;
begin
  if CheckArg(L, 1) then
  begin
  lForm := TLuaForm(GetLuaObject(L, 1));
  LuaError(L,'Form GC!');
  end;
  Result := 0;
end;

function FormParent(L: Plua_State): Integer; cdecl;
var
  LuaForm: TLuaForm;
begin
  CheckArg(L, 2);
  LuaForm := TLuaForm(GetLuaObject(L, 1));
  LuaForm.Parent := TForm(GetLuaObject(L, 2));
  Result := 0;
end;

function FormIsDocked(L: Plua_State): Integer; cdecl;
var
  LuaForm: TLuaForm;
begin
  CheckArg(L, 1);
  LuaForm := TLuaForm(GetLuaObject(L, 1));
  lua_pushboolean(L,not(LuaForm.Floating));
  Result := 1;
end;

function FormDock(L: Plua_State): Integer; cdecl;
var
  LuaForm: TLuaForm;
begin
  CheckArg(L, 2);
  LuaForm := TLuaForm(GetLuaObject(L, 1));
  LuaForm.ManualDock(TWinControl(GetLuaObject(L, 2)),nil,alClient);
  Result := 0;
end;

function FormUnDock(L: Plua_State): Integer; cdecl;
var
  LuaForm: TLuaForm;
  R:TRect;
  k:String;
  n:Integer;
begin
  CheckArg(L, 2);
  n := lua_gettop(L);
  LuaForm := TLuaForm(GetLuaObject(L, 1));
  with R do begin
    R.Left := 0;
    R.Right := 0;
    R.Top := 0;
    R.Bottom := 0;
  end;
  if lua_istable(L,2) then begin
    lua_pushnil(L);
    while (lua_next(L, n) <> 0) do
    begin
      k := lua_tostring(L,-2);
      if lowercase(k)='left' then
        R.Left := trunc(lua_tonumber(L,-1))
      else if lowercase(k)='right' then
        R.Right := trunc(lua_tonumber(L,-1))
      else if lowercase(k)='top' then
        R.Top := trunc(lua_tonumber(L,-1))
      else if lowercase(k)='bottom' then
        R.Bottom := trunc(lua_tonumber(L,-1));
      lua_pop(L, 1);
    end;
  end;
  LuaForm.ManualFloat(R);
  Result := 0;
end;

procedure SetAsMainForm(aForm:TForm);
var
  P: Pointer;
begin
  P := @Application.Mainform;
  Pointer(P^) := aForm;
end;

function FormIcon(L:Plua_State): Integer; cdecl;
var
  Frm: TLuaForm;
  Str: String;
  Buf: Pointer;
  Size: Integer;
  Bm: TImage;
  ST: TMemoryStream;
begin
 Result := 0;
 Frm := TLuaForm(GetLuaObject(L, 1));
 Str := lua_tostring(L,2);
 if (fileExists(Str)) then begin
      Frm.Icon.LoadFromFile(Str);
 end;
end;

function FormGetCanvas(L: Plua_State): Integer; cdecl;
var lForm:TLuaForm;
begin
  lForm := TLuaForm(GetLuaObject(L, 1));
  lForm.LuaCanvas.ToTable(L, -1, lForm.Canvas);
  result := 1;
end;


procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);

  LuaSetTableFunction(L, Index, 'Show', FormShow);
  LuaSetTableFunction(L, Index, 'ShowModal', FormShowModal);
  LuaSetTableFunction(L, Index, 'Hide', FormHide);
  LuaSetTableFunction(L, Index, 'ShowOnTop', FormShowOnTop);
  LuaSetTableFunction(L, Index, 'SendToBack', FormSendToBack);
  LuaSetTableFunction(L, Index, 'Close', FormClose);
  LuaSetTableFunction(L, Index, 'Release', FormRelease);
  LuaSetTableFunction(L, Index, 'Icon', FormIcon);
  LuaSetTableFunction(L, Index, 'IsDocked', FormIsDocked);
  LuaSetTableFunction(L, Index, 'Dock', FormDock);
  LuaSetTableFunction(L, Index, 'UnDock', FormUnDock);
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', FormGetCanvas);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
  LuaSetMetaFunction(L, index, '__gc', FormGC);
end;

destructor TLuaForm.Destroy;
begin
  if (LuaCanvas<>nil) then LuaCanvas.Free;
  inherited Destroy;
end;

function CreateForm(L: Plua_State): Integer; cdecl;
var
  App :TComponent;
  Name:String;
  lForm:TLuaForm;
  n:Integer;

  begin

  GetControlParents(L,App,Name);
  App := Application;
  if App = nil then
     LuaError(L,'No application found, cannot create form!', Name);

  lForm := TLuaForm.CreateNew(App,0);
  // lForm.Parent := TWinControl(App);
  lForm.Name := Name;
  lForm.LuaCtl := TLuaControl.Create(lForm,L, @ToTable);
  n := lua_gettop(L);
  if (n>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lForm),-1);

  if Application.MainForm = nil then begin
     ///QVCL start
     ///QVCL - set special main form, not first Lua-form
     ///SetAsMainForm(lForm);
     SetAsMainForm(TForm.Create(Application));
     ///QVCL end
     Application.Initialize;
     Randomize;
  end;
  if (lForm.InheritsFrom(TCustomControl) or lForm.InheritsFrom(TGraphicControl)) then
    lForm.LuaCanvas := TLuaCanvas.Create;
  ToTable(L, -1, lForm);
  
  Result := 1;
end;


end.
