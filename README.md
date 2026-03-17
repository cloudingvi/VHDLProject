# Traffic Lights
a VHDL-based game on a Basys3 FPGA

𝜗𝜚 ----------- Rules and Instructions ----------- 𝜗𝜚
In this game, 4 players test their reflexes against each other.
To start, toggle the first switch on the left. The game will wait for all four players to place themselves on the track by continuously pressing one of the four buttons each.
Once all players are ready on their buttons, the game starts by turning all the LEDs off. The traffic lights will then go from red to yellow to green, or rather, a quarter of the LEDs will light up at a time, until all of them are lit. The LEDs will then simultaneously turn off, and at that point the first player to unpress their button will be the winner.
To play the game again, toggle the first switch off and on again.

𝜗𝜚 ----------- Displays and LEDs ----------- 𝜗𝜚
The players are assigned numbers, starting from player 1 at the top and going counter-clockwise. A LED around the center will light up for each player who presses their button. The center button is not used.
A display will show the number of the winner when the game ends.

𝜗𝜚 ----------- False Starts ----------- 𝜗𝜚
If a player has raised his finger from their button before the LEDs went off, they have false started and cannot win the game anymore. If all players false start, there is no winner.

𝜗𝜚 ----------- Errors and Reset ----------- 𝜗𝜚
Should any error occur, the game can be restarted by toggling the last (first on the right) switch twice. Turn the first switch off before resetting the game. If the FPGA shows IDLE, this has not been done, and the first switch needs to be toggled correctly before playing.

thank you! ♡
