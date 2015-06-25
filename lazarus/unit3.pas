unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { Toptionen }

  Toptionen = class(TForm)
    Serialparameter: TLabeledEdit;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  optionen: Toptionen;

implementation

{$R *.lfm}

end.

