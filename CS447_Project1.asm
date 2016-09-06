#CS447 - Project 1 "Lingo"
#Summer 2016
#Author - Austin Marcus aim792@pitt.edu
#####################################################################################################################################

.data
	msgText: .asciiz "Welcome to Lingo!"
	msgTextWord: .asciiz "The word to guess is: "
	
	blankChar: .asciiz " _ "
	lineBreak: .asciiz "\n"
.align 2	
	bench: .asciiz "BENCH"
.align 2	
	benchLC: .asciiz "bench"
.align 2	
	crate: .asciiz "CRATE"
.align 2	
	crateLC: .asciiz "crate"
.align 2	
	frame: .asciiz "FRAME"
.align 2	
	frameLC: .asciiz "frame"
.align 2	
	gauge: .asciiz "GAUGE"
.align 2	
	gaugeLC: .asciiz "gauge"
.align 2	
	hands: .asciiz "HANDS"
.align 2	
	handsLC: .asciiz "hands"
.align 2	
	juice: .asciiz "JUICE"
.align 2	
	juiceLC: .asciiz "juice"
.align 2	
	loans: .asciiz "LOANS"
.align 2	
	loansLC: .asciiz "loans"
.align 2	
	mouse: .asciiz "MOUSE"
.align 2	
	mouseLC: .asciiz "mouse"
.align 2	
	power: .asciiz "POWER"
.align 2	
	powerLC: .asciiz "power"
.align 2	
	state: .asciiz "STATE"
.align 2	
	stateLC: .asciiz "state"
.align 2
	enterGuessMsg: .asciiz "Enter guess number "
	colon: .asciiz ": "
	rightPlace: .asciiz " is in the right place"
	wrongPlace: .asciiz " is in the word but not the right place"
	
	winMsg: .asciiz "You win!"
	loseMsg: .asciiz "All out of guesses! You lose!"
	
	playAgain: .asciiz "Would you like to play again? "
	yes: .asciiz "yes"
	goodbye: .asciiz "Thank you for playing! Goodbye!"
	contHolder: .space 4
	guessHolder: .space 6
	
#####################################################################################################################################

.text
START:  #beginning of game play
	la $a0, msgText		#display welcome message
	li $v0, 4		#print string syscall
	syscall
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall
	
	la $a0, msgTextWord	#display game instruction
	li $v0, 4		#print string syscall
	syscall
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall
	
RAND:   #generates random number to choose word
	li $v0, 30		#get time in ms
	syscall
	
	move $a1, $a0		#move lower 32 bits of time to seed random number generator
	li $a0, 1		#load random generator id
	li $v0, 40		#seed random number generator syscall
	syscall
	
	li $a0, 1		#load id of seeded random number generator
	li $a1, 10		#upper bound of random number
	li $v0, 42		#generate random number syscall
	syscall			#$a0 now holds random number between 0 and 9
	
	move $t0, $a0		#save random number
	li $t1, 16		#load multiplicative factor of 10 for addressing words
	mult $t0, $t1		#multiply random number by 10 to get usable address for chosen word
	mflo $s1		#save the lower 32 bits of result to $s1 to index the word; 
				#since largest possible value is 90, 
				#upper 32 bits shouldn't have any value
	la $a0, bench		#load address of first word in data segment
	add $a0, $a0, $s1	#offset address by random number * 10
	move $s1, $a0           #save word address into $s1 
	lb $a0, 0($a0)		#copy first character into $a0 to print
	li $v0, 11		#print character syscall
	syscall			#prints first character of chosen word
	
	li $t0, 3		#max number of blanks to be printed, minus 1
	li $t1, 0		#clear contents of $t1
	
BLANK:  #prints out four underscores after the first character of chosen word
	bgt $t1, $t0, GAME	#quit and start guess portion if 
				#appropriate number of blanks have been 
				#printed
	la $a0, blankChar	#display an underscore
	li $v0, 4		#print string syscall
	syscall	
	
	addi $t1, $t1, 1	#increment $t1
	j BLANK			#another iteration of BLANK
	
###########################################################################################################
#Start of guessing portion
###########################################################################################################
	
GAME:	#signifies start of guessing portion
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall

	#variables for LOOP, coming up
	li $s0, 4		#max number of guesses allowed, minus 1
	li $t0, 0		#clear contents of $t0 to act as loop induction variable
	
#################################################################################################
#Loop through guesses	
#################################################################################################

LOOP:	bgt $t0, $s0, LOSE	#jump to "lose" message if all guesses have been used
	
	la $a0, enterGuessMsg   #ask user to enter a guess
	li $v0, 4		#print string syscall
	syscall
	
	move $a0, $t0		#copy current guess number to $a0
	addi $a0, $a0, 1	#increment guess number by 1 so it's human-accurate
	li $v0, 1		#print integer syscall
	syscall			#prints guess number
	
	la $a0, colon 		#display a colon
	li $v0, 4		#print string syscall
	syscall
	
	li $v0, 8		#read string syscall
	la $a0, guessHolder	#load address to store string input
	li $a1, 6		#max input length (5 here) + 1 for null terminator
	syscall			#guessHolder now holds user input
	
        la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall
	
	la $t5, guessHolder	#save address of user guess
	
	#variables for CHECK loop, coming up
	li $s3, 0		#clears $s3 for safety across multiple plays;
				#to be used for right character, right place
	li $t3, 0		#clears $t3 for safety across multiple plays;
				#to be used as CHECK loop induction variable
				
