
-- TiepUI v2.0
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local TiepUI = {
    Config = {
        Theme = {
            Background = Color3.fromRGB(25, 25, 25),
            BackgroundTransparency = 0.1,
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(200, 200, 200),
            Success = Color3.fromRGB(64, 255, 64),
            Error = Color3.fromRGB(255, 64, 64), 
            Info = Color3.fromRGB(64, 128, 255),
            Warning = Color3.fromRGB(255, 128, 64),
            Custom = Color3.fromRGB(128, 64, 255),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Animation = {
            Duration = 0.5,
            Style = Enum.EasingStyle.Quart,
            Direction = Enum.EasingDirection.Out,
            Bounce = {
                Enabled = true,
                Intensity = 5
            }
        },
        Layout = {
            Width = UDim2.new(0, 320, 0, 100),
            Padding = 10,
            MaxNotifications = 5,
            DefaultDuration = 5,
            Position = UDim2.new(1, -340, 0, 20),
            CornerRadius = UDim.new(0, 10),
            Shadow = {
                Enabled = true,
                Transparency = 0.8
            }
        },
        Mobile = {
            Enabled = true,
            ScaleFactor = 1.2,
            TouchFeedback = true
        },
        Debug = {
            Enabled = true,
            LogToConsole = true,
            DetailedErrors = true,
            Performance = {
                Track = true,
                Threshold = 16
            }
        },
        Sound = {
            Enabled = true,
            Volume = 0.5,
            Success = "rbxasset://sounds/success.mp3",
            Error = "rbxasset://sounds/error.mp3",
            Info = "rbxasset://sounds/info.mp3",
            Warning = "rbxasset://sounds/warning.mp3"
        }
    },
    
    _notifications = {},
    _container = nil,
    _holder = nil,
    _debugLog = {},
    _performanceStats = {},
    _isMobile = false,
    _sounds = {},
    Version = "2.0.0"
}

function TiepUI:Init()
    self._isMobile = UserInputService.TouchEnabled
    self:CreateContainer()
    self:SetupDebugger()
    self:SetupSounds()
    self:SetupPerformanceMonitor()
    
    if self._isMobile and self.Config.Mobile.Enabled then
        self:ApplyMobileOptimizations()
    end
    
    return self
end

function TiepUI:CreateContainer()
    self._container = Instance.new("ScreenGui")
    self._container.Name = "TiepUI"
    self._container.IgnoreGuiInset = true
    self._container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self._holder = Instance.new("Frame")
    self._holder.Name = "NotificationHolder"
    self._holder.BackgroundTransparency = 1
    self._holder.Size = UDim2.new(0, self.Config.Layout.Width.X.Offset, 1, -40)
    self._holder.Position = self.Config.Layout.Position
    self._holder.Parent = self._container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, self.Config.Layout.Padding)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = self._holder
    
    if self.Config.Layout.Shadow.Enabled then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://7912134082"
        shadow.ImageColor3 = self.Config.Theme.Shadow
        shadow.ImageTransparency = self.Config.Layout.Shadow.Transparency
        shadow.Size = UDim2.new(1, 40, 1, 40)
        shadow.Position = UDim2.new(0, -20, 0, -20)
        shadow.ZIndex = -1
        shadow.Parent = self._holder
    end
    
    pcall(function()
        self._container.Parent = gethui() or game:GetService("CoreGui")
    end)
end

function TiepUI:CreateNotification(options)
    local startTime = os.clock()
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = self.Config.Theme.Background
    notification.BackgroundTransparency = self.Config.Theme.BackgroundTransparency
    notification.BorderSizePixel = 0
    notification.Size = self.Config.Layout.Width
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Config.Layout.CornerRadius
    corner.Parent = notification
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = self.Config.Theme[options.type:lower():gsub("^%l", string.upper)]
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 4, 1, 0)
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
    title.TextColor3 = self.Config.Theme.Text
    title.TextSize = self._isMobile and 18 * self.Config.Mobile.ScaleFactor or 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = content
    
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.BackgroundTransparency = 1
    message.Position = UDim2.new(0, 0, 0, 40)
    message.Size = UDim2.new(1, 0, 0, 40)
    message.Font = Enum.Font.Gotham
    message.Text = options.text
    message.TextColor3 = self.Config.Theme.SubText
    message.TextSize = self._isMobile and 16 * self.Config.Mobile.ScaleFactor or 14
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.Parent = content
    
    local progress = Instance.new("Frame")
    progress.Name = "ProgressBar"
    progress.BackgroundColor3 = accent.BackgroundColor3
    progress.BorderSizePixel = 0
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Parent = notification
    
    if self.Config.Mobile.TouchFeedback and self._isMobile then
        local button = Instance.new("TextButton")
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Text = ""
        button.Parent = notification
        
        button.MouseButton1Click:Connect(function()
            self:DismissNotification(notification)
        end)
    end
    
    if self.Config.Debug.Performance.Track then
        local endTime = os.clock()
        table.insert(self._performanceStats, endTime - startTime)
    end
    
    return notification
end

