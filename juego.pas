
uses crt, dos, space_invaders_module, keyboard;


// ------------------[ PARAMETROS DEL PROGRAMA ]----------------------------------------
const GAME_SPEED = 10; // En (milis): mas bajo = mas rapido

// ------------------[ VARIABLES GLOBALES ]----------------------------------------

var 
    input, gameThreadFlag:integer;
    // input --> Almacena los carateres presionados
    // gameThreadFlag --> Almacena un valor respectivo a la ejecucion del juego (0 = salir, otro = continuar)
    board:t_board; // Matrix de elementos del juego
    player_i, player_j:integer; // Coordenadas del jugador



//  --------------------------[ BEGIN ]-------------------------------------------------------
begin 
    // Program Config 
    InitKeyboard();
    cursoroff();
    gameThreadFlag := 1;
    player_i := 0;
    player_j := 0;
    resetBoard(board);
    printBoard(board);

    // --------------/ main loop /-------------------
    while gameThreadFlag <> 0 do begin
        
        // Leer caracter presionado en este instante
        input := listenKeys(); 

        // Que hacer cuando presionamos una tecla
        if input <> 0 then begin
            gameThreadFlag := parseKey(input, player_i, player_j);

            
        end;
        
        
        // Refresh game frame
        clrscr();
        resetBoard(board);
        writeln(' [i = ', player_i, '] [j = ', player_j,']'); // Header info
        board[player_i, player_j] := '#';  
        printBoard(board);

        // Game speed
        delay(GAME_SPEED);
    end;
    // -----------------/ end of main loop /----------------------

    clrscr();
    DoneKeyboard();
    writeln('Exiting the program...')

end.