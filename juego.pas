
uses crt, space_invaders_module, keyboard;


// --------------------------------------------[ PARAMETROS DEL PROGRAMA ]>


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
    resetBullets(obj_bulletsData);
    resetEnemies(obj_enemiesData);
    printFrame();
    DoneKeyboard;
    readln;
    initKeyboard;
    printBoard(board, boardBackup);

    while gameThreadFlag <> 0 do begin
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
            end;
        end;
        
        // Refresh game frame
        clrscr();
        resetBoard(board);
        // Update board values
        updateBoard(board, obj_bulletsData, obj_player, obj_enemiesData);
        // Write frame
        writeln(' [i = ', obj_player.i, '] [j = ', obj_player.j,'] [Health = ', obj_player.health ,'] [Score = ', obj_player.score ,'] [CLOCK: ', clock:6, ']'); // Header info
        printBoard(board, boardBackup);

        // Handle enemy events
        enemyEvents(clock, obj_enemiesData);        
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

    clrscr;
    writeln;
    writeln('    +------------------------------------------------+');
    writeln('    +      FIN DEL JUEGO:          SCORE: ', obj_player.score:8 ,'   +');
    writeln('    +------------------------------------------------+');
    writeln;
    writeln('    Presione ENTER para continuar...');
    DoneKeyboard();
    readln;

    mainLoop := obj_player.score;
end;


//  ----------------------------------------------------[ ENTRY POINT ]>
begin 
    // Program Config 
    InitKeyboard();
    cursoroff();
    randomize();

    // Game main loop
    // score := mainLoop();
    mainLoop();

    // Exit from the program
    clrscr();
    cursoron;
    DoneKeyboard();
    writeln('Exiting the program...')

end.