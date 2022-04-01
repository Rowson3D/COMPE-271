########################################################
# Final Project Source COMPE271 - Guessing Game in MIPS
#
# By : Jarrod Rowson - 826453843
# Date Started: March 25, 2021
# Update 1: March 29, 2021 - point system implementation
# Update 2: April 15, 2021 - guess and remaining attempts display
# Update 3: April 21, 2021 - round 1D array implementation
#
# Description : A game in which the system will generate
#        a random number for the user to guess.
#        Alongside the main guessing game, the program
#        includes sub-category options such as
#        player settings, guessing difficulty settings,
#        a cheating mode, point system, and
#        a round counter.
#
# Built for CompE 271, K. Arnold.
#
########################################################

.eqv numbers_of_rounds 10
.eqv rounds_array_size 40 # rounds_array_size = numbers_of_rounds * 4 = 10 * 4 = 40
.data
points: .word 0 # default value is 0
lower: .word 1 # default value is 1
upper: .word 100 # default value is 100
randNum: .word 1 # default value is 1
attempts: .word 10 # default value is 10
show_attempts: .word 1 # true 1
show_points: .word 1 # true 1
main_menu_msg: .ascii "<------- Menu -------->\n"
           .ascii " 1. Play the game\n"
           .ascii " 2. Settings\n"
           .ascii " 3. Difficulty settings (Bounds)\n"
           .ascii " 4. Player information\n"
           .ascii " 5. Game information\n"
           .ascii " 6. Change remaining attempts difficulty\n"
           .ascii " 7. Cheat and see the current round's random number.\n"
           .ascii " 0. Quit the game\n\n"
           .asciiz "Please choose a setting: "
main_option_error_msg: .asciiz "***Not a valid input, choose an option.***\n\n"
.align 4
round_number: .word 1 # default value is 0
rounds_array: .space rounds_array_size

    .text
    .globl  main

main:     
    li $v0,30
    syscall
    move $a1,$a0 # time
    li $a0,1 # id of pseudorandom
    syscall # srand(time(NULL));
    # iniatize randNum
    lw $a0,upper
    jal gen_rand
    sw $v0,randNum # randNum = gen_rand(upper);
    
main_loop:
    lw $t0,round_number # check if all the rounds are done
    bgt $t0,numbers_of_rounds,main_player_info_exit
    li $v0,4
    la $a0,main_menu_msg
    syscall
    li $v0,5
    syscall # $v0 = option
    blt $v0,$zero,main_error
    # menu option range of 0:8
    # quit if the menu_option is = 0
    beq $v0,$zero,main_exit
    beq $v0,1,main_play
    beq $v0,2,main_settings
    beq $v0,3,main_difficuly
    beq $v0,4,main_player_info
    beq $v0,5,main_game_info
    beq $v0,6,main_attempts
    bgt $v0,7,main_error
    jal cheat_random_number
    j main_loop    
main_play:
    jal play_game
    j main_loop
main_settings:
    jal display_settings
    j main_loop
main_difficuly:
    jal set_difficulty
    j main_loop
main_player_info:
    jal player_information
    j main_loop
main_game_info:
    jal game_information
    j main_loop
main_attempts:
    jal remaining_attempts
    j main_loop
main_player_info_exit:
    jal player_information
main_exit:
    # exit
    li $v0,10 # exit (terminate execution)
    syscall
main_error:
    li $v0,4
    la $a0,main_menu_msg
    syscall    
    j main_loop
gen_rand:
    # $a0 = upper
    li $v0,42
    move $a1,$a0
    li $a0,1 # id
    syscall
    addi $v0,$a0,1 # return rand() % upper + 1;
    jr $ra