function TiepUI:Animate(notification, duration)
    local slideIn = TweenService:Create(
        notification,
        TweenInfo.new(
            self.Config.Animation.Duration,
            self.Config.Animation.Style,
            self.Config.Animation.Direction
        ),
        {Position = UDim2.new(0, 0, 0, 0)}
    )
    
    local progress = TweenService:Create(
        notification.ProgressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    
    local slideOut = TweenService:Create(
        notification,
        TweenInfo.new(
            self.Config.Animation.Duration,
            self.Config.Animation.Style,
            self.Config.Animation.Direction
        ),
        {Position = UDim2.new(1, 0, 0, 0)}
    )
    
    if self.Config.Animation.Bounce.Enabled then
        notification.Position = UDim2.new(1.1, 0, 0, 0)
    end
    
    return slideIn, progress, slideOut
end

function TiepUI:SetupDebugger()
    if self.Config.Debug.Enabled then
        self.Debug = {
            Log = function(self, message, level)
                local entry = {
                    timestamp = os.time(),
                    message = message,
                    level = level or "INFO",
                    trace = debug.traceback()
                }
                table.insert(self._debugLog, entry)
                
                if self.Config.Debug.LogToConsole then
                    print(string.format("[TiepUI %s][%s] %s", self.Version, entry.level, entry.message))
                    
                    if self.Config.Debug.DetailedErrors and level == "ERROR" then
                        print("Stack trace:")
                        print(entry.trace)
                    end
                end
            end,
            
            Export = function(self)
                return HttpService:JSONEncode({
                    debugLog = self._debugLog,
                    performanceStats = self._performanceStats,
                    config = self.Config
                })
            end,
            
            Clear = function(self)
                table.clear(self._debugLog)
                table.clear(self._performanceStats)
            end,
            
            GetPerformanceStats = function(self)
                if #self._performanceStats == 0 then return 0 end
                local sum = 0
                for _, time in ipairs(self._performanceStats) do
                    sum = sum + time
                end
                return sum / #self._performanceStats
            end
        }
    end
end

function TiepUI:SetupSounds()
    if self.Config.Sound.Enabled then
        for notifType, soundId in pairs(self.Config.Sound) do
            if type(soundId) == "string" and soundId:match("^rbxasset://") then
                local sound = Instance.new("Sound")
                sound.SoundId = soundId
                sound.Volume = self.Config.Sound.Volume
                sound.Parent = self._container
                self._sounds[notifType:lower()] = sound
            end
        end
    end
end

function TiepUI:SetupPerformanceMonitor()
    if self.Config.Debug.Performance.Track then
        RunService.Heartbeat:Connect(function()
            if #self._performanceStats > 1000 then
                table.remove(self._performanceStats, 1)
            end
            
            local avgTime = self:Debug:GetPerformanceStats()
            if avgTime > self.Config.Debug.Performance.Threshold then
                self:Debug:Log(string.format(
                    "Performance warning: Average creation time %.2fms exceeds threshold %.2fms",
                    avgTime,
                    self.Config.Debug.Performance.Threshold
                ), "WARNING")
            end
        end)
    end
end

function TiepUI:ApplyMobileOptimizations()
    self.Config.Layout.Width = UDim2.new(
        0,
        self.Config.Layout.Width.X.Offset * self.Config.Mobile.ScaleFactor,
        0,
        self.Config.Layout.Width.Y.Offset * self.Config.Mobile.ScaleFactor
    )
    
    self.Config.Layout.Position = UDim2.new(
        1,
        -self.Config.Layout.Width.X.Offset - 20,
        0,
        20
    )
    
    self._holder.Size = UDim2.new(
        0,
        self.Config.Layout.Width.X.Offset,
        1,
        -40
    )
    
    self._holder.Position = self.Config.Layout.Position
end

function TiepUI:DismissNotification(notification)
    local slideOut = TweenService:Create(
        notification,
        TweenInfo.new(
            self.Config.Animation.Duration / 2,
            self.Config.Animation.Style,
            self.Config.Animation.Direction
        ),
        {Position = UDim2.new(1, 0, 0, 0)}
    )
    
    slideOut:Play()
    slideOut.Completed:Wait()
    notification:Destroy()
    table.remove(self._notifications, table.find(self._notifications, notification))
end

function TiepUI:PlaySound(notifType)
    if self.Config.Sound.Enabled then
        local sound = self._sounds[notifType:lower()]
        if sound then
            sound:Play()
        end
    end
end

function TiepUI:Notify(options)
    assert(type(options) == "table", "Options must be a table")
    assert(options.title, "Title is required")
    assert(options.text, "Text is required")
    
    options.type = options.type or "info"
    options.duration = options.duration or self.Config.Layout.DefaultDuration
    
    if #self._notifications >= self.Config.Layout.MaxNotifications then
        local oldest = table.remove(self._notifications, 1)
        oldest:Destroy()
    end
    
    local notification = self:CreateNotification(options)
    notification.Parent = self._holder
    table.insert(self._notifications, notification)
    
    local slideIn, progress, slideOut = self:Animate(notification, options.duration)
    
    self:PlaySound(options.type)
    slideIn:Play()
    progress:Play()
    
    task.delay(options.duration, function()
        slideOut:Play()
        slideOut.Completed:Wait()
        notification:Destroy()
        table.remove(self._notifications, table.find(self._notifications, notification))
    end)
    
    if self.Config.Debug.Enabled then
        self:Debug:Log(string.format("Created notification: %s", options.title))
    end
end

function TiepUI:SetConfig(newConfig)
    for category, values in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(values) do
                self.Config[category][key] = value
            end
        end
    end
end

function TiepUI:Success(message, duration)
    self:Notify({
        title = "Success",
        text = tostring(message),
        duration = duration,
        type = "success"
    })
end

function TiepUI:Error(message, duration)
    self:Notify({
        title = "Error",
        text = tostring(message),
        duration = duration,
        type = "error"
    })
end

function TiepUI:Info(message, duration)
    self:Notify({
        title = "Info",
        text = tostring(message),
        duration = duration,
        type = "info"
    })
end

function TiepUI:Warning(message, duration)
    self:Notify({
        title = "Warning",
        text = tostring(message),
        duration = duration,
        type = "warning"
    })
end

function TiepUI:Custom(title, message, color, duration)
    self:Notify({
        title = title,
        text = message,
        duration = duration,
        type = "custom",
        color = color
    })
end

return TiepUI:Init()