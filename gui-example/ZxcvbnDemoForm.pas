unit ZxcvbnDemoForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uDebouncedEvent, Vcl.ComCtrls,
  Zxcvbn;

type
  TMainForm = class(TForm)
    edPassword: TLabeledEdit;
    labStrength: TLabel;
    labWarnings: TLabel;
    pbStrength: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pbStrengthPaint(Sender: TObject);
  private
    { Private declarations }
    FZxcvbn: TZxcvbn;
    FPasswordScore: Integer;
  public
    { Public declarations }
    procedure DoOnPasswordEditChange(ASender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
{$R Dictionaries.res}

uses Zxcvbn.Utility,
     Zxcvbn.Result;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FZxcvbn := TZxcvbn.Create;
  FPasswordScore := 0;
  pbStrength.Canvas.Brush.Color := clWhite;
  pbStrength.Canvas.Pen.Color := clBlack;
  pbStrength.Canvas.Pen.Width := 1;

  edPassword.OnChange := TDebouncedEvent.Wrap(DoOnPasswordEditChange, 200, Self);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FZxcvbn.Free;
end;

procedure TMainForm.pbStrengthPaint(Sender: TObject);
begin
  pbStrength.Canvas.Brush.Color := clWhite;
  pbStrength.Canvas.FillRect(Rect(0, 0, pbStrength.Width, pbStrength.Height));
  pbStrength.Canvas.Rectangle(0, 0, pbStrength.Width, pbStrength.Height);

  case FPasswordScore of
    0: begin pbStrength.Canvas.Brush.Color := $00241CED; pbStrength.Canvas.FillRect(Rect(1, 1, 1 * (pbStrength.Width div 12)-1, pbStrength.Height-1)); end;
    1: begin pbStrength.Canvas.Brush.Color := $00277FFF; pbStrength.Canvas.FillRect(Rect(1, 1, 2 * (pbStrength.Width div 5)-1, pbStrength.Height-1)); end;
    2: begin pbStrength.Canvas.Brush.Color := $000EC9FF; pbStrength.Canvas.FillRect(Rect(1, 1, 3 * (pbStrength.Width div 5)-1, pbStrength.Height-1)); end;
    3: begin pbStrength.Canvas.Brush.Color := $00E8A200; pbStrength.Canvas.FillRect(Rect(1, 1, 4 * (pbStrength.Width div 5)-1, pbStrength.Height-1)); end;
    4: begin pbStrength.Canvas.Brush.Color := $004CB122; pbStrength.Canvas.FillRect(Rect(1, 1, pbStrength.Width-1, pbStrength.Height-1)); end;
  end;
end;

procedure TMainForm.DoOnPasswordEditChange(ASender: TObject);
var
  res: TZxcvbnResult;
begin
  res := FZxcvbn.EvaluatePassword(edPassword.Text);
  try
    FPasswordScore := res.Score;
    labWarnings.Caption := 'Warning: ' + #10 + Zxcvbn.Utility.GetWarning(res.Warning) + #10 +
      'Suggestions: ' + #10 + Zxcvbn.Utility.GetSuggestions(res.Suggestions);
    pbStrength.Invalidate;
  finally
    res.Free;
  end;
end;

end.
