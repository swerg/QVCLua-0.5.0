unit LuaMenu;

interface

Uses Menus, Classes, LuaPas, LuaControl, Lua;

type

  TLuaMainMenu = class(TMainMenu)
	LuaCtl: TLuaControl;
  end;

  TLuaPopupMenu = class(TPopupMenu)
    LuaCtl: TLuaControl;
    private
      // FPopupPoint: TPoint;
      // procedure PopUp(X, Y: Integer); override;
    public
      // property PopupPoint: TPoint read FPopupPoint write FPopupPoint;
  end;

  TLuaMenuItem = class(TMenuItem)
    LuaCtl: TLuaControl;
  end;

function CreateMainMenu(L: Plua_State): Integer; cdecl;
function CreatePopupMenu(L: Plua_State): Integer; cdecl;
function CreateMenuItem(L: Plua_State): Integer; cdecl;

//forward
function LoadMenu(L: Plua_State): Integer; cdecl;
procedure MenuItemToTable(L:Plua_State; Index:Integer; Sender:TObject);
procedure NewItem(L:PLua_State;Parent:TComponent);

implementation

Uses Forms, SysUtils, TypInfo, LuaImage, LuaImageList, LuaProperties, LCLProc, InterfaceBase,
     lclIntf;

// **********************************************************
// Menu Item
// **********************************************************

function LoadMenuFromLuaTable(L: Plua_State; MI:TLuaMenuItem):Boolean;
var n: Integer;
    key,val:String;
    PInfo: PPropInfo;
begin
  result := false;
  if lua_istable(L,-1) then begin
     n := lua_gettop(L);
     result := true;
     lua_pushnil(L);
     while (lua_next(L, n) <> 0) do begin
         if (lua_istable(L,-1)) and (UpperCase(lua_tostring(L,-2))<>'ACTION') then begin
            NewItem(L,MI);
         end else begin
            PInfo := GetPropInfo(TComponent(MI).ClassInfo,lua_tostring(L, -2));
            if PInfo <> nil then begin
              try
  	          SetProperty(L, -1, MI, PInfo);
              except
            	  break;
              end;
            end else
              LuaError(L,'Menuitem property not found!', lua_tostring(L, -2));

            if (UpperCase(lua_tostring(L,-2))='SHORTCUT') then
                  MI.ShortCut := TextToShortCut(lua_tostring(L,-1));
         end;
         lua_pop(L, 1);
     end;
  end;
end;


function FindMenuItemByName(lMenuParent:TLuaMenuItem; Name:String):TLuaMenuItem;
var
   lMenuItem, fMenuItem :TLuaMenuItem;
   i,n:Integer;
begin
   Result := nil;
   n := lMenuParent.Count;
   for i:= 0 to n-1 do begin
       lMenuItem := TLuaMenuItem(lMenuParent.Items[i]);
       if lMenuItem.Name = Name then begin
          result := lMenuItem;
          exit;
       end else if (lMenuItem.Count>0) then begin
          fMenuItem := FindMenuItemByName(lMenuItem,Name);
          if fMenuItem<>nil then begin
             result := fMenuItem;
             exit;
          end;
       end;
   end;
end;

function FindMenuItem(L: Plua_State): Integer; cdecl;
var
  lObject:TLuaMenuItem;
  lMenuItem:TLuaMenuItem;
  n,c:Integer;
begin
  n := lua_gettop(L);
  if (n=2) then begin
       // funny bugfix
       lObject := TLuaMenuItem(GetLuaObject(L,-2));
       lMenuItem := FindMenuItemByName(lObject, lua_tostring(L,-1));
       if lMenuItem<>nil then
        MenuItemToTable(L,-1,lMenuItem)
       else
        lua_pushnil(L);
  end
  else
    lua_pushnil(L);
  Result := 1;
end;

Procedure NewItem(L:PLua_State;Parent:TComponent);
var
  Name:String;
  lMenuItem:TLuaMenuItem;
  n:Integer;
begin
  n := lua_gettop(L);
  lua_pushnil(L);
  while (lua_next(L, n) <> 0) do begin      // menuitems
        if lua_istable(L,-1) then begin
          lMenuItem := TLuaMenuItem.Create(Parent);
          lMenuItem.LuaCtl := TLuaControl.Create(lMenuItem,L,@MenuItemToTable);
          LoadMenuFromLuaTable(L,lMenuItem);
          if Parent.ClassName = 'TLuaMainMenu' then
            TMainMenu(Parent).Items.Add(lMenuItem)
          else
          if Parent.ClassName = 'TLuaMenuItem' then
            TMenuItem(Parent).Add(lMenuItem)
          else
            TPopupMenu(Parent).Items.Add(lMenuItem);
        end;
        lua_pop(L, 1);
  end;
end;

function CreateMenuItem(L: Plua_State): Integer; cdecl;
var
  App :TComponent;
  Name:String;
  lMenu:TLuaMenuItem;
