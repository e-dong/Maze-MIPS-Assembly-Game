.data 

	maze: .word 	1,1,1,1,1,1,1,1,
			1,0,0,0,0,0,0,3,
			1,0,1,1,1,1,1,1,
			1,0,0,0,0,1,1,1,
			1,1,0,1,0,1,0,1,
			1,1,1,1,0,1,0,1,
			1,2,0,0,0,0,0,1,
			1,1,1,1,1,1,1,1
			
	winMsg: .asciiz "You have found the treasure! You Win!"
			
.text
	li $t4, 0 # int i = 0
	li $t5, 0 # int x = 0
	li $t6, 0 # int y = 0
	li $s1, 8 
	la $s0, maze
	loop: slti $t7, $t4, 64 # while (i < 64) , iterates through array , indexes 0 to 63
	beq $t7, $zero, exitLoop
	
	lw $t0, 0($s0) # load the color 
	move $a0, $t4
	move $a0, $t5
	move $a1, $t6
	move $a2, $t0
	jal _setLED
	addi $t5, $t5, 1
	div $t5, $s1
	mfhi $s2
	# if x % 8 == 0, then go to column, otherwise jump to end_Row and prepare for next iteration
	beq $s2, $zero, next_Column
	j end_Row
	next_Column: #go to next column by incrementing the y. 
	# rest x back to zero, since we are in next column
	li $t5, 0
	addi $t6, $t6, 1
	
	
	end_Row:
	# increment counter for array index
	addi $t4, $t4, 1
	# increment to next color element
	addi $s0, $s0, 4
	
	j loop
	exitLoop:
	#####################################################################
	#  			MAZE IS DRAWN				    #
	#####################################################################
	
	
	# Polling loop to keep track of keypresses
	li $s1, 2 # store 2, the orange value (goal)
	li $s6, 1 # store 1, the red value (walls)
	li $s7, 7 # represents x coordinate in which the user can not exit the entrance
	# value for the arrow keys
	li $s2, 0xE0 # up
	li $s3, 0xE1 # down
	li $s4, 0xE2 # left
	li $s5, 0xE3 # right
	# hero in (7,1) - x,y
	li $t5, 7
	li $t6, 1
	# while (_getLED != 2), if user finds orange spot, end game
	# $t4 will find the next LED spot (_getLED) when the specific key is pressed. 
	pollLoop: beq $t4, $s1, endGame
	
	# sleep for 200 ms
	li $v0, 32
	li $a0, 200
	syscall 
	
	jal _getKeyPress
	
	
	
	
	# now I must deal with what happens when the user hits the arrow keys
	# result stored in $v0, make comparison with $s2 - $s5
	
	##############################
	#     UP_ARROW_CASE_EVENT    #
	##############################
	
	# if it is not equal to up arrow, go to not_UP
	bne $v0, $s2, not_UP
	# if next position is the orange spot, I win
	move $a0, $t5 # load x parameter
	addi $a1, $t6, -1 # load the y coordiate above the hero
	jal _getLED
	move $t4, $v0
	# test if if the orange spot is directly above the hero, if true end game. 
	beq $t4, $s1, EXIT
	
	# check when the user hits the up arrow when there is a red wall above him.
	bne $t4, $s6, noRedWallsABOVE
	j pollLoop # if there is a red wall.. cannot continue 
	noRedWallsABOVE:
	
	
	# now we can move the hero up 1 spot. 
	# first change hero's current position to "0" (off)
	move $a0, $t5
	move $a1, $t6
	li $a2, 0
	jal _setLED
	
	# next set Hero's new position
	addi $t6, $t6, -1 
	move $a1, $t6
	li $a2, 3
	jal _setLED
	
	j pollLoop # done here, go back to beginning of loop
	
	not_UP:
	
	
	##############################
	#     DOWN ARROW CASE        #
	##############################
	bne $v0, $s3, not_DOWN
	# if next position is the orange spot, I win
	move $a0, $t5 # load x parameter
	addi $a1, $t6, 1 # load the y coordiate below the hero
	jal _getLED
	move $t4, $v0
	# test if if the orange spot is directly below the hero, if true end game. 
	beq $t4, $s1, EXIT
	
	# check when the user hits the down arrow when there is a red wall below him.
	bne $t4, $s6, noRedWallsBELOW
	j pollLoop # if there is a red wall.. cannot continue 
	noRedWallsBELOW:
	
	
	# now we can move the hero down 1 spot. 
	# first change hero's current position to "0" (off)
	move $a0, $t5
	move $a1, $t6
	li $a2, 0
	jal _setLED
	
	# next set Hero's new position
	addi $t6, $t6, 1 
	move $a1, $t6
	li $a2, 3
	jal _setLED
	
	j pollLoop # done here, go back to beginning of loop
	
	
	
	not_DOWN:
	
	##############################
	#     LEFT ARROW CASE        #
	##############################
	
	bne $v0, $s4, not_LEFT
	# if next position is the orange spot, I win
	addi $a0, $t5,-1 # load x parameter to the left of hero
	move $a1, $t6 # load the y coordiate
	jal _getLED
	move $t4, $v0
	# test if if the orange spot is directly to the left of the hero, if true end game. 
	beq $t4, $s1, EXIT
	
	# check when the user hits the left arrow when there is a red wall to the left of him.
	bne $t4, $s6, noRedWallsLEFT
	j pollLoop # if there is a red wall.. cannot continue 
	noRedWallsLEFT:
	
	
	# now we can move the hero to the left 1 spot. 
	# first change hero's current position to "0" (off)
	move $a0, $t5
	move $a1, $t6
	li $a2, 0
	jal _setLED
	
	# next set Hero's new position
	addi $t5, $t5, -1 
	move $a0, $t5
	li $a2, 3
	jal _setLED
	
	j pollLoop # done here, go back to beginning of loop
	
	
	not_LEFT:
	
	##############################
	#     RIGHT ARROW CASE       #
	##############################
	bne $v0, $s5, not_RIGHT
	# test if the user is at entrance, if so cannot go to the right
	#bne $t5, $s7, heroNotAtENTRANCE
	#j pollLoop # otherwise, loop back to the polling loop
	#heroNotAtENTRANCE:
	# if next position is the orange spot, I win
	addi $a0, $t5,1 # load x parameter to the right of hero
	move $a1, $t6 # load the y coordiate
	jal _getLED
	move $t4, $v0
	# test if if the orange spot is directly to the right of hero, if true end game. 
	beq $t4, $s1, EXIT
	
	# check when the user hits the right arrow when there is a red wall to the right of him.
	bne $t4, $s6, noRedWallsRIGHT
	j pollLoop # if there is a red wall.. cannot continue 
	noRedWallsRIGHT:
	
	
	# now we can move the hero to the right  1 spot. 
	# first change hero's current position to "0" (off)
	move $a0, $t5
	move $a1, $t6
	li $a2, 0
	jal _setLED
	
	# next set Hero's new position
	addi $t5, $t5,1 
	move $a0, $t5
	li $a2, 3
	jal _setLED
	
	j pollLoop # done here, go back to beginning of loop
	not_RIGHT:
	
	
	
	
	
	# another key pressed(e.g middle button, or no button pressed)?, nothing would happen, iterate again.
	
	j pollLoop
	endGame:
	EXIT:
	# print win message, when the user reaches the treasure chest
	li $v0, 4
	la $a0, winMsg
	syscall
	# end program
	li $v0, 10
	syscall

	
		# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=orange, 3=green
	#
	# warning:   x, y and color are assumed to be legal values (0-63,0-63,0-3)
	# arguments: $a0 is x, $a1 is y, $a2 is color 
	# trashes:   $t0-$t3
	# returns:   none
	#
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008	# base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra



	# int _getLED(int x, int y)
	#   returns the value of the LED at position (x,y)
	#
	#  warning:   x and y are assumed to be legal values (0-63,0-63)
	#  arguments: $a0 holds x, $a1 holds y
	#  trashes:   $t0-$t2
	#  returns:   $v0 holds the value of the LED (0, 1, 2, 3)
	#
_getLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	jr   $ra


	# int _getKeyPress(void)
	#	returns the key last pressed, unless there is none
	#
	# trashes: $t0-$t1
	# returns in $v0:
	#	0	No key pressed
	# 	0x42	Middle button pressed
	# 	0xE0	Up arrow 
	# 	0xE1	Down arrow 
	# 	0xE2	Left arrow 
	# 	0xE3 Right arrow
	#
_getKeyPress:
	la	$t1, 0xffff0000			# status register
	li	$v0, 0				# default to no key pressed
	lw	$t0, 0($t1)			# load the status
	beq	$t0, $zero, _keypress_return	# no key pressed, return
	lw	$v0, 4($t1)			# read the key pressed
_keypress_return:
	jr $ra
