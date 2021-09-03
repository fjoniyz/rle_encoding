	#+ BITTE NICHT MODIFIZIEREN: Vorgabeabschnitt
	#+ ------------------------------------------

.data

str_Eingabe: .asciiz "Eingabe: "
str_Rueckgabewert: .asciiz "\nRueckgabewert: "
str_Ausgabe: .asciiz "\nAusgabedaten:"

rle_compressed_output_buf: .space 100

.text

.eqv SYS_PUTSTR 4
.eqv SYS_PUTCHAR 11
.eqv SYS_PUTINT 1
.eqv SYS_EXIT 10

.globl main
main:

	# Eingabezeichenfolge anzeigen:
	li $v0, SYS_PUTSTR
	la $a0, str_Eingabe
	syscall
	la $a0, str_test_input
	syscall
	
	# Aufruf der zu testenden Funktion rle:
	la $a0, str_test_input
	la $a1, rle_compressed_output_buf
	jal rle

	# Rueckgabewert anzeigen:
	move $t0, $v0
	li $v0, SYS_PUTSTR
	la $a0, str_Rueckgabewert
	syscall
	li $v0, SYS_PUTINT
	move $a0, $t0
	syscall

	# Ausgabedaten anzeigen:
	li $v0, SYS_PUTSTR
	la $a0, str_Ausgabe
	syscall
	
	la $t0, rle_compressed_output_buf
_main_output_loop:
	lb $t2, 0($t0)
	lb $t1, 1($t0)
	or $t3, $t2, $t1
	beqz $t3, _main_output_endloop
	
	li $v0, SYS_PUTCHAR
	li $a0, ' '
	syscall	
	li $a0, '('
	syscall
	li $a0, '\''
	syscall
	
	move $a0, $t2
	syscall

	li $a0, '\''
	syscall
	li $a0, ','
	syscall
	
	li $v0, SYS_PUTINT
	move $a0, $t1
	syscall
	
	li $v0, SYS_PUTCHAR
	li $a0, ')'
	syscall	
	
	addi $t0, $t0, 2
	j _main_output_loop
_main_output_endloop:
	
	# Programmende
	li $v0, SYS_EXIT
	syscall

.data

str_test_input: .asciiz "FFGGGEEEJKJ"

.text
rle:
	# Funktion rle bitte hier implementieren.
	addi 	$sp, $sp, -24  #Speicher auf dem Stack belegen
	sw	$ra, 20($sp) 	#speichere die return Adresse im Stack
	sw	$s0, 16($sp) 
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)	
	sw	$s3, 4($sp)
	sw	$s4, 0($sp)
	move 	$s0, $a0	#$s0 = str_in[]
	li	$s1, 1		#int count = 1 count ist die Anzahl der Widerholungen einer Buchstabe
	li	$s2, 0		#int k = 0	k ist das char in str_in
	li 	$s3, 1 		#int j = 1	j ist das naechste char in str_in
	li	$s4, 0		#int i = 0	i ist die Anzahl der Paaren
while:
	add	$t0, $s0, $s2		#$t0 = &str_in[k]
	lb	$t0, 0($t0)			#$t0 = str_in[k]
	beq	$t0, 0, exitWhile	#while(str_in[k] != '\0')
if:
	add	$t1, $s0, $s3	#$t1 = &str_in[j]
	lb	$t1, 0($t1)		#$t1 = str_in[j]
	beq 	$t0, $t1, else	#branch zu else if str_in[k] == str_in[j]
	add	$t2, $a1, $s4  #&buff_out[i] in $t2 gespeichert
	sb 	$t0, 0($t2)    #buff_out[i] = str_in[k]
	addi 	$s4, $s4, 1    #i++
	add	$t2, $s4, $a1  #buff_out[i] nochmal
	addi 	$v1, $v1, 1	#addiere die Anzahl der Paaren
	sb	$s1, 0($t2)    #buff_out[i] = count
	move 	$s2, $s3 	    #k = j
	move 	$s1, $zero		#count = 0
	addi 	$s4, $s4, 1	#i++
else:
	addi 	$s1, $s1, 1	#count++
	addi 	$s3, $s3, 1	#j++
exitElse:
	j 	while				#zureuckspringen
exitWhile:
	move 	$v0, $v1		#kopiere die Anzahl der Bitpairs von $v1 in $v0
	lw   	$ra,20($sp)    #wiederherstellen die Werte von $s und $ra
	lw   	$s0,16($sp)
	lw   	$s1,12($sp)
	lw  	$s2,8($sp)
	lw   	$s3,4($sp)
	lw   	$s4,0($sp)
	addi 	$sp,$sp,24 	#inkrementiere den Stack
	jr 	$ra
