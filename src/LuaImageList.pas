unit LuaImageList;

interface

Uses ExtCtrls, Controls, Classes,
     ImgList,
     LuaPas,
     LuaControl,
     Graphics;

function CreateImageList(L: Plua_State): Integer; cdecl;

type
     TLuaImageList = class(TImageList)
        LuaCtl: TLuaControl;
        published
           property Count;
     end;

implementation

Uses Forms, SysUtils, LuaProperties, Lua, LuaImage, Dialogs;

// ************ IMAGELIST **************** //


function LoadImagesFromLuaTable(L: Plua_State): Integer; cdecl;
var
    lImageList:TLuaImageList;
    img:TImage;
    fname: String;
    n,i: Integer;
begin
  result := 0;
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  if lua_istable(L,-1) then begin
     n := lua_gettop(L);
     lua_pushnil(L);
     while (lua_next(L, n) <> 0) do begin
         if (lua_isstring(L,-1)) then begin
            fname := lua_tostring(L,-1);
            img := TImage.Create(lImageList);
            img.Picture.LoadFromFile(fname);
            i := lImageList.Add(img.Picture.Bitmap,nil);
            img.free;
         end else begin
             // TODO
            // Load buffers here
         end;
         lua_pop(L,1);
     end;
  end;
end;

function LoadImageFromFile(L: Plua_State): Integer; cdecl;
var
    lImageList:TLuaImageList;
    fname: String;
    img:TImage;
    i:Integer;
begin
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  fname := lua_tostring(L,2);
  try
    img := TImage.Create(lImageList);
    img.Picture.LoadFromFile(fname);
    i := lImageList.Add(img.Picture.Bitmap,nil);
    img.free;
    lua_pushnumber(L,i);
  except
    lua_pushnil(L);
  end;
  result := 1;
end;

function LoadStreamToList(L: Plua_State): Integer; cdecl;
var
    lImageList:TLuaImageList;
    lImage:TImage;
    ST: TMemoryStream;
    fname, fext: string;
    i,Size: Integer;
begin
  CheckArg(L, 3);
  i := -1;
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  ST := TMemoryStream(lua_touserdata(L,2));
  fname := lua_tostring(L,3);
  if (ST=nil) then
    LuaError(L,'Image not found!',lua_tostring(L,3));
  try
       ST.Seek(0, soFromBeginning);
       lImage := TImage.Create(lImageList);
       fext := ExtractFileExt(fname);
       System.Delete(fext, 1, 1);
       lImage.Picture.LoadFromStreamWithFileExt(ST,fext);
       i := lImageList.Add(TCustomBitmap(lImage.Picture.Bitmap),nil);
       // LCL bug?
  finally
       if (Assigned(lImage)) then lImage.Free;
  end;
  lua_pushnumber(L,i);
  result := 1;
end;

function LoadBufferToList(L: Plua_State): Integer; cdecl;
var
    lImageList:TLuaImageList;
    lImage:TImage;
    ST: TMemoryStream;
    Buf: pointer;
    fname, fext: string;
    i,Size: Integer;
begin
  CheckArg(L, 4);
  i := -1;
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  Size := trunc(lua_tonumber(L,3));
  Buf := lua_tolstring(L,2,@Size);
  fname := lua_tostring(L,4);
  if (Buf=nil) then
    LuaError(L,'Image not found!',lua_tostring(L,2));
  try
       ST := TMemoryStream.Create;
       ST.WriteBuffer(Buf^,trunc(lua_tonumber(L,3)));
       ST.Seek(0, soFromBeginning);
       lImage := TImage.Create(lImageList);
       fext := ExtractFileExt(fname);
       System.Delete(fext, 1, 1);
       lImage.Picture.LoadFromStreamWithFileExt(ST,fext);
       i := lImageList.Add(TCustomBitmap(lImage.Picture.Bitmap),nil);
       // LCL bug?
  finally
       if (Assigned(ST)) then ST.Free;
       if (Assigned(lImage)) then lImage.Free;
  end;
  lua_pushnumber(L,i);
  result := 1;
end;


function ClearImageList(L: Plua_State): Integer; cdecl;
var lImageList:TLuaImageList;
begin
  CheckArg(L, 1);
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  lImageList.Clear;
  result := 0;
end;

function GetGlyph(L: Plua_State): Integer; cdecl;
var lImageList:TLuaImageList;
    i:Integer;
    b:TBitmap;
begin
  CheckArg(L, 2);
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  i := trunc(lua_tonumber(L,2));
  BitmapToTable(L,-1,b);
  result := 1;
end;

function GetCount(L: Plua_State): Integer; cdecl;
var lImageList:TLuaImageList;
    i:Integer;
begin
  CheckArg(L, 1);
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  i := TCustomImageList(lImageList).Count;
  lua_pushnumber(L,i);
  result := 1;
end;

function Add(L: Plua_State): Integer; cdecl;
var lImageList:TLuaImageList;
    lBmp: TBitmap;
    i:Integer;
begin
  // CheckArg(L, 1);
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  lBmp := TBitmap(GetLuaObject(L, 2));
  if lBmp = nil then lBmp := TBitmap.Create;
  i := TCustomImageList(lImageList).Add(lBmp,nil);
  lua_pushnumber(L,i);
  result := 1;
end;

function Insert(L: Plua_State): Integer; cdecl;
var lImageList:TLuaImageList;
    lBmp: TBitmap;
    i:Integer;
begin
  // CheckArg(L, 1);
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  i := lua_tointeger(L,2);
  lBmp := TBitmap(GetLuaObject(L, 3));
  if lBmp = nil then lBmp := TBitmap.Create;
  TCustomImageList(lImageList).Insert(i,lBmp,nil);
  result := 0;
end;

function Delete(L: Plua_State): Integer; cdecl;
var lImageList:TLuaImageList;
    lBmp: TBitmap;
    i:Integer;
begin
  CheckArg(L, 2);
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  i := lua_tointeger(L,2);
  TCustomImageList(lImageList).Delete(i);
  result := 0;
end;

function Move(L: Plua_State): Integer; cdecl;
var lImageList:TLuaImageList;
    curi,newi:Integer;
begin
  CheckArg(L, 3);
  lImageList := TLuaImageList(GetLuaObject(L, 1));
  curi := lua_tointeger(L,2);
  newi := lua_tointeger(L,3);
  TCustomImageList(lImageList).Move(curi,newi);
  result := 0;
end;


procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, index, 'LoadFromTable', LoadImagesFromLuaTable);
  LuaSetTableFunction(L, index, 'LoadFromFile', LoadImageFromFile);
  LuaSetTableFunction(L, index, 'LoadFromStream', LoadStreamToList);
  // LuaSetTableFunction(L, index, 'LoadFromBuffer', LoadBufferToList);
  LuaSetTableFunction(L, index, 'Clear', ClearImageList);
  LuaSetTableFunction(L, index, 'GetGlyph', GetGlyph);
  // LuaSetTableFunction(L, index, 'GetCount', GetCount);
  LuaSetTableFunction(L, index, 'Add', Add);
  LuaSetTableFunction(L, index, 'Insert', Insert);
  LuaSetTableFunction(L, index, 'Delete', Delete);
  LuaSetTableFunction(L, index, 'Move', Move);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateImageList(L: Plua_State): Integer; cdecl;
var
  lImagelist:TLuaImageList;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lImagelist := TLuaImagelist.Create(Parent);
  lImagelist.LuaCtl := TLuaControl.Create(lImagelist,L,@ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lImagelist),-1)
  else 
     lImagelist.Name := Name;

  ToTable(L, -1, lImagelist);
  Result := 1;
end;

end.
