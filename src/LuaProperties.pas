unit LuaProperties;

interface

Uses  Dialogs, Forms, Graphics, Classes, Controls, StdCtrls, TypInfo, LuaPas, Lua;

function LuaListProperties(L: Plua_State): Integer; cdecl;
function LuaGetProperty(L: Plua_State): Integer; cdecl;
function LuaSetProperty(L: Plua_State): Integer; cdecl;
function SetPropertiesFromLuaTable(L: Plua_State; Obj:TObject; Index:Integer):Boolean;
procedure SetProperty(L:Plua_State; Index:Integer; Comp:TObject; PInfo:PPropInfo);
procedure LuaSetControlProperty(L:Plua_State; Comp: TObject; PropName:String; Index:Integer);

procedure lua_pushtable_object(L: Plua_State; Comp:TObject; PropName:String; index: Integer);overload;
procedure lua_pushtable_object(L: Plua_State; Comp:TObject; PInfo:PPropInfo; index: Integer);overload;
procedure lua_pushtable_object(L: Plua_State; Comp:TObject; index: Integer);overload;

// color converter
function ToColor(L: Plua_State; index: Integer):TColor;

implementation

Uses SysUtils, ExtCtrls, Grids, ActnList, LuaActionList, LuaImageList, LuaControl, LCLProc,
     LuaStrings,
     LuaCanvas,
     LuaBitmap,
     LuaPicture;

// ****************************************************************

function tabletotext(L:Plua_State; Index:Integer):String;
var n :integer;
begin
    result := '';
    if lua_istable(L,Index) then begin
        n := lua_gettop(L);
        lua_pushnil(L);
        while (lua_next(L, n) <> 0) do begin
              Result := Result + lua_tostring(L, -1) + #10;
              lua_pop(L, 1);
        end;
    end else if lua_isstring(L,Index) then
       Result := lua_tostring(L,Index);
    Result := AnsiToUTF8(Result);  ///QVCL
end;

function ToColor(L: Plua_State; index: Integer):TColor;
begin
     result := 0;
     if lua_isstring(L,index) then
        result := StringToColor(lua_tostring(L,index))
     else if lua_isnumber(L,index) then
        result := TColor(trunc(lua_tonumber(L,index)));
end;

function SetTStringsProperty( L: Plua_State; Comp:TObject; PropName:String; index:Integer):boolean;
var target: TStrings;
begin
    result := false;
    target := TStrings( Pointer(GetInt64Prop(Comp,PropName)));
    if Assigned(target) then begin
      target.Clear;
      target.Text := tabletotext(L,index);
      result := true;
    end;
end;

// ****************************************************************

procedure lua_pushtable_object(L: Plua_State; Comp:TObject; PropName:String; index: Integer);overload;
begin
    lua_newtable(L);
    LuaSetTableLightUserData(L, index, HandleStr, Pointer(GetInt64Prop(Comp,PropName)));
    LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
    LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

procedure lua_pushtable_object(L: Plua_State; Comp:TObject; PInfo:PPropInfo; index: Integer); overload;
begin
    // check pinfo for TStrings
    if (PInfo.PropType^.Name = 'TStrings') then  begin
         TStringsToTable(L,Comp,PInfo,index);
    end else begin
         lua_newtable(L);
         LuaSetTableLightUserData(L, index, HandleStr, Pointer(GetInt64Prop(Comp, PInfo.Name)));
    end;
    LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
    LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

procedure lua_pushtable_object(L: Plua_State; Comp:TObject; index: Integer);overload;
begin
    lua_newtable(L);
    LuaSetTableLightUserData(L, index, HandleStr, Comp);
    LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
    LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function isVcluaObject(L: Plua_State; index: Integer):boolean;
begin
    Result := (LuaGetTableLightUserData(L,Index,'Handle') <> nil);
end;

// ****************************************************************
procedure ListProperty(L: Plua_State; PName:String; PInfo: PPropInfo; idx:Integer);
var
     PropType: String;
begin
    try
        PropType := PInfo^.Proptype^.Name;
        if PropType[1] = 'T' then
           delete(Proptype,1,1);
        lua_pushnumber(L,idx);
        lua_newtable(L);
           lua_pushstring(L, PChar(PName));
           lua_pushstring(L, PChar(PropType));
           lua_rawset(L,-3);
        lua_rawset(L,-3);
    except
    end;
end;

