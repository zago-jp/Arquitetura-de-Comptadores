.section .bitmap
__bitmap_start:
.space 1024

.section .data
    .align 4
pos_x:          .word 0
pos_y:          .word 16
score:          .word 0
move_processed: .word 0
prev_pos_x:     .word 0
prev_pos_y:     .word 16

victory_msg:
    .ascii "VICTORY! SCORE: "
victory_len:
    .word 16

gameover_msg:
    .ascii "GAME OVER! SCORE: "
gameover_len:
    .word 18

.section .text
    .globl main

# Definições
.equ KEY_W, 0x77        # 'w' (minúsculo)
.equ KEY_A, 0x61        # 'a'
.equ KEY_S, 0x73        # 's'
.equ KEY_D, 0x64        # 'd'

.equ MAP_WIDTH, 32
.equ MAP_HEIGHT, 32
.equ BYTES_PER_ROW, 32
.equ BITMAP_SIZE, 1024

.equ START_X, 0
.equ START_Y, 16
.equ END_X, 31
.equ END_Y, 15

# Cores (ajustadas para visibilidade no emulsiV)
.equ COLOR_WALL, 0x00   # Preto
.equ COLOR_PATH, 0xFF   # Branco
.equ COLOR_PLAYER, 0xE0 # Vermelho

.text
main:
    call init_game
    call clear_bitmap
    call draw_map  # Desenha o mapa uma vez na inicialização

game_loop:
    call draw_player  # Atualiza apenas o personagem
    call read_input
    call update_game
    j game_loop

init_game:
    la t0, pos_x
    li t1, START_X
    sw t1, 0(t0)
    la t0, pos_y
    li t1, START_Y
    sw t1, 0(t0)
    la t0, score
    sw zero, 0(t0)
    la t0, move_processed
    sw zero, 0(t0)  # Inicializa a flag como 0
    la t0, prev_pos_x
    sw t1, 0(t0)    # Inicializa a posição anterior
    la t0, prev_pos_y
    sw t1, 0(t0)
    ret

clear_bitmap:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    la s0, __bitmap_start
    li t0, BITMAP_SIZE
    li t1, COLOR_WALL
clear_loop:
    sb t1, 0(s0)
    addi s0, s0, 1
    addi t0, t0, -1
    bnez t0, clear_loop

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

draw_map:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    la s0, __bitmap_start
    li s1, 0

draw_y_loop:
    li s2, 0

draw_x_loop:
    mv a0, s2
    mv a1, s1
    call is_path
    beqz a0, draw_wall
    li s3, COLOR_PATH
    j draw_pixel

draw_wall:
    li s3, COLOR_WALL

draw_pixel:
    slli t0, s1, 5
    add t0, t0, s2
    add s4, s0, t0
    sb s3, 0(s4)
    addi s2, s2, 1
    li t0, MAP_WIDTH
    blt s2, t0, draw_x_loop
    addi s1, s1, 1
    li t0, MAP_HEIGHT
    blt s1, t0, draw_y_loop

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

is_path:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)

    mv s0, a0    # x
    mv s1, a1    # y

    # Entrada: (0,16)
    li t0, 0
    bne s0, t0, check_bottom
    li t0, 16
    beq s1, t0, is_path_true
    j not_path

check_bottom:
    # Caminho inferior: y=16, x in [0..13]
    li t0, 16
    bne s1, t0, check_left
    li t0, 0
    blt s0, t0, not_path
    li t0, 13
    ble s0, t0, is_path_true
    j not_path

check_left:
    # Subida esquerda: x=13, y in [1..16]
    li t0, 13
    bne s0, t0, check_top
    li t0, 1
    blt s1, t0, not_path
    li t0, 16
    ble s1, t0, is_path_true
    j not_path

check_top:
    # Caminho superior: y=1, x in [13..30]
    li t0, 1
    bne s1, t0, check_right
    li t0, 13
    blt s0, t0, not_path
    li t0, 30
    ble s0, t0, is_path_true
    j not_path

