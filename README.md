# AssemblyLingo
The classic guessing game Lingo, written in MIPS assembly language.

*Written June 2016, uploaded September 2016 (AIM)*

## An in-depth functionality description, for anyone brave or bored enough to dive in...

1. Structure:

- Words are stored as both upper-case and lower-case word-aligned ASCII strings
- Welcome message and instruction ("the word to guess is: ") are printed
- Random number generator seeded by current time; random number generated between 0 and 9, multiplied by 16 to index one of the 10 words
- First character of the chosen word displayed; a small loop prints four underscores
- Each guess is stored in a 6-byte .space field
- Outermost loop (LOOP) loops through guesses and checks each guess, as described below:
- Inner loop (CHECK) first checks each character with the character in the chosen word at the same index (offset by 8 to access lowercase version for comparison); if the two are identical, a "right-character-right-place" (RCRP) counter is incremented, a "right-character-right-place" message displayed, and the next character is checked. 
- If character "held" by "CHECK" is not found to be in right place, an inner loop (EACH) then compares the character against each other character in the chosen word (except the character at the same index). If any other character is equal to the current one, a "right-character-wrong-place" message is displayed and EACH is broken, allowing CHECK to increment to the next character.
- If the RCRP counter is found to be greater than 4 by LOOP, then the game is ended and a "win" message displayed. If the LOOP counter is found to be greater than 4, the game is ended and a "losing" message is displayed.
- Players are given the option to play again by entering "yes", or may exit by entering "no".

2. There are no known bugs; everything is functioning as expected at most recent testing.

-6/26/2016