procedure ListObjectProperties(L: Plua_State; PObj:TObject);
var subObj, tmpObj:TObject;
    Count,Loop:Integer;
    PInfo: PPropInfo;
    PropInfos: PPropList;
    s,t:String;
    n:Integer;
begin
     Count := GetPropList(PObj.ClassInfo, tkAny, nil);
     GetMem(PropInfos, Count * SizeOf(PPropInfo));
     GetPropList(PObj.ClassInfo, tkAny, PropInfos, true);
     for Loop := 0 to Count - 1 do begin
         PInfo := GetPropInfo(PObj.ClassInfo, PropInfos^[Loop]^.Name);
         case PInfo^.Proptype^.Kind of
              tkClass:
                  begin
                      subObj := GetObjectProp(PObj, PInfo);
                      if subObj<>nil then begin
                         s := PropInfos^[Loop]^.Name;
                         t := PInfo^.Proptype^.Name;
                         lua_pushnumber(L,Loop+1);
                         lua_newtable(L);
                              lua_pushstring(L, PChar(s));  // name
                              lua_pushstring(L, PChar(t));  // type
                              lua_rawset(L,-3);

                              // avoid circular reference
                              if (s<>'Owner') and (s<>'Parent') then begin
                                  if subObj.InheritsFrom(TStrings) then begin
                                    tmpObj := TLuaStrings.Create;
                                    ListObjectProperties(L,tmpObj);
                                    tmpObj.Free;
                                  end else
                                    ListObjectProperties(L,subObj);
                               end;

                         lua_rawset(L,-3);
                      end;
                  end;
              tkMethod:
                  begin
                      ListProperty(L, PropInfos^[Loop]^.Name, PInfo, Loop+1);
                  end
              else begin
                  ListProperty(L, PropInfos^[Loop]^.Name, PInfo, Loop+1);
              end
         end;
     end;
     FreeMem(PropInfos);
end;

function LuaListProperties(L: Plua_State): Integer; cdecl;
var
  PObj: TObject;
begin
  CheckArg(L, 1);
  PObj := GetLuaObject(L, 1);
  lua_newtable(L);
  ListObjectProperties(L, PObj);
  Result := 1;
end;

// ****************************************************************
procedure LuaSetControlProperty(L:Plua_State; Comp: TObject; PropName:String; Index:Integer);
var
  PInfo: PPropInfo;
begin
  PInfo := GetPropInfo(TObject(Comp).ClassInfo, PropName);
  SetProperty(L,Index,Comp,PInfo);
end;

procedure SetProperty(L:Plua_State; Index:Integer; Comp:TObject; PInfo:PPropInfo);
Var propVal:String;
    LuaFuncPInfo: PPropInfo;
    Str: String;
    tm: TMethod;
    cc: TObject;
    // refrence!!!
    luafunc, top: Integer;
begin
     Str := PInfo^.Proptype^.Name;
     // to be safe...
     if ((Str = 'TStringList') or (Str = 'TStrings')) and
        (SetTStringsProperty( L, Comp, PInfo.Name, index))
        // (ComponentStringList(TComponent(Comp), lua_tostring(L, -2), tabletotext(L,-1)))
     then else
     if (Str = 'SHORTCUT') and (ComponentShortCut(TComponent(Comp),lua_tostring(L, -1))) then
     else
     case PInfo^.Proptype^.Kind of
      tkMethod: begin
          // Property Name
          Str := lua_tostring(L,index-1);
          // omg watchout!
          cc := TComponent(Comp).Components[0];
          LuaFuncPInfo := GetPropInfo(cc, Str+'_Function');
	  if LuaFuncPInfo <> nil then begin
              // OnXxxx_Function
              if lua_isfunction(L,index) then begin
                // store luafunc in component by LuaCtl
                top := lua_gettop(L);
                lua_settop(L,index);
                luafunc := luaL_ref(L, LUA_REGISTRYINDEX);
                SetOrdProp(cc, LuaFuncPInfo, luafunc);
                lua_settop(L,top);
                // setup luaeventhandler
                LuaFuncPInfo := GetPropInfo(Comp.ClassInfo, Str);
                // OnXxxx -->OnLuaXxxx
                insert('Lua',Str,3);
                if (LuaFuncPInfo<>nil) then begin
                    tm.Data := Pointer(cc);
                    tm.Code := cc.MethodAddress(Str);
                    SetMethodProp(Comp, LuaFuncPInfo, tm);
                 end
              end else begin
                  // LuaError(L,'Lua function required for event!' , lua_tostring(L,index));
                  tm.Data:= nil;
                  tm.Code:= nil;
                  SetMethodProp(Comp, PInfo, tm);
              end
          end
	  else begin
               LuaError(L,'Method not found or not supported!' , lua_tostring(L,index));
          end
        end;
        tkSet:
            begin
               // writeln('SET ', Comp.Classname, StringToSet(PInfo,lua_tostring(L,index)));
               SetOrdProp(Comp, PInfo, StringToSet(PInfo,lua_tostring(L,index)));
            end;
	tkClass:
           begin
               // not a vclua class
               if (not isVcluaObject(L,index)) then begin
                 // create on runtime
                 lua_pushtable_object(L, Comp, PInfo, index);
               end;
      	       SetInt64Prop(Comp, PInfo, Int64(Pointer(GetLuaObject(L, index))));
           end;
	tkInteger:
           begin
                   if (Str='TGraphicsColor') and lua_isstring(L, index) then
                      SetOrdProp(Comp, PInfo, ToColor(L, index))
                   else
     	              SetOrdProp(Comp, PInfo, Trunc(lua_tonumber(L, index)));
           end;
