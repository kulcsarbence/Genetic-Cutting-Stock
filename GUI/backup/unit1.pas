unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, ShellApi, Windows,jwatlhelp32,fpvectorial,fpvtocanvas,fpcanvas, bgrabitmap, bgrasvg, LCLType;
     type
	Rectangle = record
		width,height: integer;
                alreadyWas:boolean;
	end;
type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;

    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Memo1: TMemo;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure ComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1MouseLeave(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    Procedure BubbleSort(var numbers : Array of Rectangle; size : Integer);
    function KillTask(ExeFileName: string): Integer;
    procedure Timer2Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  stepCount: integer;
  cutWidth: integer;
  stepSize: integer;
  theend: boolean = false;
  sortstock: array of Rectangle;
  notfirst: boolean=false;
  chosenItemString: ansistring;
   _stock: array of Rectangle;
   _tobecut: array of Rectangle;
implementation

{$R *.lfm}

{ TForm1 }

{* megoldas keresese gombra kattintva javaslom, hogy jojjon egy felugro ablak amiben megkerdezi
   hogy mi legyen a vagasi szelesseg,
   el kene donteni tovabba, hogy hogyan valasszon a program a keszletbol egy elemet amire lefuttatja
   az algoritmust! *}





procedure TForm1.FormCreate(Sender: TObject);     //beolvasas keszletbe es kivagandoba
var
  stock: TextFile;
  i, counter: Integer;
  line,listboxline: ansistring;
  list: TStringList;
  f: textfile;

begin
     Label3.Visible := False;
     Label4.Visible := False;
     KillTask('Genetic1.exe');
     AssignFile(f, 'progress.txt');
     Rewrite(f);
     Writeln(f, '0');
     CloseFile(f);
     //DrawFPVectorialToCanvas('teszt.svg',Image1.Canvas);
     Button5.Enabled:=False;
     Button6.Enabled:=False;
     stepSize:=0;
     stepCount:=0;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     AssignFile(stock,'stock.csv');
     Reset(stock);

     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
     //Memo beallitasa uresre
     Memo1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject); //Hozzaadas keszlethez
var
  wwidth,hheight,count: integer;
  stock: TextFile;
  counter: integer;
  faktor: integer;
  found: boolean;
  whichLine,i: integer;
  list,F,SL: TStringList;
  line,listboxline: ansistring;
begin

   //Hozzadas a keszlethez!
     wwidth := StrToInt(InputBox('Szélesség','Kérem adja meg egész számban kifejezve a SZÉLESSÉGET!',''));
     hheight := StrToInt(InputBox('Szélesség','Kérem adja meg egész számban kifejezve a MAGASSÁGOT!',''));
     count := StrToInt(InputBox('Szélesség','Kérem adja meg egész számban kifejezve a DARABSZÁMOT!',''));
     AssignFile(stock,'stock.csv');
     Reset(stock);
     found:=false;
     if combobox1.Items[combobox1.ItemIndex]='mm' then
                       begin
                            faktor := 1;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='cm' then
                       begin
                            faktor := 10;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='dm' then
                       begin
                            faktor := 100;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='m' then
                       begin
                            faktor := 1000;
                       end;
     whichLine:=-1;
     while not Eof(stock) and not found do
     begin
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
        try
         list.CommaText := line;
         if (StrToint(list[0])=wwidth) and (StrToInt(list[1])=hheight) then
         begin
              found:=true;
              F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('stock.csv');

                       F.Strings[whichLine]:=IntToStr(StrToInt(list[0])*faktor )+','+IntToStr(StrToInt(list[1])*faktor )+','+IntToStr( StrToInt(list[2])+count )+',';
                       F.SaveToFile('stock.csv');
                    finally
                       F.Free;
                    end;
                    break;
         end;
      finally
         list.Free;
      end;
     end;
     if not found then
     begin
                CloseFile(stock);
                Append(stock);
                WriteLn(stock,IntToStr(wwidth*faktor)+','+IntToStr(hheight*faktor)+','+IntToStr(count)+',');
                CloseFile(stock);
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     {*AssignFile(stock,'stock.csv');
     Reset(stock);
     ListBox1.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox1.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);    *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);  //Torles keszletbol
var

  stock: TextFile;
  counter: integer;
  found: boolean;
  whichLine,i: integer;
  list,F,SL: TStringList;
  line,listboxline: ansistring;
