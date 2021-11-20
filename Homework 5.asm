.include	"macros.asm"

.data
buffer:		.space	1024
compressed:	.space	1024
uncompressed:	.space  1024
prompt1:	.asciiz	"Please enter the filename to compress or <enter> to exit: "
description1:	.asciiz	"Original Data:"
description2:	.asciiz	"Compressed Data:"
description3:	.asciiz	"Uncompressed Data:"
description4:	.asciiz	"Original File Size: "
description5:	.asciiz	"Compressed File Size: "
error_message:	.asciiz	"Error opening file. Program terminating."
newLine:	.asciiz	"\n"
fileName:	.asciiz ""

.text
main:
	# Prompt user to enter fileName
	print_string(prompt1)

	# Read file's name into fileName
	read_string(fileName, 100)
	
	# Exit program if nothing was inputted.
	la	$t0, fileName	# $t0 = %fileName
	lb	$t0, ($t0)	# $t0 = fileName[0]
	li	$t1, 10		# $t1 = '\n' = 10
	beq	$t0, $t1, exit	# if $t0 == $t1, exit
	
	removeNewLineChars(fileName)
		
	# Open File
	file_open(fileName)
	move	$s0, $v0	# $s0 = descriptor
	
	# Exit program if file dne
	bgtz	$s0, exists	# continue if file does exist
	print_string(error_message)	# print error message
	b	exit		# exit program
	
exists:
	# Read the contents of the file into the buffer
	file_read($s0, buffer, 1024)	# read from file
	move	$s1, $v0	# save number of characters read
	file_close($s0)		# close the file
	
	# Print original data
	print_string(description1)
	print_string(newLine)
	print_string(buffer)
	print_string(newLine)
	
	# Compress data
	la	$a0, buffer	# $a0 = input string
	la	$a1, compressed	# $a1 = compressed space
	move	$a2, $s1	# $a2 = size of input string
	jal compress
	move	$s2, $v0	# $s2 = compressed String
	move	$s3, $v1	# $v1 = size of compressed string
	
	# Print compressed data
	print_string(description2)
	print_string(newLine)
	print_string_r($s2)
	print_string(newLine)
	
	# Uncompress compressed data
	move	$a0, $s2	# $a0 = input string
	la	$a1, uncompressed	# $a1 = compressed string
	move	$a2, $s3	# $a2 = size of compressed string
	jal uncompress
	move	$s4, $v0	# $s4 = uncompressed string
	move	$s5, $v1	# $s5 = size of uncompressed string
	
	# Print compressed data
	print_string(description3)
	print_string(newLine)
	print_string_r($s4)
	print_string(newLine)
	
	# Print size of uncompressed string
	print_string(description4)
	print_int_r($s5)
	print_string(newLine)
	
	# Print size of compressed string
	print_string(description5)
	print_int_r($s3)
	print_string(newLine)
	
	

exit:	li	$v0, 10
	syscall
	
# Parameters: $a0 = input string, $a1 = output space, $a2 = size ; Returns: $v0 = output string, $v1 = output size
compress:
	# Load initials
	li	$t6, 0		# $t6 = i = 0
	li	$t7, 0		# $t7 = j = 0
	li	$t8, 0		# $t8 = latest count = 0
	li	$t9, 0		# $t9 = latest word = 0
	
	# loop start
	loop1:
		beq	$t6, $a2, newWord	# Print last if done reading string
		add	$t0, $a0, $t6	# $t0 = &input[i]
		lb	$t1, ($t0)	# $t1 = input[i]
		beq	$t9, 0, setNewWord	# Branch if this is the first word being read
		bne	$t9, $t1, newWord	# Branch if a new word is being read
		addi	$t8, $t8, 1		# count++
		b 	skip1
		newWord:
		# Print compression data into the output string
		add	$t2, $a1, $t7	# $t2 = &output[j]
		sb	$t9, ($t2)	# output[j] = $t9 = last word
		addi	$t7, $t7, 1	# j++
		add	$t2, $a1, $t7	# $t2 = &output[j]
		addi	$t8, $t8, 48	# Convert int to byte
		sb	$t8, ($t2)	# output[j] = $t8 = count
		addi	$t7, $t7, 1	# j++
		beq	$t6, $a2, done1	# Exit loop if done reading string
		setNewWord:
		move	$t9, $t1	# move new word to $t9
		li	$t8, 1		# Set count to 1
	
		skip1:
		addi	$t6, $t6, 1	# i++
		j	loop1
	# loop end
	done1:
	move	$v0, $a1	# return compressed string
	move	$v1, $t7	# return size
	jr	$ra
		
# Parameters: $a0 = input string, $a1 = output string, $a2 = size ; Returns: $v0 = output string, $v1 = output size
uncompress:
	# Load Initials
	li	$t6, 0		# $t6 = i = 0
	li	$t7, 0		# $t7 = j = 0
	
	# loop start
	loop2:
		beq	$t6, $a2, done2	# Exit loop if done reading string
		add	$t0, $a0, $t6	# $t0 = &input[i]
		lb	$t1, ($t0)	# $t1 = input[i] = letter
		addi	$t6, $t6, 1	# i++
		add	$t0, $a0, $t6	# $t0 = &input[i]
		lb	$t2, ($t0)	# $t2 = input[i] = number of occurences
		subi	$t2, $t2, 48	# convert byte to int
		# Print uncompression data into the output string
		move	$t9, $t7	# $t9 = $t7 = starting index
		# inner loop start
		innerloop2:
			sub	$t8, $t7, $t9	# calc difference between start and now
			beq	$t8, $t2, skip2
			add	$t3, $a1, $t7	# $t3 = &output[j]
			sb	$t1, ($t3)	# output[j] = input[i-1] = letter
			addi	$t7, $t7, 1	# j++			
			j	innerloop2
		# inner loop end
		skip2:
		addi	$t6, $t6, 1	# i++
		j	loop2
	# loop end
	done2:
	move	$v0, $a1
	move	$v1, $t7
	jr	$ra
