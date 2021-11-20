#
#	Justin Hardy
#	JEH180008
#

#	Screen Size
.eqv	WIDTH	64
.eqv	HEIGHT	64

#	Memory Address of (0,0)
.eqv	MEM	$gp

#	Colors
.eqv	RED 	0x00FF0000
.eqv	GREEN 	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE 	0x00FFFFFF
.eqv	YELLOW 	0x00FFFF00
.eqv	CYAN	0x0000FFFF
.eqv	MAGENTA	0x00FF00FF

.data
colors:		.word	MAGENTA, CYAN, YELLOW, WHITE, BLUE, GREEN, RED

.text
main:	
	# Set up initial positions
	addi	$s0, $0, WIDTH	# s0 = X = WIDTH / 2
	sra	$s0, $s0, 1
	addi	$s1, $0, HEIGHT	# s1 = Y = HEIGHT / 2
	sra	$s1, $s1, 1
	la	$s2, colors
	
	# Draw Box
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	jal	draw_box
	
	loop:
		# Check for input
		lw	$s3, 0xffff0000	# load input
		beq	$s3, 0, loop	# if no input, keep displaying
		
		# process input
		lw	$s3, 0xffff0004
		beq	$s3, 32, exit	# input space
		beq	$s3, 119, up	# input w
		beq	$s3, 115, down	# input s
		beq	$s3, 97, left	# input a
		beq	$s3, 100, right	# input d
		# invalid input, ignore
		j	loop
		
		up:
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $0
			jal	draw_box
			addi	$s1, $s1, -1	# y--
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $s2
			jal	draw_box
			j	loop
		
		down:
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $0
			jal	draw_box
			addi	$s1, $s1, 1	# y++
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $s2
			jal	draw_box
			j	loop
		
		left:
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $0
			jal	draw_box
			addi	$s0, $s0, -1	# x--
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $s2
			jal	draw_box
			j	loop
		
		right:
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $0
			jal	draw_box
			addi	$s0, $s0, 1	# x++
			move	$a0, $s0
			move	$a1, $s1
			move	$a2, $s2
			jal	draw_box
			j	loop
		
	
exit:	li	$v0, 10
	syscall
	
#################################################
# Function to draw a 7x7 hollow box.
# $a0 = center X
# $a1 = center Y
# $a2 = array of colors
draw_box:
	# Move coordinates to registers t7 & t8
	move	$t7, $a0	# t7 = center X
	move	$t8, $a1	# t8 = center Y
	move	$t9, $a2	# move colors array to register t9
	
	# Draw Top
	li	$a0, 1		# a0 = 1 = top
	move	$a1, $t9	# a1 = colors
	move	$a2, $t7	# a2 = center X
	move	$a3, $t8	# a3 = center Y
	addi	$sp, $sp, -4	# Save $ra to stack
	sw	$ra, 4($sp)	# Save $ra to stack
	jal	draw_Horizontal
	lw	$ra, 4($sp)	# Load $ra from stack
	addi	$sp, $sp, 4	# Load $ra from stack
	
	# Draw Bottom
	li	$a0, -1		# a0 = -1 = bottom
	move	$a1, $t9	# a1 = colors
	move	$a2, $t7	# a2 = center X
	move	$a3, $t8	# a3 = center Y
	addi	$sp, $sp, -4	# Save $ra to stack
	sw	$ra, 4($sp)	# Save $ra to stack
	jal	draw_Horizontal
	lw	$ra, 4($sp)	# Load $ra from stack
	addi	$sp, $sp, 4	# Load $ra from stack
	
	# Draw Left
	li	$a0, -1		# a0 = -1 = left
	move	$a1, $t9	# a1 = colors
	move	$a2, $t7	# a2 = center X
	move	$a3, $t8	# a3 = center Y
	addi	$sp, $sp, -4	# Save $ra to stack
	sw	$ra, 4($sp)	# Save $ra to stack
	jal	draw_Vertical
	lw	$ra, 4($sp)	# Load $ra from stack
	addi	$sp, $sp, 4	# Load $ra from stack
	
	# Draw Right
	li	$a0, 1		# a0 = 1 = right
	move	$a1, $t9	# a1 = colors
	move	$a2, $t7	# a2 = center X
	move	$a3, $t8	# a3 = center Y
	addi	$sp, $sp, -4	# Save $ra to stack
	sw	$ra, 4($sp)	# Save $ra to stack
	jal	draw_Vertical
	lw	$ra, 4($sp)	# Load $ra from stack
	addi	$sp, $sp, 4	# Load $ra from stack
	
	# Exit
	jr	$ra
	
