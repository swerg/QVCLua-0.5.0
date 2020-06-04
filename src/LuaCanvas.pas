unit LuaCanvas;

interface

Uses ExtCtrls, Controls, Classes,
     LuaPas, Lua, LuaProperties,
     Graphics;

type
	TLuaCanvas = class(TCanvas)
          public
            L:Plua_State;
            procedure ToTable(LL:Plua_State; Index:Integer; Sender:TObject);
        end;

function LuaGetRect(L: Plua_State; index:Integer): TRect;

implementation

Uses TypInfo, LuaBitmap, LuaGraphic, sysutils, graphtype;

function LuaGetRect(L: Plua_State; index:Integer): TRect;
var ARect:TRect;
begin
   if lua_istable(L,index) then begin
       lua_pushnil(L);
       while (lua_next(L, index) <> 0) do begin
           if (UpperCase(lua_tostring(L,-2))='TOP') then
              ARect.Top:=trunc(lua_tonumber(L,-1)) else
           if (UpperCase(lua_tostring(L,-2))='LEFT') then
              ARect.Left:=trunc(lua_tonumber(L,-1)) else
           if (UpperCase(lua_tostring(L,-2))='BOTTOM') then
              ARect.Bottom:=trunc(lua_tonumber(L,-1)) else
           if (UpperCase(lua_tostring(L,-2))='RIGHT') then
              ARect.Right:=trunc(lua_tonumber(L,-1));
          lua_pop(L, 1);
       end;
    end;
   Result := ARect;
end;

// luatable to TTextStyle
function LuaGetTextStyle(L: Plua_State; index:Integer):TTextStyle;
var ts:TTextStyle;
begin
   if lua_istable(L,index) then begin
       lua_pushnil(L);
       while (lua_next(L, index) <> 0) do begin
           if (LowerCase(lua_tostring(L,-2))='alignment') then
              ts.Alignment := TAlignment(GetEnumValue(TypeInfo(TAlignment),lua_tostring(L,-1))) else
           if (UpperCase(lua_tostring(L,-2))='clipping') then
              ts.Clipping := lua_toboolean(L,-1) else
           if (UpperCase(lua_tostring(L,-2))='endellipsis') then
              ts.EndEllipsis := lua_toboolean(L,-1) else
           if (UpperCase(lua_tostring(L,-2))='expandtabs') then
              ts.ExpandTabs := lua_toboolean(L,-1) else
           if (LowerCase(lua_tostring(L,-2))='layout') then
              ts.Layout := TTextLayout(GetEnumValue(TypeInfo(TTextLayout),lua_tostring(L,-1))) else
           if (UpperCase(lua_tostring(L,-2))='opaque') then
              ts.Opaque := lua_toboolean(L,-1) else
           if (UpperCase(lua_tostring(L,-2))='righttoleft') then
              ts.RightToLeft := lua_toboolean(L,-1) else
           if (UpperCase(lua_tostring(L,-2))='showprefix') then
              ts.ShowPrefix := lua_toboolean(L,-1) else
           if (UpperCase(lua_tostring(L,-2))='singleline') then
              ts.SingleLine := lua_toboolean(L,-1) else
           if (UpperCase(lua_tostring(L,-2))='systemfont') then
              ts.SystemFont := lua_toboolean(L,-1) else
           if (UpperCase(lua_tostring(L,-2))='wordbreak') then
              ts.Wordbreak := lua_toboolean(L,-1);
          lua_pop(L, 1);
       end;
    end;
   Result := ts;
end;

// ---------------