begin

  GetControlParents(L,App,Name);
  
  // create differs!!!
  lMenu := TLuaMenuItem.Create(nil);
  if App.ClassName = 'TLuaMainMenu' then
     TMainMenu(App).Items.Add(lMenu)
  else
  if App.ClassName = 'TLuaMenuItem' then
     TMenuItem(App).Add(lMenu)
  else
     TPopupMenu(App).Items.Add(lMenu);

  lMenu.Name := Name;
  lMenu.LuaCtl := TLuaControl.Create(lMenu,L,@MenuItemToTable);
  
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lMenu),-1);

  MenuItemToTable(L, -1, lMenu);

  Result := 1;
end;

function InsertMenuItem(L: Plua_State): Integer; cdecl;
var
  App :TComponent;
  Name:String;
  lMenu:TLuaMenuItem;
  idx:Integer;
begin
  CheckArg(L, 3);
  App := TComponent(GetLuaObject(L,1));
  Name := '';
  Idx := 0;
  Name := lua_tostring(L,-1);
  Idx := trunc(lua_tonumber(L,-2));

  // create differs!!!
  lMenu := TLuaMenuItem.Create(nil);
  if App.ClassName = 'TLuaMainMenu' then
     TMainMenu(App).Items.Insert(idx, lMenu)
  else
  if App.ClassName = 'TLuaMenuItem' then
     TMenuItem(App).insert(idx,lMenu)
  else
     TPopupMenu(App).Items.insert(idx,lMenu);

  lMenu.Name := Name;
  lMenu.LuaCtl := TLuaControl.Create(lMenu,L,@MenuItemToTable);

  MenuItemToTable(L, -1, lMenu);

  Result := 1;
end;

function RemoveMenuItem(L: Plua_State): Integer; cdecl;
var
  lMenu:TLuaMenuItem;
  n,idx:Integer;
begin
  n := lua_gettop(L);
  lMenu := TLuaMenuItem(GetLuaObject(L,-1));
  if (n=2) then begin
     idx := Trunc(lua_tonumber(L,-2));
     lMenu.Delete(idx);
  end else begin
     lMenu.Free;
  end;
  Result := 0;
end;

procedure MenuItemToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'LoadFromTable', @LoadMenu);
  LuaSetTableFunction(L, Index, 'Find', @FindMenuItem);
  LuaSetTableFunction(L, Index, 'Add', @CreateMenuItem);
  LuaSetTableFunction(L, Index, 'Remove', @RemoveMenuItem);
  LuaSetTableFunction(L, Index, 'Insert', @InsertMenuItem);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;


// **********************************************************
// Main Menu
// **********************************************************

function FindMainMenuItemByName(lMenuParent:TLuaMainMenu; Name:String):TLuaMenuItem;
var
   lMenuItem, fMenuItem:TLuaMenuItem;
   i,n:Integer;
begin
   Result := nil;
   n := lMenuParent.Items.Count;
   for i:= 0 to n-1 do begin
       lMenuItem := TLuaMenuItem(lMenuParent.Items[i]);
       if lMenuItem.Name = Name then begin
          result := lMenuItem;
          exit;
       end else if (lMenuItem.Count>0) then begin
          fMenuItem := FindMenuItemByName(lMenuItem,Name);
          if fMenuItem<>nil then begin
             result := fMenuItem;
             exit;
          end;
       end;
   end;
end;

function FindMainMenuItem(L: Plua_State): Integer; cdecl;
var
  lObject:TObject;
  lMenuItem:TLuaMenuItem;
  n,c:Integer;
begin
  n := lua_gettop(L);
  if (n=2) then begin
       lMenuItem := FindMainMenuItemByName(TLuaMainMenu(GetLuaObject(L,-2)), lua_tostring(L,-1));
       if lMenuItem<>nil then
        MenuItemToTable(L,-1,lMenuItem)
       else
        lua_pushnil(L);
  end
  else
    lua_pushnil(L);
  Result := 1;
end;

function LoadMenu(L: Plua_State): Integer; cdecl;
var
  Parent :TComponent;
  Name:String;
  lMenuItem:TLuaMenuItem;
  n:Integer;
begin
  Parent := nil;
  n := lua_gettop(L);
  if (n=2) then begin
       Parent := TComponent(GetLuaObject(L,-2));
       NewItem(L,Parent);
  end;
  Result := 0;
end;


function SetImages(L: Plua_State): Integer; cdecl;
var
  lMenu:TLuaMenuItem;
  TI:TLuaImageList;
begin
  CheckArg(L, 2);
  lMenu := TLuaMenuItem(GetLuaObject(L, 1));
  TI := TLuaImageList(GetLuaObject(L, 2));
  TLuaMainMenu(lMenu).Images := TI;
  Result := 0;
end;

