# M152A_W22_FinalProject_Wordle
Final project for CS M152A - implementing wordle using FPGA board
Proposal:
CS M152A Final Project Proposal
Jenson Choi, 305309648
Rafi Moldovsky, 605561455
Jacob Zhang, Insert UID 

Overview
For our project, we will create a 1-player version of the game wordle on the FPGA 
board. Two buttons (up and down) will be used to alternate between letters in the alphabet. The right button will be used to enter the current letter selected, and the left button will be used to delete the previous letter entered. A switch will be used to reset the game. In addition, we will use the VGA display to display the game on a monitor.

Game Mode
Wordle is a fairly simple game - the game will pick a random 5 letter word in a built-in word list, and the player wins if he/she can guess the word correctly within 6 attempts. When the game launches, it will be automatically in game mode. The player can then enter/delete letters of his/her choosing using the controls described above and those letters will be displayed on the monitor.

When 5 letters are entered, an attempt will be used if the word entered is in the word list. If a letter is in the target word and in the correct position, the box in which that letter appears will turn green. If a letter is in the target word but in the wrong position, the box in which that letter appears will turn yellow. If a letter is not in the target word, the box in which that letter appears will not change color. If, however, the word entered is not in the word list, the game will display the following message: “your word is not in our word list”, and the player can make changes to their word without using an attempt.

The game terminates either when the player correctly guesses the target word or the player uses all 6 of his/her attempts. The reset switch can be used to restart the game with a new word as the target word.

Grading Rubric
Pick a Word Functionality (10%) - When the game begins, it will pick a random word from its word list and display it on the monitor (for now)
Keyboard Functionality (20%) - The player can use the up and down buttons to alternate through letters in the alphabet. Moreover, the player can use the right button to enter the current letter selected and the left button to delete the previous letter entered.
Display Functionality (20%) - The VGA display is able to display a letter that the player enters on the monitor.
Coloring Functionality (20%) - The VGA display is able to change the color of the box of a letter based on whether it’s in the correct position or not.
Terminate Functionality (20%) - The game terminates either when the player correctly guesses the target word or the player uses all 6 of his/her attempts.
Reset Functionality (10%) - Switches will allow players to reset the game. 


Plan: 
