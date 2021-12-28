@ File:    GPhise.s
@ Author:  Matthew Hise
@ Email: mrh0036@uah.edu
@ Section: CS309-01 Spring 2020
@ Date: 04/03/2020
@ Purpose: Simulate a gas pump using the assembly we have learned.
@
@ Use these command to assemble, link, run and debug this program:
@    as -o GPhise.o GPhise.s
@    gcc -o GPhise GPhise.o
@    ./GPhise ;echo $?
@    gdb --args ./GPhise


.equ READERROR, 0
.equ GRADE_COUNT, 3	@ The number of grades
.equ HALF_INIT_INV, 250	@ Half the initial inventory for each grade (tenths of gallons)
.equ REG_PRICE, 250	@ The price of regular gas (cents)
.equ MID_PRICE_DIFF, 83	@ The difference in price of mid-grade gas (cents) vs regular
.equ PREM_PRICE_DIFF, 250 @ The difference in price of premium gas (cents) vs regular

.global main

@*******************
main:
@*******************

	ldr r0, =startMsg @ Load in the startup message
	bl printf	  @ Print the startup message


@*******************
init:
@*******************

@ Initialize the gas pump's inventory and prices

	ldr r1, =gradeNameLens	@ Initialize the starting address of the offsets
	mov r2, #0		@ Initialize the loop counter
	mov r3, #0		@ Initialize the offset value


@*******************
init_offsets_loop:
@*******************

