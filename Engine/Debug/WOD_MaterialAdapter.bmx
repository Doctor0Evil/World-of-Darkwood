' File: /Engine/Debug/WOD_MaterialAdapter.bmx

Const MAT_EMPTY:Int      = 0
Const MAT_WALL:Int       = 1
Const MAT_OBSTACLE:Int   = 2
Const MAT_PLAYER:Int     = 3
Const MAT_ENEMY:Int      = 4
Const MAT_PROJECTILE:Int = 5

Function WOD_MaterialToPaletteIndex:Byte( matId:Int ) 
    Select matId
        Case MAT_EMPTY      ; Return 0
        Case MAT_WALL       ; Return 1
        Case MAT_OBSTACLE   ; Return 2
        Case MAT_PLAYER     ; Return 3
        Case MAT_ENEMY      ; Return 4
        Case MAT_PROJECTILE ; Return 5
        Default
            ' Fallback: unknown material → debug magenta slot
            Return 250
    End Select
End Function

' tiles: Int Ptr of material IDs (physics-side grid)
Function WOD_DumpMaterialLayerToPixmap:Void( pix:IndexedPixmap, tiles:Int Ptr )
    Local w:Int = pix.m_Width
    Local h:Int = pix.m_Height

    For Local y:Int = 0 Until h
        For Local x:Int = 0 Until w
            Local idx:Int = y * w + x
            Local matId:Int = tiles[idx]
            Local palIndex:Byte = WOD_MaterialToPaletteIndex( matId )
            pix.WritePixel( x, y, palIndex )
        Next
    Next
End Function