.data
play_game_round_msg1: .asciiz "Round Number ("
play_game_round_msg2: .asciiz "|"
play_game_round_msg3: .asciiz ").\n"
play_game_msg1: .asciiz "Guess a number between "
play_game_msg2: .asciiz " and "
play_game_msg3: .asciiz ".\n"
play_game_msg4: .asciiz " attempts remaining. \n"
play_game_msg51: .asciiz "Currently you have "
play_game_msg52: .asciiz " points.\n"
play_game_msg6: .asciiz "Game over, you've run out of attempts.\n\n"
play_game_msg7: .asciiz "What is your guess? "
play_game_msg8: .asciiz "\nYou got it correct\n"
play_game_msg9: .asciiz "The guessed number was too low.\n"
play_game_msg10: .asciiz "The guessed number was too high.\n"
.text    
play_game:
    addiu $sp,$sp,-12
    sw $ra,0($sp)
    sw $s0,4($sp)
    sw $s1,8($sp)
    lw $s0,attempts # we use $s0 as attempts
    
    li $v0,4
    la $a0,play_game_round_msg1
    syscall
    

    # we display round_number here
    li $v0,1
    lw $a0,round_number
    syscall
    
    li $v0,4
    la $a0,play_game_round_msg2
    syscall
    
    # we display here numbers_of_rounds
    li $v0,1
    li $a0,numbers_of_rounds
    syscall
    
    li $v0,4
    la $a0,play_game_round_msg3
    syscall
    
    # we use $s1 as user_guess
    li $v0,4
    la $a0,play_game_msg1
    syscall
    
    # print lower bounds
    li $v0,1
    lw $a0,lower
    syscall
    
    li $v0,4
    la $a0,play_game_msg2
    syscall
    
    # print upper bounds
    li $v0,1
    lw $a0,upper
    syscall
    
    li $v0,4
    la $a0,play_game_msg3
    syscall
    
play_game_loop:
    
    lw $t0,show_attempts
    beq $t0,$zero,play_game_check_show_points
    # show_attempts = true
    # print attempts
    li $v0,1
    move $a0,$s0
    syscall
    
    li $v0,4
    la $a0,play_game_msg4
    syscall
    
play_game_check_show_points:
    lw $t0,show_points
    beq $t0,$zero,play_game_check_attempts
    # show_points = true
    
    li $v0,4
    la $a0,play_game_msg51
    syscall
    
    li $v0,1
    lw $a0,points
    syscall
    
    li $v0,4
    la $a0,play_game_msg52
    syscall
    
play_game_check_attempts:
    bgt $s0,$zero,play_game_play
    # attempts <= 0
    li $v0,4
    la $a0,play_game_msg6
    syscall
    
    lw $t0,round_number # $t0 = round_number
    addi $t0,$t0,-1 # $t0 = round_number -1
    sll $t0,$t0,2 # $t0 = 4*(round_number -1)
    la $t1,rounds_array
    addu $t0,$t0,$t1 # $t0 = &rounds_array[round_number-1]
    li $t1,0
    sw $t1,0($t0) # rounds_array[round_number-1] = 0;
    lw $t0,round_number
    addi $t0,$t0,1
    sw $t0,round_number # round_number ++
    
    j play_game_done
play_game_play: #main play method
    
    li $v0,4
    la $a0,play_game_msg7
    syscall
    
    # read user_guess
    li $v0,5
    syscall
    move $s1,$v0
    
    lw $t0,randNum
    blt $s1,$t0,play_game_too_low
    bgt $s1,$t0,play_game_too_high
    li $v0,4
    la $a0,play_game_msg8
    syscall
    lw $t0,points
    add $t0,$t0,$s0
    sw $t0,points # points += attempts;
    lw $t0,round_number # $t0 = round_number
    addi $t0,$t0,-1 # $t0 = round_number -1
    sll $t0,$t0,2 # $t0 = 4*(round_number -1)
    la $t1,rounds_array
    addu $t0,$t0,$t1 # $t0 = &rounds_array[round_number-1]
    sw $s0,0($t0) # rounds_array[round_number-1] = attempts;
    lw $t0,round_number
    addi $t0,$t0,1
    sw $t0,round_number # round_number ++
    j play_game_done
play_game_too_low:
    li $v0,4
    la $a0,play_game_msg9
    syscall
    addi $s0,$s0,-1 # --attempts; //too low
    j play_game_loop
play_game_too_high:
    li $v0,4
    la $a0,play_game_msg10
    syscall
    addi $s0,$s0,-1 # --attempts; //too high
    j play_game_loop
play_game_done:
    # we change the random number when play game -is done
    lw $a0,upper
    jal gen_rand
    sw $v0,randNum # randNum = gen_rand(upper);
    
    lw $ra,0($sp)
    lw $s0,4($sp)
    lw $s1,8($sp)
    addiu $sp,$sp,12
    jr $ra
.data
display_settings_msg1: .ascii "1. Show remaining attempts\n"
               .ascii "2. Hide remaining attempts\n"
               .ascii "3. Show points\n"
               .ascii "4. Hide points\n\n"
               .asciiz "Please choose an option: "
