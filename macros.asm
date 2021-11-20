.macro print_int (%int)
	li	$v0, 1
	la	$a0, %int
	syscall
.end_macro

.macro print_int_r (%int)
	li	$v0, 1
	move	$a0, %int
	syscall
.end_macro

.macro print_char (%char)
	li	$v0, 11
	la	$a0, %char
	syscall
.end_macro

.macro print_string (%string)
	li	$v0, 4
	la	$a0, %string
	syscall
.end_macro

.macro print_string_r (%string)
	li	$v0, 4
	move	$a0, %string
	syscall
.end_macro

.macro read_string (%buffer, %character_amount)
	li	$v0, 8
	la	$a0, %buffer
	li	$a1, %character_amount
	syscall
.end_macro

.macro file_open (%file_name)
	li	$v0, 13
	la	$a0, %file_name
	li	$a1, 0
	syscall
.end_macro

.macro file_read (%descriptor, %buffer, %character_amount)
	li	$v0, 14
	move	$a0, %descriptor
	la	$a1, %buffer
	li	$a2, %character_amount
	syscall
.end_macro

.macro file_close (%descriptor)
	li	$v0, 16
	move	$a0, %descriptor
	syscall
.end_macro

.macro removeNewLineChars (%string)
	li	$t0, 0		# $t0 = i = 0
	la	$t9, %string
	# loop start
	loop_rNLC:
		# pointer arithmetic
		add	$t1, $t9, $t0	# $t1 = &string[i]
		lb	$t2, ($t1)	# $t2 = string[i]
		beqz	$t2, leave_rNLC	# break out of the loop if the byte equals zero
		bne	$t2, 10, cont_rNLC	# Jump if newline character is not here
		# remove newline character
		sb	$0, ($t1)	# override a zero into this address
		# continue
		cont_rNLC:
		addi	$t0, $t0, 1	# i++	
		b	loop_rNLC	# loop
	# loop end
	leave_rNLC:	# exit
.end_macro
