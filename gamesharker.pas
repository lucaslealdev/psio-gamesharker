unit gamesharker;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, FileCtrl, Types, jpeg, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    XPManifest1: TXPManifest;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure VerificarArquivoMenuSys;
const
  NomeArquivo = 'MENU.SYS';
var
  CaminhoArquivo: string;
begin
  // Obtém o caminho completo para o arquivo MENU.SYS
  CaminhoArquivo := ExtractFilePath(Application.ExeName) + NomeArquivo;

  // Verifica se o arquivo MENU.SYS existe
  if not FileExists(CaminhoArquivo) then
  begin
    // O arquivo não foi encontrado, exibe uma mensagem e fecha o programa
    ShowMessage('The file ' + NomeArquivo + ' was not found. PSIO Gamesharker is going to close now.');
    Application.Terminate;
  end;
end;

function DirectoryHasFilesOfType(const Diretorio: string; const TiposArquivo: array of string): Boolean;
var
  SearchRec: TSearchRec;
  TipoArquivo: string;
  I: Integer;
begin
  Result := False;
  for I := 0 to High(TiposArquivo) do
  begin
    TipoArquivo := TiposArquivo[I];
    if (FindFirst(Diretorio + '\*.' + TipoArquivo, faAnyFile, SearchRec) = 0)
      or (FindFirst(Diretorio + '\*.' + LowerCase(TipoArquivo), faAnyFile, SearchRec) = 0)
    then
    begin
      try
        repeat
        Result := True;
        Exit;
        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end;
    end;
  end;
end;


// ...

// Função principal para popular a ListBox1 com os subdiretórios
procedure PopularListBoxComSubdiretorios;
var
  SearchRec: TSearchRec;
  Caminho: string;
  TiposArquivoDesejados: array of string;
  I: Integer;
  TipoArquivo: string;
begin
  // Obtém o caminho do diretório onde o executável está
  Caminho := ExtractFilePath(Application.ExeName);

  // Limpa a Form1.ListBox1 antes de adicionarmos os subdiretórios
  Form1.ListBox1.Clear;

  // Define os tipos de arquivo desejados (IMG, BIN, ISO)
  SetLength(TiposArquivoDesejados, 3);
  TiposArquivoDesejados[0] := 'IMG';
  TiposArquivoDesejados[1] := 'BIN';
  TiposArquivoDesejados[2] := 'ISO';

  // Inicia a busca por subdiretórios
  if FindFirst(Caminho + '*.*', faDirectory, SearchRec) = 0 then
  begin
    try
      repeat
        // Ignora diretórios especiais ('.' e '..')
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          // Verifica se é um diretório
          if (SearchRec.Attr and faDirectory) = faDirectory then
          begin
            // Verifica se o diretório possui pelo menos um arquivo do tipo desejado
            if DirectoryHasFilesOfType(Caminho + SearchRec.Name, TiposArquivoDesejados) then
            begin
              // Adiciona o nome do subdiretório à Form1.ListBox1
              Form1.ListBox1.Items.Add(SearchRec.Name);
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;




procedure TForm1.FormCreate(Sender: TObject);
begin
Application.Icon.Assign(Icon);
VerificarArquivoMenuSys;
PopularListBoxComSubdiretorios;
end;

procedure CriarArquivoMultidisc(const Diretorio: string; const TiposArquivo: array of string);
var
  ArquivoMultidisc: TextFile;
  SearchRec: TSearchRec;
  NomeArquivo, CaminhoRelativo, CaminhoCompleto: string;
  I: Integer;
  PrimeiroArquivo: Boolean;
  DiretorioSelecionado: string;
