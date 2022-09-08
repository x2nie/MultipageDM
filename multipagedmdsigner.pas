unit MultipageDmDsigner;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Graphics, Controls, ExtCtrls, StdCtrls,
  FormEditingIntf;

type

  { TMultipageDmDesigner }

  TMultipageDmDesigner = class(TNonControlProxyDesignerForm)
  private
    FFooter : TPanel;
    FBtn1 : TButton;
    FPaintArea : TScrollBox;
    FTransfering:Boolean;
    //FWrapper: TDmWrapperForm;
    FWrapper: TForm;
    procedure Attach;
    function GetAreaHeight: integer;
    function GetAreaLeft: integer;
    function GetAreaTop: integer;
    function GetAreaWidth: integer;
    procedure SetAreaHeight(AValue: integer);
    procedure SetAreaLeft(AValue: integer);
    procedure SetAreaTop(AValue: integer);
    procedure SetAreaWidth(AValue: integer);
  protected
    function GetPublishedBounds(AIndex: Integer): Integer; override;
    procedure SetPublishedBounds(AIndex: Integer; AValue: Integer); override;
    procedure SetLookupRoot(AValue: TComponent); override;
    procedure RealSetText(const Value: TCaption); override;
    //procedure Activate; override;
    procedure SetZOrder(Topmost: Boolean); override; //called by BringToFront.
    procedure Btn1Click(Sender: TObject);
    function Wrapped: boolean;
  public
    constructor Create(AOwner: TComponent; ANonFormDesigner: INonFormDesigner); override;
    destructor Destroy; override;
    procedure Detach(CloseForm:Boolean);
    procedure Paint; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    //procedure BringToFront; reintroduce;
    procedure WrapperChangedBounds(ALeft, ATop, AWidth, AHeight: integer);
    procedure WrapperOnActivate(Sender: TObject);
    property AreaLeft: integer read GetAreaLeft write SetAreaLeft;
    property AreaTop: integer read GetAreaTop write SetAreaTop;
    property AreaWidth: integer read GetAreaWidth write SetAreaWidth;
    property AreaHeight: integer read GetAreaHeight write SetAreaHeight;
    {property AreaLeft: Integer index 100 read GetPublishedBounds write SetPublishedBounds;
    property AreaTop: Integer index 101 read GetPublishedBounds write SetPublishedBounds;
    property AreaWidth: Integer index 102 read GetPublishedBounds write SetPublishedBounds;
    property AreaHeight: Integer index 103 read GetPublishedBounds write SetPublishedBounds;}

  published
    //property ClientHeight: Integer read GetTabbedClientHeight write SetTabbedClientHeight;
    //property ClientHeight: Integer index 13 read GetPublishedBounds write SetPublishedBounds;
  end;

procedure Register;

implementation

uses
  LCLIntf,LCLType, DmWrapper;

procedure Register;
begin
  FormEditingHook.NonFormProxyDesignerForm[NonControlProxyDesignerFormId] := TMultipageDmDesigner;
end;

type
  TFormAccess = class(TCustomForm);

function Wrapper(me: TMultipageDmDesigner): TDmWrapperForm;
begin
  result := TDmWrapperForm(me.FWrapper);
end;

{ TMultipageDmDesigner }

procedure TMultipageDmDesigner.Attach;
begin
  if not assigned(FWrapper) then
  begin
    FWrapper := TDmWrapperForm.Create(self.Owner);
    // WARNING: do not reorder !
    FWrapper.SetBounds(Left,Top,Width,Height);
    FTransfering := true;

    self.Parent := TDmWrapperForm(FWrapper).ScrollBox;
    //self.Parent := FWrapper;
    //self.Align:= alClient;

    TControl(self).Left := 0;
    TControl(self).Top := 0;
    //self.HorzScrollBar.Visible:=False;
    FWrapper.Show;
    TDmWrapperForm(FWrapper).DmDesigner:=self;
    //FWrapper.OnActivate:= @WrapperOnActivate;
    FTransfering := false;
  end;
end;

function TMultipageDmDesigner.GetAreaHeight: integer;
begin
  result := TControl(self).Height;
end;

function TMultipageDmDesigner.GetAreaLeft: integer;
begin
  result := TControl(self).Left;
end;

function TMultipageDmDesigner.GetAreaTop: integer;
begin
  result := TControl(self).Top;
end;

function TMultipageDmDesigner.GetAreaWidth: integer;
begin
  result := TControl(Self).Width;
end;

procedure TMultipageDmDesigner.SetAreaHeight(AValue: integer);
begin
  //TControl(self).Height := Avalue;
  SetDesignerFormBounds(AreaLeft, AreaTop, AreaWidth, AValue);
end;

procedure TMultipageDmDesigner.SetAreaLeft(AValue: integer);
begin
  //TControl(Self).Left:= AValue;
  SetDesignerFormBounds(AValue, AreaTop, AreaWidth, AreaHeight);
end;

procedure TMultipageDmDesigner.SetAreaTop(AValue: integer);
begin
  SetDesignerFormBounds(AreaLeft, AValue, AreaWidth, AreaHeight);
end;

procedure TMultipageDmDesigner.SetAreaWidth(AValue: integer);
begin
  //TControl(Self).Width := AValue;
  SetDesignerFormBounds(AreaLeft, AreaTop, AValue, AreaHeight);
end;

procedure TMultipageDmDesigner.Detach(CloseForm: Boolean);
var LWrapper: TForm;
begin
  if assigned(FWrapper) then
  begin
    self.Parent := nil;
    LWrapper := FWrapper;
    FWrapper := nil;
    self.close;
    if CloseForm then
       LWrapper.close;
  end;
