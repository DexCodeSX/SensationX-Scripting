local TiepUI = {}
TiepUI.__index = TiepUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local FONT = Enum.Font.GothamBold
local NOTIFICATION_DURATION = 5
local TWEEN_DURATION = 0.5

function TiepUI.new()
    local self = setmetatable({}, TiepUI)
    self.notifications = {}
    self:createUI()
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
    self.notificationContainer.Size = UDim2.new(0, 300, 1, -40)
    self.notificationContainer.Parent = self.screenGui
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    uiListLayout.Parent = self.notificationContainer
    
    self.screenGui.Parent = gethui()
end

function TiepUI:notify(title, message, notificationType)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Font = FONT
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Font = FONT
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.Size = UDim2.new(1, -30, 1, -45)
    messageLabel.Parent = notification
    
    local typeColor = Color3.fromRGB(0, 170, 255)
    if notificationType == "success" then
        typeColor = Color3.fromRGB(0, 255, 128)
    elseif notificationType == "error" then
        typeColor = Color3.fromRGB(255, 64, 64)
    elseif notificationType == "warning" then
        typeColor = Color3.fromRGB(255, 170, 0)
    end
    
    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.BackgroundColor3 = typeColor
    colorBar.BorderSizePixel = 0
    colorBar.Position = UDim2.new(0, 0, 0, 0)
    colorBar.Size = UDim2.new(0, 5, 1, 0)
    colorBar.Parent = notification
    
    local cornerBar = Instance.new("UICorner")
    cornerBar.CornerRadius = UDim.new(0, 8)
    cornerBar.Parent = colorBar
    
    notification.Parent = self.notificationContainer
    
    local textSize = game:GetService("TextService"):GetTextSize(message, 14, FONT, Vector2.new(270, 1000))
    local targetSize = UDim2.new(1, 0, 0, math.min(textSize.Y + 60, 200))
    
    TweenService:Create(notification, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    
    table.insert(self.notifications, notification)
    self:updateNotificationPositions()
    
    task.delay(NOTIFICATION_DURATION, function()
        self:removeNotification(notification)
    end)
end

function TiepUI:removeNotification(notification)
    for i, v in ipairs(self.notifications) do
        if v == notification then
            table.remove(self.notifications, i)
            break
        end
    end
    
    local fadeTween = TweenService:Create(notification, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        notification:Destroy()
        self:updateNotificationPositions()
    end)
end

function TiepUI:updateNotificationPositions()
    for i, notification in ipairs(self.notifications) do
        local targetPosition = UDim2.new(0, 0, 1, -i * (notification.AbsoluteSize.Y + 10))
        TweenService:Create(notification, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPosition}):Play()
    end
end

function TiepUI:debugExploit(callback)
    local success, result = pcall(callback)
    if not success then
        self:notify("Debug Error", "An error occurred while debugging: " .. tostring(result), "error")
    else
        self:notify("Debug Success", "Debugging completed successfully.", "success")
    end
    return success, result
end

function TiepUI:parseJSON(jsonString)
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    if not success then
        self:notify("JSON Error", "Failed to parse JSON: " .. tostring(result), "error")
        return nil
    end
    return result
end

function TiepUI:stringifyJSON(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not success then
        self:notify("JSON Error", "Failed to stringify JSON: " .. tostring(result), "error")
        return nil
    end
    return result
end

return TiepUI