#################################################
# function to draw a 7-pixel long horizontal
# line of pixels. Alternates bt Green & Red.
# $a0 = top/bottom, denote with a 1 (top) or -1 (bottom).
# $a1 = array of colors
# $a2 = center X
# $a3 = center Y
draw_Horizontal:
	# Load Initials
	li	$t0, 0		# t0 = i = 0
	li	$t4, 0		# t4 = j = 0
	li	$t2, 3		# t2 = 3 = top
	beq	$a0, 1, isTop
	li	$t2, -3		# t2 = -3 = bottom
	isTop:
	move	$t7, $a2	# t7 = center X
	move	$t8, $a3	# t8 = center Y
	
	# Get Starting Color
	move	$t9, $a1
	beq	$t9, 0, isBlack_H	# If color is black, then we are printing a box to clear a previous box (all black)
	sll	$t3, $t4, 2	# t3 = j * 4
	add	$t3, $t9, $t3	# t3 = &colors[j]
	lw	$t1, ($t3)	# t1 = colors[j]
	addi	$t4, $t4, 1	# j++
	j	horizLoop
	
	isBlack_H:
	move	$t1, $0
	
	# Draw Top
	horizLoop:
	# start loop
		## Draw left-side (could also be center)
		beq	$t0, 4, exitHorizLoop
		move	$a0, $t7
		sub	$a0, $a0, $t0	# move a0 left i pixels
		move	$a1, $t8
		sub	$a1, $a1, $t2	# move a1 up/down 3 pixels
		move	$a2, $t1	# a2 = current color
		
		# Draw pixel
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	draw_pixel
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		# Add Delay between draws
		li	$a0, 5		# delay by 5 ms
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	pause
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		beq	$t0, 0, isCenter_H	# Skip drawing right-side if center-piece
		
		# Alternate Color
		beq	$t9, 0, isBlack_H_L	# If color is black, then we are printing a box to clear a previous box (all black)
		sll	$t3, $t4, 2	# t3 = j * 4
		add	$t3, $t9, $t3	# t3 = &colors[j]
		lw	$t1, ($t3)	# $t1 = colors[j]
		addi	$t4, $t4, 1	# j++
		
		isBlack_H_L:
		
		## Draw right-side
		move	$a0, $t7
		add	$a0, $a0, $t0	# move a0 right i pixels
		move	$a1, $t8
		sub	$a1, $a1, $t2	# move a1 up/down 3 pixels
		move	$a2, $t1	# a2 = current color
		
		# Draw pixel
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	draw_pixel
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		# Add Delay between draws
		li	$a0, 5		# delay by 5 ms
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	pause
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		isCenter_H:
		addi	$t0, $t0, 1	# i++
		
		# Alternate Color
		beq	$t9, 0, horizLoop	# If color is black, then we are printing a box to clear a previous box (all black)
		sll	$t3, $t4, 2	# t3 = j * 4
		add	$t3, $t9, $t3	# t3 = &colors[j]
		lw	$t1, ($t3)	# $t1 = colors[j]
		addi	$t4, $t4, 1
		
		b	horizLoop		
	# end loop
	exitHorizLoop:
	jr	$ra
	
