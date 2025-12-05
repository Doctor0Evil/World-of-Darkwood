' File: /Engine/Debug/WOD_PhysicsRingBuffer.bmx

Const WOD_MAX_ENTITIES:Int       = 4096
Const WOD_MAX_FRAMES_LOGGED:Int  = 4096  ' circular buffer length

Type WODPhysicsSample
    Field timestamp_s:Double        ' high-precision time
    Field frame_number:Int
    Field entity_id:Int

    Field pos_x_m:Float
    Field pos_y_m:Float
    Field vel_x_mps:Float
    Field vel_y_mps:Float

    Field force_x_n:Float
    Field force_y_n:Float
    Field mass_kg:Float

    Field collision_flag:Int
    Field impulse_ns:Float
End Type

' 2D ring buffer: [frame_slot][entity_index]
Global WOD_PhysicsRing:WODPhysicsSample[WOD_MAX_FRAMES_LOGGED][WOD_MAX_ENTITIES]

Global WOD_PhysicsFixedDt_s:Double = 1.0 / 60.0
Global WOD_PhysicsFrameCounter:Int = 0

Function WOD_BeginPhysicsFrame:Void( now_s:Double )
    Local slot:Int = WOD_PhysicsFrameCounter Mod WOD_MAX_FRAMES_LOGGED
    ' Optional: IDE agent can zero/mark this frame slot here via hooks
End Function

Function WOD_RecordEntitySample:Void( now_s:Double, entIndex:Int, entId:Int, _
    px:Float, py:Float, vx:Float, vy:Float, fx:Float, fy:Float, m:Float, _
    collided:Int, j_ns:Float )

    Local slot:Int = WOD_PhysicsFrameCounter Mod WOD_MAX_FRAMES_LOGGED
    Local s:WODPhysicsSample Ptr = Varptr WOD_PhysicsRing[slot][entIndex]

    s\timestamp_s   = now_s
    s\frame_number  = WOD_PhysicsFrameCounter
    s\entity_id     = entId

    s\pos_x_m       = px
    s\pos_y_m       = py
    s\vel_x_mps     = vx
    s\vel_y_mps     = vy
    s\force_x_n     = fx
    s\force_y_n     = fy
    s\mass_kg       = m

    s\collision_flag = collided
    s\impulse_ns     = j_ns
End Function

Function WOD_EndPhysicsFrame:Void()
    WOD_PhysicsFrameCounter :+ 1
End Function
