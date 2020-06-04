unit LuaApplication;

{$mode objfpc}{$H+}

interface

Uses Classes, Controls, LuaPas, Forms, TypInfo, SysUtils;

function CreateApplication(L: Plua_State): Integer; cdecl;

// other stuff
function GetScreenSize(L: Plua_State): Integer; cdecl;
function LuaFileExists(L: Plua_State): Integer; cdecl;
function LuaDirectoryExists(L: Plua_State): Integer; cdecl;
function ApplicationExeName(L: Plua_State): Integer; cdecl;
function ApplicationExePath(L: Plua_State): Integer; cdecl;

function XMLFormToLua(L: Plua_State): Integer; cdecl;

implementation

Uses LuaProperties, Lua, LuaForm,  DOM, fileutil, XMLRead;

// ***********************************************

function XMLFormToLua(L: Plua_State): Integer; cdecl;

var
    compList: TStringList;
    identList: TStringList;
    LuaScript: TStringList;

procedure DoControls(Node:TDOMNode; parentNode:TDomNode);
var
  i: integer;
  s,nn,name,clas:String;
  tmpNode,lastNode:TDomNode;
begin
  lastNode := parentNode;
  if not Assigned(Node) then exit;
  for i:=0 to Node.ChildNodes.Count - 1 do
  begin
    nn := Node.ChildNodes[i].NodeName;
    case nn of
        'component': begin
                       if parentNode=nil then
                          s := 'nil'
                       else
                          s := parentNode.Attributes[0].NodeValue;
                       // list of components
                       name := Node.ChildNodes[i].Attributes[0].NodeValue;
                       compList.Add(name);
                       name := Node.ChildNodes[i].Attributes[0].NodeValue;
                       clas := Node.ChildNodes[i].Attributes[1].NodeValue;
                       // remove leading T char
                       clas := Copy (clas,2,(length(clas)));
                       if not ((Copy (clas,1,3)='Syn') and (clas<>'SynEdit')) then
                          LuaScript.Add(name + ' = VCL.'+ clas +'('+s+',"' + name + '")')
                       else
                          continue;
                       parentNode := Node.ChildNodes[i];
                     end;
        'properties': ;

        'children': ;
        else
    end;
    DoControls(Node.ChildNodes[i],parentNode);
    parentNode := lastNode;
  end;
end;

procedure processIdents(node:TDomNode);
var s,k,v,q1,q2:string;
    n: Integer;
