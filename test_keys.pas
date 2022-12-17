uses crt;

var c:char;
    temp:integer;

begin 

    while true do begin
        c := ' ';
        temp := 0;
        if keypressed then begin 
            c := readkey();
            if c <> ' ' then temp := ord(c);
        end;

        if temp <> 0 then writeln('Code: ', temp);
    end;
end.