######################################################################################
#Loop through each character of guess
######################################################################################

CHECK:	#loops over characters of guess and compares
	bgt $s3, $s0, WIN	#jump to win message if all characters in right place
				#(i.e. if RCRP counter > 4)
	bgt $t3, $s0, AFTER	#skip rest of loop if all characters have been checked
				#(i.e. if loop induction variable is greater than 4)
	add $t4, $t3, $t5	#increment address of guess by offset, store in $t4
	lb $t4, 0($t4)		#load correct character of guess into $t4
	add $s4, $t3, $s1	#increment address of number by offset, store in $s4
	addi $s4, $s4, 8	#increase offset to correspond to same character in lower case
				#for comparison
	lb $s4, 0($s4)          #load correct character of word into $s4
	beq $t4, $s4, RCRP	#jump to code handling right color, right place if character
				#from guess at current index is equal to character from word
				#at current index
				
	li $s5, 0		#loop induction for EACH, coming up
	
#################################################################
#Compare one character of guess against each character of word
#################################################################

EACH:	#check one character of guess against each character of word
	bgt $s5, $s0, INC	#if loop induction variable is greater than
				#4 (i.e. total number of characters in word - 1),
				#skip to incrementing outer CHECK loop
	beq $s5, $t3, SKIP	#if current offset is the same as the offset that indexes
				#the guess character's current place, skip to next iteration
				#of EACH(avoids double-counting)
	add $s4, $s5, $s1	#increment address of word by offset, store in $s4
	addi $s4, $s4, 8	#increase offset by 8 to index corresponding word
				#character in lowercase version
	lb $s4, 0($s4)		#store correct character of word into $s4
	beq $s4, $t4, RCWP	#if the given guess character is equal to the word character
				#indexed at the current iteration, jump to 
				#code that handles right character, wrong place
	
SKIP:	#utility jump point to allow skipping index that was already checked 
	addi $s5, $s5, 1	#increment $s5
	j EACH			#another iteration of EACH
	
	j INC			#keep from jumping to RCRP or RCWP if
				#correct characters not found after EACH finishes
	
###############################################################
#End comparing one guess character against each word character
###############################################################

RCRP:   #displays appropriate message if a character from guess is in the
	#right place	
	add $a0, $s1, $t3	#increment address of word by offset, store in $a0
	lb $a0, 0($a0)          #store correctly guessed character of word,
				#pulled from uppercase version, into $a0
	li $v0, 11		#print character syscall
	syscall
	
	la $a0, rightPlace	#display right place message
	li $v0, 4		#print string syscall
	syscall
	
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall
	
	addi $s3, $s3, 1	#increment RCRP counter
	
	j INC			#skip to incrementing CHECK
	
RCWP:   #displays appropriate message if a character from guess is valid but
	#is in the wrong place
	add $a0, $s1, $s5       #increment word address by iterative offset, store in $a0
	lb $a0, 0($a0)	        #store character of word that is correct but in wrong place,
				#pulled from uppercase version
	li $v0, 11		#print character syscall
	syscall
	
	la $a0, wrongPlace	#display wrong place message
	li $v0, 4		#print string syscall
	syscall
	
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall

INC:	#utility jump point to build condition gating for case of 
	#right character wrong place vs. right character wrong place
	addi $t3, $t3, 1	#increment $t3
	j CHECK			#another iteration of CHECK

##################################################################################
#End loop through characters of guess
##################################################################################
	
	
AFTER:	#jumps here if check is finished
	addi $t0, $t0, 1	#increment $t0
	j LOOP			#another iteration of LOOP

#############################################################################################
#End loop through guesses
#############################################################################################
	
WIN:	la $a0, winMsg		#display win message if user guess correct
	li $v0, 4		#print string syscall
	syscall
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall
	j CONT			#jump to 'continue playing' option
	
LOSE:	la $a0, loseMsg		#display lose message if all guesses exhausted
	li $v0, 4		#print string syscall
	syscall
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall
	
CONT:	#determine if user wants to play again, restart if yes or exit if no
	la $a0, playAgain	#ask user if they want to keep playing
	li $v0, 4		#print string syscall
	syscall
	
	li $v0, 8		#read string syscall
	la $a0, contHolder	#specify address to hold string input
	li $a1, 4		#max input length (3 here) + 1 for null terminator
	syscall			#stringHolder now holds user input 
	
	la $t0, contHolder	#load address of stored user input
	lw $t1, 0($t0)		#load user input content
	la $t2, yes		#load address of "yes" string
	lw $t3, 0($t2)		#load "yes" string to compare against user response
	
	la $a0, lineBreak	#print a line break
	li $v0, 4		#print string syscall
	syscall
	
	beq $t1, $t3, START	#return to beginning of game if user responded "yes"
	
EXIT:	la $a0, goodbye		#display goodbye message
	li $v0, 4		#print string syscall
	syscall
	
	li $v0, 10		#exit program syscall
	syscall