check_right:
    # Descida direita: x=30, y in [1..16]
    li t0, 30
    bne s0, t0, check_goal
    li t0, 1
    blt s1, t0, not_path
    li t0, 16
    ble s1, t0, is_path_true
    j not_path

check_goal:
    # Objetivo final: (31,15)
    li t0, 31
    bne s0, t0, not_path
    li t0, 15
    beq s1, t0, is_path_true
    j not_path

is_path_true:
    li a0, 1
    j is_path_done

not_path:
    li a0, 0

is_path_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret

draw_player:
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    la t0, pos_x
    lw s0, 0(t0)  # x atual
    la t0, pos_y
    lw s1, 0(t0)  # y atual
    la t0, prev_pos_x
    lw s2, 0(t0)  # x anterior
    la t0, prev_pos_y
    lw s3, 0(t0)  # y anterior

    # Verifica se a posição mudou
    bne s0, s2, update_position
    bne s1, s3, update_position
    j done  # Sai se a posição não mudou

update_position:
    # Restaura a posição anterior
    la t0, __bitmap_start
    slli t1, s3, 5
    add t1, t1, s2
    add t2, t0, t1
    mv a0, s2
    mv a1, s3
    call is_path
    beqz a0, set_wall
    li t3, COLOR_PATH
    j set_prev

set_wall:
    li t3, COLOR_WALL

set_prev:
    sb t3, 0(t2)

    # Desenha a nova posição
    la t0, __bitmap_start
    slli t1, s1, 5
    add t1, t1, s0
    add t1, t0, t1
    li t2, COLOR_PLAYER
    sb t2, 0(t1)

    # Atualiza as posições anteriores
    la t0, prev_pos_x
    sw s0, 0(t0)
    la t0, prev_pos_y
    sw s1, 0(t0)

done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20
    ret

read_input:
    li t0, 0xB0000000
    lb t1, 0(t0)
    andi t1, t1, 0x40
    beqz t1, no_input
    lb a0, 1(t0)
    ret
no_input:
    li a0, 0
    ret

update_game:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    la t0, pos_x
    lw t1, 0(t0)
    la t0, pos_y
    lw t2, 0(t0)
    li t3, END_X
    li t4, END_Y
    bne t1, t3, check_input
    bne t2, t4, check_input
    
    # Vitória - carrega score em a0
    la t0, score
    lw a0, 0(t0)
    j victory

check_input:
    beqz a0, update_done
    la t0, move_processed
    lw t1, 0(t0)
    bnez t1, update_done  # Ignora se movimento já foi processado
    li t0, KEY_W
    beq a0, t0, move_up
    li t0, KEY_S
    beq a0, t0, move_down
    li t0, KEY_A
    beq a0, t0, move_left
    li t0, KEY_D
    beq a0, t0, move_right
    j update_done

move_up:
    la t0, pos_y
    lw t1, 0(t0)
    addi t2, t1, -1
    mv a1, t2
    la t0, pos_x
    lw a0, 0(t0)
    call is_path
    beqz a0, game_over_move
    la t0, pos_y
    sw t2, 0(t0)
    j valid_move

move_down:
    la t0, pos_y
    lw t1, 0(t0)
    addi t2, t1, 1
    mv a1, t2
    la t0, pos_x
    lw a0, 0(t0)
    call is_path
    beqz a0, game_over_move
    la t0, pos_y
    sw t2, 0(t0)
    j valid_move

move_left:
    la t0, pos_x
    lw t1, 0(t0)
    addi t2, t1, -1
    mv a0, t2
    la t0, pos_y
    lw a1, 0(t0)
    call is_path
    beqz a0, game_over_move
    la t0, pos_x
    sw t2, 0(t0)
    j valid_move

