.data
fileName:	.asciiz	"input.txt"
errorMessage:	.asciiz	"ERROR. Did not read anything from \"input.txt\"."
desc1:		.asciiz	"The array before:\t"
desc2:		.asciiz	"The array after:\t"
desc3:		.asciiz	"The mean is:\t"
desc4:		.asciiz	"The median is:\t"
desc5:		.asciiz	"The standard deviation is:\t"
space:		.asciiz " "
newLine:	.asciiz "\n"
size:		.word	20
count:		.word	0
mean:		.word	0
median:		.word	0
SD:		.word	0
buffer:		.space	80
array:		.space	80

.text
main:
	# Read from File
	la	$a0, fileName
	la	$a1, buffer
	jal	readInts
	
	# Check if $v0 <= 0 (did not read anything)
	bgtz	$v0, didRead	# Continue through program if you did read something from input.txt
	# Print Error Message & exit the program
	li 	$v0, 4
	la	$a0, errorMessage
	syscall
	j	exit
	
	didRead:
	# Convert contents of buffer into int array
	la	$a0, buffer
	la	$a1, array
	lw	$a2, size
	jal	convertStoI	# call conversion function
	move	$s0, $v0	# $s0 = array
	sw	$v1, count
	
	# Print description 1
	li	$v0, 4		# load 4 to print string
	la	$a0, desc1
	syscall
	
	# Print int array
	move	$a0, $s0
	lw	$a1, count
	la	$a2, space
	jal	printArray	# call array printing function
	
	# Sort int array
	move	$a0, $s0
	lw	$a1, count
	jal	selectionSort	# call function to sort the array
	move	$s0, $v0
	
	# Print newline
	li	$v0, 4		# load 4 to print string
	la	$a0, newLine
	syscall
	
	# Print description 2
	li	$v0, 4		# load 4 to print string
	la	$a0, desc2
	syscall
	
	# Print int array
	move	$a0, $s0
	lw	$a1, count
	la	$a2, space
	jal	printArray	# call array printing function
	
	# Print newline
	li	$v0, 4		# load 4 to print string
	la	$a0, newLine
	syscall
	
	# Print Description 3
	li	$v0, 4		# load 4 to print string
	la	$a0, desc3
	syscall
	
	# Calculate Mean
	move	$a0, $s0
	lw	$a1, count
	jal	calcMean	# call mean calculation function
	mtc1	$v0, $f0	# Save returned float to memory
	swc1	$f0, mean
	
	# Print Mean
	li	$v0, 2		# load 2 to print float
	lwc1	$f12, mean
	syscall
	
	# Print newline
	li	$v0, 4		# load 4 to print string
	la	$a0, newLine
	syscall
	
	# Print Description 4
	li	$v0, 4		# load 4 to print string
	la	$a0, desc4
	syscall
	
	# Calculate Median
	move	$a0, $s0
	lw	$a1, count
	jal	calcMedian	# call median calculation function
	mtc1	$v0, $f0	# Save returned float to memory
	swc1	$f0, median
	
	# Print Median
	li	$v0, 2		# load 2 to print float
	lwc1	$f12, median
	syscall
	
	# Print newline
	li	$v0, 4		# load 4 to print string
	la	$a0, newLine
	syscall
	
	# Print Description 5
	li	$v0, 4		# load 4 to print string
	la	$a0, desc5
	syscall
	
	# Calculate Standard Deviation
	move	$a0, $s0
	lw	$a1, count
	lw	$a2, mean
	jal	calcSD		# call standard deviation calculation function
	mtc1	$v0, $f0	# Save returned float to memory
	swc1	$f0, SD
	
	# Print Standard Deviation
	li	$v0, 2		# load 2 to print float
	lwc1	$f12, SD
	syscall
	
exit:	li	$v0, 10		# exit
	syscall
	
# Parameters:	($a0 = fileName, $a1 = buffer)
# Returns:	($v0 = bytes read)
readInts:
	# Save parameters
	move	$t0, $a0	# $t0 = fileName
	move	$t1, $a1	# $t1 = buffer
	
	# Open File
	li	$v0, 13
	la	$a1, 0
	syscall
	move	$t2, $v0	# $v0 = file descriptor
	
	# Read from File
	li	$v0, 14
	move	$a0, $t2	# descriptor
	move	$a1, $t1	# buffer
	li	$a2, 100
	syscall
	
	jr	$ra
	
