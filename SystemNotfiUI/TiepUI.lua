-- TiepUI.lua
local TiepUI = {
    _notifications = {},
    _config = {
        Theme = {
            Background = Color3.fromRGB(25, 25, 25),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(200, 200, 200),
            Success = Color3.fromRGB(64, 255, 64),
            Error = Color3.fromRGB(255, 64, 64),
            Info = Color3.fromRGB(64, 128, 255),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Layout = {
            Width = 300,
            Height = 100,
            Padding = 10,
            CornerRadius = 8,
            AccentWidth = 4
        },
        Animation = {
            Duration = 0.5,
            Style = Enum.EasingStyle.Quart
        },
        Notification = {
            DefaultDuration = 5,
            MaxCount = 5
        }
    }
}

local Services = {
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    TextService = game:GetService("TextService"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService")
}

function TiepUI:CreateContainer()
    local container = Instance.new("ScreenGui")
    container.Name = "TiepUI"
    container.Parent = gethui()

    local holder = Instance.new("Frame")
    holder.Name = "NotificationHolder"
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.new(1, -self._config.Layout.Width - 20, 0, 20)
    holder.Size = UDim2.new(0, self._config.Layout.Width, 1, -40)
    holder.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, self._config.Layout.Padding)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = holder

    self._container = container
    self._holder = holder
end

function TiepUI:CreateNotification(options)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = self._config.Theme.Background
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(1, 0, 0, self._config.Layout.Height)
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification.ClipsDescendants = true

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = self._config.Theme.Shadow
    shadow.ImageTransparency = 0.6
    shadow.Parent = notification

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self._config.Layout.CornerRadius)
    corner.Parent = notification

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = options.type == "error" and self._config.Theme.Error or
                             options.type == "success" and self._config.Theme.Success or
                             self._config.Theme.Info
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, self._config.Layout.AccentWidth, 1, 0)
    accent.Parent = notification

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 15, 0, 0)
    content.Size = UDim2.new(1, -20, 1, 0)
    content.Parent = notification

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Font = Enum.Font.GothamBold
    title.Text = options.title
    title.TextColor3 = self._config.Theme.Text
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = content

    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.BackgroundTransparency = 1
    message.Position = UDim2.new(0, 0, 0, 40)
    message.Size = UDim2.new(1, 0, 0, 40)
    message.Font = Enum.Font.Gotham
    message.Text = options.text
    message.TextColor3 = self._config.Theme.SubText
    message.TextSize = 14
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.Parent = content

    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.BackgroundColor3 = accent.BackgroundColor3
    progressBar.BorderSizePixel = 0
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Parent = notification

    return notification
end

function TiepUI:Animate(notification, duration)
    local slideIn = Services.TweenService:Create(
        notification,
        TweenInfo.new(self._config.Animation.Duration, self._config.Animation.Style),
        {Position = UDim2.new(0, 0, 0, 0)}
    )

    local progress = Services.TweenService:Create(
        notification.ProgressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )

    local slideOut = Services.TweenService:Create(
        notification,
        TweenInfo.new(self._config.Animation.Duration, self._config.Animation.Style),
        {Position = UDim2.new(1, 0, 0, 0)}
    )

    return slideIn, progress, slideOut
end

function TiepUI:SetConfig(newConfig)
    for category, values in pairs(newConfig) do
        if self._config[category] then
            for key, value in pairs(values) do
                if self._config[category][key] ~= nil then
                    self._config[category][key] = value
                end
            end
        end
    end
end

function TiepUI:Init()
    self:CreateContainer()
    return self
end

function TiepUI:Notify(options)
    assert(type(options) == "table", "Options must be a table")
    assert(options.title, "Title is required")
    assert(options.text, "Text is required")
    
    options.duration = options.duration or self._config.Notification.DefaultDuration
    
    if #self._notifications >= self._config.Notification.MaxCount then
        local oldest = table.remove(self._notifications, 1)
        oldest:Destroy()
    end
    
    local notification = self:CreateNotification(options)
    notification.Parent = self._holder
    
    table.insert(self._notifications, notification)
    
    local slideIn, progress, slideOut = self:Animate(notification, options.duration)
    
    slideIn:Play()
    progress:Play()
    
    task.delay(options.duration, function()
        slideOut:Play()
        slideOut.Completed:Wait()
        notification:Destroy()
        
        local index = table.find(self._notifications, notification)
        if index then
            table.remove(self._notifications, index)
        end
    end)
end

function TiepUI:Success(message, duration)
    self:Notify({
        title = "Success",
        text = tostring(message),
        duration = duration or 5,
        type = "success"
    })
end

function TiepUI:Error(message, duration)
    self:Notify({
        title = "Error",
        text = tostring(message),
        duration = duration or 5,
        type = "error"
    })
end

function TiepUI:Info(message, duration)
    self:Notify({
        title = "Info",
        text = tostring(message),
        duration = duration or 5,
        type = "info"
    })
end

return TiepUI:Init()
