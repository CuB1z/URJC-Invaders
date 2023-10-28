{Autor 1: Jaime Portillo   }
{Autor 2: Diego Sánchez    }
{Autor 3: Daniel Santos    }

{Grado en Ingenieria del Software}

{Objetivo del programa:
  Crear una consola que trabaje con usuarios y contraseñas, los cuales se guardan permanentemente en un fichero de usuarios.
  Ademas de crear un juego ('URJC INVADERS') que genera unas estadisticas del jugador.
  Estas estadisticas se guardan en un archivo de texto con el formato ('usuario + año + mes + dia + .txt')
}

{Datos de entrada: Fichero ('fichusers' / 'users.dat' ) --> Datos genericos de los usuarios registrados en Consola_URJC.    }
{Datos de entrada: Fichero ('fichdata'  / 'IP2JL9.dat') --> Datos especificos de los usuarios registrados en URJC INVADERS. }

{Datos de salida: Fichero ('userstats' / 'user + fecha.txt') --> Archivo de texto que ofrece las estadisticas del usuario. }

program Consola_URJC;

uses crt, menuprograma;

// ============================================ [ Programa Principal ] ========================================
begin
assign(fichusers, 'users.dat');
assign(fichdata, 'IP2JL8.dat');
logged := false;

Welcoming;
writeln;
writeln('PRESIONE <ENTER> PARA COMENZAR');
readln;

repeat
  Menu(logged,loggeduser);
  readln(option);

  case option of
    1:UserRegistry(fichusers);
    2:UserLogin(fichusers,logged,loggeduser);
    3:UserModify(loggeduser,logged, fichusers);
    4:logged := false;
    5:GameStart(logged,loggeduser,fichusers,fichdata);
  end;
until option = 6;
end.

