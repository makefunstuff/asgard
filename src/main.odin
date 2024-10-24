package funhalla
import gl "vendor:OpenGL"
import "vendor:glfw"
import vk "vendor:vulkan"
import "core:fmt"
import "core:os"

WIDTH :: 800
HEIGHT :: 600

vk_context :: struct {
  instance : vk.Instance
}

g_vulkan_context : vk_context

VALIDATION_LAYERS := [?]cstring {
  "VK_LAYER_KHRONOS_validation"
}

init_vulkan :: proc() {
  context.user_ptr = &g_vulkan_context.instance
  get_proc_address :: proc(p: rawptr, name: cstring) {
    (cast(^rawptr)p)^ = glfw.GetInstanceProcAddress((^vk.Instance)(context.user_ptr)^, name)
  }

  vk.load_proc_addresses(get_proc_address)

  // create instance
  app_info : vk.ApplicationInfo
  app_info.sType = vk.StructureType.APPLICATION_INFO
  app_info.applicationVersion = vk.MAKE_VERSION(1, 0, 0)
  app_info.pEngineName = "Assgard"
  app_info.apiVersion = vk.API_VERSION_1_0

  create_info : vk.InstanceCreateInfo
  create_info.sType = vk.StructureType.INSTANCE_CREATE_INFO
  create_info.pApplicationInfo = &app_info

  glfw_extensions := glfw.GetRequiredInstanceExtensions()

  create_info.enabledExtensionCount = cast(u32) len(glfw_extensions)
  create_info.ppEnabledExtensionNames = raw_data(glfw_extensions)

  when ODIN_DEBUG {
    layer_count: u32
    vk.EnumerateInstanceLayerProperties(&layer_count, nil)

    layers := make([]vk.LayerProperties, layer_count)
    vk.EnumerateInstanceLayerProperties(&layer_count, raw_data(layers))

    outer: for name in VALIDATION_LAYERS {
      for layer in &layers {
				if name == cstring(&layer.layerName[0]) do continue outer
      }

      fmt.eprintf("ERROR: validation layer %q not available\n", name)
      os.exit(1)
    }
  }

  create_info.enabledLayerCount = 0


  if vk.CreateInstance(&create_info, nil, &g_vulkan_context.instance) != .SUCCESS {
    fmt.eprintf("ERROR: Failed to create vk instance\n")
    return
  }

  fmt.println("Vulkan instance created successfully")
}

main :: proc() {
  glfw.Init()

  glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
  glfw.WindowHint(glfw.RESIZABLE, glfw.FALSE)

  window := glfw.CreateWindow(WIDTH, HEIGHT, "assgard", nil, nil)

  init_vulkan()
  defer vk.DestroyInstance(g_vulkan_context.instance, nil)

  for !glfw.WindowShouldClose(window) {
    glfw.PollEvents()
  }
}
