
uses crt, windows, keyboard, space_invaders_module;

// --------------------------------------------------[ FUNCION MAIN LOOP ]>
function mainLoop():integer; 
var
    clock:uint16;
    input:uint16; // Almacena los carateres presionados
    gameThreadFlag:integer; // Almacena un valor respectivo a la ejecucion del juego (0 = salir, otro = continuar)
    board,boardBackup:t_board; // Matrix de elementos del juego y Matriz que guarda el ultimo estado del juego
    obj_player:t_player; // Creamos un registro para el jugador
    obj_bulletsData:t_bulletsData; // Array de datos de las balas
    obj_enemiesData:t_enemiesData;
begin

    // Initial setup
    gameThreadFlag := 1; // Set game flag to 1 (running)
    clock := 0;
    // Setup for player parameters
    obj_player.i := 0; 
    obj_player.j := 0;
    obj_player.health := 100;
    obj_player.score := 0;
    // Setup for game parameters
    obj_bulletsData.n := 0;
    obj_enemiesData.n := 0;
    // Reset the game to default values and print it
    resetBoard(board);
    boardBackup := board;
    resetBullets(obj_bulletsData);
    resetEnemies(obj_enemiesData);
    clrscr();
    writeln();
    printFrame();
    printBoard(board, boardBackup);

    while gameThreadFlag > 0 do begin
        // Save the current state of `board` in `boardBackup`
        boardBackup := board;

        // Leer caracter presionado en este instante
        input := listenKeys(); 

        // Que hacer cuando presionamos una tecla
        if input <> 0 then begin
            case input of
                11779: gameThreadFlag := 0; // Exit with Ctrl+C
                65313: if (obj_player.i > 0) then  obj_player.i := obj_player.i-1; // Flecha arriba
                65315: if (obj_player.j > 0) then  obj_player.j := obj_player.j-1; // Flecha izqda
                65319: if (obj_player.i < HEIGHT-PLAYER_H+1) then  obj_player.i := obj_player.i+1; // Flecha abajo
                65317: if (obj_player.j < BORDER-PLAYER_W) then  obj_player.j := obj_player.j+1; // Flecha decha
                14624: playerShoot(obj_bulletsData, obj_player); // Espacio
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
        // Write game headers
        gotoXY(1,1);
        writeln(' [i = ', obj_player.i, '] [j = ', obj_player.j,'] [Health = ', obj_player.health ,'] [Score = ', obj_player.score ,'] [CLOCK: ', clock:6, ']    '); // Header info
        
        // Print the game
        printBoard(board, boardBackup);

        // Update the possition of the dynamic objects of the game
        updateGameDynamics(clock, obj_bulletsData, obj_enemiesData);
        // Check hits
        checkHits(board, obj_bulletsData, obj_player, obj_enemiesData);
        // Game speed
        delay(GAME_SPEED);
        // Game clock
        clock := clock+1 mod CLOCK_RESET;
        // Lose condition
        if obj_player.health <= 0 then gameThreadFlag := 0;
    end;

    // Return value
    case gameThreadFlag of 
        0:  mainLoop := obj_player.score;
        -1: mainLoop := -1;
    end;

end;


function game():integer; 
begin

    // Initial banner
    SetConsoleOutputCP(CP_UTF8);
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
        game := mainLoop();   
    until (game <> -1);

    // Exit banner
    clrscr;
    writeln;
    writeln('    +------------------------------------------------+');
    writeln('    +      FIN DEL JUEGO:          SCORE: ', game:8 ,'   +');
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

//  ----------------------------------------------------[ ENTRY POINT ]>
begin 
    
    game();

end.