display_settings_msg2: .asciiz "Showing attempts set to: "
display_settings_msg3: .asciiz "Show points allotted: "
display_settings_msg4: .asciiz "true\n\n"
display_settings_msg5: .asciiz "false\n\n"
display_settings_msg6: .asciiz "***Not a valid input for display settings menu, choose an option.***\n\n"
.text
display_settings:
    li $v0,4
    la $a0,display_settings_msg1
    syscall    
    # read option
    li $v0,5
    syscall
    ble $v0,$zero,display_settings_error
    bgt $v0,4,display_settings_error
    beq $v0,1,display_settings_enable_show_attempts
    beq $v0,2,display_settings_disable_show_attempts
    beq $v0,3,display_settings_enable_show_points
    beq $v0,4,display_settings_disable_show_points
display_settings_error:
    li $v0,4
    la $a0,display_settings_msg6
    syscall    
    j display_settings
display_settings_enable_show_attempts:
    li $t0,1
    sw $t0,show_attempts
    j display_settings_show_update
display_settings_disable_show_attempts:
    li $t0,0
    sw $t0,show_attempts
    j display_settings_show_update
display_settings_enable_show_points:
    li $t0,1
    sw $t0,show_points
    j display_settings_show_update
display_settings_disable_show_points:
    li $t0,0
    sw $t0,show_points
display_settings_show_update:
    li $v0,4
    la $a0,display_settings_msg2
    syscall    
    lw $t0,show_attempts
    beq $t0,$zero,display_settings_show_attempts_false
    # true here
    li $v0,4
    la $a0,display_settings_msg4
    syscall    
    j display_settings_check_show_points
display_settings_show_attempts_false:
    li $v0,4
    la $a0,display_settings_msg5
    syscall    
display_settings_check_show_points:
    li $v0,4
    la $a0,display_settings_msg3
    syscall    
    lw $t0,show_points
    beq $t0,$zero,display_settings_show_points_false
    # here true
    li $v0,4
    la $a0,display_settings_msg4
    syscall    
    j display_settings_done
display_settings_show_points_false:
    li $v0,4
    la $a0,display_settings_msg5
    syscall    
display_settings_done:
    jr $ra
.data
set_difficulty_msg1: .ascii "1. Easy\n"
             .ascii "2. Normal\n"
             .ascii "3. Hard\n"
             .ascii "4. Expert\n"
             .ascii "5. Impossible\n\n"
             .asciiz "Enter a difficulty option (Default = 1): "
set_difficulty_msg2: .asciiz "You've modified the difficulty to "
set_difficulty_msg3: .asciiz " resulting in a change of the upper bound to "
set_difficulty_msg4: .asciiz ".\n\n"
.text
set_difficulty:
    li $v0,4
    la $a0,set_difficulty_msg1
    syscall    
    # read option
    li $v0,5
    syscall
    move $t1,$v0
    ble $t1,1,set_difficulty_default
    beq $t1,2,set_difficulty_normal
    beq $t1,3,set_difficulty_hard
    beq $t1,4,set_difficulty_expert
    bgt $t1,5,set_difficulty_default
set_difficulty_impossible:
    li $t0,500
    sw $t0,upper
    j set_difficulty_show
set_difficulty_normal:
    li $t0,200
    sw $t0,upper
    j set_difficulty_show
set_difficulty_hard:
    li $t0,300
    sw $t0,upper
    j set_difficulty_show
set_difficulty_expert:
    li $t0,400
    sw $t0,upper
    j set_difficulty_show
set_difficulty_default:
    li $t0,100
    sw $t0,upper
    li $t1,1
set_difficulty_show:
    li $v0,4
    la $a0,set_difficulty_msg2
    syscall    
    # print option
    li $v0,1
    move $a0,$t1
    syscall
    
    li $v0,4
    la $a0,set_difficulty_msg3
    syscall    
    # print upper
    li $v0,1
    lw $a0,upper
    syscall
    li $v0,4
    la $a0,set_difficulty_msg4
    syscall    
    
set_difficulty_done:
    jr $ra
    
.data
player_information_msg1: .asciiz "Current points: "
player_information_msg2: .asciiz " .\n"
player_information_msg3: .asciiz "Round "
player_information_msg4: .asciiz " you earned "
player_information_msg5: .asciiz " points.\n"
player_information_msg6: .asciiz "*************************\n"
.text
player_information:
    # for (i=0;i<min(round_number-1,numbers_of_rounds);i++)
    # printf("Round %d you earned %d points.\n",i+1,rounds_array[i]);
    # we use $t2 as i
    li $t2,0 # i= 0
player_information_for_loop:
    lw $t0,round_number
    addi $t0,$t0,-1 # $t0 = round_number -1
    li $t1,numbers_of_rounds
    ble $t0,$t1,player_information_for_loop_check
    li $t0,numbers_of_rounds # $t0 = numbers_of_rounds
    # $t0 = min(round_number-1,numbers_of_rounds)
