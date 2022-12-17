


unit space_invaders_module;


interface // ----------------------------------------------------
// Modulos
uses crt, dos;
// Parametros del programa
const WIDTH = 40; HEIGHT = 20;
// Tipos
type t_board = array[0..HEIGHT, 0..WIDTH] of char;
// Subprogramas
function gameThread():integer;
procedure printBoard(board:t_board);
procedure resetBoard(var board:t_board); 
function parseKey(input:integer; var i,j:integer):integer;



implementation // ----------------------------------------------------

// Leer inputs
function gameThread():integer;
var c:char; temp:integer;
begin
    c := ' ';
    temp := 0;
        if keypressed then begin 
            c := readkey();
            if c <> ' ' then temp := ord(c);
        end;

    gameThread := temp;
end;


// Imprimir el juego
procedure printBoard(board:t_board); // IDEA: Imprimir linea por linea en vez de caracter por caracter
var i,j:integer; buff:string;
begin

    for i:=0 to HEIGHT do begin
        buff := '';
        for j:=0 to WIDTH do
            buff:=buff+board[i,j];
        writeln(buff);
    end;
end;


// Borrar datos de la matriz del juego
procedure resetBoard(var board:t_board); 
var i,j:integer;
begin
    for i:=0 to HEIGHT do 
        for j:=0 to WIDTH do
            board[i,j] := ' ';
end;

// Evaluar accion en base a la tecla resionada
function parseKey(input:integer; var i,j:integer):integer; begin
    parseKey := 1; // Default flag 1: Keep running
    
    case input of

        3: parseKey := 0; // Exit with Ctrl+C
        75: if (j <> 0) then  j:=j-1;
        72: if (i <> 0) then  i:=i-1;
        80: if (i <> HEIGHT) then  i:=i+1;
        77: if (j <> WIDTH) then  j:=j+1;

    end;
end;
// --------------------------------------------------------------------------
end.