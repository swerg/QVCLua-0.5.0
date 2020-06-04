SourceCodeDir = "genericsrc/"
UsesInclude = "genuses.inc"
LibInclude = "genlibs.inc"
LibCount = "genlibcount.inc"
GenericComponentCount = 0
CToken = "#CMPNT#"
PToken = "#PN#"
GToken = "#GL#"

GenericComponentsWithCanvas = {
    "Bevel",	
	"Label",		
	"Panel",
	"Shape",
	"Splitter",
	"ScrollBox",
}

GenericComponents = {
	"Button",
	"CheckBox",
	"Edit",	
	"CalcEdit",
	"CheckGroup",
	"ComboBox",
    "DirectoryEdit",
    "FileNameEdit",
	"GroupBox",	
	"Memo",
	"PageControl",
	"RadioButton",		
	"RadioGroup",
	"SpinEdit",
	"StaticText",
	"FloatSpinEdit",
	"TabSheet",	
	"ToggleBox",
	"TrackBar",	
}
GenericComponents_PN = {
	"Timer",
	"IdleTimer",
}
GenericComponents_GL = {
	"SpeedButton",
	"BitBtn",
	"EditButton",
}


ComponentTemplate = [[
unit Lua#CMPNT#;	
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function Create#CMPNT#(L: Plua_State): Integer; cdecl;
type
    TLua#CMPNT# = class(T#CMPNT#)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;
implementation
Uses LuaProperties, Lua, LCLClasses;
destructor TLua#CMPNT#.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function #CMPNT#GetCanvas(L: Plua_State): Integer; cdecl;
var l#CMPNT#:TLua#CMPNT#;
begin
  l#CMPNT# := TLua#CMPNT#(GetLuaObject(L, 1));
  l#CMPNT#.LuaCanvas.ToTable(L, -1, l#CMPNT#.Canvas);
  result := 1;
end;
{$ENDIF}
procedure #CMPNT#ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  #GL#
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', #CMPNT#GetCanvas); 
  {$ENDIF}
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;
function Create#CMPNT#(L: Plua_State): Integer; cdecl;
var
  l#CMPNT#:TLua#CMPNT#;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  l#CMPNT# := TLua#CMPNT#.Create(Parent);
  #PN#
  l#CMPNT#.LuaCtl := TLuaControl.Create(l#CMPNT#,L,@#CMPNT#ToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(l#CMPNT#),-1)
  else
     l#CMPNT#.Name := Name;
  {$IFDEF HASCANVAS}
  if (l#CMPNT#.InheritsFrom(TCustomControl) or l#CMPNT#.InheritsFrom(TGraphicControl) or
	  l#CMPNT#.InheritsFrom(TLCLComponent)) then
    l#CMPNT#.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  #CMPNT#ToTable(L, -1, l#CMPNT#);
  Result := 1;
end;
end.
]]

-- //////////////////////////////////////////////////
function SaveFile(filename, rbuf)
  if rbuf==nil then return false end
  local f = io.open(filename, "w+b")
  if f==nil then return false end
  f:write(rbuf)
  f:flush()
  f:close()
  return true
end
-- ///////////////////////////////////////////////////

s = ""
l = ""

-- Standard with canvas
for i,v in ipairs(GenericComponentsWithCanvas) do
	s = s.."Lua"..v.." in '"..SourceCodeDir.."Lua"..v..".pas',\n"
	c0 = i
	l = l.."(name:'"..v.."'; func:@Create"..v.."),\n"
	local p = "{$DEFINE HASCANVAS}\n"
	p = p..string.gsub(ComponentTemplate,PToken,"l#CMPNT#.Parent := TWinControl(Parent);")
	p = string.gsub(p,CToken,v)
	p = string.gsub(p,GToken,"")
	SaveFile(SourceCodeDir.."Lua"..v..".pas",p)
end

-- Standard
for i,v in ipairs(GenericComponents) do
	s = s.."Lua"..v.." in '"..SourceCodeDir.."Lua"..v..".pas',\n"
	c1 = i
	l = l.."(name:'"..v.."'; func:@Create"..v.."),\n"
	local p = string.gsub(ComponentTemplate,PToken,"l#CMPNT#.Parent := TWinControl(Parent);")
	p = string.gsub(p,CToken,v)
	p = string.gsub(p,GToken,"")
	SaveFile(SourceCodeDir.."Lua"..v..".pas",p)
end

-- NonVisual
for i,v in ipairs(GenericComponents_PN) do
	s = s.."Lua"..v.." in '"..SourceCodeDir.."Lua"..v..".pas',\n"
	c2 = i
	l = l.."(name:'"..v.."'; func:@Create"..v.."),\n"
	local p = string.gsub(ComponentTemplate,PToken,"")
	p = string.gsub(p,CToken,v)
	p = string.gsub(p,GToken,"")
	SaveFile(SourceCodeDir.."Lua"..v..".pas",p)
end

-- Glyph buttons 
for i,v in ipairs(GenericComponents_GL) do
	s = s.."Lua"..v.." in '"..SourceCodeDir.."Lua"..v..".pas',\n"
	c3 = i
	l = l.."(name:'"..v.."'; func:@Create"..v.."),\n"
	local p = string.gsub(ComponentTemplate,PToken,"l#CMPNT#.Parent := TWinControl(Parent);")
	p = string.gsub(p,CToken,v)
	-- p = string.gsub(p,GToken,"LuaSetTableFunction(L, Index, 'Image', ControlGlyph);")
	p = string.gsub(p,GToken,"LuaSetTableFunction(L, index, 'GetGlyph', ControlGetGlyph);") 
	SaveFile(SourceCodeDir.."Lua"..v..".pas",p)
end

SaveFile(SourceCodeDir..UsesInclude,s)
SaveFile(SourceCodeDir..LibCount,c1+c2+c3+c0)
SaveFile(SourceCodeDir..LibInclude,l)
