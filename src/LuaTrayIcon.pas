unit LuaTrayIcon;

interface

Uses Classes, Controls, Contnrs, LuaPas, LuaControl, Forms, ExtCtrls, TypInfo, LuaCanvas;

function CreateTrayIcon(L: Plua_State): Integer; cdecl;

type
    TLuaTrayIcon = class(TTrayIcon)
          LuaCtl: TLuaControl;
          LuaCanvas: TLuaCanvas;
           public
             destructor Destroy; override;
     end;

// ***********************************************

implementation

Uses LuaProperties, Lua, Dialogs, SysUtils, LuaForm, LCLClasses;


function TrayIconShow(L: Plua_State): Integer; cdecl;
var
  lTrayIcon: TTrayIcon;
begin
  CheckArg(L, 1);
  lTrayIcon := TLuaTrayIcon(GetLuaObject(L, 1));
  lTrayIcon.Show;
  Result := 0;
end;

function TrayIconHide(L: Plua_State): Integer; cdecl;
var
  lTrayIcon: TTrayIcon;
begin
  CheckArg(L, 1);
  lTrayIcon := TLuaTrayIcon(GetLuaObject(L, 1));
  lTrayIcon.Hide;
  Result := 0;
end;

function TrayIconShowBalloonHint(L: Plua_State): Integer; cdecl;
var
  lTrayIcon: TTrayIcon;
begin
  CheckArg(L, 1);
  lTrayIcon := TLuaTrayIcon(GetLuaObject(L, 1));
  lTrayIcon.ShowBalloonHint;
  Result := 0;
end;

function TrayIconLoad(L:Plua_State): Integer; cdecl;
var
  Frm: TTrayIcon;
  Str: String;
  Buf: Pointer;
  Size: Integer;
  Bm: TImage;
  ST: TMemoryStream;
begin
 Result := 0;
 Frm := TTrayIcon(GetLuaObject(L, 1));
 Str := lua_tostring(L,2);
 if (fileExists(Str)) then begin
      Frm.Icon.LoadFromFile(Str);
 end;
end;

function TrayIconGetCanvas(L: Plua_State): Integer; cdecl;
var lC:TLuaTrayIcon;
begin
  lC := TLuaTrayIcon(GetLuaObject(L, 1));
  lC.LuaCanvas.ToTable(L, -1, lC.Canvas);
  result := 1;
end;


destructor TLuaTrayIcon.Destroy;
begin
  if (LuaCanvas<>nil) then LuaCanvas.Free;
  inherited Destroy;
end;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);

  LuaSetTableFunction(L, Index, 'Show', TrayIconShow);
  LuaSetTableFunction(L, Index, 'Hide', TrayIconHide);
  LuaSetTableFunction(L, Index, 'ShowBalloonHint', TrayIconShowBalloonHint);
  LuaSetTableFunction(L, Index, 'Icon', TrayIconLoad);
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', TrayIconGetCanvas);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateTrayIcon(L: Plua_State): Integer; cdecl;
var
  lTrayIcon:TLuaTrayIcon;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lTrayIcon := TLuaTrayIcon.Create(Parent);
  lTrayIcon.LuaCtl := TLuaControl.Create(lTrayIcon,L,@Totable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lTrayIcon),-1)
  else 
     lTrayIcon.Name := Name;
  if (lTrayIcon.InheritsFrom(TCustomControl) or lTrayIcon.InheritsFrom(TGraphicControl) or lTrayIcon.InheritsFrom(TLCLComponent)) then
    lTrayIcon.LuaCanvas := TLuaCanvas.Create;
  ToTable(L, -1, lTrayIcon);
  Result := 1;
end;

end.
