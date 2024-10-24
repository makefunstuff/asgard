package funhalla
import gl "vendor:OpenGL"
import "vendor:glfw"
import "vendor:vulkan"

WIDTH :: 800
HEIGHT :: 600

init_vulkan :: proc() {

}

main :: proc() {
  glfw.Init()

  glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
  glfw.WindowHint(glfw.RESIZABLE, glfw.FALSE)

  window := glfw.CreateWindow(WIDTH, HEIGHT, "assgard", nil, nil)

  for !glfw.WindowShouldClose(window) {
    glfw.PollEvents()
  }
}
