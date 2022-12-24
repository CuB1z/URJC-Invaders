
uses crt;


const
    HEIGHT = 10;
    WIDTH = 20;
type 
    t_board = array[0..HEIGHT, 0..WIDTH] of char;
    t_boardInt = array[0..HEIGHT, 0..WIDTH] of integer;
var 
    board1, board2:t_board;
    board3:t_boardInt;
    i,j:integer;

procedure printBoard(b:t_board); var i,j:integer; begin
    for i:=0 to HEIGHT do begin
        for j:=0 to WIDTH do 
            write(b[i,j], ' ');
        writeln;
    end;
end;
procedure printBoard(b:t_boardInt); var i,j:integer; begin
    for i:=0 to HEIGHT do begin
        for j:=0 to WIDTH do 
            write(b[i,j], ' ');
        writeln;
    end;
end;

// ==============================================================================
// Return a board of integers (changes) where (0=no_change) (1=Changed)
// Diffs are from new related to old
procedure diffBoard(old, new:t_board; var changes:t_boardInt);
var i,j:integer;
begin
    for i:=0 to HEIGHT do
        for j:=0 to WIDTH do begin
            if new[i,j] <> old[i,j] then changes[i,j] := 1
            else changes[i,j] := 0;
        end;
end;
// ==============================================================================

begin

    // TEST CASES
    // Board1
    for i:=0 to HEIGHT do
        for j:=0 to WIDTH do 
            board1[i,j] := ' ';
    board1[2,4] := 'x';
    board1[6,1] := 'x';
    board1[9,7] := 'x';
    // Board2
    for i:=0 to HEIGHT do
        for j:=0 to WIDTH do 
            board2[i,j] := ' ';
    board2[2,4] := 'x';
    board2[1,5] := 'x';
    board2[2,6] := 'x';
    // -------------
    writeln('-------------------------------------------------');
    printBoard(board1);
    printBoard(board2);
    writeln('-------------------------------------------------');

    diffBoard(board1, board2, board3);
    printBoard(board3);
    // -------------
    // diffBoard();

end.