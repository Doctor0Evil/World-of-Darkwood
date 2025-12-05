' File: /Engine/Debug/WOD_Palette.bmx

Const WOD_MAX_PALETTE_ENTRIES:Int = 256

Type WODColorRGBA
    Field r:Byte  ' 0..255
    Field g:Byte
    Field b:Byte
    Field a:Byte
End Type

Global WOD_Palette:WODColorRGBA[WOD_MAX_PALETTE_ENTRIES]

Function WOD_InitDefaultPalette:Void()
    ' 0: empty / background
    WOD_Palette[0].r = 0;   WOD_Palette[0].g = 0;   WOD_Palette[0].b = 0;   WOD_Palette[0].a = 0

    ' 1: solid wall
    WOD_Palette[1].r = 80;  WOD_Palette[1].g = 80;  WOD_Palette[1].b = 80;  WOD_Palette[1].a = 255

    ' 2: obstacle
    WOD_Palette[2].r = 120; WOD_Palette[2].g = 80;  WOD_Palette[2].b = 40;  WOD_Palette[2].a = 255

    ' 3: player
    WOD_Palette[3].r = 40;  WOD_Palette[3].g = 200; WOD_Palette[3].b = 40;  WOD_Palette[3].a = 255

    ' 4: enemy
    WOD_Palette[4].r = 200; WOD_Palette[4].g = 40;  WOD_Palette[4].b = 40;  WOD_Palette[4].a = 255

    ' 5: projectile / thrown object
    WOD_Palette[5].r = 240; WOD_Palette[5].g = 220; WOD_Palette[5].b = 80;  WOD_Palette[5].a = 255

    ' 250: debug magenta for unknown materials
    WOD_Palette[250].r = 255; WOD_Palette[250].g = 0; WOD_Palette[250].b = 255; WOD_Palette[250].a = 255

    ' remaining entries reserved for other materials / debug channels
End Function