begin
  AssignFile(ArquivoMultidisc, Diretorio + '\MULTIDISC.LST');
  try
    // Abre o arquivo em modo Rewrite para sobrescrever o conteúdo existente
    Rewrite(ArquivoMultidisc);

    PrimeiroArquivo := True;

    for I := Low(TiposArquivo) to High(TiposArquivo) do
    begin
      // Procura por arquivos com a extensão desejada
      if FindFirst(Diretorio + '\*.' + TiposArquivo[I], faAnyFile, SearchRec) = 0 then
      begin
        try
          repeat
            // Ignora diretórios especiais ('.' e '..') e apenas adiciona arquivos
            if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (SearchRec.Attr and faDirectory = 0) then
            begin
              NomeArquivo := SearchRec.Name;

              // Adiciona a quebra de linha antes do nome do arquivo, exceto para o primeiro arquivo
              if not PrimeiroArquivo then
                WriteLn(ArquivoMultidisc);

              // Adiciona apenas o nome do arquivo ao arquivo MULTIDISC.LST
              Write(ArquivoMultidisc, NomeArquivo);

              PrimeiroArquivo := False;
            end;
          until FindNext(SearchRec) <> 0;
        finally
          FindClose(SearchRec);
        end;
      end;
    end;

    // Adiciona uma linha final contendo o primeiro arquivo encontrado no diretório selecionado no ListBox1 com caminho relativo
    if Form1.ListBox1.ItemIndex >= 0 then
    begin

    if not PrimeiroArquivo then
                WriteLn(ArquivoMultidisc);

       for I := 0 to Form1.ListBox1.Items.Count - 1 do
       begin
        if Form1.ListBox1.Selected[I] then
        begin
          DiretorioSelecionado := Form1.ListBox1.Items[I];
          Break;
        end;
       end;

      // Procura pelo primeiro arquivo nas extensões permitidas no diretório selecionado
      for I := Low(TiposArquivo) to High(TiposArquivo) do
      begin
        if FindFirst(DiretorioSelecionado + '\*.' + TiposArquivo[I], faAnyFile, SearchRec) = 0 then
        begin
          try
            repeat
              // Ignora diretórios especiais ('.' e '..') e apenas adiciona arquivos
              if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (SearchRec.Attr and faDirectory = 0) then
              begin
                CaminhoCompleto := DiretorioSelecionado + '\' + SearchRec.Name;
                CaminhoRelativo := ExtractRelativePath(DiretorioSelecionado, CaminhoCompleto);

                // Substitui as barras invertidas por barras normais
                CaminhoRelativo := '/' + StringReplace(CaminhoRelativo, '\', '/', [rfReplaceAll]);

                // Adiciona o caminho relativo do primeiro arquivo ao arquivo MULTIDISC.LST
                Write(ArquivoMultidisc, CaminhoRelativo);
                Break;
              end;
            until FindNext(SearchRec) <> 0;
          finally
            FindClose(SearchRec);
          end;
        end;
      end;
    end;
  finally
    CloseFile(ArquivoMultidisc);
  end;
end;





procedure TForm1.Button1Click(Sender: TObject);
var
  Caminho: string;
  TiposArquivoDesejados: array of string;
  I: Integer;
  AlgumItemSelecionado: Boolean; // Variável para verificar se algum item está selecionado
begin
  // Obtém o caminho do diretório onde o executável está
  Caminho := ExtractFilePath(Application.ExeName);

  // Define os tipos de arquivo desejados (IMG, BIN, ISO) em maiúsculo e minúsculo
  SetLength(TiposArquivoDesejados, 6);
  TiposArquivoDesejados[0] := 'IMG';
  TiposArquivoDesejados[1] := 'BIN';
  TiposArquivoDesejados[2] := 'ISO';

  // Verifica se algum item está selecionado na ListBox1
  AlgumItemSelecionado := False;
  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    if ListBox1.Selected[I] then
    begin
      AlgumItemSelecionado := True;
      Break;
    end;
  end;

  // Se nenhum item estiver selecionado, exibe uma mensagem e sai da função
  if not AlgumItemSelecionado then
  begin
    ShowMessage('Select the folder where your GameShark image is.');
    Exit;
  end;

  // Itera sobre os itens selecionados da ListBox1
  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    // Cria o arquivo MULTIDISC.LST no diretório correspondente
    CriarArquivoMultidisc(Caminho + ListBox1.Items[I], TiposArquivoDesejados);
  end;

  ShowMessage('MULTIDISC.LST files created.');
end;






procedure TForm1.ListBox1Click(Sender: TObject);
var
  I: Integer;
begin
// Verifica se algum item está selecionado na ListBox1
  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    if ListBox1.Selected[I] then
    begin
      Button1.Enabled := true;
      Break;
    end;
  end;
end;

end.
