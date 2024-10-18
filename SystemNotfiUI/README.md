# Notification UI for Roblox Exploits

A sleek, customizable notification system for Roblox Exploit.

## Features

- 🎨 Modern, minimalist design
- 📱 Responsive layout for all devices
- 🌈 Multiple notification types (success, info, warning, error, custom)
- ⚡ Smooth animations
- 🔧 Customizable options
- 📚 Easy-to-use API

## Installation

```lua
local NotificationUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/DexCodeSX/SensationX-Scripting/refs/heads/Blox/SystemNotfiUI/SNU.luau"))()
```

## Usage

### Basic Notifications

```lua
NotificationUI.success("Success", "Operation completed!")
NotificationUI.info("Info", "Here's some information.")
NotificationUI.warning("Warning", "Be careful!")
NotificationUI.error("Error", "Something went wrong.")
```

### Custom Notifications

```lua
NotificationUI.custom("Custom", "This is a custom notification", {
    duration = 5,
    type = "custom"
})
```

### Toast Notifications

```lua
NotificationUI.toast("Quick update!", 2)
```

### Notifications with Actions

```lua
NotificationUI.custom("Confirm Action", "Do you want to proceed?", {
    duration = 10,
    actions = {
        {
            text = "Yes",
            callback = function()
                print("User confirmed")
            end
        },
        {
            text = "No",
            callback = function()
                print("User cancelled")
            end
        }
    }
})
```

### Clear All Notifications

```lua
-- Clear all notifications after 15 seconds
task.wait(15)
NotificationUI.clearAll()
```

## Customization

You can customize colors, sizes, and other properties by modifying the constants at the top of the [SNU.lua Source Code](https://github.com/DexCodeSX/SensationX-Scripting/blob/Blox/SystemNotfiUI/SNU.lua) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/DexCodeSX/SensationX-Scripting/blob/Blox/SystemNotfiUI/LICENSE) file for details.
