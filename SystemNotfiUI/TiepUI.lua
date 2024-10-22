local TiepUI = {}
TiepUI.__index = TiepUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local FONTS = {
    REGULAR = Enum.Font.Gotham,
    BOLD = Enum.Font.GothamBold,
    LIGHT = Enum.Font.GothamLight
}

local COLORS = {
    BACKGROUND = Color3.fromRGB(30, 30, 30),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    INFO = Color3.fromRGB(0, 170, 255),
    SUCCESS = Color3.fromRGB(0, 255, 128),
    WARNING = Color3.fromRGB(255, 170, 0),
    ERROR = Color3.fromRGB(255, 64, 64)
}

local DEFAULT_SETTINGS = {
    NOTIFICATION_DURATION = 5,
    TWEEN_DURATION = 0.5,
    MAX_NOTIFICATIONS = 5,
    NOTIFICATION_WIDTH = 300,
    NOTIFICATION_PADDING = 10,
    CORNER_RADIUS = 8
}

function TiepUI.new(customSettings)
    local self = setmetatable({}, TiepUI)
    self.settings = table.clone(DEFAULT_SETTINGS)
    if customSettings then
        for k, v in pairs(customSettings) do
            self.settings[k] = v
        end
    end
    self.notifications = {}
    self.debugLogs = {}
    self:createUI()
    self:setupInputHandling()
    return self
end

function TiepUI:createUI()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "TiepUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.notificationContainer = Instance.new("Frame")
    self.notificationContainer.Name = "NotificationContainer"
    self.notificationContainer.AnchorPoint = Vector2.new(1, 1)
    self.notificationContainer.BackgroundTransparency = 1
    self.notificationContainer.Position = UDim2.new(1, -20, 1, -20)
    self.notificationContainer.Size = UDim2.new(0, self.settings.NOTIFICATION_WIDTH, 1, -40)
    self.notificationContainer.Parent = self.screenGui

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, self.settings.NOTIFICATION_PADDING)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    uiListLayout.Parent = self.notificationContainer

    self.screenGui.Parent = gethui()
end

function TiepUI:setupInputHandling()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            self:toggleDebugConsole()
        end
    end)
end

function TiepUI:createNotification(title, message, notificationType)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = COLORS.BACKGROUND
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.settings.CORNER_RADIUS)
    corner.Parent = notification

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Font = FONTS.BOLD
    titleLabel.Text = title
    titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Font = FONTS.REGULAR
    messageLabel.Text = message
    messageLabel.TextColor3 = COLORS.TEXT_SECONDARY
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.Size = UDim2.new(1, -30, 1, -45)
    messageLabel.Parent = notification

    local typeColor = COLORS[notificationType:upper()] or COLORS.INFO

    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.BackgroundColor3 = typeColor
    colorBar.BorderSizePixel = 0
    colorBar.Position = UDim2.new(0, 0, 0, 0)
    colorBar.Size = UDim2.new(0, 5, 1, 0)
    colorBar.Parent = notification

    local cornerBar = Instance.new("UICorner")
    cornerBar.CornerRadius = UDim.new(0, self.settings.CORNER_RADIUS)
    cornerBar.Parent = colorBar

    return notification
end