begin
     if compList.IndexOf(node.Attributes[1].NodeValue) = -1 then begin
          q1 := '"'; q2 := '"';
     end else begin
           q1 := ''; q2 := '';
     end;
     if node.Attributes.Length>0 then begin
         s := node.Attributes[0].NodeValue;
         if pos('.',s)>0  then begin
           k := copy(s,1,pos('.',s)-1);
           v := copy(s,pos('.',s)+1,length(s));
           identList.Values[k] := identList.Values[k] + v + '=' + q1 + node.Attributes[1].NodeValue + q2 + ','
         end else
           LuaScript.Add(#9 +  s + ' = ' + q1 + node.Attributes[1].NodeValue + q2 +',')
     end;
end;

procedure DoProps(Node:TDOMNode; parentNode:TDomNode; CompClass:String);
var
  i,n,k,kk: integer;
  s,nn,name,clas,q1,q2:String;
  tmpNode, lastNode:TDomNode;
  PInfo: PPropInfo;
begin
  lastNode := parentNode;
  if not Assigned(Node) then exit;
  for i:=0 to Node.ChildNodes.Count - 1 do
  begin
    nn := Node.ChildNodes[i].NodeName;
    case nn of
        'component': begin
                       CompClass :=  Node.ChildNodes[i].Attributes[1].NodeValue;
                       parentNode := Node.ChildNodes[i];
                     end;
        'properties': begin
                       if (Copy (CompClass,1,4)='TSyn') and (CompClass<>'TSynEdit') then
                          continue;
                       name := parentNode.Attributes[0].NodeValue;
                       LuaScript.Add(name + '._ = {');
                       for k:=0 to Node.ChildNodes[i].ChildNodes.Count - 1 do begin
                          tmpNode := Node.ChildNodes[i].ChildNodes[k];
                          if Assigned(tmpNode.Attributes) then begin
                              case tmpNode.NodeName of
                                  'string':  begin q1 := '"'; q2 := '"'; end;
                                  'integer': begin q1 := ''; q2 := ''; end;
                                  'boolean': begin q1 := ''; q2 := ''; end;
                                  'set':     begin q1 := '"['; q2 := ']"'; end;
                                  'ident':   begin
                                                  processIdents(tmpNode);
                                                  continue;
                                             end;
                                  'collectionproperty': begin
                                                  DoProps(tmpNode,tmpNode,CompClass);
                                                  continue;
                                              end;
                                  'list': begin
                                             name := parentNode.Attributes[0].NodeValue;
                                             Case UpperCase(CompClass) of
                                                 'TLISTBOX','TCOMBOBOX': begin
                                                                   LuaScript.Add(#9 + 'Items = {');
                                                             end;
                                                 'TMEMO': begin
                                                                   LuaScript.Add(#9 + 'Lines = {');
                                                          end;
                                                 'TSYNEDIT': begin
                                                                   LuaScript.Add(#9 +  'Lines = {');
                                                             end;
                                                 else
                                                   LuaScript.Add(#9 + name + '._ = {');
                                             end;
                                             for kk:=0 to tmpNode.ChildNodes.Count - 1 do begin
                                                if Assigned(tmpNode.ChildNodes[kk].Attributes) then begin
                                                    case tmpNode.ChildNodes[kk].NodeName of
                                                        'string', 'ident':  begin q1 := '"'; q2 := '",'; end;
                                                    else begin
                                                              q1 := '';
                                                              q2 := ',';

                                                        end
                                                    end;
                                                    if tmpNode.ChildNodes[kk].Attributes.Length>0 then
                                                       s := tmpNode.ChildNodes[kk].Attributes[0].NodeValue;
                                                    if tmpNode.ChildNodes[kk].Attributes.Length>1 then
                                                       LuaScript.Add(#9#9 + s + ' = ' + q1 + tmpNode.ChildNodes[kk].Attributes[1].NodeValue + q2 )
                                                    else
                                                    if tmpNode.ChildNodes[kk].Attributes.Length>0 then
                                                       LuaScript.Add(#9#9 + q1 + s +q2)

                                                end;
                                             end;
                                             LuaScript.Add(#9 + '},');
                                        end;
                              else begin
                                        // unknown, unhandled
                                        q1 := '';
                                        q2 := '-- ??'+tmpNode.NodeName+'??';

                                  end
                              end;
                              // find dot in name
                              s := '';
                              if tmpNode.Attributes.Length>0 then
                                 s := tmpNode.Attributes[0].NodeValue;
                              if tmpNode.Attributes.Length>1 then
                                 if pos('.',s)>0  then begin
                                    processIdents(tmpNode);
                                    // LuaScript.Add(#9 + copy(s,1,pos('.',s)-1) + ' = {');
                                    // LuaScript.Add(#9 + copy(s,pos('.',s)+1,length(s)) + ' = ' + q1 + tmpNode.Attributes[1].NodeValue + q2 + '},');
                                 end else
                                    LuaScript.Add(#9 +  s + ' = ' + q1 + tmpNode.Attributes[1].NodeValue + q2 +',')
                              // else if tmpNode.Attributes.Length>0 then
                                 // LuaScript.Add(#9 + '-- '+ s + ' // ' + q1 + q2)
                              //else
                                 // LuaScript.Add(#9 + '-- '+ q1 + q2)

                          end;
                       end;
                       // processidents
                       if Assigned(identList) then begin
                          for k:=0 to identList.Count - 1 do begin
                              LuaScript.Add(#9 + identList.Names[k] + ' = {' + identList.ValueFromIndex[k] + '},' );
                          end;
                          identList.Clear;
                       end;
                       LuaScript.Add('}');
                     end;
          'children': begin

                      end;
          'collectionproperty' : begin
                      end;
          'collection': begin
                          // DoProps( Node.ChildNodes[i],parentNode, CompClass);
                     end;
          // ie. list in collection
          'list': begin
         (*
                       name := parentNode.Attributes[0].NodeValue;
                       Case UpperCase(CompClass) of
                           'TSYNEDIT': begin
                                             LuaScript.Add(#9 + name + ' = {');
                                       end;
                           else
                             continue;
                             // LuaScript.Add(#9 + name + '._ = {');
                       end;
                       for k:=0 to Node.ChildNodes[i].ChildNodes.Count - 1 do begin
                          tmpNode := Node.ChildNodes[i].ChildNodes[k];
                          if Assigned(tmpNode.Attributes) then begin
                              case tmpNode.NodeName of
                                  'string', 'ident':  begin q1 := '"'; q2 := '",'; end;
                              else begin
                                        q1 := '';
                                        q2 := ',';

                                  end
                              end;
                              if tmpNode.Attributes.Length>0 then
                                 s := tmpNode.Attributes[0].NodeValue;
                              if tmpNode.Attributes.Length>1 then
                                 LuaScript.Add(#9#9 + s + ' = ' + q1 + tmpNode.Attributes[1].NodeValue + q2 )
                              else
                              if tmpNode.Attributes.Length>0 then
                                 LuaScript.Add(#9#9 + q1 + s +q2)

                          end;
                       end;
                       LuaScript.Add(#9 + '},');
         *)
                  end
        else

    end;
    DoProps(Node.ChildNodes[i],parentNode, CompClass);
    parentNode := lastNode;
  end;
end;

var b: TStringStream;
    s: String;
    FDoc: TXMLDocument;
    i:Integer;

begin
  s := String(lua_tostring(L,1));
  if FileExistsUTF8(s) then begin
     try
       ReadXMLFile(FDoc, UTF8ToSys(s));
     except
       FreeAndNil(FDoc);
     end;
  end else begin
     try
       b := TStringStream.Create(s);
       b.WriteBuffer(Pointer(s)^,Length(s));
       b.Seek(0,0);
       ReadXMLFile(FDoc, b);
       b.Free;
     except
       FreeAndNil(FDoc);
     end;
  end;
  if Assigned(FDoc) then begin
      compList := TStringList.Create;
      identList := TStringList.Create;
      identList.NameValueSeparator:='=';
      luaScript := TStringList.Create;
      DoControls(FDoc, nil);
      DoProps(FDoc, nil, '');
      // output table of strings
      lua_newtable(L);
      for i:=0 to luaScript.Count-1 do begin
          lua_pushnumber(L, i + 1);
          lua_pushstring(L, luaScript.Strings[i]);
          lua_rawset(L,-3);
      end;
      identList.Free;
      compList.Free;
      FDoc.Free;
      luaScript.Free;
  end else begin
    lua_pushnil(L);
  end;
  Result := 1;
end;

function GetScreenSize(L: Plua_State): Integer; cdecl;
begin
  lua_pushnumber(L, Screen.Width);
  lua_pushnumber(L, Screen.Height);
  Result := 2;
end;

function LuaFileExists(L: Plua_State): Integer; cdecl;
begin
  CheckArg(L, 1);
  lua_pushboolean(L,FileExists(lua_tostring(L,1)));
  Result := 1;
end;

function LuaDirectoryExists(L: Plua_State): Integer; cdecl;
begin
  CheckArg(L, 1);
  lua_pushboolean(L,DirectoryExists(lua_tostring(L,1)));
  Result := 1;
end;

// ***********************************************
function ApplicationInitialize(L: Plua_State): Integer; cdecl;
var
  App: TApplication;
begin
  CheckArg(L, 1);
  App := TApplication(GetLuaObject(L, 1));
  App.initialize;
  Result := 0;
end;

function ApplicationRun(L: Plua_State): Integer; cdecl;
var
  App: TApplication;
begin
  CheckArg(L, 1);
  App := TApplication(GetLuaObject(L, 1));
  App.run;
  Result := 0;
end;

function ApplicationTerminate(L: Plua_State): Integer; cdecl;
var
  App: TApplication;
begin
  CheckArg(L, 1);
  App := TApplication(GetLuaObject(L, 1));
  App.terminate;
  Result := 0;
end;

function ApplicationProcessmessages(L: Plua_State): Integer; cdecl;
var
  App: TApplication;
begin
  CheckArg(L, 1);
  App := TApplication(GetLuaObject(L, 1));
  App.processmessages;
  Result := 0;
end;

function ApplicationExeName(L: Plua_State): Integer; cdecl;
var
  App: TApplication;
begin
  CheckArg(L, 1);
  App := TApplication(GetLuaObject(L, 1));
  lua_pushString(L,pchar(App.Exename));
  Result := 1;
end;

function ApplicationExePath(L: Plua_State): Integer; cdecl;
var
  App: TApplication;
begin
  CheckArg(L, 1);
  App := TApplication(GetLuaObject(L, 1));
  lua_pushString(L,pchar(ExtractFilePath(App.Exename)));
  Result := 1;
end;

function ApplicationFindForm(L:Plua_State): Integer; cdecl;
Var Temp: TComponent;
	i: Integer;
begin
 Result := 1;
 CheckArg(L, 2);
 for i:=0 to Application.ComponentCount-1 do begin
	Temp := Application.Components[I];
	if ((Temp is TLuaForm) or (Temp is TForm)) and (Temp.Name=lua_tostring(L,2))then begin
		TLuaForm(Temp).LuaCtl.ToTable(L, -1, Temp);
		Exit;
	end;
 end;
 lua_pushnil(L);
end;


function ApplicationGetMainForm(L:Plua_State): Integer; cdecl;
begin
 Result := 1;
 CheckArg(L, 1);
 if Application.MainForm = nil then
      lua_pushnil(L)
 else begin
   TLuaForm(Application.MainForm).LuaCtl.ToTable(L, -1, Application.MainForm);
 end;
end;


procedure ApplicationTable(L:Plua_State; Index:Integer);
begin
  lua_newtable(L);
  LuaSetTableLightUserData(L, Index, HandleStr, Pointer(Application));

  LuaSetTableFunction(L, Index, 'Initialize', @ApplicationInitialize);
  LuaSetTableFunction(L, Index, 'Run', @ApplicationRun);
  LuaSetTableFunction(L, Index, 'Terminate', @ApplicationTerminate);
  LuaSetTableFunction(L, Index, 'ProcessMessages', @ApplicationProcessmessages);
  LuaSetTableFunction(L, Index, 'FindForm', @ApplicationFindForm);
  LuaSetTableFunction(L, Index, 'GetMainForm', @ApplicationGetMainForm);

  LuaSetMetaFunction(L, index, '__index', @LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', @LuaSetProperty);

end;


function CreateApplication(L: Plua_State): Integer; cdecl;
begin
  ApplicationTable(L, -1);
  Result := 1;
end;

end.
