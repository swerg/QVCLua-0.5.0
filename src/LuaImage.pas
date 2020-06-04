unit LuaImage;

interface

Uses ExtCtrls, Controls, Classes,
     LuaPas,
     LuaControl,
     LuaCanvas,
     LuaBitmap,
     LuaGraphic,
     LuaPicture,
     Graphics;

function CreateImage(L: Plua_State): Integer; cdecl;
procedure BitmapToTable(L:Plua_State; Index:Integer; Sender:TObject);

type
	TLuaImage = class(TImage)
	    LuaCtl: TLuaControl;
            LuaCanvas: TLuaCanvas;
        public
             destructor Destroy; override;
        end;

implementation

Uses Forms, SysUtils, LuaProperties, Lua, Dialogs;

destructor TLuaImage.Destroy;
begin
  LuaCanvas.Free;
  inherited Destroy;
end;

// ************ IMAGE ******************** //
function LoadImageFromFile(L: Plua_State): Integer; cdecl;
var success:Boolean;
    lImage:TLuaImage;
    fname, ftype : String;
begin
  success := false;
  CheckArg(L, 2);
  lImage := TLuaImage(GetLuaObject(L, 1));
  fname := lua_tostring(L,2);
  ftype := ExtractFileExt(fname);
  try
      lImage.Picture.LoadFromFile(fname);
      success := true;
  finally
  end;
  lua_pushboolean(L,success);
  result := 1;
end;

function SaveImageToFile(L: Plua_State): Integer; cdecl;
var success:Boolean;
    lImage:TLuaImage;
    fname, ftype : String;
begin
  success := false;
  CheckArg(L, 2);
  lImage := TLuaImage(GetLuaObject(L, 1));
  fname := lua_tostring(L,2);
  ftype := ExtractFileExt(fname);
  try
      lImage.Picture.SaveToFile(fname, ftype);
      success := true;
  finally
  end;
  lua_pushboolean(L,success);
  result := 1;
end;

function LoadImageFromStream(L: Plua_State): Integer; cdecl;
var success:Boolean;
    lImage:TLuaImage;
    lStream: TMemoryStream;
begin
  success := false;
  CheckArg(L, 2);
  lImage := TLuaImage(GetLuaObject(L, 1));
  lStream := TMemoryStream(lua_touserdata(L,2));
  try
      if lStream<>nil then begin
         lStream.Position:=0;
         lImage.Picture.LoadFromStream(lStream);
         success := true;
      end;
  finally
  end;
  lua_pushboolean(L,success);
  result := 1;
end;

(*
function LoadImageFromBuffer(L: Plua_State): Integer; cdecl;
var lImage:TLuaImage;
    fname,fext: String;
    ST: TMemoryStream;
    Buf: pointer;
    Size: Integer;
begin
  CheckArg(L, 4);
  lImage := TLuaImage(GetLuaObject(L, 1));
  Size := trunc(lua_tonumber(L,3));
  Buf := lua_tolstring(L,2,@Size);
  fname := lua_tostring(L,4);
  if (Buf=nil) then
    LuaError(L,'Image not found! ',lua_tostring(L,2));
  try
       ST := TMemoryStream.Create;
       ST.WriteBuffer(Buf^,trunc(lua_tonumber(L,3)));
       ST.Seek(0, soFromBeginning);
       fext := ExtractFileExt(fname);
       System.Delete(fext, 1, 1);
       lImage.Picture.LoadFromStreamWithFileExt(ST,fext);
  finally
       if (Assigned(ST)) then ST.Free;
  end;
  lua_pushnumber(L,size);
  result := 1;
end;
*)

function LuaGetCanvas(L: Plua_State): Integer; cdecl;
var lImage:TLuaImage;
begin
  lImage := TLuaImage(GetLuaObject(L, 1));
  lImage.LuaCanvas.ToTable(L, -1, lImage.Canvas);
  result := 1;
end;

function LuaGetBitmap(L: Plua_State): Integer; cdecl;
var lImage:TLuaImage;
begin
  lImage := TLuaImage(GetLuaObject(L, 1));
  BitmapToTable(L, -1, lImage.Picture.Bitmap);
  result := 1;
end;

function LoadBitmapFromStream(L: Plua_State): Integer; cdecl;

function DecodeHexString(s:String):TMemoryStream;
var
  i: Integer;
  B:Byte;
  OutStr: TMemoryStream;
begin
    OutStr := TMemoryStream.Create;
    // remove first 8 bytes (size)
    i := 9;
    While i<=Length(s) Do Begin
          B:=Byte(StrToIntDef('$'+Copy(s,i,2),0));
          Inc(i,2);
          OutStr.Write(B,1);
    End;
    OutStr.Seek(0, soFromBeginning);
    Result := OutStr;
end;

var lBmp:TBitmap;
    lPic:TPicture;
    AStream: TStream;
    tmpStream: TMemoryStream;
    // ASize: Cardinal;
begin
  CheckArg(L, 2);
  lBmp := TBitmap(GetLuaObject(L, 1));
  if lua_isstring(L,2) then
     AStream := DecodeHexString(lua_tostring(L,2))
  else
     AStream := TStream(GetLuaObject(L, 2));
  lPic := TPicture.Create;
  tmpStream := TMemoryStream.Create;
  // ASize := lua_tointeger(L,3);
  try
     lPic.LoadFromStream(AStream);
     lPic.Bitmap.SaveToStream(tmpStream);
     tmpStream.position := 0;
     lBmp.LoadFromStream(tmpStream, tmpStream.size);
     lBmp := lPic.Bitmap;
  finally
     lPic.Free;
     tmpStream.Free;
     if lua_isstring(L,2) then
        AStream.Free;
  end;
  result := 0;
end;

procedure BitmapToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, index, 'LoadFromStream', LoadBitmapFromStream);
  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);
end;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, index, 'LoadFromFile', LoadImageFromFile);
  LuaSetTableFunction(L, index, 'SaveToFile', SaveImageToFile);
  LuaSetTableFunction(L, index, 'LoadFromStream', LoadImageFromStream);
  // LuaSetTableFunction(L, index, 'LoadFromBuffer', LoadImageFromBuffer);
  LuaSetTableFunction(L, index, 'GetCanvas', LuaGetCanvas);
  LuaSetTableFunction(L, index, 'GetBitmap', LuaGetBitmap);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateImage(L: Plua_State): Integer; cdecl;
var
  lImage:TLuaImage;
  lCanvas:TLuaCanvas;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lImage := TLuaImage.Create(Parent);
  lImage.Parent := TWinControl(Parent);
  lImage.LuaCtl := TLuaControl.Create(lImage,L,@ToTable);
  lImage.LuaCanvas := TLuaCanvas.Create;
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lImage),-1)
  else 
     lImage.Name := Name;
  ToTable(L, -1, lImage);

  Result := 1;
end;

end.
