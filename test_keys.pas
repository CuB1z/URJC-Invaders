uses crt, keyboard;

var kbdEvent:TKeyEvent;
    kbdCode: word;

begin
    InitKeyboard();

    while true do BEGIN
        if pollKEyEvent <> 0 then begin
            kbdEvent := GetKeyEvent();
            kbdEvent := TranslateKeyEvent(kbdEvent);
            kbdCode := GetKeyEventCode(kbdEvent);

            while pollKEyEvent <> 0 do GetKeyEvent();

            writeln(kbdCode, ' ', pollKEyEvent());
            // writeln('K: ', readkey(), ' - P:', keypressed());
        end;
        // writeln('......');
        delay(100);
    end;

end.