# Parameters:	($a0 = buffer, $a1 = int[], $a2 = int)
# Returns:	($v0 = int[], $v1 = int)
convertStoI:
	move	$t0, $0		# $t0 = i = 0
	li	$t1, 0		# $t1 = number = 0
	li	$t8, 0		# $t8 = count = 0
	li	$t9, 10		# $t9 = constant = 10
	
	# loop start
	loop1:
	beq	$t0, $a2, doneConverting# branch if i == size
	lb	$t2, ($a0)		# $t2 = current character
	beq	$t2, 0, doneConverting	# if $t2 == 0 => done converting, branch
	beq	$t2, 10, else		# if $t2 == 10, branch
	
	sge	$t3, $t2, 48		# set $t3 = 1 if $t2 >= 48
	beq	$t3, 0, cont		# if $t3 == 0, branch
	
	sle	$t4, $t2, 57		# set $t4 = 1 if $t2 <= 57
	beq	$t4, 0,	cont		# if $t4 == 0, branch
	
	# if here, then the character is a number
	mult	$t1, $t9		# multiply register $t1 by 10
	mflo	$t1			# move product to lo register
	subi	$t2, $t2, 48		# convert $t2 from ascii to int
	add	$t1, $t1, $t2		# add digit to the number
	j	cont
	
	else:
	# add current number to array
	sll	$t5, $t0, 2	# $t5 = i * 4
	add	$t6, $a1, $t5	# $t6 = &array[i]
	sw	$t1, 0($t6)	# array[i] = digit
	move	$t1, $0		# reset digit to 0
	addi	$t8, $t8, 1	# increase count by 1
	addi	$t0, $t0, 1	# i++
	
	cont:
	addi	$a0, $a0, 1	# Step to next bit
	j	loop1		# branch back to loop
	# loop end

	doneConverting:
	move	$v0, $a1
	move	$v1, $t8
	jr	$ra

# Parameters:	($a0 = int[], $a1 = int, $a2 = " ")
# Returns:	(N/A)
printArray:
	move	$t0, $0		# $t0 = i = 0
	move	$t9, $a0	# t9 = int[],  save array address
	
	# loop start
	loop2:
	# move array ptr
	sll	$t1, $t0, 2	# $t1 = i * 4
	add	$t2, $t9, $t1	# $t2 = &array[i]
	beq	$t0, $a1, donePrinting	# break out of loop if last element in array
	#beq	$t0, $zero, loop2	# skip if element is invalid
	
	# Print word
	li	$v0, 1		# load 1 to print integer
	lw	$a0, ($t2)	# $a0 = array[i]
	syscall			# print integer
	
	# print space after
	li	$v0, 4		# load 4 to print string
	move	$a0, $a2
	syscall
	
	# increase i & loop
	addi	$t0, $t0, 1
	j	loop2
	# loop end
	
	donePrinting:
	move	$a0, $t9
	jr	$ra

# Parameters:	($a0 = int[], $a1 = int)
# Returns:	($v0 = int[])
selectionSort:
	li	$t0, 0		# $t0 = i = 0
	
	# loop start
	loop3:
	beq	$t0, $a1, doneSorting	# break out of loop if i == count
	sll	$t1, $t0, 2	# $t1 = i * 4
	add	$t2, $a0, $t1	# $t2 = &array[i]
	move	$t3, $t0	# $t3 = j = i
	move	$t9, $t2	# $t9 = l = &array[i]
	# nested loop start
	nestedLoop3:
	beq	$t3, $a1, contLoop3	# break out of nested loop if j == count
	sll	$t4, $t3, 2	# $t4 = j * 4
	add	$t5, $a0, $t4	# $t5 = &array[j]
	lw	$t6, ($t9)	# $t6 = l's data
	lw	$t7, ($t5)	# $t7 = array[j]
	bge	$t7, $t6, else_ss	# If array[j] < array[i], mark array[j].
	move	$t9, $t5	# Set l = &array[j]
	else_ss:
	addi	$t3, $t3, 1	# j++
	j	nestedLoop3
	# nested loop end
	contLoop3:
	
	# Swap array[i] with l's data (which is the lowest value after i)
	lw	$t3, ($t2)	# $t3 = array[i]
	lw	$t4, ($t9)	# $t4 = l's data
	sw	$t3, ($t9)	# l's data = array[i]
	sw	$t4, ($t2)	# array[i] = l's data
	
	addi	$t0, $t0, 1	# i++
	j	loop3
	# loop end
	
	doneSorting:
	move	$v0, $a0
	jr	$ra