begin
  //Torlese a keszletbol egy kivalasztott elemnek
  chosenItemString := ListBox1.Items[ListBox1.ItemIndex];
  found:=false;
  AssignFile(stock,'stock.csv');
  Reset(stock);
  whichLine := -1;
     while not Eof(stock) and not found do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         if listboxline=chosenItemString then
         begin
              if StrToInt(list[2])>1 then
              begin
                   F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('stock.csv');
                       F.Strings[whichLine]:=list[0]+','+list[1]+','+IntToStr( StrToInt(list[2])-1 )+',';
                       F.SaveToFile('stock.csv');
                    finally
                       F.Free;
                    end;
                    break;
              end
              else
              begin
                   SL := TStringList.Create();
                   try
                      CloseFile(stock);
                       SL.LoadFromFile('stock.csv');
                       SL.Delete(whichLine);
                       SL.SaveToFile('stock.csv');
                   finally
                      SL.Free();
                   end;
                   break;


              end;
         end;
      finally
         list.Free;
      end;
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     {*AssignFile(stock,'stock.csv');
     Reset(stock);
     ListBox1.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox1.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);      *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);  //Hozzadas a kivagandokhoz
var
  counter: integer;
  wwidth,hheight,count: integer;
  stock: TextFile;
  faktor: integer;
  found: boolean;
  whichLine,i: integer;
  list,F,SL: TStringList;
  line,listboxline: ansistring;
begin
   //Hozzadas a keszlethez!
     wwidth := StrToInt(InputBox('Szélesség','Kérem adja meg egész számban kifejezve a SZÉLESSÉGET!',''));
     hheight := StrToInt(InputBox('Szélesség','Kérem adja meg egész számban kifejezve a MAGASSÁGOT!',''));
     count := StrToInt(InputBox('Szélesség','Kérem adja meg egész számban kifejezve a DARABSZÁMOT!',''));
     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     found:=false;
     whichLine:=-1;
     if combobox1.Items[combobox1.ItemIndex]='mm' then
                       begin
                            faktor := 1;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='cm' then
                       begin
                            faktor := 10;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='dm' then
                       begin
                            faktor := 100;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='m' then
                       begin
                            faktor := 1000;
                       end;
     while not Eof(stock) and not found do
     begin
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
        try
         list.CommaText := line;
         if (StrToint(list[0])=wwidth) and (StrToInt(list[1])=hheight) then
         begin
              found:=true;
              F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('tobecut.csv');

                       F.Strings[whichLine]:=IntToStr(StrToInt(list[0])*faktor )+','+IntToStr(StrToInt(list[1])*faktor )+','+IntToStr( StrToInt(list[2])+count )+',';
                       F.SaveToFile('tobecut.csv');
                    finally
                       F.Free;
                    end;
                    break;
         end;
      finally
         list.Free;
      end;
     end;
     if not found then
     begin
                CloseFile(stock);
                Append(stock);
                WriteLn(stock,IntToStr(wwidth*faktor)+','+IntToStr(hheight*faktor)+','+IntToStr(count)+',');
                CloseFile(stock);
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     {*AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ListBox2.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox2.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);       *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);  //Torles kivagandobol
var
  faktor: integer;
  counter: integer;
  chosenItemString: ansistring;
  stock: TextFile;
  found: boolean;
  whichLine,i: integer;
  list,F,SL: TStringList;
  line,listboxline: ansistring;
begin
  //Torlese a kivagandobol egy kivalasztott elemnek
  chosenItemString := ListBox2.Items[ListBox2.ItemIndex];
  found:=false;
  AssignFile(stock,'tobecut.csv');
  Reset(stock);
  whichLine := -1;
     while not Eof(stock) and not found do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         if listboxline=chosenItemString then
         begin
              if StrToInt(list[2])>1 then
              begin
                   F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('tobecut.csv');
                       F.Strings[whichLine]:=list[0]+','+list[1]+','+IntToStr( StrToInt(list[2])-1 )+',';
                       F.SaveToFile('tobecut.csv');
                    finally
                       F.Free;
                    end;
                    break;
              end
              else
              begin
                   SL := TStringList.Create();
                   try
                      CloseFile(stock);
                       SL.LoadFromFile('tobecut.csv');
                       SL.Delete(whichLine);
                       SL.SaveToFile('tobecut.csv');
                   finally
                      SL.Free();
                   end;
                   break;


              end;
         end;
      finally
         list.Free;
      end;
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
    {* AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ListBox2.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox2.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock); *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);  //Kovetkezo lepes
