local TiepUI = {}

TiepUI.Config = {
    DefaultDuration = 5,
    MaxNotifications = 5,
    AnimationSpeed = 0.5,
    Padding = 10,
    Width = 300,
    Height = 100
}

local Services = {
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    TextService = game:GetService("TextService"),
    UserInputService = game:GetService("UserInputService")
}

local Components = {
    Container = nil,
    NotificationHolder = nil,
    ActiveNotifications = {}
}

local function CreateBaseUI()
    Components.Container = Instance.new("ScreenGui")
    Components.Container.Name = "TiepUI"
    Components.Container.Parent = gethui()

    Components.NotificationHolder = Instance.new("Frame") 
    Components.NotificationHolder.Name = "NotificationHolder"
    Components.NotificationHolder.BackgroundTransparency = 1
    Components.NotificationHolder.Position = UDim2.new(1, -TiepUI.Config.Width - 20, 0, 20)
    Components.NotificationHolder.Size = UDim2.new(0, TiepUI.Config.Width, 1, -40)
    Components.NotificationHolder.Parent = Components.Container

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, TiepUI.Config.Padding)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Components.NotificationHolder
end

local function CreateNotification(options)
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Notification.BorderSizePixel = 0
    Notification.Size = UDim2.new(1, 0, 0, TiepUI.Config.Height)
    Notification.Position = UDim2.new(1, 0, 0, 0)
    Notification.ClipsDescendants = true
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.Parent = Notification

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Notification
    
    local Accent = Instance.new("Frame")
    Accent.Name = "Accent"
    Accent.BackgroundColor3 = options.type == "error" and Color3.fromRGB(255, 64, 64) or
                             options.type == "success" and Color3.fromRGB(64, 255, 64) or
                             Color3.fromRGB(64, 128, 255)
    Accent.BorderSizePixel = 0
    Accent.Position = UDim2.new(0, 0, 0, 0)
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.Parent = Notification

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 15, 0, 0)
    Content.Size = UDim2.new(1, -20, 1, 0)
    Content.Parent = Notification

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = options.title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Content
    
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.BackgroundTransparency = 1
    Message.Position = UDim2.new(0, 0, 0, 40)
    Message.Size = UDim2.new(1, 0, 0, 40)
    Message.Font = Enum.Font.Gotham
    Message.Text = options.text
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 14
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.Parent = Content

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.BackgroundColor3 = Accent.BackgroundColor3
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Position = UDim2.new(0, 0, 1, -2)
    ProgressBar.Size = UDim2.new(1, 0, 0, 2)
    ProgressBar.Parent = Notification

    Notification.Parent = Components.NotificationHolder
    
    return Notification
end

local function AnimateNotification(notification, duration)
    local slideIn = Services.TweenService:Create(notification,
        TweenInfo.new(TiepUI.Config.AnimationSpeed, Enum.EasingStyle.Quart),
        {Position = UDim2.new(0, 0, 0, 0)}
    )
    
    local progressTween = Services.TweenService:Create(notification.ProgressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    
    local fadeOut = Services.TweenService:Create(notification,
        TweenInfo.new(TiepUI.Config.AnimationSpeed, Enum.EasingStyle.Quart),
        {Position = UDim2.new(1, 0, 0, 0)}
    )
    
    slideIn:Play()
    progressTween:Play()
    
    task.delay(duration, function()
        fadeOut:Play()
        fadeOut.Completed:Wait()
        notification:Destroy()
    end)
end

function TiepUI.SetConfig(newConfig)
    for key, value in pairs(newConfig) do
        if TiepUI.Config[key] ~= nil then
            TiepUI.Config[key] = value
        end
    end
end

function TiepUI.Notify(options)
    assert(type(options) == "table", "Options must be a table")
    assert(options.title, "Title is required")
    assert(options.text, "Text is required")
    
    options.duration = options.duration or TiepUI.Config.DefaultDuration
    
    if #Components.ActiveNotifications >= TiepUI.Config.MaxNotifications then
        local oldestNotification = Components.ActiveNotifications[1]
        table.remove(Components.ActiveNotifications, 1)
        oldestNotification:Destroy()
    end
    
    local notification = CreateNotification(options)
    table.insert(Components.ActiveNotifications, notification)
    
    AnimateNotification(notification, options.duration)
end

function TiepUI.Debug(message, duration)
    TiepUI.Notify({
        title = "Debug",
        text = tostring(message),
        duration = duration or 10,
        type = "error"
    })
end

function TiepUI.Success(message, duration)
    TiepUI.Notify({
        title = "Success", 
        text = tostring(message),
        duration = duration or 5,
        type = "success"
    })
end

function TiepUI.Info(message, duration)
    TiepUI.Notify({
        title = "Info",
        text = tostring(message),
        duration = duration or 5,
        type = "info"
    })
end

CreateBaseUI()
return TiepUI
