

unit space_invaders_module;


interface // ============================================================[ INTERFACE ]>
// Modules
uses crt, dos, keyboard;

// Program parameters
const
    WIDTH = 80;    // Board size
    HEIGHT = 12;
    PLAYER_W = 9; // Size of the player design
    PLAYER_H = 3;
    BORDER = 50;
    MAX_BULLETS = 100; // Maximum number of player bullets
    GAME_SPEED = 50; // Main loop dalay (millis): "lower nums." = "faster game"
    CLOCK_RESET = 10000; // The max value the clock will reach before return to 0
    MAX_ENEMIES = 5;
    LEVEL = 1; // From 1 (easy) to 10 (hard)

// Program Types
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
    t_boardInt = array[0..HEIGHT, 0..WIDTH] of integer;

// Subprogramas
function listenKeys():uint16;
procedure printBoard(board,backup:t_board; obj_player:t_player; clock:uint16);
procedure printFrame();
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
procedure enemyEvents(clock:uint16; var obj_enemiesData:t_enemiesData; var obj_bulletsData:t_bulletsData);
procedure resetEnemies(var obj_enemiesData:t_enemiesData);
procedure checkHits(board:t_board; var obj_bulletsData:t_bulletsData; var obj_player:t_player; var obj_enemiesData:t_enemiesData); 
procedure diffBoard(old, new:t_board; var changes:t_boardInt);
function pauseGame():integer;
procedure resetScreen(var board:t_board);
procedure printGameStats(obj_player:t_player; clock:uint16);



implementation // ============================================================[ IMPLEMENTATION ]>

// ----------------------------------------------------
// Read inputs without blocking the program workflow
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
// Print the game interface
procedure printBoard(board,backup:t_board; obj_player:t_player; clock:uint16);
var i,j:integer; changes:t_boardInt;
begin

    diffBoard(backup, board, changes);

    // Print game matrix
    for i:=0 to HEIGHT do
        for j:=0 to WIDTH do 
            if (changes[i,j] = 1) then begin
                gotoXY(j+2,i+3); // Moving keeping in mind the offset genereated by the game stats (header)
                if ord(board[i,j]) > 30 then write(board[i,j])
                else write(' ');
            end;
            
    printGameStats(obj_player, clock);

end;


// ----------------------------------------------------
// Print just external frame of the game
procedure printFrame();
var i:integer;
begin
    write('+');
    for i:=0 to WIDTH do write('-');
    writeln('+');

    for i:=0 to HEIGHT do begin
        writeln('|',' ':WIDTH+1, '|');
    end;

    write('+');
    for i:=0 to WIDTH do write('-');
    writeln('+');
end;


// ----------------------------------------------------
// sync the board data with the possitions of all the game elements
procedure updateBoard(var board:t_board; obj_bulletsData:t_bulletsData; obj_player:t_player; obj_enemiesData:t_enemiesData); begin
    writeBullets(board, obj_bulletsData); // Write bullets possition to the board
    writePlayerPos(board, obj_player.i, obj_player.j); // Write player position to the board
    writeEnemies(board, obj_enemiesData); // Write player position to the board
end;


// ----------------------------------------------------
// Set all the elements to space characters
procedure resetBoard(var board:t_board);
var i,j:integer;
begin
    for i:=0 to HEIGHT do
        for j:=0 to WIDTH do
            board[i,j] := ' ';
end;


// ----------------------------------------------------
// Set all the bullets to inactive
procedure resetBullets(var obj_bulletsData:t_bulletsData);
var x:integer;
begin
    for x:=0 to MAX_BULLETS do begin
        obj_bulletsData.bulletsList[x].active := false;
    end;
end;


// ----------------------------------------------------
// Writes a string character by character in a matrix
procedure strPush(var board:t_board; i,j:integer; str:string);
var x,n:integer;
begin
    n := length(str);
    for x:=0 to n-1 do begin
        if j+x <= WIDTH then board[i,j+x] := str[x+1];
    end;
end;


