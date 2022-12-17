
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
begin
    // Initial setup
    gameThreadFlag := 1;
    obj_player.i := 0;
    obj_player.j := 0;
    resetBoard(board);
    printBoard(board);

    while gameThreadFlag <> 0 do begin
        
        // Leer caracter presionado en este instante
        input := listenKeys(); 

        // Que hacer cuando presionamos una tecla
        if input <> 0 then begin
            gameThreadFlag := parseKey(input, obj_player.i, obj_player.j);
    
        end;
        
        
        // Refresh game frame
        clrscr();
        resetBoard(board);
        writeln(' [i = ', obj_player.i, '] [j = ', obj_player.j,']'); // Header info
        setPlayerPos(board, obj_player.i, obj_player.j);  
        printBoard(board);

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