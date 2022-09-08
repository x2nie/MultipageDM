unit DmWrapper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  PairSplitter, MultipageDmDsigner;

type

  { TDmWrapperForm }

  TDmWrapperForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Panel1: TPanel;
    Corner: TPanel;
    HScrollBar: TScrollBar;
    ScrollBox: TScrollBox;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure HScrollBarChange(Sender: TObject);
  private
    FDmDesigner: TMultipageDmDesigner;
    FHScrollbarUpdate : integer;
    procedure SetDmDesigner(AValue: TMultipageDmDesigner);
    procedure RecalculateAreaSize;

  public
    property DmDesigner: TMultipageDmDesigner read FDmDesigner write SetDmDesigner;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
  end;

var
  DmWrapperForm: TDmWrapperForm;

implementation

uses Math;

{$R *.lfm}

{ TDmWrapperForm }

procedure TDmWrapperForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if assigned(FDmDesigner) then
     TMultipageDmDesigner(FDmDesigner).Detach(False);
  CloseAction := caFree;
end;

procedure TDmWrapperForm.Button1Click(Sender: TObject);
begin
  //FDmDesigner.HorzScrollBar.Visible:= not FDmDesigner.HorzScrollBar.Visible;
  ScrollBox.HorzScrollBar.Visible:= not ScrollBox.HorzScrollBar.Visible;
end;

procedure TDmWrapperForm.FormResize(Sender: TObject);
var hiddenH, visibleArea: integer;
begin
  RecalculateAreaSize;
  //HScrollBar.Assign(ScrollBox.HorzScrollBar);

  inc(FHScrollbarUpdate);
  //max = hidden part
  visibleArea := ScrollBox.Width;//.HorzScrollBar.ClientSizeWithoutBar;
  hiddenH := Max(0, FDmDesigner.AreaWidth - visibleArea);
  // check if it enough to fill the available visible area by shift right?
  if (FDmDesigner.AreaLeft < 0) and (visibleArea - (FDmDesigner.AreaLeft + FDmDesigner.AreaWidth) > 0) then
  begin
    FDmDesigner.AreaLeft := - Max(0, FDmDesigner.AreaWidth - visibleArea);
  end;

  if hiddenH > 0 then
  begin
    HScrollBar.Max:= visibleArea;
    HScrollBar.PageSize := visibleArea - hiddenH;
    HScrollBar.Position:= - FDmDesigner.AreaLeft;
    HScrollBar.Visible:=True;
  end
  else
  begin
    HSCrollBar.Visible:=False;
    HScrollBar.Max:=1;
    HScrollBar.PageSize:=1;
    HScrollBar.Position:=1;
  end;

  dec(FHScrollbarUpdate);
end;

procedure TDmWrapperForm.HScrollBarChange(Sender: TObject);

begin
  if FHScrollbarUpdate > 0 then exit;
  //ScrollBox.scr.HorzScrollBar.position := HScrollBar.Position;
  FDmDesigner.AreaLeft := - HScrollBar.Position;
end;

procedure TDmWrapperForm.SetDmDesigner(AValue: TMultipageDmDesigner);
begin
  if (FDmDesigner=AValue) or (Avalue = nil) then Exit;
  FDmDesigner:=AValue;
  self.OnActivate:=@FDmDesigner.WrapperOnActivate;
  RecalculateAreaSize;
end;

procedure TDmWrapperForm.RecalculateAreaSize;
var i,w,h : integer;
begin
  exit;
  w := ScrollBox.Width;
  h := ScrollBox.Height;

  w := ScrollBox.ClientWidth;
  h := ScrollBox.ClientHeight;

  //iterate children here

  //if FDmDesigner.AreaWidth < ;
  //FDmDesigner.AreaWidth := ScrollBox.Width;
  //FDmDesigner.AreaHeight:= ScrollBox.Height;
  FDmDesigner.SetDesignerFormBounds(0,0, w, h);

  //HScrollBar.Max:=FDmDesigner.AreaWidth;

end;

procedure TDmWrapperForm.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if assigned(DmDesigner) then
     TMultipageDmDesigner(DmDesigner).WrapperChangedBounds(ALeft, ATop, AWidth, AHeight);
end;

end.