end;

function TMultipageDmDesigner.GetPublishedBounds(AIndex: Integer): Integer;
begin
  if not Wrapped or (AIndex >=100) then
     exit(inherited GetPublishedBounds(AIndex));

  Result := 0;
  case AIndex mod 10 of
    0: Result := FWrapper.Left;
    1: Result := FWrapper.Top;
    2: Result := FWrapper.Width;
    3: Result := FWrapper.Height;
  end;
end;

procedure TMultipageDmDesigner.SetPublishedBounds(AIndex: Integer; AValue: Integer
  );
begin
  if not Wrapped or (AIndex >=100) then
  begin
    inherited SetPublishedBounds(AIndex, AValue);
    exit;
  end;

  case AIndex mod 10 of
    0: FWrapper.Left := AValue;
    1: FWrapper.Top := AValue;
    2: FWrapper.Width := AValue;
    3: FWrapper.Height := AValue;
  end
end;

procedure TMultipageDmDesigner.SetLookupRoot(AValue: TComponent);
begin
  inherited SetLookupRoot(AValue);
  if AValue is TDataModule then
     Attach;
end;

procedure TMultipageDmDesigner.RealSetText(const Value: TCaption);
begin
  inherited RealSetText(Value);
  if Wrapped then
     FWrapper.Caption:=self.Caption;
end;

{procedure TMultipageDmDesigner.Activate;
begin
  inherited Activate;
  if wrapped then
     with TFormAccess(FWrapper) do
     begin
       Activate;
       BringToFront;
     end;
end;}

procedure TMultipageDmDesigner.Btn1Click(Sender: TObject);
begin
  FBtn1.Tag := FBtn1.tag + 1;
  writeln('halo btn!');
  Caption := '#'+IntToStr(FBtn1.tag);
end;

function TMultipageDmDesigner.Wrapped: boolean;
begin
  result := Assigned(FWrapper);
end;

constructor TMultipageDmDesigner.Create(AOwner: TComponent;
  ANonFormDesigner: INonFormDesigner);
begin
  inherited Create(AOwner, ANonFormDesigner);
  {FFooter := TPanel.Create(self);
  FFooter.Parent := self;
  FFooter.Align:=alBottom;
  FFooter.Height:=35;
  //FFooter.Color:=clCream;
  FFooter.BorderStyle:=bsNone;

  FBtn1 := TButton.Create(self);
  FBtn1.Parent := FFooter;
  FBtn1.Top:=5;
  FBtn1.Left:=10;
  FBtn1.OnClick:=@Btn1Click;
  FBtn1.Caption:='halo dev';

  FPaintArea := TScrollBox.Create(self);
  FPaintArea.Color:=clBlue;
  FPaintArea.width:=100;
  FPaintArea.Parent:= self;
  FPaintArea.Align:=alLeft;
  FPaintArea.HorzScrollBar.Range:=500;
  FPaintArea.VertScrollBar.Range:=500;
  }
end;

destructor TMultipageDmDesigner.Destroy;
begin
  if assigned(FWrapper) then
     Detach(True);
  inherited Destroy;
end;

type TComponentAccess = class(TComponent);
procedure SetToDesigning(A:TComponent);
begin
  TComponentAccess(A).SetDesigning(False);
end;

procedure TMultipageDmDesigner.Paint;
var FormCanvas : TCanvas;
begin
  inherited Paint;
  {if csDesigning in FFooter.ComponentState then
  begin
    SetToDesigning(FFooter);
    SetToDesigning(TComponent(FBtn1));
    SetToDesigning(TComponent(FPaintArea));

    FBtn1.OnClick:=@Btn1Click;
  end;
  FormCanvas := self.Canvas;
  try
     self.Canvas:=self.FPaintArea.Canvas;
     inherited Paint;
  finally
    self.Canvas:=FormCanvas;
  end;
  //FFooter.Hide;
  //FFooter.Show;}
end;

procedure TMultipageDmDesigner.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  if not wrapped then
    inherited SetBounds(ALeft, ATop, AWidth, AHeight)
  else
  begin
    if Assigned(NonFormDesigner) then
       NonFormDesigner.SetBounds(ALeft, ATop, AWidth, AHeight);
  end;
end;


procedure TMultipageDmDesigner.SetZOrder(Topmost: Boolean);
begin
  if not wrapped then
     inherited SetZOrder(Topmost)
  else
  begin
    // do not call 'AForm.Show', because it will set Visible to true
    FWrapper.BringToFront;
    LCLIntf.ShowWindow(FWrapper.Handle,SW_SHOWNORMAL);
  end;
end;

procedure TMultipageDmDesigner.WrapperChangedBounds(ALeft, ATop, AWidth,
  AHeight: integer);
begin
  if not FTransfering then
  begin
     //inherited SetBounds(aLeft, aTop, aWidth, aHeight);
    inherited SetPublishedBounds(0, ALeft);
    inherited SetPublishedBounds(1, ATop);
    inherited SetPublishedBounds(2, AWidth);
    inherited SetPublishedBounds(3, AHeight);
  end;
end;

procedure TMultipageDmDesigner.WrapperOnActivate(Sender: TObject);
begin
  //if assigned(Self.OnActivate) then
     //Self.OnActivate(Self);
  //TFormAccess(self).Activate;
  //Self.Activate;
  //self.SetFocus;
  self.Click;
end;

end.

