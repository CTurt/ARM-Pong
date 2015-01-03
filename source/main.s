#include "video.h"

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

.global main
main:
	bl		init
	
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
	
	
	@ Draw paddles
	mov			R0, #1
	mov			R1, #4
	mov			R2, #80
	bl			drawPaddle
	
	
	mov			R0, #2
	mov			R1, #(256 - 16 - 4)
	mov			R2, #80
	bl			drawPaddle
	
	
	bl			swiWaitForVBlank
	
	ldr			R0, =oamMain
	bl			oamUpdate
	
	b			.infinite