// ----------------------------------------------------
// Write the player possition in the board matrix
procedure writePlayerPos(var board:t_board; i,j:integer); begin
    // PLAYER_H, PLAYER_W must be changes if the design is changed
    strPush(board, i,j,   '\   />');
    strPush(board, i+1,j, '=|=[#]==>');
    strPush(board, i+2,j, '/   \>');
end;


// ----------------------------------------------------
// Write all the active bullets in the board matrix
procedure writeBullets(var board:t_board; obj_bulletsData:t_bulletsData);
var x:integer;
begin
    for x:=0 to MAX_BULLETS do
        if obj_bulletsData.bulletsList[x].active then begin
            board[obj_bulletsData.bulletsList[x].i, obj_bulletsData.bulletsList[x].j] := obj_bulletsData.bulletsList[x].design;
        end;
end;


// ----------------------------------------------------
// Write all the active enemies in the board matrix
procedure writeEnemies(var board:t_board; obj_enemiesData:t_enemiesData);
var x:integer;
begin
    for x:=0 to MAX_ENEMIES do
        if obj_enemiesData.enemiesList[x].active then begin
            // Enemies are written with the literal ascii value before them as the first character
            strPush(board, obj_enemiesData.enemiesList[x].i, obj_enemiesData.enemiesList[x].j, chr(x)+obj_enemiesData.enemiesList[x].design);
        end;
end;


// ----------------------------------------------------
// Create a bullet shoot by the player with the corresponding parameters
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
// Create a bullet shoot by an enemy with the corresponding parameters
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
// Update the possitions of the objects that pretend to be moving (bullets)
procedure updateGameDynamics(clock:uint16; var obj_bulletsData:t_bulletsData; var obj_enemiesData:t_enemiesData);
var x:integer;
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
    enemyEvents(clock, obj_enemiesData, obj_bulletsData);        

end;


// ----------------------------------------------------
// Manage enemy spawns and shooting rate
procedure enemyEvents(clock:uint16; var obj_enemiesData:t_enemiesData; var obj_bulletsData:t_bulletsData); 
var 
    x:integer;
    shootRate:boolean;
begin
    if obj_enemiesData.n >= MAX_ENEMIES then obj_enemiesData.n := 0; // Reset enemies counter

    if (clock mod 50 = 0) then begin // Spawn enemy
        obj_enemiesData.enemiesList[obj_enemiesData.n].active := true;
        obj_enemiesData.enemiesList[obj_enemiesData.n].i := random(HEIGHT-2)+1;
        obj_enemiesData.enemiesList[obj_enemiesData.n].j := BORDER + random(WIDTH-BORDER-5);
        obj_enemiesData.enemiesList[obj_enemiesData.n].design := '=(o)';

        obj_enemiesData.n := obj_enemiesData.n+1;
    end;

    shootRate := (clock mod 10) = 0; // Enemy shoots
    for x:=0 to MAX_ENEMIES do begin
        if (obj_enemiesData.enemiesList[x].active = true) then begin 
            if ( shootRate and (random(11 - LEVEL)=0) ) then enemyShoot(obj_bulletsData, obj_enemiesData.enemiesList[x]);
        end;
    end;

end;


// ----------------------------------------------------
// Set all the enemies to inactive
procedure resetEnemies(var obj_enemiesData:t_enemiesData);
var x:integer;
begin
    for x:=0 to MAX_ENEMIES do begin
        obj_enemiesData.enemiesList[x].active := false;
    end;
end;


