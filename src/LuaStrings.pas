unit LuaStrings;

interface

Uses Classes, Types, Controls, Contnrs, LuaPas, Forms, StdCtrls, FileCtrl, TypInfo;

procedure TStringsToTable(L: Plua_State; Comp:TObject; PInfo:PPropInfo; index: Integer);

type
  TLuaStrings = class(TStrings)
  published
    Property TextLineBreakStyle;
    property Delimiter;
    property DelimitedText;
    Property StrictDelimiter;
    property QuoteChar;
    Property NameValueSeparator;
    // property ValueFromIndex[Index: Integer]: string read GetValueFromIndex write SetValueFromIndex;
    property Capacity;
    property CommaText;
    property Count;
    // property Names[Index: Integer]: string read GetName;
    // property Objects[Index: Integer]: TObject read GetObject write PutObject;
    // property Values[const Name: string]: string read GetValue write SetValue;
    // property Strings[Index: Integer]: string read Get write Put; default;
    property Text;
    property StringsAdapter;
  end;

implementation

Uses SysUtils, LuaProperties, Lua, SynEdit, CheckLst, Dialogs;

function StringsAdd(L: Plua_State): Integer; cdecl;
var
  lStrings: TStrings;
begin
  CheckArg(L, 2);
  lStrings := TStrings(GetLuaObject(L, 1));
  lStrings.Add(AnsiToUTF8(lua_tostring(L,2)));
  Result := 0;
end;

function StringsInsert(L: Plua_State): Integer; cdecl;
var
  lStrings: TStrings;
begin
  CheckArg(L, 3);
  lStrings := TStrings(GetLuaObject(L, 1));
  lStrings.Insert(Trunc(lua_tonumber(L,2)),AnsiToUTF8(lua_tostring(L,3)));
  Result := 0;
end;

function StringsDelete(L: Plua_State): Integer; cdecl;
var
  lStrings: TStrings;
begin
  CheckArg(L, 2);
  lStrings := TStrings(GetLuaObject(L, 1));
  lStrings.Delete(Trunc(lua_tonumber(L,2)));
  Result := 0;
end;

function StringsClear(L: Plua_State): Integer; cdecl;
var
  lStrings: TStrings;
begin
  CheckArg(L, 1);
  lStrings := TStrings(GetLuaObject(L, 1));
  lStrings.Clear;
  Result := 0;
end;

procedure TStringsToTable(L: Plua_State; Comp:TObject; PInfo:PPropInfo; index: Integer);
begin
    lua_newtable(L);
    LuaSetTableLightUserData(L, index, HandleStr, Pointer(GetInt64Prop(Comp, PInfo.Name)));
    LuaSetTableFunction(L, Index, 'Add', StringsAdd);
    LuaSetTableFunction(L, Index, 'Insert', StringsInsert);
    LuaSetTableFunction(L, Index, 'Delete', StringsDelete);
    LuaSetTableFunction(L, Index, 'Clear', StringsClear);
    LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
    LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

end.