# Parameters:	($a0 = int[], $a1 = int)
# Returns:	($v0 = float)
calcMean:
	li	$t0, 0		# $t0 = i = 0
	mtc1	$0, $f0		# move a 0 to $f0
	cvt.s.w	$f0, $f0	# convert $f0 to float equal to 0
	mtc1	$a1, $f9	# move count to $f9
	cvt.s.w	$f9, $f9	# convert $f9 to float equal to count
	
	# loop start
	meanLoop:
	beq	$t0, $a1, exitMean	# exit loop if i == count
	sll	$t1, $t0, 2	# $t1 = i * 4
	add	$t2, $a0, $t1	# $t2 = &array[i]
	lw	$t3, ($t2)	# $t3 = array[i]
	
	mtc1	$t3, $f1	# move int to coprocessor1
	cvt.s.w	$f1, $f1	# convert to float
	add.s	$f0, $f0, $f1	# add $f1 to $f0 (sum)
	
	addi	$t0, $t0, 1	# i++
	j	meanLoop
	# loop end
	
	exitMean:
	div.s	$f0, $f0, $f9	# divide sum by count
	mfc1	$v0, $f0	# return product
	jr	$ra

# Parameters:	($a0 = int[], $a1 = int)
# Returns:	($v0 = float)
calcMedian:
	li	$t0, 2		# $t0 = constant = 2
	div	$a1, $t0	# divide count by 2
	mfhi	$t1		# $t1 = remainder
	mflo	$t2		# $t2 = floor(count/2)
	beqz	$t1, even	# if remainder is 0, calculate average of middle two numbers
	# if remainder is 1, return the middle value.
	sll	$t3, $t2, 2	# $t3 = count/2 * 4
	add	$t4, $a0, $t3	# $t4 = &array[count/2]
	lw	$t5, ($t4)	# $t5 = array[count/2]
	mtc1	$t5, $f0	# move $t5 to cp1
	cvt.s.w	$f0, $f0	# convert to float
	mfc1	$v0, $f0	# return value
	j	exitMedian
	
	even:
	# if remainder is 0, return average of the 2 middle-most values
	subi	$t3, $t2, 1	# $t3 = count/2 - 1
	sll	$t4, $t3, 2	# $t4 = (count/2 - 1) * 4
	add	$t5, $a0, $t4	# $t5 = &array[count/2-1]
	lw	$t6, ($t5)	# $t6 = array[count/2-1]
	sll	$t4, $t2, 2	# $t4 = (count/2) * 4
	add	$t5, $a0, $t4	# $t5 = &array[count/2]
	lw	$t7, ($t5)	# $t7 = array[count/2]
	add	$t8, $t6, $t7	# $t8 = sum
	mtc1	$t8, $f0	# move sum to cp1
	mtc1	$t0, $f1	# move 2 to cp1
	cvt.s.w	$f0, $f0	# convert sum to float
	cvt.s.w	$f1, $f1	# convert 2 to float
	div.s	$f2, $f0, $f1	# $f3 = sum / 2
	mfc1	$v0, $f2	# $v0 = $f3
	
	exitMedian:
	jr	$ra

# Parameters:	($a0 = int[], $a1 = int, $a2 = float)
# Returns:	($v0 = float)
calcSD:
	mtc1	$a2, $f0	# $f0 = avg
	subi	$t0, $a1, 1	# $t0 = n-1
	mtc1	$t0, $f1	# $f1 = $t0
	cvt.s.w	$f1, $f1	# convert to float
	li	$t1, 0		# $t1 = i = 0
	
	# loop start
	SDLoop:
	beq	$t1, $a1, exitSD# break out of loop if last element in array
	sll	$t2, $t1, 2	# $t2 = i * 4
	add	$t3, $a0, $t2	# $t3 = &array[i]
	lw	$t4, ($t3)	# $t4 = array[i]
	mtc1	$t4, $f2	# $f2 = ri
	cvt.s.w	$f2, $f2	# convert $f2 to float
	sub.s	$f3, $f2, $f0	# subtract avg from ri
	mul.s	$f3, $f3, $f3	# square the difference
	add.s	$f4, $f4, $f3	# add to $f4 (= summation)
	addi	$t1, $t1, 1	# i++
	j	SDLoop
	# loop end
	
	exitSD:
	div.s	$f5, $f4, $f1	# $f5 = summation / n-1
	sqrt.s	$f5, $f5	# $f5 = sqrt(summation/n-1)
	mfc1	$v0, $f5
	jr	$ra
	