function LuaLock(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
begin
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  lua_pushboolean(L,lCanvas.TryLock);
  result := 1;
end;

function LuaUnlock(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
begin
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  lCanvas.Unlock;
  result := 0;
end;

function LuaRefresh(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
begin
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  lCanvas.Refresh;
  result := 0;
end;

function LuaClear(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
begin
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  lCanvas.Clear;
  result := 0;
end;

function LuaArc(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ALeft, ATop, ARight, ABottom, Angle16Deg, Angle16DegLength: Integer;
    SX, SY, EX, EY: Integer;
    n: Integer;
begin
  n := lua_gettop(L);
  if n>4 then begin
     lCanvas := TLuaCanvas(GetLuaObject(L, 1));
     ALeft := trunc(lua_tonumber(L,2));
     ATop := trunc(lua_tonumber(L,3));
     ARight := trunc(lua_tonumber(L,4));
     ABottom := trunc(lua_tonumber(L,5));
     if n=7 then begin
        Angle16Deg := trunc(lua_tonumber(L,6));
            Angle16DegLength := trunc(lua_tonumber(L,7));
        lCanvas.Arc(ALeft, ATop, ARight, ABottom, Angle16Deg, Angle16DegLength);
     end else
     if n=9 then begin
        SX := trunc(lua_tonumber(L,6));
        SY := trunc(lua_tonumber(L,7));
        EX := trunc(lua_tonumber(L,8));
        EY := trunc(lua_tonumber(L,9));
        lCanvas.Arc(ALeft, ATop, ARight, ABottom, SX, SY, EX, EY);
     end
     else CheckArg(L, 7);
  end
  else CheckArg(L, 7);
  result := 0;
end;

function LuaChord(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
        x1,x2,x3,x4, Angle16Deg, Angle16DegLength: Integer;
        SX, SY, EX, EY: Integer;
        n: Integer;
begin
  n := lua_gettop(L);
  if n>4 then begin
     lCanvas := TLuaCanvas(GetLuaObject(L, 1));
     x1 := trunc(lua_tonumber(L,2));
     x2 := trunc(lua_tonumber(L,3));
     x3 := trunc(lua_tonumber(L,4));
     x4 := trunc(lua_tonumber(L,5));
     if n=7 then begin
        Angle16Deg := trunc(lua_tonumber(L,6));
        Angle16DegLength := trunc(lua_tonumber(L,7));
        lCanvas.Chord(x1, x2, x3, x4, Angle16Deg, Angle16DegLength);
     end else
     if n=9 then begin
        SX := trunc(lua_tonumber(L,6));
        SY := trunc(lua_tonumber(L,7));
        EX := trunc(lua_tonumber(L,8));
        EY := trunc(lua_tonumber(L,9));
        lCanvas.Chord(x1, x2, x3, x4, SX, SY, EX, EY);
     end
     else CheckArg(L, 7);
  end
  else CheckArg(L, 7);
  result := 0;
end;

function LuaCopyRect(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    SrcCanvas: TLuaCanvas;
    Dest,Source: TRect;
begin
  CheckArg(L, 4);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  Dest := LuaGetRect(L,2);
  SrcCanvas := TLuaCanvas(GetLuaObject(L, 3));
  Source := LuaGetRect(L,4);
  lCanvas.CopyRect(Dest, TCanvas(SrcCanvas), Source);
  result := 0;
end;

function LuaBrushCopy(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    SrcBitmap: TLuaBitmap;
    Dest,Source: TRect;
    tc: TColor;
begin
  CheckArg(L, 5);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  Dest := LuaGetRect(L,2);
  SrcBitmap := TLuaBitmap(GetLuaObject(L, 3));
  Source := LuaGetRect(L,4);
  tc := ToColor(L,5);
  lCanvas.BrushCopy(Dest, TBitmap(SrcBitmap), Source, tc);
  result := 0;
end;

function LuaDraw(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    SrcGraphic: TLuaGraphic;
    x,y: Integer;
begin
  CheckArg(L, 4);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  x := trunc(lua_tonumber(L,2));
  y := trunc(lua_tonumber(L,3));
  SrcGraphic := TLuaGraphic(GetLuaObject(L, 4));
  lCanvas.Draw(x,y,SrcGraphic);
  result := 0;
end;

function LuaDrawFocusRect(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
begin
  CheckArg(L, 2);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  ARect := LuaGetRect(L,2);
  lCanvas.DrawFocusRect(ARect);
  result := 0;
end;

function LuaStretchDraw(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    SrcGraphic: TLuaGraphic;
begin
  CheckArg(L, 3);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  ARect := LuaGetRect(L,2);
  SrcGraphic := TLuaGraphic(GetLuaObject(L, 3));
  lCanvas.StretchDraw(ARect, SrcGraphic);
  result := 0;
end;

function LuaEllipse(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x1,y1,x2,y2,n: Integer;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  if (n=2) then begin
     ARect := LuaGetRect(L,2);
     lCanvas.Ellipse(ARect);
  end else
  if (n=5) then begin
     x1 := trunc(lua_tonumber(L,2));
     y1 := trunc(lua_tonumber(L,3));
     x2 := trunc(lua_tonumber(L,4));
     y2 := trunc(lua_tonumber(L,5));
     lCanvas.Ellipse(x1,y1,x2,y2);
  end else
     CheckArg(L, 5);
  result := 0;
end;

function LuaFillRect(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x1,y1,x2,y2,n: Integer;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  if (n=2) then begin
     ARect := LuaGetRect(L,2);
     lCanvas.FillRect(ARect);
  end else
  if (n=5) then begin
     x1 := trunc(lua_tonumber(L,2));
     y1 := trunc(lua_tonumber(L,3));
     x2 := trunc(lua_tonumber(L,4));
     y2 := trunc(lua_tonumber(L,5));
     lCanvas.FillRect(x1,y1,x2,y2);
  end else
     CheckArg(L, 5);
  result := 0;
end;

function LuaFloodFill(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    x,y : Integer;
    FillStyle: TFillStyle;
    tc: TColor;
begin
  CheckArg(L, 5);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  x := trunc(lua_tonumber(L,2));
  y := trunc(lua_tonumber(L,3));
  tc := ToColor(L,4);
  FillStyle := TFillStyle(GetEnumValue(TypeInfo(TFillStyle),lua_tostring(L,5)));
  lCanvas.FloodFill(x,y,tc,FillStyle);
  result := 0;
end;

function LuaFrame3d(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    FrameWidth: integer;
    TopColor, BottomColor: TColor;
    Style: TGraphicsBevelCut;
    n: Integer;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  ARect := LuaGetRect(L,2);
  if (n=4) then begin
     FrameWidth := trunc(lua_tonumber(L,3));
     Style := TGraphicsBevelCut(GetEnumValue(TypeInfo(TGraphicsBevelCut),lua_tostring(L,4)));
     lCanvas.Frame3d(ARect, FrameWidth, Style);
  end else
  if (n=5) then begin
     TopColor := ToColor(L,3);
     BottomColor := ToColor(L,4);
     FrameWidth := trunc(lua_tonumber(L,5));
     lCanvas.Frame3d(ARect, TopColor, BottomColor, FrameWidth);
  end else
     CheckArg(L, 5);
  result := 0;
end;

function LuaFrame(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x1,y1,x2,y2: Integer;
    n: Integer;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  if (n=2) then begin
     ARect := LuaGetRect(L,2);
     lCanvas.Frame(ARect);
  end else
  if (n=5) then begin
     x1 := trunc(lua_tonumber(L,2));
     y1 := trunc(lua_tonumber(L,3));
     x2 := trunc(lua_tonumber(L,4));
     y2 := trunc(lua_tonumber(L,5));
     lCanvas.Frame(x1,y1,x2,y2);
  end else
     CheckArg(L, 5);
  result := 0;
end;

function LuaFrameRect(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x1,y1,x2,y2,n: Integer;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  if (n=2) then begin
     ARect := LuaGetRect(L,2);
     lCanvas.FrameRect(ARect);
  end else
  if (n=5) then begin
     x1 := trunc(lua_tonumber(L,2));
     y1 := trunc(lua_tonumber(L,3));
     x2 := trunc(lua_tonumber(L,4));
     y2 := trunc(lua_tonumber(L,5));
     lCanvas.FrameRect(x1,y1,x2,y2);
  end else
     CheckArg(L, 5);
  result := 0;
end;

function LuaGradientFill(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    StartColor, StopColor: TColor;
    ADirection: TGradientDirection;
begin
  CheckArg(L, 5);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  ARect := LuaGetRect(L,2);
  StartColor := ToColor(L,3);
  StopColor := ToColor(L,4);
  ADirection := TGradientDirection(GetEnumValue(TypeInfo(TGradientDirection),lua_tostring(L,5)));
  lCanvas.GradientFill(ARect, StartColor, StopColor, ADirection);
  result := 0;
end;


function LuaLine(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x1,y1,x2,y2,n: Integer;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  if (n=2) then begin
     ARect := LuaGetRect(L,2);
     lCanvas.Line(ARect);
  end else
  if (n=5) then begin
     x1 := trunc(lua_tonumber(L,2));
     y1 := trunc(lua_tonumber(L,3));
     x2 := trunc(lua_tonumber(L,4));
     y2 := trunc(lua_tonumber(L,5));
     lCanvas.Line(x1,y1,x2,y2);
  end else
     CheckArg(L, 5);
  result := 0;
end;

function LuaRadialPie(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    StartAngle16Deg, Angle16DegLength: Integer;
    x1, y1, x2, y2: Integer;
begin
   CheckArg(L, 7);
   lCanvas := TLuaCanvas(GetLuaObject(L, 1));
   x1 := trunc(lua_tonumber(L,2));
   y1 := trunc(lua_tonumber(L,3));
   x2 := trunc(lua_tonumber(L,4));
   y2 := trunc(lua_tonumber(L,5));
   StartAngle16Deg := trunc(lua_tonumber(L,6));
   Angle16DegLength := trunc(lua_tonumber(L,7));
   lCanvas.RadialPie(x1, y1, x2, y2, StartAngle16Deg, Angle16DegLength);
   result := 0;
end;

function LuaPie(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    EllipseX1,EllipseY1,EllipseX2,EllipseY2,StartX,StartY,EndX,EndY: Integer;
begin
   CheckArg(L, 9);
   lCanvas := TLuaCanvas(GetLuaObject(L, 1));
   EllipseX1 := trunc(lua_tonumber(L,2));
   EllipseY1 := trunc(lua_tonumber(L,3));
   EllipseX2 := trunc(lua_tonumber(L,4));
   EllipseY2 := trunc(lua_tonumber(L,5));
   StartX := trunc(lua_tonumber(L,6));
   StartY := trunc(lua_tonumber(L,7));
   EndX := trunc(lua_tonumber(L,8));
   EndY := trunc(lua_tonumber(L,9));
   lCanvas.Pie(EllipseX1,EllipseY1,EllipseX2,EllipseY2,StartX,StartY,EndX,EndY);
   result := 0;
end;

function LuaRoundRect(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x1,y1,x2,y2,n: Integer;
    RX,RY: Integer ;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  if (n=4) then begin
     ARect := LuaGetRect(L,2);
     rx := trunc(lua_tonumber(L,3));
     ry := trunc(lua_tonumber(L,4));
     lCanvas.RoundRect(ARect,rx,ry);
  end else
  if (n=7) then begin
     x1 := trunc(lua_tonumber(L,2));
     y1 := trunc(lua_tonumber(L,3));
     x2 := trunc(lua_tonumber(L,4));
     y2 := trunc(lua_tonumber(L,5));
     rx := trunc(lua_tonumber(L,6));
     ry := trunc(lua_tonumber(L,7));
     lCanvas.RoundRect(x1,y1,x2,y2,rx,ry);
  end else
     CheckArg(L, 7);
  result := 0;
end;

function LuaRectangle(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x1,y1,x2,y2,n: Integer;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  if (n=2) then begin
     ARect := LuaGetRect(L,2);
     lCanvas.Rectangle(ARect);
  end else
  if (n=5) then begin
     x1 := trunc(lua_tonumber(L,2));
     y1 := trunc(lua_tonumber(L,3));
     x2 := trunc(lua_tonumber(L,4));
     y2 := trunc(lua_tonumber(L,5));
     lCanvas.Rectangle(x1,y1,x2,y2);
  end else
     CheckArg(L, 5);
  result := 0;
end;

function LuaTextOut(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    x,y: Integer;
    txt: String;
begin
  CheckArg(L, 4);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  x := trunc(lua_tonumber(L,2));
  y := trunc(lua_tonumber(L,3));
  txt := lua_tostring(L,4);
  lCanvas.TextOut(x,y,txt);
  result := 0;
end;

function LuaTextRect(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    ARect: TRect;
    x,y,n: Integer;
    txt: String;
    Style: TTextStyle;
begin
  n := lua_gettop(L);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  ARect := LuaGetRect(L,2);
  x := trunc(lua_tonumber(L,3));
  y := trunc(lua_tonumber(L,4));
  txt := lua_tostring(L,5);
  if (n=5) then begin
     lCanvas.TextRect(ARect,x,y,txt);
  end else
  if (n=6) then begin
     Style := LuaGetTextStyle(L,6);
     lCanvas.TextRect(ARect,x,y,txt,Style);
  end else
     CheckArg(L, 6);
  result := 0;
end;

function LuaGetPixel(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    x,y: Integer;
begin
  CheckArg(L, 3);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  x := trunc(lua_tonumber(L,2));
  y := trunc(lua_tonumber(L,3));
  lua_pushnumber(L, lCanvas.Pixels[x,y]);
  result := 1;
end;

function LuaSetPixel(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
    x,y: Integer;
    c:TColor;
begin
  CheckArg(L, 4);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  x := trunc(lua_tonumber(L,2));
  y := trunc(lua_tonumber(L,3));
  c := ToColor(L,4);
  lCanvas.Pixels[x,y] := c;
  result := 0;
end;

function LuaSetTextStyle(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
begin
  CheckArg(L, 2);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  lCanvas.TextStyle := LuaGetTextStyle(L,2);
  result := 0;
end;

function LuaTextHeight(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
begin
  CheckArg(L, 2);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  lua_pushnumber(L,lCanvas.TextHeight(lua_tostring(L,2)));
  result := 1;
end;

function LuaTextWidth(L: Plua_State): Integer; cdecl;
var lCanvas:TLuaCanvas;
begin
  CheckArg(L, 2);
  lCanvas := TLuaCanvas(GetLuaObject(L, 1));
  lua_pushnumber(L,lCanvas.TextWidth(lua_tostring(L,2)));
  result := 1;
end;

procedure TLuaCanvas.ToTable(LL:Plua_State; Index:Integer; Sender:TObject);
begin
  L := LL;
  lua_newtable(L);
  LuaSetTableLightUserData(L, Index, HandleStr, Pointer(Sender));

  LuaSetTableFunction(L, index, 'Lock', LuaLock);
  LuaSetTableFunction(L, index, 'Unlock', LuaUnlock);
  LuaSetTableFunction(L, index, 'Refresh', LuaRefresh);
  LuaSetTableFunction(L, index, 'Clear', LuaClear);

  LuaSetTableFunction(L, index, 'Arc', LuaArc);
  LuaSetTableFunction(L, index, 'BrushCopy', LuaBrushCopy);
  LuaSetTableFunction(L, index, 'Chord', LuaChord);
  LuaSetTableFunction(L, index, 'CopyRect', LuaCopyRect);
  LuaSetTableFunction(L, index, 'Draw', LuaDraw);
  LuaSetTableFunction(L, index, 'DrawFocusRect', LuaDrawFocusRect);
  LuaSetTableFunction(L, index, 'StretchDraw', LuaStretchDraw);
  LuaSetTableFunction(L, index, 'Ellipse', LuaEllipse);
  LuaSetTableFunction(L, index, 'FillRect', LuaFillRect);
  LuaSetTableFunction(L, index, 'FloodFill', LuaFloodFill);
  LuaSetTableFunction(L, index, 'Frame3d', LuaFrame3d);
  LuaSetTableFunction(L, index, 'Frame', LuaFrame);
  LuaSetTableFunction(L, index, 'FrameRect', LuaFrameRect);
  LuaSetTableFunction(L, index, 'GradientFill', LuaGradientFill);
  LuaSetTableFunction(L, index, 'SetPixel', LuaSetPixel);
  LuaSetTableFunction(L, index, 'GetPixel', LuaGetPixel);
  LuaSetTableFunction(L, index, 'Line', LuaLine);
  LuaSetTableFunction(L, index, 'RadialPie', LuaRadialPie);
  LuaSetTableFunction(L, index, 'Pie', LuaPie);
  LuaSetTableFunction(L, index, 'Rectangle', LuaRectangle);
  LuaSetTableFunction(L, index, 'RoundRect', LuaRoundRect);
  LuaSetTableFunction(L, index, 'TextOut', LuaTextOut);
  LuaSetTableFunction(L, index, 'TextRect', LuaTextRect);
  LuaSetTableFunction(L, index, 'SetTextStyle', LuaSetTextStyle);
  LuaSetTableFunction(L, index, 'TextHeight', LuaTextHeight);
  LuaSetTableFunction(L, index, 'TextWidth', LuaTextWidth);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

end.

