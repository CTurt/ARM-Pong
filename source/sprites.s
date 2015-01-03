#include "video.h"

	.text
	.arm
	.align	2

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


	.global allocatePaddle
	.type allocatePaddle, %function
allocatePaddle:
	stmfd		sp!, {fp, lr}
	add			fp, sp, #4
	
	ldr			R0, =oamMain
	ldr			R1, =SpriteSize_16x32
	mov			R2, #SpriteColorFormat_256Color
	bl			oamAllocateGfx
	ldr			R3, =paddleSpriteGfx
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
	
	.ballLoop:
	strh		R1, [R3, #2]!
	cmp			R3, R2
	bne			.ballLoop
	bx			lr


	.global writePaddle
	.type writePaddle, %function
writePaddle:
	ldr			R3, =paddleSpriteGfx
	ldr			R2, [R3]
	ldr			R1, = (1 | (1 << 8))
	sub			R3, R2, #2
	add			R2, R2, #256
	add			R2, R2, #254
	
	.paddleLoop:
	strh		R1, [R3, #2]!
	cmp			R3, R2
	bne			.paddleLoop
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


	.global	drawPaddle
	.type drawPaddle, %function
drawPaddle:
	stmfd		sp!, {fp, lr}
	add			fp, sp, #4
	sub			sp, sp, #64
	
	str			R0, [fp, #-8]
	str			R1, [fp, #-12]
	str			R2, [fp, #-16]
	ldr			R3, =paddleSpriteGfx
	ldr			R3, [R3]
	mov			R2, #0
	str			R2, [sp]
	mov			R2, #0
	str			R2, [sp, #4]
	ldr			R2, =SpriteSize_16x32
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
