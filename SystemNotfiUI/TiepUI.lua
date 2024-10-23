-- TiepUI.lua
local TiepUI = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local Container = Instance.new("ScreenGui")
Container.Name = "TiepUI"
Container.Parent = gethui()

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Position = UDim2.new(0.8, 0, 0.05, 0)
NotificationHolder.Size = UDim2.new(0.2, 0, 0.9, 0)
NotificationHolder.Parent = Container

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = NotificationHolder

local function CreateNotification(title, text, duration, type)
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Notification.BorderSizePixel = 0
    Notification.Size = UDim2.new(1, 0, 0, 80)
    Notification.Position = UDim2.new(1, 0, 0, 0)
    Notification.Parent = NotificationHolder
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Notification
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.BackgroundTransparency = 1
    Message.Position = UDim2.new(0, 10, 0, 35)
    Message.Size = UDim2.new(1, -20, 0, 35)
    Message.Font = Enum.Font.Gotham
    Message.Text = text
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 14
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.Parent = Notification
    
    local Bar = Instance.new("Frame")
    Bar.Name = "Bar"
    Bar.BackgroundColor3 = type == "error" and Color3.fromRGB(255, 75, 75) or
                          type == "success" and Color3.fromRGB(75, 255, 75) or
                          Color3.fromRGB(75, 75, 255)
    Bar.BorderSizePixel = 0
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.Size = UDim2.new(1, 0, 0, 2)
    Bar.Parent = Notification
    
    local function AnimateIn()
        local Tween = TweenService:Create(Notification, 
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 0, 0, 0)}
        )
        Tween:Play()
    end
    
    local function AnimateOut()
        local Tween = TweenService:Create(Notification,
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 0, 0, 0)}
        )
        Tween:Play()
        Tween.Completed:Wait()
        Notification:Destroy()
    end
    
    AnimateIn()
    task.delay(duration or 5, AnimateOut)
end

function TiepUI:Notify(options)
    assert(type(options) == "table", "Options must be a table")
    assert(options.title, "Title is required")
    assert(options.text, "Text is required")
    
    CreateNotification(
        options.title,
        options.text,
        options.duration,
        options.type
    )
end

function TiepUI:Debug(message)
    self:Notify({
        title = "Debug",
        text = tostring(message),
        duration = 10,
        type = "error"
    })
end

function TiepUI:Success(message)
    self:Notify({
        title = "Success",
        text = tostring(message),
        duration = 5,
        type = "success"
    })
end

function TiepUI:Info(message)
    self:Notify({
        title = "Info",
        text = tostring(message),
        duration = 5,
        type = "info"
    })
end

return TiepUI