// ----------------------------------------------------
// Check if some bullet is colliding or about to collide with something
procedure checkHits(board:t_board; var obj_bulletsData:t_bulletsData; var obj_player:t_player; var obj_enemiesData:t_enemiesData); 
var x,pj,bi,bj:integer;
begin

    pj := obj_player.j; // Shorthand for player possition "j"

    for x:=0 to MAX_BULLETS do if obj_bulletsData.bulletsList[x].active then begin // Iter Active bullets

            // Shorthand for bullet possition
            bi := obj_bulletsData.bulletsList[x].i; 
            bj := obj_bulletsData.bulletsList[x].j;


            // Bullet hit enemy/player
            if ((board[bi, bj] <> ' ') and (ord(board[bi,bj]) > 30)) then begin 
                // Player hitted
                if pj+PLAYER_W >= bj then obj_player.health := obj_player.health-10
                // Enemy hitted
                else if (bj > BORDER) then begin
                    obj_player.score := obj_player.score+100;
                    // Detect the value before the enemy to know the enemy index in the array
                    obj_enemiesData.enemiesList[ord(board[bi,bj-1])].active := false;
                end;

                obj_bulletsData.bulletsList[x].active := false;
            end;

            // Check bullet collision with bullets
            if (
                (obj_bulletsData.bulletsList[x].owner = 1) and (board[bi,bj+1] = 'o') or
                (obj_bulletsData.bulletsList[x].owner = 2) and (board[bi,bj-1] = '-')
                ) then obj_bulletsData.bulletsList[x].active := false;
        end;
end;


// ----------------------------------------------------
// Compare two matrix and return a matrix of 1's & 0's to mark differences between them
procedure diffBoard(old, new:t_board; var changes:t_boardInt);
var i,j:integer;
begin
    for i:=0 to HEIGHT do
        for j:=0 to WIDTH do begin
            if new[i,j] <> old[i,j] then changes[i,j] := 1
            else changes[i,j] := 0;
        end;
end;


// ----------------------------------------------------
// Manage PAUSE menu
function pauseGame():integer; 
var tmp:uint16; selected:integer;
const MENU_OFFSET_X = 20; MENU_OFFSET_Y = 3; MAX_OPTS = 4;
begin
    selected := 1;
    tmp := 0;

    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+1); write('#=========================================#');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+2); write('#              GAME PAUSED                #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+3); write('#              -----------                #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+4); write('#                                         #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+5); write('#            > RESUME                     #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+6); write('#              RESTART                    #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+7); write('#              EXIT                       #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+8); write('#                                         #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+9); write('#  (use the ARROWS and ENTER to navigate) #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+10);write('#          (Press "p" to resume)          #');
    gotoXY(MENU_OFFSET_X, MENU_OFFSET_Y+11);write('#=========================================#');
    
    while (tmp <> 7181) and (tmp <> 6512) do begin
        tmp := listenKeys();

        if tmp <> 0 then begin            
            gotoXY(MENU_OFFSET_X+13, MENU_OFFSET_Y+4+selected);
            write(' ');

            // Option navigation
            case tmp of 
                65313: if (selected > 1) then selected := selected-1; // Flecha arriba
                65319: if (selected < MAX_OPTS) then selected := selected+1; // Flecha arriba
            end;

            gotoXY(MENU_OFFSET_X+13, MENU_OFFSET_Y+4+selected);
            write('>');

        end;
    end;

    if tmp = 6512 then pauseGame := 1 // Pressed "p"
    else pauseGame := selected;

end;


// ----------------------------------------------------
// Clear and rewrite the whole interface
procedure resetScreen(var board:t_board);
begin
    resetBoard(board);
    clrscr();
    gotoXY(1,2);
    printFrame();
end;


// ----------------------------------------------------
// Print the bottom part of the interface with the health and the score
procedure printGameStats(obj_player:t_player; clock:uint16); 
var i:integer; healthStr:string;
begin
    healthStr := ' ';
    gotoXY(1,HEIGHT+5);
    for i:=1 to (obj_player.health*2 div 10) do healthStr := healthStr + '#';

    write('|',' HEALTH: ', healthStr, '          ');
    gotoXY(33, HEIGHT+5);
    write('| SCORE: ', obj_player.score:10, ' | TIME ALIVE: ', clock*GAME_SPEED div 700); // Not accurate time due to operations delay
    gotoXY(WIDTH+3, HEIGHT+5);
    writeln('|');

    write('+');
    for i:=0 to WIDTH do write('-');
    writeln('+');

end;



// =========================================================================================
end.