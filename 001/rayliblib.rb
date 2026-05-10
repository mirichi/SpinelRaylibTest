# RayLib Binding Test

module RAY
  ffi_lib "raylib"

  # RaylibをWindowsでスタティックリンクする場合は必要
  ffi_lib "gdi32"
  ffi_lib "winmm"

  ffi_cflags "-L/usr/local/lib -I/usr/local/include sp_raylib.c"

  ffi_func :InitWindow,           [:int, :int, :str], :void
  ffi_func :CloseWindow,          [], :void
  ffi_func :WindowShouldClose,    [], :bool
  ffi_func :SetWindowTitle,       [:str], :void
  ffi_func :SetWindowSize,        [:int, :int], :void

  # Drawing
  ffi_func :BeginDrawing,         [], :void
  ffi_func :EndDrawing,           [], :void
  ffi_func :ClearBackground,      [:uint32], :void

  # Text
  ffi_func :DrawText,             [:str, :int, :int, :int, :uint32], :void

  # Textures(sp_raylib)
  ffi_func :SpLoadTexture,        [:str], :int
  ffi_func :SpUnloadTexture,      [:int], :void
  ffi_func :SpDrawTexture,        [:int, :int, :int, :uint32], :void
  ffi_func :SpDrawTextureRec,     [:int, :int, :int, :int, :int, :int, :int, :uint32], :void
  ffi_func :SpDrawTriangle,       [:float, :float, :float, :float, :float, :float, :uint32], :void

  # Input
  ffi_func :IsKeyDown,            [:int], :uint8
  ffi_func :IsKeyPressed,         [:int], :uint8
  ffi_func :IsMouseButtonPressed, [:int], :uint8
  ffi_func :IsMouseButtonDown,    [:int], :uint8
  ffi_func :SpGetMouseX,          [], :float
  ffi_func :SpGetMouseY,          [], :float

  class Color
    def self.value(r, g, b, a)
      r + g * 256 + b * 65536 + a * 16777216
    end
  end

  RED      = Color.value(255, 0, 0, 255)
  GREEN    = Color.value(0, 255, 0, 255)
  BLUE     = Color.value(0, 0, 255, 255)
  BLACK    = Color.value(0, 0, 0, 255)
  WHITE    = Color.value(255, 255, 255, 255)
  YELLOW   = Color.value(253, 249, 0, 255)
  ORANGE   = Color.value(255, 161, 0, 255)
  GRAY     = Color.value(128, 128, 128, 255)
  DARKGRAY = Color.value(64, 64, 64, 255)
  DARKBLUE = Color.value(0, 0, 128, 255)

  ffi_func :SetTargetFPS,         [:int], :void
  ffi_func :SetExitKey,           [:int], :void
  ffi_func :SpSleep,              [], :void
  ffi_func :DrawRectangle,        [:int, :int, :int, :int, :uint32], :void
  ffi_func :DrawRectangleLines,   [:int, :int, :int, :int, :uint32], :void
  ffi_func :DrawLine,             [:int, :int, :int, :int, :uint32], :void

  # Constants
  ffi_const :KEY_LEFT, 263
  ffi_const :KEY_RIGHT, 262
  ffi_const :KEY_UP, 265
  ffi_const :KEY_DOWN, 264
  ffi_const :KEY_NULL, 0
  ffi_const :KEY_ESCAPE, 256
  ffi_const :KEY_W, 87
  ffi_const :KEY_A, 65
  ffi_const :KEY_S, 83
  ffi_const :KEY_D, 68
  ffi_const :KEY_ONE, 49
  ffi_const :KEY_TWO, 50
  ffi_const :KEY_THREE, 51
  ffi_const :KEY_FOUR, 52
#   ffi_const :KEY_ENTER, 257
#   ffi_const :KEY_KP_ENTER, 280
#   ffi_const :KEY_BACKSPACE, 259
#   ffi_const :KEY_BACK, 257
  ffi_const :MOUSE_LEFT_BUTTON, 0
  ffi_const :MOUSE_RIGHT_BUTTON, 1
#   ffi_const :MOUSE_MIDDLE_BUTTON, 2

end