player_information_for_loop_check:
    bge $t2,$t0,player_information_for_loop_done
    # here i<numbers_of_rounds
    
    li $v0,4
    la $a0,player_information_msg3
    syscall
    # we print i+1
    li $v0,1
    addi $a0,$t2,1
    syscall
    li $v0,4
    la $a0,player_information_msg4
    syscall
    # we print rounds_array[i]
    sll $t0,$t2,2 # $t0 = 4*i
    la $t1,rounds_array
    addu $t0,$t0,$t1 # $t0 = &rounds_array[i]
    li $v0,1
    lw $a0,0($t0) # $a0 = rounds_array[i]
    syscall
    li $v0,4
    la $a0,player_information_msg5
    syscall
    
    addi $t2,$t2,1 # i++
    j player_information_for_loop
player_information_for_loop_done:
    li $v0,4
    la $a0,player_information_msg6
    syscall
    
    li $v0,4
    la $a0,player_information_msg1
    syscall
    # print point
    li $v0,1
    lw $a0,points
    syscall
    li $v0,4
    la $a0,player_information_msg2
    syscall
    jr $ra
.data
game_information_msg1: "Current upper bound: "
game_information_msg2: "Remaining attempts: "
game_information_msg3: "Show attempts: "
game_information_msg4: "Show points: "
.text
game_information:
    li $v0,4
    la $a0,game_information_msg1
    syscall    
    # print upper
    li $v0,1
    lw $a0,upper
    syscall
    # print new line
    li $v0,11
    li $a0,10
    syscall
    
    li $v0,4
    la $a0,game_information_msg2
    syscall    
    
    # print attempts
    li $v0,1
    lw $a0,attempts
    syscall
    
    # print new line
    li $v0,11
    li $a0,10
    syscall
    
    li $v0,4
    la $a0,game_information_msg3
    syscall    
    
    lw $t0,show_attempts
    beq $t0,$zero,game_information_attempts_false
    # true here
    li $v0,4
    la $a0,display_settings_msg4
    syscall    
    j game_information_check_show_points
game_information_attempts_false:
    li $v0,4
    la $a0,display_settings_msg5
    syscall    
game_information_check_show_points:
    
    li $v0,4
    la $a0,game_information_msg4
    syscall    
    
    lw $t0,show_points
    beq $t0,$zero,game_information_points_false
    # true here
    li $v0,4
    la $a0,display_settings_msg4
    syscall    
    j game_information_done
game_information_points_false:
    li $v0,4
    la $a0,display_settings_msg5
    syscall    
game_information_done:
    jr $ra
.data
remaining_attempts_msg1: .ascii "1. Easy\n"
             .ascii "2. Normal\n"
             .ascii "3. Hard\n\n"
             .asciiz "Enter a difficulty option (Default = 1): "
remaining_attempts_msg2: .asciiz "You've modified the difficulty to "
remaining_attempts_msg3: .asciiz  " resulting in a change of the remaining attempts to "
remaining_attempts_msg4: .asciiz ".\n\n"
.text
remaining_attempts:
    li $v0,4
    la $a0,remaining_attempts_msg1
    syscall    
    # read option
    li $v0,5
    syscall
    move $t1,$v0
    ble $t1,1,remaining_attempts_easy
    beq $t1,2,remaining_attempts_normal
    bgt $t1,3,remaining_attempts_easy
remaining_attempts_hard:
    li $t0,3
    sw $t0,attempts
    j remaining_attempts_show
remaining_attempts_normal:
    li $t0,5
    sw $t0,attempts
    j remaining_attempts_show
remaining_attempts_easy:
    li $t0,10
    sw $t0,attempts
    li $t1,1
remaining_attempts_show:
    li $v0,4
    la $a0,remaining_attempts_msg2
    syscall    
    
    # print option
    li $v0,1
    move $a0,$t1
    syscall
    
    li $v0,4
    la $a0,remaining_attempts_msg3
    syscall    
    
    # print attempts
    li $v0,1
    lw $a0,attempts
    syscall
    
    li $v0,4
    la $a0,remaining_attempts_msg4
    syscall    
    
    jr $ra
.data
cheat_random_number_msg1: .asciiz "[Cheating] The random number is "
cheat_random_number_msg2: .asciiz ".\n"
.text
cheat_random_number:
    li $v0,4
    la $a0,cheat_random_number_msg1
    syscall    
    # print randNum
    li $v0,1
    lw $a0,randNum
    syscall
    
    li $v0,4
    la $a0,cheat_random_number_msg2
    syscall    
    jr $ra
    
# ----- EOF ----- #
