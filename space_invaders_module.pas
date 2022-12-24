

unit space_invaders_module;


interface // ============================================================[ INTERFACE ]>
// Modulos
uses crt, dos, keyboard;

// Parametros del programa
const
    WIDTH = 80;    // Board size
    HEIGHT = 10;
    PLAYER_W = 9; // Size of the player design
    PLAYER_H = 3;
    BORDER = 50;
    MAX_BULLETS = 100; // Maximum number of player bullets
    GAME_SPEED = 10; // En (milis): mas bajo = mas rapido
    CLOCK_RESET = 10000; // The max value the clock will reach before return to 0
    MAX_ENEMIES = 5;
    LEVEL = 1; // From 1 (easy) to 10 (hard)

// Tipos
type
    t_player = RECORD // Player object
        i,j, health, score:integer;
    end;
    t_bullet = RECORD // Bullet object
        // Direction takes (1=forward) or (-1=backwards)
        // Owner takes (1=player), (2=enemy)
        i,j, direction, owner:int8; 
        active:boolean; // Display or not
        design:char; // Graphics of the object
    end;
    t_bulletsData = RECORD // Bullets list object
        n:integer; // Number of bullets
        bulletsList:array[0..MAX_BULLETS] of t_bullet;
    end;
    t_enemy = RECORD // Enemy object
        i,j, health:integer;
        active:boolean;
        design:string[10];
    end;
    t_enemiesData = RECORD // Bullets list object
        n:integer; // Number of bullets
        enemiesList:array[0..MAX_ENEMIES] of t_enemy;
    end;
    t_board = array[0..HEIGHT, 0..WIDTH] of char;

// Subprogramas
function listenKeys():uint16;
procedure printBoard(board:t_board);
procedure updateBoard(var board:t_board; obj_bulletsData:t_bulletsData; obj_player:t_player; obj_enemiesData:t_enemiesData);
procedure resetBoard(var board:t_board);
procedure strPush(var board:t_board; i,j:integer; str:string);
procedure writePlayerPos(var board:t_board; i,j:integer);
procedure writeBullets(var board:t_board; obj_bulletsData:t_bulletsData);
procedure writeEnemies(var board:t_board; obj_enemiesData:t_enemiesData);
procedure playerShoot(var obj_bulletsData:t_bulletsData; obj_player:t_player);
procedure enemyShoot(var obj_bulletsData:t_bulletsData; obj_enemy:t_enemy);
procedure updateGameDynamics(clock:uint16; var obj_bulletsData:t_bulletsData; var obj_enemiesData:t_enemiesData);
procedure resetBullets(var obj_bulletsData:t_bulletsData);
procedure enemyEvents(clock:uint16; var obj_enemiesData:t_enemiesData);
procedure resetEnemies(var obj_enemiesData:t_enemiesData);
procedure checkHits(board:t_board; var obj_bulletsData:t_bulletsData; var obj_player:t_player; var obj_enemiesData:t_enemiesData); 

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
    write('+');
    for i:=0 to WIDTH do write('-');
    writeln('+');
    for i:=0 to HEIGHT do begin
        buff := '';
        for j:=0 to WIDTH do
            buff:=buff+board[i,j];
        writeln('|'+buff+'|');
    end;
    write('+');
    for i:=0 to WIDTH do write('-');
    writeln('+');


end;


// ----------------------------------------------------
procedure updateBoard(var board:t_board; obj_bulletsData:t_bulletsData; obj_player:t_player; obj_enemiesData:t_enemiesData); begin
    writeBullets(board, obj_bulletsData); // Write bullets possition to the board
    writePlayerPos(board, obj_player.i, obj_player.j); // Write player position to the board
    writeEnemies(board, obj_enemiesData); // Write player position to the board
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
        if j+x <= WIDTH then board[i,j+x] := str[x+1];
    end;
end;


// ----------------------------------------------------
procedure writePlayerPos(var board:t_board; i,j:integer); begin
    // Si se cambia el diseño, tambiend deben cambiarse PLAYER_H, PLAYER_W
    strPush(board, i,j,   '\   />');
    strPush(board, i+1,j, '=|=[#]==>');
    strPush(board, i+2,j, '/   \>');
end;


// ----------------------------------------------------
procedure writeBullets(var board:t_board; obj_bulletsData:t_bulletsData);
var x:integer;
begin
    for x:=0 to MAX_BULLETS do
        if obj_bulletsData.bulletsList[x].active then begin
            board[obj_bulletsData.bulletsList[x].i, obj_bulletsData.bulletsList[x].j] := obj_bulletsData.bulletsList[x].design;
        end;
end;


// ----------------------------------------------------
procedure writeEnemies(var board:t_board; obj_enemiesData:t_enemiesData);
var x:integer;
begin
    for x:=0 to MAX_ENEMIES do
        if obj_enemiesData.enemiesList[x].active then begin
            strPush(board, obj_enemiesData.enemiesList[x].i, obj_enemiesData.enemiesList[x].j, obj_enemiesData.enemiesList[x].design);
        end;
end;


