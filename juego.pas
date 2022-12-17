
uses crt, space_invaders_module, keyboard;


// --------------------------------------------[ PARAMETROS DEL PROGRAMA ]>
const GAME_SPEED = 10; // En (milis): mas bajo = mas rapido


// --------------------------------------------------[ FUNCION MAIN LOOP ]>
function mainLoop():integer; 
var
    input:uint16; // Almacena los carateres presionados
    gameThreadFlag:integer; // Almacena un valor respectivo a la ejecucion del juego (0 = salir, otro = continuar)
    board:t_board; // Matrix de elementos del juego
    obj_player:t_player; // Creamos un registro para el jugador
    obj_bulletsData:t_bulletsData; // Array de datos de las balas
begin
    // Initial setup
    gameThreadFlag := 1; // Set game flag to 1 (running)
    // Setup for player parameters
    obj_player.i := 0; 
    obj_player.j := 0;
    obj_player.health := 100;
    // Setup for bullet parameters
    obj_bulletsData.n := 0;
    // Reset the game to default values and print it
    resetBoard(board);
    resetBullets(obj_bulletsData);
    printBoard(board);

    while gameThreadFlag <> 0 do begin

        
        // Leer caracter presionado en este instante
        input := listenKeys(); 

        // Que hacer cuando presionamos una tecla
        if input <> 0 then begin
            case input of
                11779: gameThreadFlag := 0; // Exit with Ctrl+C
                65313: if (obj_player.i > 0) then  obj_player.i:=obj_player.i-1; // Flecha arriba
                65315: if (obj_player.j > 0) then  obj_player.j:=obj_player.j-1; // Flecha izqda
                65319: if (obj_player.i < HEIGHT-PLAYER_H) then  obj_player.i:=obj_player.i+1; // Flecha abajo
                65317: if (obj_player.j < WIDTH-PLAYER_W) then  obj_player.j:=obj_player.j+1; // Flecha decha
                14624: playerShoot(obj_bulletsData, obj_player); // Espacio
            end;
        end;
        
        // Refresh game frame
        clrscr();
        resetBoard(board);
        // Update board values
        updateBoard(board, obj_bulletsData, obj_player);
        // Write frame
        writeln(' [i = ', obj_player.i, '] [j = ', obj_player.j,'] []'); // Header info
        printBoard(board);
        
        // Update the possition of the dynamic objects of the game
        updateGameDynamics(obj_bulletsData);
        
        // Game speed
        delay(GAME_SPEED);
    end;
end;


//  ----------------------------------------------------[ ENTRY POINT ]>
begin 
    // Program Config 
    InitKeyboard();
    cursoroff();

    // Game main loop
    mainLoop();

    // Exit from the program
    clrscr();
    DoneKeyboard();
    cursoron;
    writeln('Exiting the program...')

end.