#################################################
# function to draw a 7-pixel long horizontal
# line of pixels. Alternates bt Green & Red.
# $a0 = top/bottom, denote with a 1 (top) or -1 (bottom).
# $a1 = array of colors
# $a2 = center X
# $a3 = center Y
draw_Vertical:
	# Load Initials
	li	$t0, 0		# t0 = i = 0
	li	$t4, 0		# t4 = j = 0
	li	$t2, 3		# t2 = 3 = right
	beq	$a0, 1, isRight
	li	$t2, -3		# t2 = -3 = left
	isRight:
	move	$t7, $a2	# t7 = center X
	move	$t8, $a3	# t8 = center Y
	
	# Get Starting Color
	move	$t9, $a1
	beq	$t9, 0, isBlack_V	# If color is black, then we are printing a box to clear a previous box (all black)
	sll	$t3, $t4, 2	# t3 = j * 4
	add	$t3, $t9, $t3	# t3 = &colors[j]
	lw	$t1, ($t3)	# $t1 = colors[j]
	addi	$t4, $t4, 1	# j++
	j	vertLoop
	
	isBlack_V:
	move	$t1, $0
	
	# Draw Top
	vertLoop:
	# start loop
		## Draw top-side (could also be center)
		beq	$t0, 4, exitVertLoop
		move	$a0, $t7
		add	$a0, $a0, $t2	# move a0 left/right 3 pixels
		move	$a1, $t8
		sub	$a1, $a1, $t0	# move a1 up i pixels
		move	$a2, $t1	# a2 = current color
		
		# Draw pixel
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	draw_pixel
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		# Add Delay between draws
		li	$a0, 5		# delay by 5 ms
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	pause
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		beq	$t0, 0, isCenter_V	# Skip drawing bottom-side if center-piece
		
		# Alternate Color
		beq	$t9, 0, isBlack_V_L	# If color is black, then we are printing a box to clear a previous box (all black)
		sll	$t3, $t4, 2	# t3 = j * 4
		add	$t3, $t9, $t3	# t3 = &colors[j]
		lw	$t1, ($t3)	# $t1 = colors[j]
		addi	$t4, $t4, 1	# j++
		
		isBlack_V_L:
		
		## Draw bottom-side
		move	$a0, $t7
		add	$a0, $a0, $t2	# move a0 left/right 3 pixels
		move	$a1, $t8
		add	$a1, $a1, $t0	# move a1 down i pixels
		move	$a2, $t1	# a2 = current color
		
		# Draw pixel
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	draw_pixel
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		# Add Delay between draws
		li	$a0, 5		# delay by 5 ms
		addi	$sp, $sp, -4	# Save $ra to stack
		sw	$ra, 4($sp)	# Save $ra to stack
		jal	pause
		lw	$ra, 4($sp)	# Load $ra from stack
		addi	$sp, $sp, 4	# Load $ra from stack
		
		isCenter_V:
		addi	$t0, $t0, 1	# i++
		
		# Alternate Color
		beq	$t9, 0, vertLoop	# If color is black, then we are printing a box to clear a previous box (all black)
		sll	$t3, $t4, 2	# t3 = j * 4
		add	$t3, $t9, $t3	# t3 = &colors[j]
		lw	$t1, ($t3)	# $t1 = colors[j]
		addi	$t4, $t4, 1	# j++
			
		b	vertLoop		
	# end loop
	exitVertLoop:
	jr	$ra
	
#################################################
# function to pause between pixel writes
# $a0 = time to pause (ms)
pause:	
	# Add Delay between draws
	li	$v0, 32
	syscall
	jr	$ra
	
#################################################
# function to clear the screen of colored pixels
# a0 = X
# a1 = Y
# a2 = clearColor
clear_box:
	addi	$sp, $sp, -4	# Save $ra to stack
	sw	$ra, 4($sp)	# Save $ra to stack
	jal	draw_box
	lw	$ra, 4($sp)	# Load $ra from stack
	addi	$sp, $sp, 4	# Load $ra from stack
	jr	$ra

#################################################
# subroutine to draw a pixel
# $a0 = X
# $a1 = Y
# $a2 = color
draw_pixel:
	# s7 = address = MEM + 4*(x + y*width)
	mul	$s7, $a1, WIDTH   # y * WIDTH
	add	$s7, $s7, $a0	  # add X
	mul	$s7, $s7, 4	  # multiply by 4 to get word offset
	add	$s7, $s7, MEM	  # add to base address
	sw	$a2, 0($s7)	  # store color at memory location
	jr 	$ra