var
   bmp: TBGRABitmap;
  svg: TBGRASVG;
  stock: TextFile;
  faktor: integer;
  i: Integer;
  line,listboxline, viz: ansistring;
  list: TStringList;
begin
       if combobox1.Items[combobox1.ItemIndex]='mm' then
                       begin
                            faktor := 1;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='cm' then
                       begin
                            faktor := 10;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='dm' then
                       begin
                            faktor := 100;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='m' then
                       begin
                            faktor := 1000;
                       end;
     //beolvasasa a lepeseknek
     AssignFile(stock,'steps.csv');
     Reset(stock);
     stepCount := stepCount +1;
          Button5.Enabled := True;
          Button6.Enabled := True;

     for i:=1 to stepCount-1 do
         begin
          ReadLn(stock,line);
          end;

      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         Memo1.Lines.Clear;
         if (StrToint(list[1])=0) then
         begin
              viz:='fuggolegesen';
         end
         else
         begin
              viz:='vizszintesen';
         end;
         Memo1.Lines.Add(list[0]+'. lepes: '+sLineBreak+'A '+FloatToStr(StrToFloat(list[5])/faktor)+' szelessegu es '+FloatToStr(StrToFloat(list[6])/faktor)+' hosszusagu elemet vegye kezhez!'+sLineBreak+
         'Vagjuk el '+viz +' '+FloatToStr(StrToFloat(list[4])/faktor)+' pozicioban! '+sLineBreak+'(ha vizszintes a vagas, akkor nyilvan az elem magassagara ertendo a pozicio, ha pedig fuggoleges akkor a szelessegere)');
          bmp:= TBGRABitmap.Create;
           try
            svg:= TBGRASVG.Create('temp'+IntToStr(StrToint(list[0])-1)+'.svg');
            try
             if (Image1.Width > 0) and (Image1.Height > 0)
             then
               begin
                 bmp.SetSize(Round(Image1.Width),Round(Image1.Height));
                 bmp.Fill(clSilver);
                 svg.StretchDraw(bmp.Canvas2D, taCenter, tlCenter, 0,0,Image1.Width,Image1.Height);
                 Image1.Picture.Bitmap.Assign(bmp);
               end;
            finally
             svg.Free;
            end;
           finally
            bmp.Free;
           end;
         if list[0]='1' then
         begin
              Button6.Enabled:=False;
         end
         else
         if list[0]=IntToStr(stepSize) then
         begin
              Button5.Enabled:=False;
         end
         else
         begin
          Button5.Enabled:=True;
          Button6.Enabled:=True;
         end;
      finally
         list.Free;
      end;

     CloseFile(stock);


end;

procedure TForm1.Button6Click(Sender: TObject);  //Elozo lepes
var
   bmp: TBGRABitmap;
  svg: TBGRASVG;
  faktor: integer;
  stock: TextFile;
  i: Integer;
  line,listboxline, viz: ansistring;
  list: TStringList;
begin
     if combobox1.Items[combobox1.ItemIndex]='mm' then
                       begin
                            faktor := 1;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='cm' then
                       begin
                            faktor := 10;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='dm' then
                       begin
                            faktor := 100;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='m' then
                       begin
                            faktor := 1000;
                       end;
     stepCount := stepCount -1;

          Button5.Enabled := True;
          Button6.Enabled := True;

     //beolvasasa a lepeseknek
     AssignFile(stock,'steps.csv');
     Reset(stock);


     for i:=1 to stepCount-1 do
         begin
          ReadLn(stock,line);
          end;

      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         Memo1.Lines.Clear;
         if (strtoint(list[1])=0) then
         begin
              viz:='fuggolegesen';
         end
         else
         begin
              viz:='vizszintesen';
         end;
         Memo1.Lines.Add(list[0]+'. lepes: '+sLineBreak+'A '+FloatToStr(StrToFloat(list[5])/faktor)+' szelessegu es '+FloatToStr(StrToFloat(list[6])/faktor)+' hosszusagu elemet vegye kezhez!'+sLineBreak+
         'Vagjuk el '+viz +' '+FloatToStr(StrToFloat(list[4])/faktor)+' pozicioban! '+sLineBreak+'(ha vizszintes a vagas, akkor nyilvan az elem magassagara ertendo a pozicio, ha pedig fuggoleges akkor a szelessegere)');
         bmp:= TBGRABitmap.Create;
           try
            svg:= TBGRASVG.Create('temp'+IntToStr(StrToint(list[0])-1)+'.svg');
            try
             if (Image1.Width > 0) and (Image1.Height > 0)
             then
               begin
                 bmp.SetSize(Round(Image1.Width),Round(Image1.Height));
                 bmp.Fill(clSilver);
                 svg.StretchDraw(bmp.Canvas2D, taCenter, tlCenter, 0,0,Image1.Width,Image1.Height);
                 Image1.Picture.Bitmap.Assign(bmp);
               end;
            finally
             svg.Free;
            end;
           finally
            bmp.Free;
           end;
         if list[0]='1' then
         begin
              Button6.Enabled:=False;
         end
         else
         if list[0]=IntToStr(stepSize) then
         begin
              Button5.Enabled:=False;
         end
         else
         begin
          Button5.Enabled:=True;
          Button6.Enabled:=True;
         end;
      finally
         list.Free;
      end;

     CloseFile(stock);