function SetImage(L: Plua_State): Integer; cdecl;
var
	lMenu:TLuaMenuItem;
  lImage: TLuaImage;
begin
  CheckArg(L, 2);
  lMenu := TLuaMenuItem(GetLuaObject(L, 1));
  lImage := TLuaImage(GetLuaObject(L, 2));
  lMenu.Bitmap := lImage.Picture.Bitmap;
  Result := 0;
end;

procedure MainMenuToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'LoadFromTable', @LoadMenu);
  LuaSetTableFunction(L, Index, 'Find', @FindMainMenuItem);
  LuaSetTableFunction(L, Index, 'Add', @CreateMenuItem);
  LuaSetTableFunction(L, Index, 'Remove', @RemoveMenuItem);
  LuaSetTableFunction(L, Index, 'Insert', @InsertMenuItem);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateMainMenu(L: Plua_State): Integer; cdecl;
var
  App :TComponent;
  Name:String;
  lMenu:TLuaMainMenu;
  n:Integer;
begin
  GetControlParents(L,App,Name);
  lMenu := TLuaMainMenu.Create(App);
  lMenu.Name := Name;
  lMenu.LuaCtl := TLuaControl.Create(lMenu,L,@MainMenuToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lMenu),-1);
  MainMenuToTable(L, -1, lMenu);
  Result := 1;
end;


// **********************************************************
// Popup Menu
// **********************************************************

function FindPopupMenuItemByName(lMenuParent:TLuaPopupMenu; Name:String):TLuaMenuItem;
var
   lMenuItem, fMenuItem:TLuaMenuItem;
   i,n:Integer;
begin
   Result := nil;
   n := lMenuParent.Items.Count;
   for i:= 0 to n-1 do begin
       lMenuItem := TLuaMenuItem(lMenuParent.Items[i]);
       if lMenuItem.Name = Name then begin
          result := lMenuItem;
          exit;
       end else if (lMenuItem.Count>0) then begin
          fMenuItem := FindMenuItemByName(lMenuItem,Name);
          if fMenuItem<>nil then begin
             result := fMenuItem;
             exit;
          end;
       end;
   end;
end;

function FindPopupMenuItem(L: Plua_State): Integer; cdecl;
var
  lMenuItem:TLuaMenuItem;
  n:Integer;
begin
  n := lua_gettop(L);
  if (n=2) then begin
       lMenuItem := FindPopupMenuItemByName(TLuaPopupMenu(GetLuaObject(L,-2)), lua_tostring(L,-1));
       if lMenuItem<>nil then
        MenuItemToTable(L,-1,lMenuItem)
       else
        lua_pushnil(L);
  end
  else
    lua_pushnil(L);
  Result := 1;
end;

(*
procedure TLuaPopupMenu.PopUp(X, Y: Integer);
var i:Integer;
  MenuHandle: HMENU;
  AppHandle: HWND;
begin
  if ActivePopupMenu <> nil then ActivePopupMenu.Close;
  FPopupPoint := Point(X, Y);
  ReleaseCapture;
  DoPopup(Self);
  if Items.Count = 0 then exit;
  ActivePopupMenu := Self;
  for i := 0 to Items.Count - 1 do
    Items[i].InitiateAction;
  DestroyHandle;
  CreateHandle;
  if Assigned(OnMenuPopupHandler) then OnMenuPopupHandler(Self);
  TWSPopupMenuClass(WidgetSetClass).Popup(Self, X, Y);
end;
*)

function LuaPopup(L: Plua_State): Integer; cdecl;
var
  lMenu: TLuaPopupMenu;
  x,y :Integer;
begin
  CheckArg(L, 3);
  lMenu := TLuaPopupMenu(GetLuaObject(L, 1));
  x := trunc(lua_tonumber(L,2));
  y := trunc(lua_tonumber(L,3));
  lMenu.Popup(x,y);
  Result := 0;
end;

procedure PopupMenuToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'Popup', @LuaPopup);
  LuaSetTableFunction(L, Index, 'LoadFromTable', @LoadMenu);
  LuaSetTableFunction(L, Index, 'Add', @CreateMenuItem);
  LuaSetTableFunction(L, Index, 'Remove', @RemoveMenuItem);
  LuaSetTableFunction(L, Index, 'Find', @FindPopupMenuItem);
  LuaSetTableFunction(L, Index, 'Insert', @InsertMenuItem);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreatePopupMenu(L: Plua_State): Integer; cdecl;
var
  App :TComponent;
  Name:String;
	lMenu:TLuaPopupMenu;
  n:Integer;
begin
  GetControlParents(L,App,Name);
  lMenu := TLuaPopupMenu.Create(App);
  lMenu.Name := Name;
  lMenu.LuaCtl := TLuaControl.Create(lMenu,L,@PopupMenuToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lMenu),-1);
  PopupMenuToTable(L, -1, lMenu);
  Result := 1;
end;

end.
