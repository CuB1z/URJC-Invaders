unit game_main;
    
interface // ===========================================================================================
        
uses crt, keyboard, space_invaders_module;

function mainLoop(var stats:t_stats):integer; 
function play(var stats:t_stats):integer; 
function play():integer; 


implementation // ======================================================================================


// --------------------------------------------------[ FUNCION MAIN LOOP ]>
function mainLoop(var stats:t_stats):integer; 
var
    clock:uint16;
    input:uint16; // Store the inputed characters
    gameThreadFlag:integer; // Store the respective value about the game workflow (0 = exit, 1 = continue, -1 = Play again)
    board,boardBackup:t_board; // Matrix of game elentes and backup
    obj_player:t_player; // Player related data
    obj_bulletsData:t_bulletsData; // Array bullets related data
    obj_enemiesData:t_enemiesData; // Enemies related data
begin

    // Initial setup
    gameThreadFlag := 1; // Set game flag to 1 (running)
    clock := 0;
    // Setup for player parameters
    obj_player.i := 1; 
    obj_player.j := 1;
    obj_player.health := 100;
    obj_player.score := 0;
    // Setup for game parameters
    obj_bulletsData.n := 0;
    obj_enemiesData.n := 0;
    // Stats initialization
    stats.timeAlive := 0;
    stats.kills := 0;
    stats.score := 0;
    // Reset the game to default values and print it
    resetBoard(board);
    boardBackup := board;
    resetBullets(obj_bulletsData);
    resetEnemies(obj_enemiesData);
    clrscr();
    writeln();
    printFrame();
    printBoard(board, boardBackup, obj_player, clock);

    while gameThreadFlag > 0 do begin
        // Save the current state of `board` in `boardBackup`
        boardBackup := board;

        // Read characters if anyone is pressed
        input := listenKeys(); 

        // Select what to do with the user input
        if input <> 0 then begin
            case input of
                11779: gameThreadFlag := 0; // Exit with Ctrl+C
                65313: if (obj_player.i > 0) then  obj_player.i := obj_player.i-1; // Flecha arriba
                65315: if (obj_player.j > 0) then  obj_player.j := obj_player.j-1; // Flecha izqda
                65319: if (obj_player.i < HEIGHT-PLAYER_H+1) then  obj_player.i := obj_player.i+1; // Flecha abajo
                65317: if (obj_player.j < BORDER-PLAYER_W) then  obj_player.j := obj_player.j+1; // Flecha decha
                14624: begin // Espacio
                            playerShoot(obj_bulletsData, obj_player); 
                            stats.shoots := stats.shoots+1; 
                        end;
                6512: begin // (P)ause
                            case pauseGame() of
                                2: gameThreadFlag := -1; // Restart
                                3: gameThreadFlag := 0; // Exit
                            end;
                            resetScreen(boardBackup);
                        end; 
            end;
        end;
        
        // Refresh game frame
        resetBoard(board);
        // Update board values
        updateBoard(board, obj_bulletsData, obj_player, obj_enemiesData);
        // Write headers (debug)
        // gotoXY(1,1);
        // writeln(' [i = ', obj_player.i, '] [j = ', obj_player.j,'] [Health = ', obj_player.health ,'] [Score = ', obj_player.score ,'] [CLOCK: ', clock:6, ']    '); 
        
        // Print the game
        printBoard(board, boardBackup, obj_player, clock);

        // Update the possition of the dynamic objects of the game
        updateGameDynamics(clock, obj_bulletsData, obj_enemiesData);
        // Check hits (update stats)
        stats.kills := stats.kills + checkHits(board, obj_bulletsData, obj_player, obj_enemiesData);
        // Game speed
        delay(GAME_SPEED);
        // Game clock
        clock := clock+1 mod CLOCK_RESET;
        if (clock mod (700 div GAME_SPEED) = 0) then stats.timeAlive := stats.timeAlive+1; // Time alive updates every 700ms + 300ms (aprox. for program operations)
        // Lose condition
        if obj_player.health <= 0 then gameThreadFlag := 0;

    end;

    stats.score := obj_player.score; // (Stats)

    // Return value
    case gameThreadFlag of 
        0:  mainLoop := obj_player.score;
        -1: mainLoop := -1;
    end;

end;


function play(var stats:t_stats):integer; 
begin

    // Initial banner
    clrscr();
    writeln();
    writeln('      __  _____     _______  ____                 __          ');
    writeln('     / / / / _ \__ / / ___/ /  _/__ _  _____ ____/ /__ _______');
    writeln('    / /_/ / , _/ // / /__  _/ // _ \ |/ / _ `/ _  / -_) __(_-<');
    writeln('    \____/_/|_|\___/\___/ /___/_//_/___/\_,_/\_,_/\__/_/ /___/');
    writeln();
    writeln('    #====================[ HOW TO PLAY ]====================#');
    writeln();
    writeln('     *** Shoot the enemies to get points and dont get hit ***');
    writeln();
    writeln('       + MOVEMENT: Use the arrows to move your character');
    writeln('       + SHOOT: Press SPACE to shoot!');
    writeln('       + PAUSE: Press "p" to pause the game');
    writeln('       + EXIT: Press CTRL+C to exit the game');
    writeln();
    writeln();
    write('    >>> Press ENTER to start...');
    readln();
    // Program Config 
    InitKeyboard();
    cursoroff();
    randomize();

    // Game main loop
    repeat
        play := mainLoop(stats);   
    until (play <> -1);

    // Exit banner
    clrscr;
    writeln;
    writeln('    +------------------------------------------------+');
    writeln('    +      FIN DEL JUEGO:          SCORE: ', play:8 ,'   +');
    writeln('    +------------------------------------------------+');
    writeln;
    writeln('    Presione ENTER para continuar...');
    DoneKeyboard();
    readln;

    // Clearing settings before exiting from the program
    clrscr();
    cursoron;
    DoneKeyboard();
    writeln('Exiting the program...');
end;

// Overload the play function to allow skipping parameters
function play():integer; 
var stats:t_stats;
begin
    play := play(stats);
end;


end.