@ Set the offsets for the grade names

	str r3, [r1, r2, LSL #2] @ Store the prev offset
	add r2, #1		 @ Increment the counter
	cmp r2, #GRADE_COUNT	 @ Check if time to stop
	beq init_inv		 @ If so, break from loop
	ldr r0, =gradeNames	 @ Initialize the starting name address
	add r0, r3		 @ Move to the start of the next string


@*******************
inner_offset_loop:
@*******************

	ldrb r4, [r0], #1	@ Load character, then move over one character
	cmp r4, #0		@ Check if current character is the null terminator
	add r3, #1		@ Increment the offset
	bne inner_offset_loop	@ If end of the string not reached yet, keep iterating over string
	b init_offsets_loop	@ Otherwise break to main loop


@*******************
init_inv:
@*******************

	ldr r0, =gradeInvs  	@ Load r0 with the starting grade inventory address
	mov r1, #HALF_INIT_INV	@ Load r1 with half the initial inventory
	add r1, #HALF_INIT_INV	@ Add the other half
	mov r2, #0		@ Reset the loop counter


@*******************
init_inv_loop:
@*******************

	str r1, [r0, r2, LSL #2] @ Initialize the inventory
	add r2, #1		@ Increment the counter
	cmp r2, #GRADE_COUNT	@ Check if time to stop
	bne init_inv_loop	@ If not, restart loop


	ldr r0, =gradePrices 	@ Load r0 with the starting grade price address

	mov r1, #REG_PRICE	@ Move the price of regular grade gas in cents into r1	
	str r1, [r0]		@ Initialize the gas price
	add r1, #MID_PRICE_DIFF	@ Add the additional price of medium grade gas in cents to r1
	str r1, [r0, #4]!	@ Initialize the gas price
	sub r1, #MID_PRICE_DIFF	@ Remove the additional price of medium grade gas in cents from r1
	add r1, #PREM_PRICE_DIFF @ Add the additional price of premium grade gas in cents to r1
	str r1, [r0, #4]!		@ Initialize the gas price


@*******************
print_pump_data:
@*******************

@ Print out the pump's current inventory and totals spent

	ldr r0, =currentInvMsg  @ Load in the inventory message
	bl printf		@ Print out the inventory message
	mov r3, #0		@ Initialize the loop counter


@*******************
print_inv_loop:
@*******************

	ldr r0, =inventoryPattern @ Load in the inventory pattern message to r0
	bl load_grade_name	  @ Load the grade name's address
	ldr r2, =gradeInvs	  @ Load in the inventory to r2
	ldr r2, [r2, r3, LSL #2]  @ Load in the value of the inventory
	push { r3 }		  @ Save the loop counter
	bl printf		  @ Make the printf call
	pop { r3 }		  @ Bring back the loop counter
	add r3, #1		  @ Increment the loop counter
	cmp r3, #GRADE_COUNT	  @ Check if time to stop
	bne print_inv_loop	  @ If not, restart loop


	ldr r0, =blankLine	  @ Load r0 with blank line
	bl printf		  @ Make the printf call
	ldr r0, =totalSpentMsg    @ Load in the total spent message
	bl printf		  @ Print out the total spent message
	mov r3, #0		  @ Initialize the loop counter


@*******************
print_totals_loop:
@*******************

	ldr r0, =totalSpentPattern @ Load in the total spent pattern message to r0
	bl load_grade_name	  @ Load the grade name's address
	ldr r2, =gradeTotals	  @ Load in the starting grade total to r2
	ldr r2, [r2, r3, LSL #2]  @ Load in the value of the total
	push { r3 }		  @ Save the loop counter
	bl printf		  @ Make the printf call
	pop { r3 }		  @ Bring back the loop counter
	add r3, #1		  @ Increment the loop counter
	cmp r3, #GRADE_COUNT	  @ Check if time to stop
	bne print_totals_loop	  @ If not, restart loop
	ldr r0, =blankLine	  @ Load r0 with blank line
	bl printf		  @ Make the printf call
	ldr r0, =pumpClosedFlag	  @ Load the pump closed flag address
	ldr r0, [r0]		  @ Load the flag
	cmp r0, #1		  @ Check if flag is set
	bne grade_prompt	  @ If not, go prompt for the grade
	ldr r0, =pumpClosedMsg    @ Otherwise load r0 with the pump closed message address
	bl printf		  @ Make the printf call
	b myexit		  @ Terminate the program

	
@*******************
load_grade_name:
@*******************

@ Loads in the grade name between 0 and
@ (GRADE_COUNT - 1)

@ Takes r3 as a parameter for the grade int to print

@ Returns the address of the name in r1

	ldr r1, =gradeNames	  @ Load in the name address to r1
	ldr r2, =gradeNameLens	  @ Load the initial offset address to r2
	ldr r2, [r2, r3, LSL #2]  @ Load in the offset value
	add r1, r2		  @ Load in the name to r1
	bx lr


@*******************
grade_prompt:
@*******************

	ldr r0, =inputMsg @ Load in the input message
	bl printf	  @ Print the input message


@*******************
grade_input:
@*******************

@ Get the user's selected grade

	ldr r0, =inputCharPattern	@ Load the input pattern address into r0
	ldr r1, =gradeSelected		@ Load the selected grade variable address into r1
	bl scanf			@ Make the scanf call


@*******************
grade_validate:
@*******************

@ Confirm that the user selected a valid grade

	ldr r0, =gradeSelected  @ Load r0 with the grade selected address
	ldrb r0, [r0]		@ Load r0 with the grade selected value
	mov r3, #0		@ Initialize the loop counter


@*******************
grade_check_loop:
@*******************
	
	push { r0, r2 }		@ Save registers to the stack
	bl load_grade_name	@ Load in the next name
	pop { r0, r2 }		@ Reload in the registers
	ldrb r1, [r1]		@ Load the first letter of the grade name
	subs r2, r0, r1		@ Calculate the difference of the grade selected and the first letter
	cmpne r2, #32		@ Check if grade was selected with lowercase letter
	bne grade_loop_test	@ Skip to checking the loop state if grade not yet found

	ldr r4, =gradeInt	@ Load r4 with the address of the grade selection integer
	str r3, [r4]		@ Store the grade selection integer
	ldr r0, =gradeInvs	@ Load r0 with the starting address of the grade inventories
	ldr r0, [r0, r3, LSL #2]@ Load the inventory value
	cmp r0, #10		@ Check if there is at least a gallon
	bl load_grade_name	@ Reload the full grade name
	blt grade_closed	@ If closed, go handle that
	b grade_selected	@ Branch to grade selected


@*******************
grade_closed:
@*******************

	ldr r0, =gradeClosedMsg	@ Load the grade closed message address
	bl printf		@ Make the printf call
	b grade_prompt		@ Go prompt for another grade
	

@*******************
grade_loop_test:
@*******************

	add r3, #1		@ Increment counter
	cmp r3, #GRADE_COUNT	@ Check if time to stop
	beq special_char_check  @ If so, break from loop
	b grade_check_loop	@ Otherwise keep going


@*******************
special_char_check:
@*******************

	cmp r0, #47		@ Check if the special character '/' was entered
	bne grade_not_found	@ If not, the grade was not found
	ldr r0, =gradeSelectMsg @ Load r0 with the grade selection confirmation message 
	ldr r1, =invCodeMsg     @ Load r1 with the inventory code string
	bl printf		@ Make the printf call
	b print_pump_data	@ If true, go print the pump data


@*******************
grade_not_found:
@*******************

	mov r1, r0		  @ Move the user's input into r1
	ldr r0, =gradeNotFoundMsg @ Load r0 with the grade not found message
	bl printf		  @ Make the printf call
	bl readerror		  @ Clear the input buffer
	b grade_prompt		  @ Start back at the grade prompt


@*******************
grade_selected:
@*******************

	ldr r0, =gradeSelectMsg @ Load r0 with the grade selection confirmation message 
	bl printf		@ Make the printf call


@*******************
amount_prompt:
@*******************

	ldr r0, =payScanMsg 	@ Load r0 with the pay prompt
	bl printf		@ Make the printf call
	

@*******************
amount_input:
@*******************

@ Get the user's payment

	ldr r0, =inputNumPattern	@ Load the input pattern address into r0
	ldr r1, =paymentInput		@ Load the selected grade variable address into r1
	bl scanf			@ Make the scanf call


@*******************
amount_validate:
@*******************

@ Validate that the user entered an integer between 1 and 50

	cmp r0, #READERROR	 @ Check if there was a read error
	ldreq lr, =amount_prompt @ If there was, set the link register to contain the address of the amount prompt
	beq readerror		 @ Then go handle the read error
	ldr r0, =paymentInput	 @ If there was no read error, load r0 with the address of the payment
	ldr r0, [r0]		 @ Then load it with the user's entered payment value
	cmp r0, #1		 @ Compare it by subtraction to 1
	blt amount_prompt	 @ If it is less than 1, reprompt for a new value
	cmp r0, #50		 @ Compare it by subtraction to 50
	bgt amount_prompt	 @ If it is less than 50, reprompt for a new value
	mov r2, #100		 @ Load r2 with the cents conversion factor
	mul r3, r0, r2		 @ Convert the pay to cents
	ldr r0, =paymentInput	 @ Reload r0 with the address of the payment
	str r3, [r0]		 @ Store the payment in cents


@*******************
dispense:
@*******************

	ldr r3, =gradeInt	@ Load in the grade selected int address
	ldr r3, [r3]		@ Load in the grade int
	ldr r0, =gradePrices	@ Load in the starting grade prices address
	ldr r0, [r0, r3, LSL #2]@ Load in the price
	ldr r1, =gradeInvs	@ Load in the starting grade inventory address
	ldr r1, [r1, r3, LSL #2]@ Load in the inventory
	ldr r2, =paymentInput	@ Load in the payment address
	ldr r2, [r2]		@ Load in the payment
	mov r5, #10		@ Load the multiplier
	mul r4, r2, r5		@ Multiply payment by 10 to account for fuel being in tenths of gallons
	mov r2, r4		@ Transfer the new payment to r2
	mov r4, #0		@ Initialize the number of tenths of gallons to dispense


@*******************
dispense_loop:
@*******************

	subs r2, r0		@ Subtract the price in cents from the payment in cents, convert to tenths of gallons
	addpl r4, #1		@ Increment the number of tenths of gallons to dispense if enough payment
	bpl dispense_loop	@ Restart the loop unless payment has run out

	cmp r4, r1		@ Check if there is enough to dispense the requested amount
	bgt inadequate_fuel	@ If there is not, go handle that
	mov r1, r4		@ Load the amount of tenths of gallons to be dispensed


@*******************
update_grade:
@*******************

@ Updates the total spent and inventory for the grade
@ currently selected.

	ldr r3, =gradeInt	@ Load in the grade selected int address
	ldr r3, [r3]		@ Load in the grade int
 
	ldr r0, =gradeTotals	@ Load in the starting grade totals address
	ldr r4, [r0, r3, LSL #2]! @ Load in the current total
	push { r3, r4 }		@ Save the registers r3 and r4
	ldr r3, =paymentInput	@ Load in the payment address
	ldr r3, [r3]		@ Load in the payment
	bl convert_to_dollar	@ Convert the price to dollars
	pop { r3, r4 }		@ Reload the saved registers
	add r4, r2		@ Update the total
	str r4, [r0]		@ Store the total

	ldr r0, =gradeInvs	@ Load in the starting grade inventory address
	ldr r4, [r0, r3, LSL #2]! @ Load in the current inventory
	sub r4, r1		@ Update the inventory
	str r4, [r0]		@ Store the inventory
	

@*******************
print_results:
@*******************

	ldr r0, =amountDispensedMsg @ Load the amount dispensed message
	bl printf		    @ Make the printf call


@*******************
reset:
@*******************	

@ Reset the value stored for payment and go back to
@ prompt for a new grade if the pump is still open.
@ If the gas in every pump has fallen below a gallon,
@ close the pump.

	mov r0, #0		@ Initialize the loop counter
	ldr r1, =gradeInvs	@ Load r1 with the starting address of the grade inventories
	mov r3, #0		@ Initialize r3 with the number of grades closed


@*******************
reset_loop:
@*******************	

	
	ldr r2, [r1, r0, LSL #2]@ Load in the inventory
	cmp r2, #10		@ Check if there is at least a gallon
	addlt r3, #1		@ Increment the closed grade counter if this grade is closed
	add r0, #1		@ Increment the loop counter
	cmp r0, #GRADE_COUNT	@ See if all grades have been checked
	bne reset_loop		@ If not, keep checking

	cmp r3, #GRADE_COUNT	@ Once done, see if all grades closed
	bne restart		@ If the pump is still open, skip these next few lines
	ldr r0, =pumpClosedFlag @ Load in the pump closed flag that will close pump after printing data
	mov r1, #1		@ Move the flag into r1
	str r1, [r0]		@ Store the flag
	b print_pump_data	@ Print the pump data


@*******************
restart:
@*******************

@ If the pump is still open	

	ldr r0, =paymentInput	@ Load in the payment address
	mov r1, #0		@ Reset the payment val
	str r1, [r0]		@ Store the payment
	b grade_prompt		@ Go prompt for a new grade now that the fuel has been dispensed


@*******************
inadequate_fuel:
@*******************

@ Handle the case where the user requests more fuel than is available
@ Parameters:
@ r0 should contain price of gallon of grade in cents
@ r1 should contain inventory in tenths of gallons

	mov r2, #0	@ Initialize variable for quotient


@*******************
convert_inv_loop:
@*******************

@ Convert the inventory to gallons by dividing by 10

	subs r1, #10	@ Subtract divisor from dividend
	addpl r2, #1	@ If divisor still fitting, increment partial quotient
	bpl convert_inv_loop @ And restart loop


@*******************
calc_maximum:
@*******************

@ Calculate the maximum cents for which adequate fuel is available

	mul r3, r2, r0  @ Calculate the amount of cents avaliable and store in r3
	bl convert_to_dollar @ Convert to dollars
	b print_fuel_error   @ Go print the fuel error


@*******************
convert_to_dollar:
@*******************

@ Convert price from cents to dollars
@ Parameter:
@ r3 - The price in cents
@ Return:
@ r2 - The price in dollars

	mov r2, #0	@ Initialize variable for quotient


@*******************
convert_dollar_loop:
@*******************

	subs r3, #100	@ Subtract divisor from dividend
	addpl r2, #1	@ If divisor still fitting, increment partial quotient
	bpl convert_dollar_loop @ And restart loop
	bx lr


@*******************
print_fuel_error:
@*******************

@ Alert the user that not enough fuel is available
@ Notify user of the maximum dollar amount that may
@ be requested for this grade.

	ldr r0, =inadequateFuelMsg	@ Load the address of the format string
	mov r1, r2			@ Load the max dollar amount
	bl printf			@ Make the printf call
	b amount_prompt			@ Go prompt user to enter a new amount


@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer and ask
@ for the user to enter a value. 
@ An invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

	push { lr }
	ldr r0,=strInputPattern
	ldr r1, =strInputError   @ Put address into r1 for read.
	bl scanf                 @ scan the keyboard.
	pop { lr }
	bx lr


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @SVC call to exit
   svc 0         @Make the system call. 


.data
.balign 4
startMsg: .asciz "Welcome to the gasoline pump.\n\n"
@ Startup message for when the program begins

.balign 4
inputMsg: .asciz "Select the grade of gas to dispense (R, M, or P) or / to print pump data:\n"
@ Prompt for the user to select the grade of gas

.balign 4
currentInvMsg: .asciz "Current inventory of gasoline (in tenths of gallons) is:\n\n"
@ Header message for the current inventory output

.balign 4
totalSpentMsg: .asciz "Dollar amount dispensed by grade:\n\n"
@ Header message for the total spent on each gas type

.balign 4
gradeSelectMsg: .asciz "You selected %s.\n"
@ Output the user's selected gas grade

.balign 4
gradeNotFoundMsg: .asciz "The grade starting with %c was not found.\n"
@ Output the user's selected gas grade

.balign 4
amountDispensedMsg: .asciz "%d tenths of gallons have been dispensed.\n"
@ Output the amount of gas dispensed

.balign 4
inadequateFuelMsg: .asciz "This pump does not have enough fuel to dispense the requested \ndollar amount's worth. Please enter an amount less than $%d.\n"
@ Output message for inadequate fuel

.balign 4
gradeClosedMsg: .asciz "The %s grade is closed due to insufficient inventory.\nPlease choose a different grade.\n"
@ Output the grade closed message

.balign 4
pumpClosedMsg: .asciz "All grades are now closed due to insufficient inventory.\nThe gas pump is now closing...\n"
@ Output the pump closed message

.balign 4
invCodeMsg: .asciz "the inventory code /, printing pump data..."
@ Output message when user enters inventory code

.balign 4
inputCharPattern: .asciz "%s"
@ Format string for char

.balign 4
inputNumPattern: .asciz "%d"
@ Format string for n

.balign 4
inventoryPattern: .asciz "%s \t %d\n"
@ Format string for printing out the inventory

.balign 4
totalSpentPattern: .asciz "%s \t $%d\n"
@ Format string for printing out the totals spent

.balign 4
payScanMsg: .asciz "Enter the dollar amount to dispense (as an integer between 1 and 50):\n"
@ Prompt for the user to enter the dollar amount of gas to dispense

.balign 4
paymentInput: .word 0
@ Integer value to store payment in cents

.balign 4
gradeNameLens: .word 0, 0, 0
@ The offset for each name assigned to the grades of gas

.balign 4
gradeNames: .asciz "Regular", "Mid-grade", "Premium"
@ The name assigned to each grade of gas

.balign 4
gradeInvs: .word 0, 0, 0
@ The inventory of each grade of gas

.balign 4
gradePrices: .word 0, 0, 0
@ The price of each grade of gas in cents

.balign 4
gradeTotals: .word 0, 0, 0
@ The total spent on each grade of gas in dollars

.balign 4
gradeSelected: .byte ' '
@ The grade selected by the user

.balign 4
gradeInt: .word 0
@ The grade choice as an int between 0 and
@ GRADE_COUNT - 1

.balign 4
pumpClosedFlag: .word 0
@ The flag that shows if the pump is closed

.balign 4
blankLine: .asciz "\n"

.balign 4
strInputPattern: .asciz "%[^\n]"
@ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4
@ For the read error handling to read in the input

.global printf

.global scanf
