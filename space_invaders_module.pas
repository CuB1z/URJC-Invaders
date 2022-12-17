


unit space_invaders_module;


interface // ============================================================[ INTERFACE ]>
// Modulos
uses crt, dos, keyboard;

// Parametros del programa
const 
    WIDTH = 50;    // Board size
    HEIGHT = 10;
    PLAYER_W = 11; // Size of the player design
    PLAYER_H = 3;
    MAX_BULLETS = 20; // Maximum number of bullets

// Tipos
type 
    t_player = RECORD
        i,j, health:integer;
    end;
    t_bullet = RECORD
        i,j, damage:integer;
        active:boolean;
    end;
    t_bulletsData = RECORD
        n:integer; // Number of bullets
        bulletsList:array[0..MAX_BULLETS] of t_bullet;
    end;
    t_board = array[0..HEIGHT, 0..WIDTH] of char;

// Subprogramas
function listenKeys():uint16;
procedure printBoard(board:t_board);
procedure updateBoard(var board:t_board; obj_bulletsData:t_bulletsData; obj_player:t_player);
procedure resetBoard(var board:t_board); 
procedure strPush(var board:t_board; i,j:integer; str:string);
procedure writePlayerPos(var board:t_board; i,j:integer);
procedure playerShoot(var obj_bulletsData:t_bulletsData; obj_player:t_player);
procedure writeBullets(var board:t_board; obj_bulletsData:t_bulletsData);
procedure updateGameDynamics(var obj_bulletsData:t_bulletsData);
procedure resetBullets(var obj_bulletsData:t_bulletsData);

implementation // ============================================================[ IMPLEMENTATION ]>

// ----------------------------------------------------
// Leer inputs
function listenKeys():uint16;
var kbdEvent:TKeyEvent; kbdCode: word;
begin
    listenKeys := 0;
    if PollKeyEvent <> 0 then begin
        kbdEvent := GetKeyEvent();
        kbdEvent := TranslateKeyEvent(kbdEvent);
        kbdCode := GetKeyEventCode(kbdEvent);

        // Clean buffer
        while PollKeyEvent <> 0 do GetKeyEvent();

        listenKeys := kbdCode;
    end;
end;


// ----------------------------------------------------
// Imprimir el juego
procedure printBoard(board:t_board); 
var i,j:integer; buff:string;
begin

    // Print game matrix
    for i:=0 to HEIGHT do begin
        buff := '';
        for j:=0 to WIDTH do
            buff:=buff+board[i,j];
        writeln(buff);
    end;

end;


// ----------------------------------------------------
procedure updateBoard(var board:t_board; obj_bulletsData:t_bulletsData; obj_player:t_player); begin
    writeBullets(board, obj_bulletsData); // Write bullets possition to the board
    writePlayerPos(board, obj_player.i, obj_player.j); // Write player position to the board
end;


// ----------------------------------------------------
// Borrar datos de la matriz del juego
procedure resetBoard(var board:t_board); 
var i,j:integer;
begin
    for i:=0 to HEIGHT do 
        for j:=0 to WIDTH do
            board[i,j] := ' ';
end;


// ----------------------------------------------------
procedure resetBullets(var obj_bulletsData:t_bulletsData); 
var x:integer;
begin
    for x:=0 to MAX_BULLETS do begin
        obj_bulletsData.bulletsList[x].active := false;
    end;
end;


// ----------------------------------------------------
procedure strPush(var board:t_board; i,j:integer; str:string);
var x,n:integer;
begin
    n := length(str);
    for x:=0 to n-1 do begin
        board[i,j+x] := str[x+1];
    end;
end;


// ----------------------------------------------------
procedure writePlayerPos(var board:t_board; i,j:integer); begin
    // Si se cambia el diseño, tambiend deben cambiarse PLAYER_H, PLAYER_W
    strPush(board, i,j,   '\   />');
    strPush(board, i+1,j, '=|==[#]===>');
    strPush(board, i+2,j, '/   \>');
end;


// ----------------------------------------------------
procedure writeBullets(var board:t_board; obj_bulletsData:t_bulletsData); 
var x:integer;
begin
    for x:=0 to MAX_BULLETS do 
        if obj_bulletsData.bulletsList[x].active then begin
            // board[1, x] := '-';
            board[obj_bulletsData.bulletsList[x].i, obj_bulletsData.bulletsList[x].j] := '-';
            
        end;
end;


// ----------------------------------------------------
procedure playerShoot(var obj_bulletsData:t_bulletsData; obj_player:t_player); begin
    if obj_bulletsData.n >= MAX_BULLETS then obj_bulletsData.n := 0;

    // Spawn 1 bullet relative to the player position
    obj_bulletsData.bulletsList[obj_bulletsData.n].i := obj_player.i+1;
    obj_bulletsData.bulletsList[obj_bulletsData.n].j := obj_player.j+PLAYER_W;
    obj_bulletsData.bulletsList[obj_bulletsData.n].active := true;

    obj_bulletsData.n := obj_bulletsData.n + 1;
end;


// ----------------------------------------------------
procedure updateGameDynamics(var obj_bulletsData:t_bulletsData); 
var x:integer;
begin

    // Forward bullets possition
    for x:=0 to MAX_BULLETS do begin
        if obj_bulletsData.bulletsList[x].j >= WIDTH then
            obj_bulletsData.bulletsList[x].active := false; 
        obj_bulletsData.bulletsList[x].j := obj_bulletsData.bulletsList[x].j + 1;
    end;
end;



// =========================================================================================
end.