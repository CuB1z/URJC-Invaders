unit program_menu;
    
interface
  
uses crt, sysutils, dos, game_main, space_invaders_module;
    
// ============================================ [ Constantes ] ===========================================
const
MAXJUEGOS = 40;
MAXUSERS = 1000;

CODIGO_NAVE = 'IP2JL8';

// ========================================== [ Tipos Variables ] ========================================
type

tNumJuegos = 1..MAXJUEGOS;

tJuego = record
nombre:string [30];
CodJuego:string[10];
Puntos:longint;
Partidas:longint;
end;

tSpaceInvaders = record
Nombre:string [30];
Puntos:longint;
Partidas:longint;
Tiempo:longint;
Kills:longint
end;

tArray = array [tNumJuegos] of tJuego;

tUser = record
usuario:string[50];
Pass:string[8];
Juegos:tArray;
end;

FichConsola = file of tUser;
FichDatos = file of tSpaceInvaders;

tArrayAUX = array [0..MAXUSERS] of tUser;
tArrayAUX_P = array [0..MAXUSERS] of tSpaceInvaders;

// ======================================= [ Definir Variables ] ===================================
var
  fichusers:FichConsola;
  fichdata:FichDatos;
  stats:t_stats;
  option:integer;
  loggeduser:string;
  logged:boolean;

//Subprogramas
procedure Menu (logged:boolean; loggeduser:string);
procedure Welcoming ();
procedure UserRegistry (var f:FichConsola);
procedure UserLogin (var f:FichConsola; var logged:boolean; var loggeduser:string);
procedure UserModify (loggeduser:string; var logged:boolean; var f:FichConsola);
procedure GameStart (logged:boolean; loggeduser:string; var f:FichConsola; var d:FichDatos);

function FileExistsF (var f:FichConsola):boolean;
function FileExistsD (var d:FichDatos):boolean;

implementation
// =========================================== [ Subprogramas ] ========================================

// -----------------------------------------[ Menu ]----------------------------------------------------
procedure Menu(logged:boolean; loggeduser:string);
begin
  clrscr;
  if logged then
    writeln('========== [ CONSOLA URJC ] ==========                                            Sesion: ',loggeduser)
  else
    writeln('========== [ CONSOLA URJC ] ==========                                            Sesion no iniciada');
  writeln('Registrar Usuario .................. 1');
  writeln('Iniciar Sesion ..................... 2');
  writeln('Modificar Usuario .................. 3');
  writeln('Cerrar Sesion ...................... 4');
  writeln('Iniciar Juego ...................... 5');
  writeln('Salir .............................. 6');
  writeln;
  writeln('Seleccione la opcion deseada: ');
end;

// ------------------------------------[ Cartel Bienvenida ]---------------------------------------------
procedure Welcoming();
begin
  writeln;
  writeln(' _______  ___   _______  __    _  __   __  _______  __    _  ___  ______   _______ ');
  writeln('|  _    ||   | |       ||  |  | ||  | |  ||       ||  |  | ||   ||      | |       |');
  writeln('| |_|   ||   | |    ___||   |_| ||  |_|  ||    ___||   |_| ||   ||  _    ||   _   |');
  writeln('|       ||   | |   |___ |       ||       ||   |___ |       ||   || | |   ||  | |  |');
  writeln('|  _   | |   | |    ___||  _    ||       ||    ___||  _    ||   || |_|   ||  |_|  |');
  writeln('| |_|   ||   | |   |___ | | |   | |     | |   |___ | | |   ||   ||       ||       |');
  writeln('|_______||___| |_______||_|  |__|  |___|  |_______||_|  |__||___||______| |_______|');
end;

// ---------------------------------[ Funcion Control Errores (F) ]--------------------------------------
function FileExistsF(var f:FichConsola):boolean;
begin
  {$I-}
  reset(f);
  {$I+}

  if ioresult = 0 then FileExistsF := true
  else FileExistsF := false;

end;

// ---------------------------------[ Funcion Control Errores (D) ]--------------------------------------
function FileExistsD(var d:FichDatos):boolean;
begin
  {$I-}
  reset(d);
  {$I+}

  if ioresult = 0 then FileExistsD := true
  else FileExistsD := false;

end;

// ---------------------------------[ Subprograma Registro de Usuario ]----------------------------------
procedure UserRegistry(var f:FichConsola);
var
  user:string[50]; password1,password2:string[8];
  condition:boolean;
  i,j,actualusers:integer;
  arrayAUX:tArrayAUX;
  myuser:tUser;
begin
  clrscr;

