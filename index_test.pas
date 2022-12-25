{
    Example file about how to implement the game
}


uses game_main, space_invaders_module; // Import game module

var 
    stats:t_stats; // Define a "t_stats" record to store the stats of the play
    score:integer; // Define an INTEGER variable to store the return (player score)

begin
    writeln('Some text blablabla');
    // Passing the stats paramter is optional
    score := play(stats); // Run the game and store the result, also stats will be stored
    writeln('Score: ', score); // Print the score
    // Print the stats
    writeln('Stats Time alive: ', stats.timeAlive/1000.0:0:2); 
    writeln('Stats Score: ', stats.score); 
    writeln('Stats kills: ', stats.kills); 
    writeln('Stats shoots: ', stats.shoots); 

end.