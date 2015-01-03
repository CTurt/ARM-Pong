#define	REG_DISPCNT 0x04000000
#define	REG_DISPCNT_SUB 0x04001000

#define MODE_0_2D 0x10000

#define VRAM_A_CR 0x04000240
#define VRAM_B_CR 0x04000241
#define VRAM_C_CR 0x04000242
#define VRAM_D_CR 0x04000243

#define VRAM_ENABLE 0x80

#define VRAM_A_MAIN_BG 1
#define VRAM_B_MAIN_SPRITE 2
#define VRAM_C_SUB_BG 4
#define VRAM_D_SUB_SPRITE 4

#define BG_PALETTE 0x05000000
#define BG_PALETTE_SUB 0x05000400

#define SPRITE_PALETTE 0x5000200
#define SPRITE_PALETTE_SUB 0x5000600

#define SpriteMapping_1D_32 16
#define SpriteSize_16x16 16392
#define SpriteSize_16x32 40976
#define SpriteColorFormat_256Color 0

#define BLACK 0
#define RED 31
#define GREEN 992
#define BLUE 31744
#define WHITE 32767