///QVCL change start
	tkChar, tkWChar:
          begin
            Str := AnsiToUTF8(lua_tostring(L, index));
            if length(Str)<1 then
              SetOrdProp(Comp, PInfo, 0)
            else
              SetOrdProp(Comp, PInfo, Ord(Str[1]));
          end;
///QVCL change end
        tkBool:
               begin
		    // writeln(PInfo^.Name, lua_toboolean(L,index)); 
		    {$IFDEF UNIX}
                    propval := BoolToStr(lua_toboolean(L,index));
                    SetOrdProp(Comp, PInfo, GetEnumValue(PInfo^.PropType, PropVal));
		    {$ELSE}
                    SetPropValue(Comp, PInfo^.Name, lua_toboolean(L,index));
		    {$ENDIF}
               end;
        tkEnumeration:
	         begin
	            if lua_type(L, index) = LUA_TBOOLEAN then
                       propval := BoolToStr(lua_toboolean(L,index))
		    else
		       propVal := lua_tostring(L, index);
		    // writeln('ENUM ', Comp.Classname, PInfo^.Name, PropVal);
                    SetOrdProp(Comp, PInfo, GetEnumValue(PInfo^.PropType, PropVal));
	         end;
        tkFloat:
	      	SetFloatProp(Comp, PInfo, lua_tonumber(L, index));

///QVCL change start
        tkString, tkLString, tkWString:
                begin
                    Str := lua_tostring(L, index);
                    SetStrProp(Comp, PInfo, AnsiToUtf8(Str));
                end;

        tkInt64: begin
	      	SetInt64Prop(Comp, PInfo, Int64(Round(lua_tonumber(L, index))));
                end;
     else begin
               Str := AnsiToUtf8(lua_tostring(L, index));
               if (PInfo^.Proptype^.Name='TTranslateString') then
		    SetStrProp(Comp, PInfo, Str )
               else if (PInfo^.Proptype^.Name='AnsiString') then
		    SetStrProp(Comp, PInfo, Str)
	       else if (PInfo^.Proptype^.Name='WideString') then
		    SetStrProp(Comp, PInfo, Str)
///QVCL change end
               else
		    LuaError(L,'Property not supported!' , PInfo^.Proptype^.Name);
	    end;
      end;
end;

procedure CheckAndSetProperty(L: Plua_State; Obj:TObject; PInfo: PPropInfo; PName: String; Index:Integer);
begin
     if lua_istable(L,Index) then begin
        if  (PInfo.PropType.Kind<>TKCLASS) and (PInfo.PropType.Kind<>TKASTRING) and (TObject(GetInt64Prop(Obj,pName))=nil) then
            SetPropertiesFromLuaTable(L,TObject(GetInt64Prop(Obj,pName)),Index)
        else
        // set table properties if the property is not a vclobject
        if (PInfo.PropType^.Kind=tkClass)  and (not isVcluaObject(L,Index))  then begin
            // loader--> items = luatable
            if TObject(GetInt64Prop(Obj, PInfo.Name)).InheritsFrom(TStrings) then
                SetTStringsProperty( L, Obj, PName, Index)
            else
                SetPropertiesFromLuaTable(L,TObject(GetInt64Prop(Obj,pName)),Index);
        end else
            SetProperty(L, Index, TComponent(Obj), PInfo);
     end else
  	    SetProperty(L, Index, TComponent(Obj), PInfo);