function TiepUI:notify(title, message, notificationType)
    if #self.notifications >= self.settings.MAX_NOTIFICATIONS then
        self:removeNotification(self.notifications[1])
    end

    local notification = self:createNotification(title, message, notificationType)
    notification.Parent = self.notificationContainer

    local textSize = game:GetService("TextService"):GetTextSize(message, 14, FONTS.REGULAR, Vector2.new(self.settings.NOTIFICATION_WIDTH - 30, 1000))
    local targetSize = UDim2.new(1, 0, 0, math.min(textSize.Y + 60, 200))

    TweenService:Create(notification, TweenInfo.new(self.settings.TWEEN_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()

    table.insert(self.notifications, notification)
    self:updateNotificationPositions()

    task.delay(self.settings.NOTIFICATION_DURATION, function()
        self:removeNotification(notification)
    end)

    self:log("Notification created: " .. title)
end

function TiepUI:removeNotification(notification)
    for i, v in ipairs(self.notifications) do
        if v == notification then
            table.remove(self.notifications, i)
            break
        end
    end

    local fadeTween = TweenService:Create(notification, TweenInfo.new(self.settings.TWEEN_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        notification:Destroy()
        self:updateNotificationPositions()
    end)

    self:log("Notification removed")
end

function TiepUI:updateNotificationPositions()
    for i, notification in ipairs(self.notifications) do
        local targetPosition = UDim2.new(0, 0, 1, -i * (notification.AbsoluteSize.Y + self.settings.NOTIFICATION_PADDING))
        TweenService:Create(notification, TweenInfo.new(self.settings.TWEEN_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPosition}):Play()
    end
end

function TiepUI:debugExploit(callback)
    local success, result = pcall(callback)
    if not success then
        self:notify("Debug Error", "An error occurred while debugging: " .. tostring(result), "error")
        self:log("Debug Error: " .. tostring(result), "error")
    else
        self:notify("Debug Success", "Debugging completed successfully.", "success")
        self:log("Debug Success: " .. tostring(result), "success")
    end
    return success, result
end

function TiepUI:parseJSON(jsonString)
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    if not success then
        self:notify("JSON Error", "Failed to parse JSON: " .. tostring(result), "error")
        self:log("JSON Parse Error: " .. tostring(result), "error")
        return nil
    end
    self:log("JSON parsed successfully")
    return result
end

function TiepUI:stringifyJSON(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not success then
        self:notify("JSON Error", "Failed to stringify JSON: " .. tostring(result), "error")
        self:log("JSON Stringify Error: " .. tostring(result), "error")
        return nil
    end
    self:log("JSON stringified successfully")
    return result
end

function TiepUI:log(message, level)
    level = level or "info"
    local logEntry = {
        timestamp = os.time(),
        message = message,
        level = level
    }
    table.insert(self.debugLogs, logEntry)
    if #self.debugLogs > 1000 then
        table.remove(self.debugLogs, 1)
    end
    if self.debugConsole then
        self:updateDebugConsole()
    end
end

function TiepUI:createDebugConsole()
    self.debugConsole = Instance.new("Frame")
    self.debugConsole.Name = "DebugConsole"
    self.debugConsole.BackgroundColor3 = COLORS.BACKGROUND
    self.debugConsole.BorderSizePixel = 0
    self.debugConsole.Position = UDim2.new(0, 20, 0, 20)
    self.debugConsole.Size = UDim2.new(0, 400, 0, 300)
    self.debugConsole.Visible = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.settings.CORNER_RADIUS)
    corner.Parent = self.debugConsole

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Font = FONTS.BOLD
    title.Text = "Debug Console"
    title.TextColor3 = COLORS.TEXT_PRIMARY
    title.TextSize = 18
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Parent = self.debugConsole

    self.logContainer = Instance.new("ScrollingFrame")
    self.logContainer.Name = "LogContainer"
    self.logContainer.BackgroundTransparency = 1
    self.logContainer.Position = UDim2.new(0, 10, 0, 40)
    self.logContainer.Size = UDim2.new(1, -20, 1, -50)
    self.logContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.logContainer.ScrollBarThickness = 6
    self.logContainer.Parent = self.debugConsole

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = self.logContainer

    self.debugConsole.Parent = self.screenGui
end

function TiepUI:updateDebugConsole()
    if not self.debugConsole then return end

    for _, child in ipairs(self.logContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for i, logEntry in ipairs(self.debugLogs) do
        local logLabel = Instance.new("TextLabel")
        logLabel.Name = "LogEntry" .. i
        logLabel.Font = FONTS.REGULAR
        logLabel.Text = string.format("[%s] %s: %s", os.date("%H:%M:%S", logEntry.timestamp), logEntry.level:upper(), logEntry.message)
        logLabel.TextColor3 = COLORS[logEntry.level:upper()] or COLORS.TEXT_SECONDARY
        logLabel.TextSize = 12
        logLabel.TextXAlignment = Enum.TextXAlignment.Left
        logLabel.TextYAlignment = Enum.TextYAlignment.Top
        logLabel.TextWrapped = true
        logLabel.BackgroundTransparency = 1
        logLabel.Size = UDim2.new(1, 0, 0, 20)
        logLabel.Parent = self.logContainer
    end

    self.logContainer.CanvasSize = UDim2.new(0, 0, 0, #self.debugLogs * 20)
    self.logContainer.CanvasPosition = Vector2.new(0, self.logContainer.CanvasSize.Y.Offset)
end

function TiepUI:toggleDebugConsole()
    if not self.debugConsole then
        self:createDebugConsole()
    end
    self.debugConsole.Visible = not self.debugConsole.Visible
    if self.debugConsole.Visible then
        self:updateDebugConsole()
    end
end

function TiepUI:clearDebugLogs()
    self.debugLogs = {}
    if self.debugConsole then
        self:updateDebugConsole()
    end
end

return TiepUI