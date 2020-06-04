{$DEFINE HASCANVAS}
unit LuaShape;
interface
Uses Classes, Controls, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, EditBtn, Buttons, Forms, Spin, ActnList, CheckLst, TypInfo, LuaPas, LuaControl, LuaCanvas;
function CreateShape(L: Plua_State): Integer; cdecl;

type
  TRotateShape = class(TShape)
  private
    fAngle: extended;
    fRotateMinSize: Boolean;
    procedure SetAngle(const Value: extended);
    procedure SetRotateMinSize(const Value: Boolean);
    function CalcR(WInt,HInt: Integer; radA: Extended): Extended;
  public
    constructor Create(aOwner: TComponent); override;
    procedure Paint; override;
  published
    property Angle: extended read fAngle write SetAngle; {in degrees}
    property RotateMinSize: Boolean read fRotateMinSize write SetRotateMinSize;
  end;

type
    TLuaShape = class(TRotateShape)
        LuaCtl: TLuaControl;
{$IFDEF HASCANVAS}  		
		LuaCanvas: TLuaCanvas;
{$ENDIF}
        public
            destructor Destroy; override;
    end;

implementation
Uses LuaProperties, Lua, LCLClasses, Windows, Math;

{ TRotateShape }

constructor TRotateShape.Create(aOwner: TComponent);
begin
    fAngle := 0;
    fRotateMinSize := False;
    inherited;
end;

function TRotateShape.CalcR(WInt,HInt: Integer; radA: Extended): Extended;
var
    radA0 :Extended;
    W,H :Extended;
begin
    W := WInt;
    H := HInt;
    if radA > 3*Pi/2 then
      radA := 2*Pi - radA
    else if radA > Pi then
      radA := radA - Pi
    else if radA > Pi/2 then
      radA := Pi - radA;
    radA0 := arctan(W / H);
    Result := 1 / (Sqrt(1 + IntPower(W/H,2)) * Cos(radA0 - radA));
end;

function Min(a, b: Extended): Extended;inline;overload;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function Max(a, b: Extended): Extended;inline;overload;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

procedure TRotateShape.Paint;
var
    xForm,xFormOld: TXForm;
    gMode: DWORD;
    r: Extended;
    radA,radA0: Extended;
begin
    if Shape = stCircle then
    begin
      inherited;
      Exit;
    end;
    radA := frac(fAngle / 360) * 2 * Pi;
    case Shape of
        stSquaredDiamond:
            r := 1;
        stSquare,stRoundSquare:
            if fRotateMinSize then
                r := 1 / Sqrt(2)
            else
                r := CalcR(Min(Width,Height),Min(Width,Height),radA);
        else
            if fRotateMinSize then
              begin
                if Shape in [stDiamond,stEllipse] then
                  r := Min(Width,Height) / Max(Width,Height)
                else
                  r := 1 / (Sqrt(1 + IntPower(Max(Width,Height)/Min(Height,Width),2)))
              end
            else
              begin
                r := Min(CalcR(Width,Height,radA), CalcR(Height,Width,radA))
              end;
    end;
    gMode:= SetGraphicsMode(Canvas.Handle,GM_ADVANCED);
    try
        XForm.eM11 := Cos(radA) * r * (Width-1)/Width;
        XForm.eM12 := Sin(radA) * r * (Height-1)/Height;
        XForm.eM21 := - Sin(radA) * r * (Width-1)/Width;
        XForm.eM22 := Cos(radA) * r * (Height-1)/Height;
        XForm.eDx := (((Width-1)/2)-(Cos(radA)*((Width-1)/2))*r)+((Sin(radA)*((Height-1)/2))*r);
        XForm.eDy := (((Height-1)/2)-(Sin(radA)*((Width-1)/2))*r)-((Cos(radA)*((Height-1)/2))*r);
        if GetWorldTransform(Canvas.Handle,xFormOld) then
        try
          SetWorldTransform(Canvas.Handle,XForm);
          inherited;
        finally
          SetWorldTransform(Canvas.Handle,XFormOld);
        end;
    finally
        SetGraphicsMode(Canvas.Handle,gMode);
    end;
end;

procedure TRotateShape.SetAngle(const Value: extended);
begin
    if fAngle <> Value then
    begin
      fAngle := Value;
      Repaint;
    end;
end;

procedure TRotateShape.SetRotateMinSize(const Value: Boolean);
begin
    if fRotateMinSize <> Value then
    begin
      fRotateMinSize := Value;
      Repaint;
    end;
end;

{ TLuaShape }

destructor TLuaShape.Destroy;
begin
{$IFDEF HASCANVAS}
  if (LuaCanvas<>nil) then LuaCanvas.Free;
{$ENDIF}
  inherited Destroy;
end;
{$IFDEF HASCANVAS}
function ShapeGetCanvas(L: Plua_State): Integer; cdecl;
var lShape:TLuaShape;
begin
  lShape := TLuaShape(GetLuaObject(L, 1));
  lShape.LuaCanvas.ToTable(L, -1, lShape.Canvas);
  result := 1;
end;
{$ENDIF}

function  SendToBack(L: Plua_State): Integer; cdecl;
var lC:TShape;
begin
  lC := TShape(GetLuaObject(L, 1));
  lC.SendToBack;
  Result := 0;
end;
function  BringToFront(L: Plua_State): Integer; cdecl;
var lC:TShape;
begin
  lC := TShape(GetLuaObject(L, 1));
  lC.BringToFront;
  Result := 0;
end;

procedure ShapeToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L,Index,Sender);
  
  {$IFDEF HASCANVAS}
  if (Sender.InheritsFrom(TCustomControl) or Sender.InheritsFrom(TGraphicControl) or
      Sender.InheritsFrom(TLCLComponent)) then
     LuaSetTableFunction(L, Index, 'GetCanvas', ShapeGetCanvas); 
  {$ENDIF}
  LuaSetTableFunction(L, Index, 'SendToBack',@SendToBack);
  LuaSetTableFunction(L, Index, 'BringToFront',@BringToFront);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateShape(L: Plua_State): Integer; cdecl;
var
  lShape:TLuaShape;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lShape := TLuaShape.Create(Parent);
  lShape.Parent := TWinControl(Parent);
  lShape.LuaCtl := TLuaControl.Create(lShape,L,@ShapeToTable);
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lShape),-1)
  else
     lShape.Name := Name;
  {$IFDEF HASCANVAS}
  if (lShape.InheritsFrom(TCustomControl) or lShape.InheritsFrom(TGraphicControl) or
	  lShape.InheritsFrom(TLCLComponent)) then
    lShape.LuaCanvas := TLuaCanvas.Create;
  {$ENDIF}	
  ShapeToTable(L, -1, lShape);
  Result := 1;
end;
end.