end;

// ****************************************************************
// Sets Property Values from a Lua table
// ****************************************************************

function SetPropertiesFromLuaTable(L: Plua_State; Obj:TObject; Index:Integer):Boolean;
var n,d: Integer;
    PInfo: PPropInfo;
    pName: String;
begin
  result := false;
  // L,1 is the Object self
  if lua_istable(L,Index) then begin
        n := lua_gettop(L);
        lua_pushnil(L);
        while (lua_next(L, n) <> 0) do begin
          pName := lua_tostring(L, -2);
  	  PInfo := GetPropInfo(Obj.ClassInfo,lua_tostring(L, -2));
  	  if PInfo <> nil then begin
             Result:=True;
             CheckAndSetProperty(L,Obj,PInfo,PName,-1);
          end else begin
              if (UpperCase(pName)='SHORTCUT') and (ComponentShortCut(TComponent(Obj),lua_tostring(L, -1))) then
              else
              if UpperCase(pName) = 'PARENT' then begin
                 TControl(Obj).Parent := TWinControl(GetLuaObject(L, -1));
              end else begin
                  // lua invalid key raised
                  LuaError(L,'Property not found! ', Obj.ClassName+'.'+PName);
              end;
          end;
          lua_pop(L, 1);
        end;
        result := true;
  end;
end;


// ****************************************************************
// Sets Property Value
// ****************************************************************
function LuaSetProperty(L: Plua_State): Integer; cdecl;
var
  PInfo: PPropInfo;
  Comp: TObject;
  propname: String;
  propType: String;
begin
  Result := 0;
  Comp := TObject(GetLuaObject(L, 1));
  if (Comp=nil) then begin
     LuaError(L, 'Can''t set null object property! ' , PropName );
     lua_pushnil(L);
     Exit;
  end;
  PropName := lua_tostring(L, 2);
  if (UpperCase(PropName)='SHORTCUT') and (ComponentShortCut(TComponent(Comp),lua_tostring(L, -1))) then
  else
  if (lua_gettop(L)=3) and (lua_istable(L,3)) and ((PropName='_')) then begin
     SetPropertiesFromLuaTable(L,Comp,3);
  end else begin
    // ClassInfo replacement
    if Comp.InheritsFrom(TStrings) then
      PInfo := GetPropInfo(TLuaStrings.ClassInfo, PropName)
    else
      PInfo := GetPropInfo(TComponent(Comp).ClassInfo, PropName);
    if (PInfo <> nil) and (lua_gettop(L)=3) then begin
      CheckAndSetProperty(L,Comp,PInfo,PropName,3);
    end else begin
       case lua_type(L,3) of
  		LUA_TNIL: LuaRawSetTableNil(L,1,lua_tostring(L, 2));
  		LUA_TBOOLEAN: LuaRawSetTableBoolean(L,1,lua_tostring(L, 2),lua_toboolean(L, 3));
  		LUA_TLIGHTUSERDATA: LuaRawSetTableLightUserData(L,1,lua_tostring(L, 2),lua_touserdata(L, 3));
  		LUA_TNUMBER: LuaRawSetTableNumber(L,1,lua_tostring(L, 2),lua_tonumber(L, 3));
  		LUA_TSTRING: LuaRawSetTableString(L,1,lua_tostring(L, 2),lua_tostring(L, 3));
  		LUA_TTABLE: LuaRawSetTableValue(L,1,lua_tostring(L, 2), 3);
  		LUA_TFUNCTION: LuaRawSetTableFunction(L,1,lua_tostring(L, 2),lua_CFunction(lua_touserdata(L, 3)));
       else
           if lowercase(PropName) = 'parent' then begin
              TWinControl(Comp).Parent := TWinControl(GetLuaObject(L, 3));

           end else
                   LuaError(L,'Property not found!',PropName);
       end;
     end;
  end;
end;


// ****************************************************************
// Gets Property Value
// ****************************************************************
function LuaGetProperty(L: Plua_State): Integer; cdecl;
var
  PInfo, PPInfo: PPropInfo;
  proptype: String;
  propname: String;
  strValue: String;
  ordValue: Int64;
  Comp, Pcomp: TObject;
  P64: Int64;
