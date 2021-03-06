#include "video.h"
#include "input.h"

#define PADDLE_SPEED 512

	.text
	.arm
	.align	2
	
	.global init
	.type init, %function
init:
	stmfd		sp!, {fp, lr}
	add			fp, sp, #4
	
	@ Set video mode
	ldr			R3, =MODE_0_2D
	
	ldr			R2, =REG_DISPCNT
	str			R3, [R2]
	
	ldr			R2, =REG_DISPCNT_SUB
	str			R3, [R2]
	
	
	@ Set VRAM banks
	movs		R2, #(VRAM_ENABLE | VRAM_A_MAIN_BG)
	ldr			R3, =VRAM_A_CR
	strb		R2, [R3]
	
	movs		R2, #(VRAM_ENABLE | VRAM_B_MAIN_SPRITE)
	ldr			R3, =VRAM_B_CR
	strb		R2, [R3]
	
	movs		R2, #(VRAM_ENABLE | VRAM_C_SUB_BG)
	ldr			R3, =VRAM_C_CR
	strb		R2, [R3]
	
	movs		R2, #(VRAM_ENABLE | VRAM_D_SUB_SPRITE)
	ldr			R3, =VRAM_D_CR
	strb		R2, [R3]
	
	
	@ Init OAM
	ldr			R0, =oamMain
	mov			R1, #SpriteMapping_1D_32
	mov			R2, #0
	bl			oamInit
	
	ldr			R0, =oamSub
	mov			R1, #SpriteMapping_1D_32
	mov			R2, #0
	bl			oamInit
	
	sub			sp, fp, #4
	ldmfd		sp!, {fp, lr}
	bx			lr


	.global respawnBall
	.type respawnBall, %function
respawnBall:
	push		{R0, R1}
	
	ldr			R1, =ballX
	mov			R0, #120
	lsl			R0, #8
	str			R0, [R1]
	
	ldr			R1, =ballY
	mov			R0, #88
	lsl			R0, #8
	str			R0, [R1]
	
	pop			{R0, R1}
	bx			lr


	.global main
	.type main, %function
main:
	bl			init
	
	@ Set BG_PALETTE and BG_PALETTE_SUB
	ldr			R3, =BLACK
	
	ldr			R2, =BG_PALETTE
	strh		R3, [R2]
	
	ldr			R2, =BG_PALETTE_SUB
	strh		R3, [R2]
	
	
	@ Set SPRITE_PALETTE and SPRITE_PALETTE_SUB
	ldr			R3, =WHITE
	
	ldr			R2, =SPRITE_PALETTE
	strh		R3, [R2, #2]
	
	ldr			R2, =SPRITE_PALETTE_SUB
	strh		R3, [R2, #2]
	
	
	@ Setup sprites
	
	bl			allocateBall
	bl			writeBall
	
	bl			allocatePaddle
	bl			writePaddle
	
	
	@ Spawn ball
	bl			respawnBall
	
	
	.infinite:
	
	@ Move and draw ball
	mov			R0, #0
	
	ldr			R1, =ballX
	ldr			R2, [R1]
	ldr			R3, =ballXV
	ldr			R4, [R3]
	add			R2, R4
	str			R2, [R1]
	lsr			R1, R2, #8
	
	cmp			R1, #0
	ble			.invertXV
	
	cmp			R1, #(256 - 16)
	ble			.invertedXV
	
	.invertXV:
	mov			R5, R4
	eor			R4, R4
	sub			R4, R4, R5
	str			R4, [R3]
	.invertedXV:
	
	ldr			R2, =ballY
	ldr			R3, [R2]
	ldr			R4, =ballYV
	ldr			R5, [R4]
	add			R3, R5
	str			R3, [R2]
	lsr			R2, R3, #8
	
	cmp			R2, #0
	ble			.invertYV
	
	cmp			R2, #(192 - 16)
	ble			.invertedYV
	
	.invertYV:
	mov			R6, R5
	eor			R5, R5
	sub			R5, R5, R6
	str			R5, [R4]
	.invertedYV:
	
	bl			drawBall
	
	
	@ Move and draw paddles
	mov			R0, #1
	mov			R1, #4
	ldr			R3, =paddleY
	ldr			R2, [R3]
	
	ldr			R4, =REG_KEYINPUT
	ldr			R4, [R4]
	tst			R4, #KEY_UP
	bne			.movedPaddle1Up
	
	.movePaddle1Up:
	cmp			R2, #0
	subgt		R2, #PADDLE_SPEED
	str			R2, [R3]
	.movedPaddle1Up:
	
	tst			R4, #KEY_DOWN
	bne			.movedPaddle1Down
	
	.movePaddle1Down:
	cmp			R2, #((192 - 32) << 8)
	addlt		R2, #PADDLE_SPEED
	str			R2, [R3]
	.movedPaddle1Down:
	
	lsr			R2, #8
	bl			drawPaddle
	
	
	mov			R0, #2
	mov			R1, #(256 - 16 - 4)
	ldr			R3, =paddleY
	ldr			R2, [R3, #4]
	
	tst			R4, #KEY_B
	bne			.movedPaddle2Down
	
	.movePaddle2Down:
	cmp			R2, #((192 - 32) << 8)
	addlt		R2, #PADDLE_SPEED
	str			R2, [R3, #4]
	.movedPaddle2Down:
	
	ldr			R4, =TRANSFER_REGION_BUTTONS
	ldr			R4, [R4]
	tst			R4, #KEY_X
	bne			.movedPaddle2Up
	
	.movePaddle2Up:
	cmp			R2, #0
	subgt		R2, #PADDLE_SPEED
	str			R2, [R3, #4]
	.movedPaddle2Up:
	
	lsr			R2, #8
	bl			drawPaddle
	
	
	bl			swiWaitForVBlank
	
	ldr			R0, =oamMain
	bl			oamUpdate
	
	b			.infinite