for i := 0 to MAXUSERS do
  arrayAUX[i].usuario := ' ';

  i := 0;

  if FileExistsF(f) then reset(f)
  else rewrite(f);

  while not eof(f) do
  begin
    read(f,myuser);
    arrayAUX[i].usuario:= myuser.usuario;
    i := i+1;
  end;

  actualusers := i;

  writeln('[ Registrar Usuario ]');

  // Usuario
  repeat
    condition := true;
    writeln;
    writeln('Usuario: ');
    readln(user);

    for j:= 0 to actualusers do
      if user = arrayAUX[j].usuario then condition := false;

    if condition = false then writeln('Usuario en uso, por favor escriba un usuario distinto.');
  until condition = true;

  myuser.usuario := user;

  // Password
  repeat
    writeln;
    writeln('Contrasena:');
    readln(password1);
    writeln;
    writeln('Repita la contrasena: ');
    readln(password2);
    if password1 <> password2 then
      writeln('La contrasena no coincide, por favor escribala de nuevo.');
  until password1 = password2;

  myuser.Pass := password1;

  seek(f,filesize(f));
  write(f,myuser);

  close(f);
end;

// ---------------------------------[ Subprograma Inicio de Sesion ]-----------------------------------
procedure UserLogin(var f:FichConsola; var logged:boolean; var loggeduser:string);
var
  user:string[50]; password:string[8];
  usercondition,passcondition:boolean;
  i,j,actualusers,posAUX:integer;
  arrayAUX:tArrayAUX;
  myuser:tUser;
begin
  clrscr;

for i := 0 to MAXUSERS do
begin
   arrayAUX[i].usuario := ' ';
   arrayAUX[i].Pass := ' ';
end;

  i := 0;

  if FileExistsF(f) then
  begin
    reset(f);
    while not eof(f) do
    begin
      read(f,myuser);
      arrayAUX[i].usuario := myuser.usuario;
      arrayAUX[i].Pass := myuser.Pass;
      i := i+1;
    end;

    actualusers := i;

    writeln('[ Acceso Usuario ]');
    //Usuario
    repeat
      usercondition := false;
      writeln;
      writeln('Usuario: ');
      readln(user);
      for j := 0 to actualusers do
      begin
        if user = arrayAUX[j].usuario then
        begin
          posAUX := j;
          usercondition := true;
        end;
      end;
      if usercondition = false then writeln('Usuario no encontrado');
    until usercondition = true;

    //Password
    repeat
      passcondition := false;
      writeln;
      writeln('Contrasena: ');
      readln(password);
      writeln;
      if password = arrayAUX[posAUX].Pass then passcondition := true
      else writeln('Contrasena incorrecta');
    until passcondition = true;

  end

  else
  begin
    writeln('No se reconoce / existe ningun archivo de usuarios.');
    writeln('Se ha creado un archivo nuevo.');
    rewrite(f);
    readln;
  end;

  close(f);

  if (passcondition = true) and (usercondition = true) then
  begin
    logged := true;
    loggeduser := user;
  end;

end;

// ---------------------------------[ Subprograma Modificar Usuario ]-----------------------------------
procedure UserModify(loggeduser:string; var logged:boolean; var f:FichConsola);
var
  user,approvement:string[50]; password1,password2:string[8];
  i,j,actualusers,posAUX,option:integer;
  arrayAUX:tArrayAUX;
  myuser:tUser;