begin
  Result := 1;
  Comp := TObject(GetLuaObject(L, 1));
  PropName := lua_tostring(L, 2);
  if (Comp=nil) then begin
     LuaError(L, 'Can''t get null object property!' , '' );
     lua_pushnil(L);
     Exit;
  end;
  // ClassInfo replacement
  if Comp.InheritsFrom(TStrings) then
      PInfo := GetPropInfo(TLuaStrings.ClassInfo, PropName)
  else
      PInfo := GetPropInfo(Comp.ClassInfo, PropName);
  if PInfo <> nil then begin
    PropType := PInfo^.Proptype^.Name;
    PropName := PInfo^.Name;
    if (Comp.ClassName = 'TLuaActionList') and  (UpperCase(PropName)='IMAGES') then
       TLuaImageList(TLuaActionList(Comp).Images).LuaCtl.ToTable(L,-1,TLuaImageList(TLuaActionList(Comp).Images))
    else
    begin
     case PInfo^.Proptype^.Kind of
          tkMethod:
            begin
               PPInfo := GetPropInfo(Comp.ClassInfo, PropName + '_FunctionName');
               if PPInfo <> nil then
                  lua_pushstring(L,pchar(GetStrProp(Comp, PPInfo)))
               else begin
                  lua_pushnil(L);
               end;
            end;
          tkSet:
            lua_pushstring(L,pchar(SetToString(PInfo,GetOrdProp(Comp, PInfo),true)));
	  tkClass: begin
                lua_pushtable_object(L, Comp, PInfo, -1);
          end;
          tkInteger:
              lua_pushnumber(L,GetOrdProp(Comp, PInfo));
          tkChar,
          tkWChar:
            lua_pushnumber(L,GetOrdProp(Comp, PInfo));
          tkBool:
              begin
                   strValue := GetEnumName(PInfo^.PropType, GetOrdProp(Comp, PInfo));
                   if (strValue<>'') then
                      lua_pushboolean(L,StrToBool(strValue));
              end;
          tkEnumeration:
             lua_pushstring(L,PChar(GetEnumName(PInfo^.PropType, GetOrdProp(Comp, PInfo))));
          tkFloat:
            lua_pushnumber(L,GetFloatProp(Comp, PInfo));
          tkString,
          tkLString,
          tkWString:
            lua_pushstring(L,pchar(UTF8ToAnsi(GetStrProp(Comp, PInfo))));  ///QVCL
          tkInt64:
            lua_pushnumber(L,GetInt64Prop(Comp, PInfo));
      else begin
	        if (PInfo^.Proptype^.Name='TTranslateString') then begin
		        lua_pushstring(L,pchar(UTF8ToAnsi(GetStrProp(Comp, PInfo))));  ///QVCL
                end else if (PInfo^.Proptype^.Name='AnsiString') then begin
		        lua_pushstring(L,pchar(UTF8ToAnsi(GetStrProp(Comp, PInfo))));  ///QVCL
		end else begin
			lua_pushnil(L);
			LuaError(L,'Property not supported!', lua_tostring(L,2) + ' ' + PInfo^.Proptype^.Name);
		end;
      end
    end;
    end
  end else begin
    // try to find the property self
    if lowercase(lua_tostring(L,2)) = 'classname' then begin
       lua_pushstring(L, pchar(AnsiString(Comp.ClassName)));
    end else
    if lowercase(lua_tostring(L,2)) = 'parent' then begin
       lua_pushtable_object(L, TComponent(Comp).Owner, 'Parent', -1);
    end else begin
    // lua property?        
	case lua_type(L,1) of
	  LUA_TBOOLEAN:
             lua_pushBoolean(L, LuaRawGetTableBoolean(L,1,lua_tostring(L, 2)));
	  LUA_TLIGHTUSERDATA:
             lua_pushlightuserdata(L,LuaRawGetTableLightUserData(L,1,lua_tostring(L, 2)));
	  LUA_TNUMBER:
             lua_pushnumber(L,LuaRawGetTableNumber(L,1,lua_tostring(L, 2)));
	  LUA_TSTRING:
             lua_pushstring(L,PChar(UTF8ToAnsi(LuaRawGetTableString(L,1,lua_tostring(L, 2)))));  ///QVCL
	  LUA_TTABLE:
            begin
	  	LuaRawGetTable(L,1,lua_tostring(L, 2));
	    end;
	  LUA_TFUNCTION:
            lua_pushcfunction(L,LuaRawGetTableFunction(L,1,lua_tostring(L, 2)));
	  else begin
               lua_pushnil(L);
	       LuaError(L,'(Lua) Property not found!', lua_tostring(L,2)+' type:'+IntToStr(lua_type(L,1)));
    	  end;
        end;
    end;
  end;
end;

end.