end;

Procedure TForm1.BubbleSort(var numbers : Array of Rectangle; size : Integer);
Var
	i, j : Integer;
        temp: Rectangle;

Begin
	For i := size-1 DownTo 1 do
		For j := 1 to i do
			If ((numbers[j-1].Width*numbers[j-1].height) > (numbers[j].Width*numbers[j].height)) Then
			Begin
				temp := numbers[j-1];
				numbers[j-1] := numbers[j];
				numbers[j] := temp;
			End;

End;

procedure TForm1.Button7Click(Sender: TObject);   //Megoldas keresese gomb
var
  i,j,counter: integer;
  ex,ex2,f,stock: TextFile;
  line,listboxline: ansistring;
  areaToBeCut: integer;
  list: TStringList;
  selected: Rectangle;
  areaStock: integer;
  def: rectangle;
  s: string;
  ii, uu: integer;
begin
     //copypasta
     //ListBox1.Clear;
     //ListBox2.Clear;

     //DrawFPVectorialToCanvas('teszt.svg',Image1.Canvas);
     Button5.Enabled:=False;
     Button6.Enabled:=False;
     stepSize:=0;
     stepCount:=0;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     AssignFile(stock,'stock.csv');
     Reset(stock);

     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             //ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             //ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
     //Memo beallitasa uresre
     Memo1.Clear;
     //copypasta



     //kivalasztjuk a legmegfelelobb lapot, ha nem sikerul akkor egy masikat valasztunk
     if notFirst=true then
     begin
          ShowMessage('Választunk egy másik lapot, ami lehetőleg megfelelőbb a vágásra...');
     end;
     areatobecut := 0;
     for i:=0 to length(_tobecut)-1 do
         begin
          areaToBeCut:= areaToBeCut + ( _tobecut[i].Width*_tobecut[i].height );
          end;
     setlength(sortstock, length(_stock));
     if notFirst=false then
     begin
     sortstock := _stock;
     end;
     bubblesort(sortstock, length(sortstock));

     def.width:=0;
     def.height:=0;
     selected:=def;
     for j:=0 to length(sortstock)-1 do
         begin
              if j=length(sortstock)-1 then
              begin
                   theend:=true;
              end;
              areaStock:=(sortstock[j].width*sortstock[j].height);
              //ShowMessage(IntToStr(areastock)+' >= '+IntToStr(areatobecut));
              if (sortstock[j].alreadyWas=false) and ( areaStock>areatobecut ) then
              begin
                   sortstock[j].alreadyWas:=True;
                   selected:=sortstock[j];
                   chosenitemstring:=inttostr(selected.width) + ', '+inttostr(selected.height);
                   Label3.Visible := True;
                   Label4.Visible := True;
                   Label4.Caption := inttostr(selected.width)+', '+inttostr(selected.height);
                   Break;
              end;
         end;
     if selected.width=0 then
     begin
        ShowMessage('Nincs megfelelő méretű elem a készletben!');
     //vege a kivalasztasnak
     end
     else
     begin

     stepCount := 0;
     Button5.Enabled:=False;
     Button6.Enabled:=False;
     if notFirst=false then
     begin
       repeat
       s:=(inputbox('Vágási szélesség', 'Mi legyen a vágási szélesség (mm-ben értendő)? Kérem egész számot adjon meg!', '1'));
        val(s,cutWidth,uu);
       until ((uu=0) and (cutWidth>=0) and (cutWidth>MaxInt)) ;
     end;
     AssignFile(ex, 'exchange.txt');
     Rewrite(ex);
     WriteLn(ex,IntToStr(selected.width));
     WriteLn(ex,IntToStr(selected.height));
     WriteLn(ex,IntToStr(cutWidth));
     WriteLn(ex,Edit1.Text);
     WriteLn(ex,Edit2.Text);
     CloseFile(ex);
     ShellExecute(0, 'open', ('Genetic1.exe'), nil, nil, SW_HIDE);
     Sleep(250);
     ProgressBar1.Min:=0;
     ProgressBar1.Max:=StrToInt(Edit2.text);
     AssignFile(ex2,'progress.txt');
     Reset(ex2);
     Readln(ex2, line);
     ProgressBar1.Position:=StrToInt(line);
     CloseFile(ex2);
     Timer1.Enabled := True;
     end;

