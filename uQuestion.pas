unit uQuestion;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfQuestion = class(TForm)
    bCancel: TButton;
    procedure bCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fQuestion: TfQuestion;

implementation

{$R *.dfm}

procedure TfQuestion.bCancelClick(Sender: TObject);
begin
  Close;
end;

end.