move_right:
    la t0, pos_x
    lw t1, 0(t0)
    addi t2, t1, 1
    mv a0, t2
    la t0, pos_y
    lw a1, 0(t0)
    call is_path
    beqz a0, game_over_move
    la t0, pos_x
    sw t2, 0(t0)
    j valid_move

game_over_move:
    # Game over - carrega score em a0
    la t0, score
    lw a0, 0(t0)
    j game_over

valid_move:
    la t0, score
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    la t0, move_processed
    li t1, 1
    sw t1, 0(t0)  # Marca que o movimento foi processado
    li t0, 0xB0000001
    sb zero, 0(t0)  # Tentativa de limpar o buffer
    j update_done

victory:
    mv s0, a0           # Salva o score em s0
    
    # Imprime mensagem de vitória
    la t0, victory_msg
    lw t1, victory_len
    li t2, 0xC0000000   # endereço de saída
    
victory_msg_loop:
    lb a0, 0(t0)
    sb a0, 0(t2)
    addi t0, t0, 1
    addi t1, t1, -1
    bnez t1, victory_msg_loop
    
    # Imprime o score
    mv a0, s0           # Recupera o score
    call print_number
    
    j victory_end

game_over:
    mv s0, a0           # Salva o score em s0
    
    # Imprime mensagem de game over
    la t0, gameover_msg
    lw t1, gameover_len
    li t2, 0xC0000000   # endereço de saída
    
gameover_msg_loop:
    lb a0, 0(t0)
    sb a0, 0(t2)
    addi t0, t0, 1
    addi t1, t1, -1
    bnez t1, gameover_msg_loop
    
    mv a0, s0
    call print_number
    
    j gameover_end

print_number:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    
    mv s0, a0           # Número a ser impresso
    li s1, 10           # Divisor
    li s2, 0            # Contador de dígitos
    li s3, 0xC0000000   # Endereço de saída
    li s4, 0            # Dígito atual
    
    bnez s0, convert_digits
    li a0, '0'
    sb a0, 0(s3)
    j print_done
    
convert_digits:
    beqz s0, print_digits
    
    # Divide s0 por 10 usando subtração repetida
    mv t0, s0           # Cópia do número
    li t1, 0            # Contador para divisão
    
division_loop:
    blt t0, s1, division_done
    sub t0, t0, s1
    addi t1, t1, 1
    j division_loop
    
division_done:
    addi t0, t0, '0'    # Converte resto para ASCII
    addi sp, sp, -1     # Empilha o dígito
    sb t0, 0(sp)
    addi s2, s2, 1      # Incrementa contador
    
    mv s0, t1           # Próximo número a dividir = quociente
    j convert_digits
    
print_digits:
    beqz s2, print_done
    lb a0, 0(sp)        # Desempilha dígito
    addi sp, sp, 1
    sb a0, 0(s3)
    addi s2, s2, -1
    j print_digits
    
print_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

divide:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    mv s0, a0           # Dividendo
    mv s1, a1           # Divisor
    
    # Casos especiais
    beqz s1, div_by_zero  # Divisão por zero
    beqz s0, div_zero     # Dividendo zero
    
    li t0, 0            # Quociente
    mv t1, s0           # Resto (inicialmente = dividendo)
    
div_loop:
    blt t1, s1, div_done
    sub t1, t1, s1
    addi t0, t0, 1
    j div_loop
    
div_done:
    mv a0, t0           # Quociente
    mv a1, t1           # Resto
    j div_end
    
div_by_zero:
    # Divisão por zero - retorna 0 para ambos
    li a0, 0
    li a1, 0
    j div_end
    
div_zero:
    # Dividendo zero - retorna 0
    li a0, 0
    li a1, 0
    
div_end:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

update_done:
    la t0, move_processed
    sw zero, 0(t0)  # Reseta a flag para o próximo ciclo
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

victory_end:
    j victory_end

gameover_end:
    j gameover_end