end;

procedure TForm1.Button8Click(Sender: TObject);   //keszlet minden torlese
var
  stock: TextFile;
  i, counter: Integer;
  line,listboxline: ansistring;
  list: TStringList;
  f: textfile;

begin
     ListBox1.Clear;
     ListBox2.Clear;
     AssignFile(f, 'stock.csv');
     Rewrite(f);
     CloseFile(f);
     //DrawFPVectorialToCanvas('teszt.svg',Image1.Canvas);
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
end;

procedure TForm1.Button9Click(Sender: TObject);    //kivagandokbol minden torlese
var
  stock: TextFile;
  i, counter: Integer;
  line,listboxline: ansistring;
  list: TStringList;
  f: textfile;

begin
     AssignFile(f, 'tobecut.csv');
     Rewrite(f);
     CloseFile(f);
     ListBox1.Clear;
     ListBox2.Clear;
     //DrawFPVectorialToCanvas('teszt.svg',Image1.Canvas);
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     AssignFile(stock,'stock.csv');
     Reset(stock);
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin

end;

procedure TForm1.ComboBox1Click(Sender: TObject);
begin

end;

procedure TForm1.ComboBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TForm1.ComboBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;



procedure TForm1.ComboBox1MouseLeave(Sender: TObject);
begin

end;

procedure TForm1.ComboBox1Select(Sender: TObject);
    var
  stock: TextFile;
  i, counter: Integer;
  line,listboxline: ansistring;
  list: TStringList;
  f: textfile;
begin
     ListBox1.Clear;
     ListBox2.Clear;
  If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
end;





procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  KillTask('Genetic1.exe');
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin

end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin

end;

function TForm1.KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;



procedure TForm1.Timer2Timer(Sender: TObject);
var
  stock: TextFile;
  i,p, counter: Integer;
  line: ansistring;
  list: TStringList;
  f: textfile;
  sstock: array of rectangle;
  ttobecut: array of rectangle;

begin
  If (ListBox1.SelCount > 0) or (ListBox2.SelCount>0) then
  begin

  end
  else
  begin
  Timer2.Interval := 1000;
     ListBox1.Clear;
     ListBox2.Clear;
     //DrawFPVectorialToCanvas('teszt.svg',Image1.Canvas);
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     AssignFile(stock,'stock.csv');
     Reset(stock);
     counter:=0;
     while not Eof(stock) do
     begin
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setlength(sstock,counter);
             sstock[counter-1].width := StrToInt(list[0]);
             sstock[counter-1].height := StrToInt(list[1]);
             sstock[counter-1].alreadywas := false;
             //ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     bubblesort(sstock, counter);
     for p:=1 to counter do
     begin
          ListBox1.Items.Add(IntToStr(sstock[p-1].width) + ', ' + IntToStr(sstock[p-1].height));
     end;
     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(ttobecut, counter);
             ttobecut[counter-1].Width:=StrToInt(list[0]);
             ttobecut[counter-1].Height:=StrToInt(list[1]);
             ttobecut[counter-1].alreadyWas:=false;
             //ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     bubblesort(ttobecut, counter);
     for p:=1 to counter do
     begin
          ListBox2.Items.Add(IntToStr(ttobecut[p-1].width) + ', ' + IntToStr(ttobecut[p-1].height));
     end;
     //beolvasas vege
end;

end;

procedure TForm1.Timer1Timer(Sender: TObject);   //Timer a ProgressBarhoz
var
  wwidth,hheight,count: integer;
  stock: TextFile;
  Reply, BoxStyle: Integer;
  rem: textfile;
  counter,p: integer;
  faktor: integer;
  found: boolean;
  whichLine,i: integer;
  F,SL: TStringList;
  listboxline,listboxline2: ansistring;
  vall: integer;
  ex2, step, f2: TextFile;
  line,line2, ln,line3: ansistring;
  list,list2,list3: TStringList;
