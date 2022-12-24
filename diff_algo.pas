
uses crt;


const
    HEIGHT = 10;
    WIDTH = 20;
type 
    t_board = array[0..HEIGHT, 0..WIDTH] of char;
    t_boardInts = array[0..HEIGHT, 0..WIDTH] of integer;
var 
    board1, board2:t_board;
    i,j:integer;

procedure printBoard(b:t_board); var i,j:integer; begin
    for i:=0 to HEIGHT do begin
        for j:=0 to WIDTH do 
            write(b[i,j] + ' ');
        writeln;
    end;
end;

// ==============================================================================
// Return a board of integers (changes) where (0=no_change) (N=Sucesive_chars_changed)
// Diffs are from new related to old
procedure diffBoard(old, new:t_board; var changes:t_boardInts);
var i,j,tmp:integer;
begin
    for i:=0 to HEIGHT do
        for j:=0 to WIDTH do begin
            if new[i,j] <> old[i,j] then changes[i,j]
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
    board2[6,1] := 'x';
    board2[9,7] := 'x';
    // -------------
    writeln('-------------------------------------------------');
    printBoard(board1);
    printBoard(board2);
    writeln('-------------------------------------------------');
    diffBoard(board1, board2)
    writeln('-------------------------------------------------');
    // -------------
    // diffBoard();

end.