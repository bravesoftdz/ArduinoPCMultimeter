unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, unit2,
  ExtCtrls, ComCtrls, StdCtrls, Menus, Spin,Unit3;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PageControl1: TPageControl;
    PaintBox1: TPaintBox;
    PaintBox2: TPaintBox;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    SpinEdit1: TSpinEdit;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure kreisanzeige(r,x,y,grad: integer);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  wert,altwert:real;
  i:integer;
  pwm:array[0..5] of byte;
  tmpstr:String;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  if 0 = OPENCOM((optionen.Serialparameter.Text)) then begin
    ShowMessage('Konnte keine verbindung mit den Parametern: ' + optionen.Serialparameter.Text + ' aufbauen');
    exit;
  end;

  SENDBYTE(5);
  SENDBYTE(5);
  DELAY(500);
  if INBUFFER>0 then
  begin
    if READBYTE=6 then
    begin
      READSTRING();
       //ShowMessage('Microcontroller antwortet korekt');
       CheckBox1.Enabled:=true;
       CheckBox2.Enabled:=true;
       Button1.Enabled:=true;
       Timer1.Enabled:=CheckBox1.Checked;

    end
    else
    begin
       ShowMessage('Microcontroller antwortet zwar, aber die Antwort ist nicht korekt!!');
       CLOSECOM();
       exit;
    end;
  end else
  begin
     ShowMessage('Microcontroller antwortet nicht');
     CLOSECOM();
     exit;
  end;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  Timer1.Enabled:=CheckBox1.Checked;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  timer1.Enabled:=false;
  READSTRING();
  //DELAY(10);
  pwm[ComboBox2.ItemIndex]:= ScrollBar1.Position ;
  SENDSTRING('P');
  SENDSTRING(inttostr(ComboBox2.ItemIndex));
  SENDBYTE(ScrollBar1.Position);
  timer1.Enabled:=true;
end;

procedure TForm1.Button2Click(Sender: TObject);
var timeron:boolean;
  delaytime:integer;
  werte:array[0..256] of byte;
  i:integer;
begin
  StatusBar1.Panels.Items[0].Text:='';
  timeron := Timer1.Enabled;
  Timer1.Enabled:=false;
  BUFFERSIZE(300);
  SENDBYTE(79);
  SENDBYTE(ComboBox3.ItemIndex);
  SENDBYTE(ScrollBar2.Position);
  delaytime := round(ScrollBar2.Position*ScrollBar2.Position*256/1000 +1000);
   TIMEINIT();
   i:=0;
   while (i<256) AND (TIMEREAD<delaytime) do
   begin
      if (INBUFFER()>0) then
      begin

           werte[i] := READBYTE();
           i += 1;
      end;
   end;
   //ShowMessage(IntToStr(i));
   if i<256 then
   begin
     READSTRING ;
     StatusBar1.Panels.Items[0].Text:='Fehler' + IntToStr(i);
     exit;

   end;
   PaintBox2.Refresh;

   PaintBox2.Canvas.MoveTo(0,(werte[0]-256)*-1);
   for i :=0 to 255 do
   begin
      PaintBox2.Canvas.LineTo(i,(werte[i]-256)*-1);

   end;
   {repeat until (INBUFFER() = 256) or (TIMEREAD>delaytime);
   if INBUFFER()  <> 256 then
   begin
     ShowMessage(inttostr(INBUFFER()));
     READSTRING ;
     StatusBar1.Panels.Items[0].Text:='Fehler';
     exit;
   end;}

end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  ScrollBar1.Position:=pwm[ComboBox2.ItemIndex];
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  timer1.Enabled:=false;
  Button1.Enabled:=false;
  CheckBox1.Enabled:=false;
  CheckBox2.Enabled:=false;
  CLOSECOM();
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  optionen.Show;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  Button1.Caption:='Setzten ' + inttostr(round(ScrollBar1.Position / 255 * 100)) + '%';
  //Button1Click(Sender);
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
  Label4.Caption:=IntToStr(ScrollBar2.Position * ScrollBar2.Position) + ' µs';
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  timer1.Interval:=SpinEdit1.Value;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   READSTRING();
   SENDSTRING(inttostr(ComboBox1.ItemIndex ));
   TIMEINIT();
   repeat until (INBUFFER() = 4) or (TIMEREAD>5);
   if INBUFFER()  <> 4 then
   begin
     READSTRING ;
     StatusBar1.Panels.Items[0].Text:='Fehler';
     exit;
   end;
   tmpstr := (chr(READBYTE()) + chr(READBYTE()) + chr(READBYTE()) + chr(READBYTE()));
   wert := int(strtoint(tmpstr) / 1023 * 5000)/1000  ;
   if wert <> altwert then
   begin
   str(wert:1:3,tmpstr);
   Edit1.Text:= tmpstr + ' V';
   StatusBar1.Panels.Items[0].Text:='';
   altwert:=wert;
   if CheckBox2.Checked then kreisanzeige(180,150,200,round(wert/5*102+309));
   end;
end;

procedure TForm1.kreisanzeige(r,x,y,grad: integer);
var xend,yend,xver,yver:integer;
  var gradpi:double;
begin
   grad:=grad+270;
   gradpi:=grad/180*3.141592653589732384;


   yver:=round(sin(gradpi)*r);
   xver := round(cos(gradpi)*r);
   yend:=y+yver;
   xend:=x+xver ;
   PaintBox1.Refresh ;
   with PaintBox1.Canvas do
   begin
      TextOut(0,80,'0 V');
      TextOut(280,80,'5 V');
      TextOut(150,0,'2,5 V');
      line(x,y,xend,yend);
   end;


end;



end.