begin
     Button1.Enabled := False;
     Button2.Enabled := False;
     Button3.Enabled := False;
     Button4.Enabled := False;
     Button5.Enabled := False;
     Button6.Enabled := False;
     Button7.Enabled := False;
     AssignFile(ex2,'progress.txt');
     Reset(ex2);
     Readln(ex2, line);
     ProgressBar1.Position:=StrToInt(line);
     CloseFile(ex2);
     if (StrToInt(line)<(StrToInt(Edit2.text)-1)) and (StrToint(line)<>9999999) and (strtoint(line)<>-1) then
     begin
           Reset(ex2);
           Readln(ex2, line);
           ProgressBar1.Position:=StrToInt(line);
           CloseFile(ex2);
     end
     else
     begin
      Button1.Enabled := True;
     Button2.Enabled := true;
     Button3.Enabled := True;
     Button4.Enabled := True;
     Button5.Enabled := True;
     Button6.Enabled := True;
     Button7.Enabled := True;
       Timer1.Enabled := False;
       sleep(1000);
       AssignFile(f2, 'steps.csv');
       Reset(f2);
       While not eof(f2) do
       begin
        Readln(f2, ln);
        end;
       list2 := TStringList.Create();
            try
               list2.CommaText := ln;
               vall:=StrToint(list2[0]);
            finally
               list2.Free;
            end;
       CloseFile(f2);



       if (StrToInt(line)=9999999) then
       begin
            //ShowMessage('Talaltunk megoldast!');
            while not Sysutils.FileExists('temp'+IntToStr(vall-1)+'.svg') do
             begin
                  sleep(50);
             end;
            KillTask('Genetic1.exe');
             AssignFile(f2, 'progress.txt');
             Rewrite(f2);
             Writeln(f2, '0');
             CloseFile(f2);
            notFirst:=false;
            ProgressBar1.Position:=StrToInt(Edit2.text);
            Button5.Enabled:=True;

            Button6.Enabled:=False;
            AssignFile(step, 'steps.csv');
            Reset(step);
            while not eof(step) do
            begin
             ReadLn(step,line2);
            end;
            list := TStringList.Create();
            try
               list.CommaText := line2;
               stepSize:=StrToint(list[0]);
            finally
               list.Free;
            end;
            CloseFile(step);
            for p:=1 to stepSize do
            begin
             Button5.Click;
             Sleep(75);
            end;
             BoxStyle := MB_ICONQUESTION + MB_YESNO;
  Reply := Application.MessageBox('Elmentsuk a jelenlegi allapotot, azaz a megmaradt elemek bekeruljenek a stockba?','Mentes' , BoxStyle);
  if Reply = IDYES then
             begin
                  ShowMessage(chosenitemstring);
                  AssignFile(rem, 'tobecut.csv');
                  Rewrite(rem);
                  CloseFile(rem);
                  ListBox2.Clear;
                 //Hozzadas a keszlethez!
                 AssignFile(rem,'remaining.csv');
     Reset(rem);
     while not Eof(rem) do
     begin
      listboxline2:='';
      list3 := TStringList.Create();
      ReadLn(rem,line3);
      try
         list3.CommaText := line3;
         wwidth := StrToint(list3[0]);
     hheight := StrToint(list3[1]);
     count := StrToint(list3[2]);
     AssignFile(stock,'stock.csv');
     Reset(stock);
     found:=false;
     if combobox1.Items[combobox1.ItemIndex]='mm' then
                       begin
                            faktor := 1;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='cm' then
                       begin
                            faktor := 10;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='dm' then
                       begin
                            faktor := 100;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='m' then
                       begin
                            faktor := 1000;
                       end;
     whichLine:=-1;
     while not Eof(stock) and not found do
     begin
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
        try
         list.CommaText := line;
         if (StrToint(list[0])=wwidth) and (StrToInt(list[1])=hheight) then
         begin
              found:=true;
              F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('stock.csv');

                       F.Strings[whichLine]:=IntToStr(StrToInt(list[0])*faktor )+','+IntToStr(StrToInt(list[1])*faktor )+','+IntToStr( StrToInt(list[2])+count )+',';
                       F.SaveToFile('stock.csv');
                    finally
                       F.Free;
                    end;
                    break;
         end;
      finally
         list.Free;
      end;
     end;
     if not found then
     begin
                CloseFile(stock);
                Append(stock);
                WriteLn(stock,IntToStr(wwidth*faktor)+','+IntToStr(hheight*faktor)+','+IntToStr(count)+',');
                CloseFile(stock);
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     {*AssignFile(stock,'stock.csv');
     Reset(stock);
     ListBox1.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox1.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);    *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
      finally
         list3.Free;
      end;
     end;
     CloseFile(rem);
     //
            //Torlese a keszletbol egy kivalasztott elemnek
  found:=false;
  AssignFile(stock,'stock.csv');
  Reset(stock);
  whichLine := -1;
     while not Eof(stock) and not found do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         if listboxline=chosenItemString then
         begin
              if StrToInt(list[2])>1 then
              begin
                   F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('stock.csv');
                       F.Strings[whichLine]:=list[0]+','+list[1]+','+IntToStr( StrToInt(list[2])-1 )+',';
                       F.SaveToFile('stock.csv');
                    finally
                       F.Free;
                    end;
                    break;
              end
              else
              begin
                   SL := TStringList.Create();
                   try
                      CloseFile(stock);
                       SL.LoadFromFile('stock.csv');
                       SL.Delete(whichLine);
                       SL.SaveToFile('stock.csv');
                   finally
                      SL.Free();
                   end;
                   break;


              end;
         end;
      finally
         list.Free;
      end;
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     {*AssignFile(stock,'stock.csv');
     Reset(stock);
     ListBox1.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox1.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);      *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;

             end;

            if stepSize=1 then
             begin
               Button5.Enabled := False;
             end;
       end;
       if (StrToint(line)=-1) then
       begin
            ShowMessage('Nem találtunk megoldást!');
            AssignFile(f2, 'progress.txt');
             Rewrite(f2);
             Writeln(f2, '0');
             CloseFile(f2);
            KillTask('Genetic1.exe');

            if theend=false then
            begin
            showmessage('folytatódik');
            notFirst:=true;
            Button7.Click;

            end
            else
            begin
            theend:=false;
            notfirst:=false;
            end;
            stepSize:=0;
            stepCount := 0;
       end;
       if  (StrToInt(line)=(StrToInt(Edit2.text)-1)) then
       begin
            //ShowMessage('Találtunk megoldást!');
             while not Sysutils.FileExists('temp'+IntToStr(vall-1)+'.svg') do
             begin
                  sleep(50);
             end;
             KillTask('Genetic1.exe');
            AssignFile(f2, 'progress.txt');
             Rewrite(f2);
             Writeln(f2, '0');
             CloseFile(f2);

            notFirst:=false;
            ProgressBar1.Position:=StrToInt(Edit2.text);
            Button5.Enabled:=True;
            Button6.Enabled:=False;
            AssignFile(step, 'steps.csv');
            Reset(step);
            while not eof(step) do
            begin
             ReadLn(step,line2);
            end;
            list := TStringList.Create();
            try
               list.CommaText := line2;
               stepSize:=StrToint(list[0]);
            finally
               list.Free;
            end;
            CloseFile(step);

            for p:=1 to stepSize do
            begin
             Button5.Click;
             Sleep(75);
            end;
            if stepSize=1 then
             begin
               Button5.Enabled := False;
             end;
            BoxStyle := MB_ICONQUESTION + MB_YESNO;
  Reply := Application.MessageBox('Elmentsuk a jelenlegi allapotot, azaz a megmaradt elemek bekeruljenek a stockba?','Mentes' , BoxStyle);
  if Reply = IDYES then
             begin
                 AssignFile(rem, 'tobecut.csv');
                  Rewrite(rem);
                  CloseFile(rem);
                  ListBox2.Clear;
                 //Hozzadas a keszlethez!
                 AssignFile(rem,'remaining.csv');
     Reset(rem);
     while not Eof(rem) do
     begin
      listboxline2:='';
      list3 := TStringList.Create();
      ReadLn(rem,line3);
      try
         list3.CommaText := line3;
         wwidth := StrToint(list3[0]);
     hheight := StrToint(list3[1]);
     count := StrToint(list3[2]);
     AssignFile(stock,'stock.csv');
     Reset(stock);
     found:=false;
     if combobox1.Items[combobox1.ItemIndex]='mm' then
                       begin
                            faktor := 1;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='cm' then
                       begin
                            faktor := 10;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='dm' then
                       begin
                            faktor := 100;
                       end;
                       if combobox1.Items[combobox1.ItemIndex]='m' then
                       begin
                            faktor := 1000;
                       end;
     whichLine:=-1;
     while not Eof(stock) and not found do
     begin
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
        try
         list.CommaText := line;
         if (StrToint(list[0])=wwidth) and (StrToInt(list[1])=hheight) then
         begin
              found:=true;
              F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('stock.csv');

                       F.Strings[whichLine]:=IntToStr(StrToInt(list[0])*faktor )+','+IntToStr(StrToInt(list[1])*faktor )+','+IntToStr( StrToInt(list[2])+count )+',';
                       F.SaveToFile('stock.csv');
                    finally
                       F.Free;
                    end;
                    break;
         end;
      finally
         list.Free;
      end;
     end;
     if not found then
     begin
                CloseFile(stock);
                Append(stock);
                WriteLn(stock,IntToStr(wwidth*faktor)+','+IntToStr(hheight*faktor)+','+IntToStr(count)+',');
                CloseFile(stock);
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     {*AssignFile(stock,'stock.csv');
     Reset(stock);
     ListBox1.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox1.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);    *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
      finally
         list3.Free;
      end;
     end;
     CloseFile(rem);
     //
            //Torlese a keszletbol egy kivalasztott elemnek
  found:=false;
  AssignFile(stock,'stock.csv');
  Reset(stock);
  whichLine := -1;
     while not Eof(stock) and not found do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      whichLine := whichLine + 1;
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         if listboxline=chosenItemString then
         begin
              if StrToInt(list[2])>1 then
              begin
                   F:=TStringList.Create;
                    try
                       CloseFile(stock);
                       F.LoadFromFile('stock.csv');
                       F.Strings[whichLine]:=list[0]+','+list[1]+','+IntToStr( StrToInt(list[2])-1 )+',';
                       F.SaveToFile('stock.csv');
                    finally
                       F.Free;
                    end;
                    break;
              end
              else
              begin
                   SL := TStringList.Create();
                   try
                      CloseFile(stock);
                       SL.LoadFromFile('stock.csv');
                       SL.Delete(whichLine);
                       SL.SaveToFile('stock.csv');
                   finally
                      SL.Free();
                   end;
                   break;


              end;
         end;
      finally
         list.Free;
      end;
     end;
     //beolvasasa a kivagando elemeknek es a keszlet elemeknek
     {*AssignFile(stock,'stock.csv');
     Reset(stock);
     ListBox1.Clear;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
             ListBox1.Items.Add(listboxline);
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);      *}
      ListBox1.Clear;
     ListBox2.Clear;
     If ComboBox1.Items[ComboBox1.ItemIndex]='mm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+list[0]+', ';
         listboxline:=listboxline+list[1];
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  If ComboBox1.Items[ComboBox1.ItemIndex]='cm' then
  begin
       AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/10 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/10 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if ComboBox1.Items[ComboBox1.ItemIndex]='dm' then
  begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/100 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/100 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;
  if combobox1.items[combobox1.itemindex]='m' then
   begin
      AssignFile(stock,'stock.csv');
     Reset(stock);
     //ComboBox csak valaszthato legyen
     ComboBox1.Style := csDropDownList;
     //ComboBox vege
     counter:=0;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
             counter:=counter+1;
             setLength(_stock, counter);
             _stock[counter-1].Width:=StrToInt(list[0]);
             _stock[counter-1].Height:=StrToInt(list[1]);
             _stock[counter-1].alreadywas:=false;
             ListBox1.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);

     counter:=0;


     AssignFile(stock,'tobecut.csv');
     Reset(stock);
     ComboBox1.Style := csDropDownList;
     while not Eof(stock) do
     begin
      listboxline:='';
      list := TStringList.Create();
      ReadLn(stock,line);
      try
         list.CommaText := line;
         listboxline:=listboxline+FloatToStr( StrToFloat(list[0])/1000 )+', ';
         listboxline:=listboxline+FloatToStr( StrToFloat(list[1])/1000 );
         for i:=1 to StrToInt(list[2]) do
         begin
              counter:=counter+1;
             setLength(_tobecut, counter);
             _tobecut[counter-1].Width:=StrToInt(list[0]);
             _tobecut[counter-1].Height:=StrToInt(list[1]);
             _tobecut[counter-1].alreadyWas:=false;
             ListBox2.Items.Add(listboxline);
         end;
      finally
         list.Free;
      end;
     end;
     CloseFile(stock);
     //beolvasas vege
  end;

             end;
       end;
     end;
end;

end.