begin
  clrscr;

  for i := 0 to MAXUSERS do
  begin
    arrayAUX[i].usuario := ' ';
    arrayAUX[i].Pass := ' ';
  end;

  i := 0;

  if FileExistsF(f) then
  begin
    reset(f);
    while not eof(f) do
    begin
      read(f,myuser);
      arrayAUX[i].usuario := myuser.usuario;
      arrayAUX[i].Pass := myuser.Pass;
      i := i+1;
    end;

    actualusers := i;

    for j := 0 to actualusers do
      if loggeduser = arrayAUX[j].usuario then
        posAUX := j;

    if logged then
    begin
    repeat
      clrscr;
      writeln('[ Modificar Usuario ]');
      writeln;
      writeln('Nombre de Usuario .............1');
      writeln('Contrasena ....................2');
      writeln('Guardar y Salir ...............3');
      writeln;
      writeln('Elija la opcion que desea modificar: ');
      readln(option);

      case option of
      1: begin
          repeat
            clrscr;
            writeln('Escriba el nuevo usuario:');
            readln(user);
            writeln;
            writeln('Escriba "CONFIRMAR" para terminar la accion / "CANCELAR" para no guardar los cambios:');
            readln(approvement);
            writeln;
          until (approvement = 'CONFIRMAR') or (approvement = 'CANCELAR');

          if approvement = 'CONFIRMAR' then arrayAUX[posAUX].usuario := user;
         end;

      2: begin
          repeat
            repeat
              clrscr;
              writeln('Escriba la nueva contrasena:');
              readln(password1);
              writeln('Repita la contrasena:');
              readln(password2);
              writeln;
              if password1 <> password2 then writeln('ERROR, las contrasenas no coinciden.');
            until password1 = password2;
            writeln('Escriba "CONFIRMAR" para terminar la accion / "CANCELAR" para no guardar los cambios:');
            readln(approvement);
            writeln;
          until (approvement = 'CONFIRMAR') or (approvement = 'CANCELAR');

          if approvement = 'CONFIRMAR' then arrayAUX[posAUX].Pass := password1;
         end;

      3: begin
          rewrite(f);
          for j := 0 to i do
          begin
            myuser.usuario := arrayAUX[j].usuario;
            myuser.Pass := arrayAUX[j].Pass;
            write(f,myuser);
            logged := false;
          end;
         end;

      end;

    until option = 3;
    end

    else
    begin
      clrscr;
      writeln('[ Modificar Usuario ]');
      writeln;
      writeln('Inicie sesion para modificar su usuario.');
      readln;
    end;

  end

  else
  begin
    writeln('No se reconoce / existe ningun archivo de usuarios.');
    writeln('Se ha creado un archivo nuevo.');
    rewrite(f);
    logged := false;
    readln;
  end;

end; 

//////////////////////////////////////////////// [ Subprograma Iniciar Juego ] //////////////////////////////////////////
procedure GameStart(logged:boolean; loggeduser:string; var f:FichConsola; var d:FichDatos);
var
  myuser:tUser; mydata:tSpaceInvaders;
  arrayAUX:tArrayAUX; arrayAUX_P:tArrayAUX_P;
  founduser,foundcode:boolean;
  i,j,option:integer;
  scoreAUX,newscore,timeAUX,newtime,killsAUX,newkills:longint;
  actualusers,gameusers,posAUX,posAUX_P,posAUX_Game:integer;
  year,month,day,wday:word;
  username,code,txtname:string[30]; line:string;
  userstats:text;
