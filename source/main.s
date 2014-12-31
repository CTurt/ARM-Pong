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


	.global allocateBall
	.type allocateBall, %function
allocateBall:
	stmfd		sp!, {fp, lr}
	add			fp, sp, #4
	
	ldr			R0, =oamMain
	ldr			R1, =SpriteSize_16x16
	mov			R2, #SpriteColorFormat_256Color
	bl			oamAllocateGfx
	ldr			R3, =ballSpriteGfx
	str			R0, [R3]
	
	sub			sp, fp, #4
	ldmfd		sp!, {fp, lr}
	bx			lr


	.global writeBall
	.type writeBall, %function
writeBall:
	ldr			R3, =ballSpriteGfx
	ldr			R2, [R3]
	ldr			R1, = (1 | (1 << 8))
	sub			R3, R2, #2
	add			R2, R2, #254
.loop:
	strh		R1, [R3, #2]!
	cmp			R3, R2
	bne			.loop
	bx			lr


	.global	drawBall
	.type drawBall, %function
drawBall:
	stmfd		sp!, {fp, lr}
	add			fp, sp, #4
	sub			sp, sp, #64
	
	str			R0, [fp, #-8]
	str			R1, [fp, #-12]
	str			R2, [fp, #-16]
	ldr			R3, =ballSpriteGfx
	ldr			R3, [R3]
	mov			R2, #0
	str			R2, [sp]
	mov			R2, #0
	str			R2, [sp, #4]
	ldr			R2, =SpriteSize_16x16
	str			R2, [sp, #8]
	mov			R2, #1
	str			R2, [sp, #12]
	str			R3, [sp, #16]
	mov			R3, #0
	str			R3, [sp, #20]
	mov			R3, #0
	str			R3, [sp, #24]
	mov			R3, #0
	str			R3, [sp, #28]
	mov			R3, #0
	str			R3, [sp, #32]
	mov			R3, #0
	str			R3, [sp, #36]
	mov			R3, #0
	str			R3, [sp, #40]
	ldr			R0, =oamMain
	ldr			R1, [fp, #-8]
	ldr			R2, [fp, #-12]
	ldr			R3, [fp, #-16]
	bl			oamSet
	
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
	
	
	bl			allocateBall
	bl			writeBall
	
	
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
	
	
	bl			swiWaitForVBlank
	
	ldr			R0, =oamMain
	bl			oamUpdate
	
	b			.infinite