// ----------------------------------------------------
procedure playerShoot(var obj_bulletsData:t_bulletsData; obj_player:t_player); begin
    if obj_bulletsData.n >= MAX_BULLETS then obj_bulletsData.n := 0;

    // Spawn 1 bullet relative to the player position
    obj_bulletsData.bulletsList[obj_bulletsData.n].i := obj_player.i+1;
    obj_bulletsData.bulletsList[obj_bulletsData.n].j := obj_player.j+PLAYER_W;
    obj_bulletsData.bulletsList[obj_bulletsData.n].active := true;
    obj_bulletsData.bulletsList[obj_bulletsData.n].design := '-';
    obj_bulletsData.bulletsList[obj_bulletsData.n].direction := 1;
    obj_bulletsData.bulletsList[obj_bulletsData.n].owner := 1;

    obj_bulletsData.n := obj_bulletsData.n + 1;
end;

// ----------------------------------------------------
procedure enemyShoot(var obj_bulletsData:t_bulletsData; obj_enemy:t_enemy); begin
    if obj_bulletsData.n >= MAX_BULLETS then obj_bulletsData.n := 0;

    // Spawn 1 bullet relative to the player position
    obj_bulletsData.bulletsList[obj_bulletsData.n].i := obj_enemy.i;
    obj_bulletsData.bulletsList[obj_bulletsData.n].j := obj_enemy.j-1;
    obj_bulletsData.bulletsList[obj_bulletsData.n].active := true;
    obj_bulletsData.bulletsList[obj_bulletsData.n].design := 'o';
    obj_bulletsData.bulletsList[obj_bulletsData.n].direction := -1;
    obj_bulletsData.bulletsList[obj_bulletsData.n].owner := 2;

    obj_bulletsData.n := obj_bulletsData.n + 1;
end;

// ----------------------------------------------------
procedure updateGameDynamics(clock:uint16; var obj_bulletsData:t_bulletsData; var obj_enemiesData:t_enemiesData);
var x:integer;
    shootRate:boolean;
begin

    // --- BULLETS ---
    // Forward bullets possition
    for x:=0 to MAX_BULLETS do begin
        if (obj_bulletsData.bulletsList[x].active = true) then begin // Move only active bullets

            // Disappear bullet when hit the edge
            if (obj_bulletsData.bulletsList[x].j <= 0) or (obj_bulletsData.bulletsList[x].j >= WIDTH) then
                obj_bulletsData.bulletsList[x].active := false;

            // Move bullet position
            obj_bulletsData.bulletsList[x].j := obj_bulletsData.bulletsList[x].j + obj_bulletsData.bulletsList[x].direction;
        end;
    end;

    // --- ENEMIES ---
    shootRate := (clock mod 10) = 0;
    for x:=0 to MAX_ENEMIES do begin
        if (obj_enemiesData.enemiesList[x].active = true) then begin 
            if ( shootRate and (random(11 - LEVEL)=0) ) then enemyShoot(obj_bulletsData, obj_enemiesData.enemiesList[x]);
        end;
    end;
end;


// ----------------------------------------------------
procedure enemyEvents(clock:uint16; var obj_enemiesData:t_enemiesData); begin
    if obj_enemiesData.n >= MAX_ENEMIES then obj_enemiesData.n := 0;


    if (clock mod 50 = 0) then begin // Spawn enemy
        obj_enemiesData.enemiesList[obj_enemiesData.n].active := true;
        obj_enemiesData.enemiesList[obj_enemiesData.n].i := random(HEIGHT-2)+1;
        obj_enemiesData.enemiesList[obj_enemiesData.n].j := BORDER + random(WIDTH-BORDER-5);
        obj_enemiesData.enemiesList[obj_enemiesData.n].design := '=(o)';

        obj_enemiesData.n := obj_enemiesData.n+1;
    end;
end;


// ----------------------------------------------------
procedure resetEnemies(var obj_enemiesData:t_enemiesData);
var x:integer;
begin
    for x:=0 to MAX_ENEMIES do begin
        obj_enemiesData.enemiesList[x].active := false;
    end;
end;


// ----------------------------------------------------
procedure checkHits(board:t_board; var obj_bulletsData:t_bulletsData; var obj_player:t_player; var obj_enemiesData:t_enemiesData); 
var x,k,pi,pj,bi,bj:integer;
begin

    pi := obj_player.i; // Shorthand for player possition
    pj := obj_player.j;

    for x:=0 to MAX_BULLETS do if obj_bulletsData.bulletsList[x].active then begin // Iter Active bullets

            // Shorthand for bullet possition
            bi := obj_bulletsData.bulletsList[x].i; 
            bj := obj_bulletsData.bulletsList[x].j;


            // Bullet hit enemy/player
            if (board[bi, bj] <> ' ') then begin 
                // Player hitted
                if pj+PLAYER_W >= bj then obj_player.health := obj_player.health-10
                // Enemy hitted
                else if (bj > BORDER) then begin
                    obj_player.score := obj_player.score+100;
                    for k:=0 to MAX_ENEMIES do
                        if obj_enemiesData.enemiesList[k].active then if (obj_enemiesData.enemiesList[k].i = bi) and (obj_enemiesData.enemiesList[k].j >= bj-1) then
                            obj_enemiesData.enemiesList[k].active := false;
                end;

                obj_bulletsData.bulletsList[x].active := false;
            end;

            if (
                (obj_bulletsData.bulletsList[x].owner = 1) and (board[bi,bj+1] = 'o') or
                (obj_bulletsData.bulletsList[x].owner = 2) and (board[bi,bj-1] = '-')
                ) then obj_bulletsData.bulletsList[x].active := false;
        end;
end;


// =========================================================================================
end.