begin
  clrscr;

  founduser := false;
  foundcode := false;

  if logged then 
  begin
    if FileExistsD(d) then 
    begin
      reset(d);
      reset(f);

      //Inicializar arrays a 0
      for i := 0 to MAXUSERS do
        for j := 1 to MAXJUEGOS do
        begin
          arrayAUX[i].usuario := ' ';
          arrayAUX[i].Juegos[j].CodJuego := ' ';
          arrayAUX[i].Juegos[j].Puntos := 0;
          arrayAUX_P[i].Nombre := ' ';
          arrayAUX_P[i].Puntos := 0;
          arrayAUX_P[i].Partidas := 0;
          arrayAUX_P[i].Tiempo := 0;
          arrayAUX_P[i].Kills := 0;
        end;

      i := 0;

      ////////////////////////////////////////////// [ INICIO FICHERO F (consola) ] ///////////////////////////////////////

      //Guardar f en myuser, y myuser en array
      while not eof(f)do
      begin
        read(f,myuser);

        for j := 1 to MAXJUEGOS do
        begin
          arrayAUX[i].usuario := myuser.usuario;
          arrayAUX[i].Juegos[j].Puntos := myuser.Juegos[j].Puntos;
          arrayAUX[i].Juegos[j].CodJuego := myuser.Juegos[j].CodJuego;
        end;
        i := i+1;
      end;

      actualusers := i + 2;          // Nº de usuarios registrados en la consola (rango posible error [2] ) 

      //Encontrar posicion loggeduser en array 
      for j := 0 to actualusers do
        if loggeduser = arrayAUX[j].usuario then
          posAUX := j;

      i := 1;
      
      //Encontrar posicion del cod.juego en array Juegos 
      for i := 1 to MAXJUEGOS do
        if arrayAUX[posAUX].Juegos[i].CodJuego = CODIGO_NAVE then 
        begin 
          posAUX_Game := i;
          foundcode := true;
        end;

      i := 1;

      //Guardar el cod.juego y su posicion en array Juegos si no existe,     
      //Iniciar su puntuacion a 0                                               
      if foundcode = false then
      begin
        repeat
          code := arrayAUX[posAUX].Juegos[i].CodJuego;
          i := i+1;
        until code = ' ';

        posAUX_Game := i;
        foundcode := true;
        arrayAUX[posAUX].Juegos[posAUX_Game].CodJuego := CODIGO_NAVE;
        arrayAUX[posAUX].Juegos[posAUX_Game].Puntos := 0;

      end;
      /////////////////////////////////////////////////// [ FIN FICHERO F ] /////////////////////////////////////////////

      i := 0;

      ////////////////////////////////////////////// [ INICIO FICHERO D (juego) ] ///////////////////////////////////////

      //Guardar d en mydata, y mydata en array
      while not eof(d) do
      begin
        read(d,mydata);
          arrayAUX_P[i].Nombre   := mydata.Nombre;
          arrayAUX_P[i].Puntos   := mydata.Puntos;
          arrayAUX_P[i].Partidas := mydata.Partidas;
          arrayAUX_P[i].Tiempo   := mydata.Tiempo;
          arrayAUX_P[i].Kills    := mydata.Kills;
          i := i + 1;
      end;

      gameusers := i + 2;         // Nº de usuarios registrados en el juego (rango posible error [2] )

      //Encontrar posicion loggeduser en array 
      for j := 0 to gameusers do
        if loggeduser = arrayAUX_P[j].Nombre then
        begin
          posAUX_P := j;
          founduser := true;
        end;

      //Guardar el username y su posicion en array si no existe,     
      //Iniciar su estadisticas a 0                                               
      if founduser = false then
      begin
        i := 0;
        repeat
          username := arrayAUX_P[i].Nombre;
          i := i + 1;
        until username = ' ';

        posAUX_P := i;
        founduser := true;

        arrayAUX_P[posAUX_P].Nombre   := loggeduser;
        arrayAUX_P[posAUX_P].Puntos   := 0;
        arrayAUX_P[posAUX_P].Partidas := 0;
        arrayAUX_P[posAUX_P].Tiempo   := 0;
        arrayAUX_P[posAUX_P].Kills    := 0;
      end;

      /////////////////////////////////////////////////// [ FIN FICHERO D ] /////////////////////////////////////////////


      //////////////////////////////////////////////////// [ Menu juego ] ///////////////////////////////////////////////
      repeat
      clrscr;
      writeln('  __  _____     _______  ____                 __          ');
      writeln(' / / / / _ \__ / / ___/ /  _/__ _  _____ ____/ /__ _______');
      writeln('/ /_/ / , _/ // / /__  _/ // _ \ |/ / _ `/ _  / -_) __(_-<');
      writeln('\____/_/|_|\___/\___/ /___/_//_/___/\_,_/\_,_/\__/_/ /___/');
      writeln();
      writeln('Instrucciones ...................... 1');
      writeln('Estadisticas ....................... 2');
      writeln('Jugar .............................. 3');
      writeln('Salir .............................. 4');
      writeln;
      writeln('Seleccione la opcion deseada: ');
      readln(option);

      case option of
      1: begin
          clrscr;
          writeln('  ___   _  _   ___   _____   ___   _   _    ___    ___   ___    ___    _  _   ___   ___     ');
          writeln(' |_ _| | \| | / __| |_   _| | _ \ | | | |  / __|  / __| |_ _|  / _ \  | \| | | __| / __|    ');
          writeln('  | |  | .` | \__ \   | |   |   / | |_| | | (__  | (__   | |  | (_) | | .` | | _|  \__ \    ');
          writeln(' |___| |_|\_| |___/   |_|   |_|_\  \___/   \___|  \___| |___|  \___/  |_|\_| |___| |___/    ');
          writeln('');
          writeln('');
          writeln('------------------------------[BIENVENIDO A LAS INSTRUCCIONES DEL JUEGO]------------------------------------------');
          writeln('');
          writeln('Para jugar, es necesario crear un usuario mediante la opcion *registrar usuario*.');
          writeln('Una vez este creado el usuario, inicie sesion haciendo uso del nickname y de su password correspondiente.');
          writeln('Con el usuario creado y registrado, esta listo para jugar.');
          writeln('');
          writeln('------------------------------------------- [CONTROLES]-----------------------------------------------------------');
          writeln('');
          writeln('+ ARROWS para moverse por la pantalla.');
          writeln('+ SPACE  para disparar balas.');
          writeln('+  "P"   para pausar la partida.');
          writeln('+ Ctrl+C para salir del juego.');
          writeln('-------------------------------------[SISTEMA DE PUNTUACIONES]----------------------------------------------------');
          writeln('');
          writeln('Cada enemigo eliminado tiene un valor de 100 pts.');
          writeln('Nuestra nave cuenta con unos potentes escudos que suman 20 pts de vida.');
          writeln('Cada bala recibida nos resta 2 pts de vida.');
          readln;
         end;
      
      2: begin
          clrscr;

          //Crear txt con stats
          getdate(year,month,day,wday);
          txtname := concat(loggeduser,IntToStr(year),IntToStr(month),IntToStr(day),'.txt');
          assign(userstats,txtname);
          rewrite(userstats);

          //Escribir en pantalla y en txt stats
          writeln(' ___   ___   _____     _     ___    ___   ___   _____   ___    ___     _     ___ ');
          writeln('| __| / __| |_   _|   /_\   |   \  |_ _| / __| |_   _| |_ _|  / __|   /_\   / __|');
          writeln('| _|  \__ \   | |    / _ \  | |) |  | |  \__ \   | |    | |  | (__   / _ \  \__ \');
          writeln('|___| |___/   |_|   /_/ \_\ |___/  |___| |___/   |_|   |___|  \___| /_/ \_\ |___/');
          writeln();                                                        
          writeln('------------------------------------------------------------------------------------------------------');
          writeln();                                                        
          line := ('Estadisticas de ' + loggeduser);
          writeln(line);
          writeln(userstats,line);
          line := ' ';
          writeln(line);
          writeln(userstats,line);
          line := ('Partidas jugadas ....... ' + IntToStr(arrayAUX_P[posAUX_P].Partidas));
          writeln(line);
          writeln(userstats,line);
          line := ('Score maximo ........... ' + IntToStr(arrayAUX_P[posAUX_P].Puntos));
          writeln(line);
          writeln(userstats,line);
          line := ('Tiempo de juego ........ ' + IntToStr(arrayAUX_P[posAUX_P].Tiempo));
          writeln(line);
          writeln(userstats,line);
          line := ('Kills totales .......... ' + IntToStr(arrayAUX_P[posAUX_P].Kills));
          writeln(line);
          writeln(userstats,line);
          close(userstats);
          readln;
         end;

      3: begin

          play(stats);

          //Actualizar estadisticas usuario 
          scoreAUX := arrayAUX_P[posAUX_P].Puntos;
          newscore := stats.score;
          timeAUX  := arrayAUX_P[posAUX_P].Tiempo;
          newtime  := stats.timeAlive;
          killsAUX := arrayAUX_P[posAUX_P].Kills;
          newkills := stats.kills;

          //Actualizar Stats en (D)
          if newscore > scoreAUX then  arrayAUX_P[posAUX_P].Puntos := newscore;            // Score Update
          arrayAUX_P[posAUX_P].Partidas := arrayAUX_P[posAUX_P].Partidas + 1;              // Games Update
          arrayAUX_P[posAUX_P].Tiempo   := timeAUX + newtime;                              // Time Update
          arrayAUX_P[posAUX_P].Kills    := killsAUX + newkills;                            // Kills Update
      
          //Actualizar Puntos en (F)
          arrayAUX[posAUX].Juegos[posAUX_Game].Puntos := arrayAUX_P[posAUX_P].Puntos;      // Score Update
         end;
      end;

      until option = 4; 

 
      //Guardar estadisticas actualizadas en fichero (F) [fichero de la consola]
      rewrite(f);
      for i := 0 to actualusers do
      begin
        for j := 1 to  MAXJUEGOS do
        begin
          myuser.Juegos[j].nombre   := arrayAUX[i].Juegos[j].nombre;
          myuser.Juegos[j].Puntos   := arrayAUX[i].Juegos[j].Puntos;
          myuser.Juegos[j].CodJuego := arrayAUX[i].Juegos[j].CodJuego;
        end;
        write(f,myuser);
      end;

      //Guardar estadisticas actualizadas en fichero (D) [fichero del juego]
      rewrite(d);
      for i := 0 to gameusers do
      begin
        mydata.Nombre    := arrayAUX_P[i].nombre;
        mydata.Puntos    := arrayAUX_P[i].Puntos;
        mydata.Partidas  := arrayAUX_P[i].Partidas;
        mydata.Tiempo    := arrayAUX_P[i].Tiempo;
        mydata.Kills     := arrayAUX_P[i].Kills;
        write(d,mydata);
      end;

      close(f);
      close(d);

      //Mensaje despedida con estadisticas
    end

    else
    begin
      writeln('No se reconoce / existe ningun archivo de puntuaciones.');
      writeln('Se ha creado un archivo nuevo, inicie el juego de nuevo.');
      rewrite(d);
      readln;
    end;
  end

  else 
  begin
    writeln('ERROR, inicie sesion para jugar.');
    readln;
  end;

end;

    
end.