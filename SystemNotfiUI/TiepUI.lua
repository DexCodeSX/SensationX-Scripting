local TiepUI = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Constants
local FONT = Enum.Font.GothamBold
local TEXT_SIZE = 14
local PADDING = 10
local CORNER_RADIUS = 8
local TWEEN_TIME = 0.5
local MAX_NOTIFICATIONS = 5

-- Helper Functions
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function createFrame(name, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CORNER_RADIUS)
    corner.Parent = frame
    
    return frame
end

local function createText(name, parent)
    local text = Instance.new("TextLabel")
    text.Name = name
    text.BackgroundTransparency = 1
    text.Font = FONT
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextSize = TEXT_SIZE
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Parent = parent
    
    return text
end

-- TiepUI Implementation
function TiepUI.new()
    local self = setmetatable({}, {__index = TiepUI})
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "TiepUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self.container = createFrame("Container", self.screenGui)
    self.container.Position = UDim2.new(1, -20, 1, -20)
    self.container.AnchorPoint = Vector2.new(1, 1)
    self.container.AutomaticSize = Enum.AutomaticSize.Y
    
    self.notificationList = createFrame("NotificationList", self.container)
    self.notificationList.Size = UDim2.new(1, 0, 0, 0)
    self.notificationList.AutomaticSize = Enum.AutomaticSize.Y
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    listLayout.Padding = UDim.new(0, PADDING)
    listLayout.Parent = self.notificationList
    
    self.notifications = {}
    self.debugMode = false
    
    self:updateScale()
    self:setupConnections()
    
    return self
end

function TiepUI:updateScale()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local scale = math.min(viewportSize.X, viewportSize.Y) / 1080
    self.container.Size = UDim2.new(0, 300 * scale, 0, 0)
    self.screenGui.Parent = (RunService:IsStudio() and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")) or game:GetService("CoreGui")
end

function TiepUI:setupConnections()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self:updateScale()
    end)
end

function TiepUI:notify(title, message, duration, type)
    if #self.notifications >= MAX_NOTIFICATIONS then
        self:removeNotification(self.notifications[1])
    end
    
    local notification = createFrame("Notification", self.notificationList)
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.AutomaticSize = Enum.AutomaticSize.Y
    
    local content = createFrame("Content", notification)
    content.Size = UDim2.new(1, -PADDING * 2, 0, 0)
    content.Position = UDim2.new(0, PADDING, 0, PADDING)
    content.AutomaticSize = Enum.AutomaticSize.Y
    
    local titleLabel = createText("Title", content)
    titleLabel.Text = title
    titleLabel.TextSize = TEXT_SIZE * 1.2
    titleLabel.Size = UDim2.new(1, 0, 0, TEXT_SIZE * 1.2)
    
    local messageLabel = createText("Message", content)
    messageLabel.Text = message
    messageLabel.Position = UDim2.new(0, 0, 0, TEXT_SIZE * 1.5)
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.TextWrapped = true
    
    local typeColor = type == "error" and Color3.new(1, 0.2, 0.2) or
                      type == "warning" and Color3.new(1, 0.8, 0.2) or
                      Color3.new(0.2, 0.8, 0.2)
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = typeColor
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.Parent = notification
    
    table.insert(self.notifications, notification)
    self:updateNotificationPositions()
    
    notification.Position = UDim2.new(1, 0, 1, 0)
    notification.AnchorPoint = Vector2.new(1, 1)
    
    local targetPosition = UDim2.new(0, 0, 1, 0)
    local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(notification, tweenInfo, {Position = targetPosition})
    tween:Play()
    
    delay(duration or 5, function()
        self:removeNotification(notification)
    end)
end

function TiepUI:removeNotification(notification)
    local index = table.find(self.notifications, notification)
    if index then
        table.remove(self.notifications, index)
    end
    
    local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local tween = TweenService:Create(notification, tweenInfo, {Position = UDim2.new(1, 0, 1, 0)})
    tween:Play()
    
    tween.Completed:Connect(function()
        notification:Destroy()
        self:updateNotificationPositions()
    end)
end

function TiepUI:updateNotificationPositions()
    for i, notification in ipairs(self.notifications) do
        local targetPosition = UDim2.new(0, 0, 1, -((notification.AbsoluteSize.Y + PADDING) * (i - 1)))
        local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = TweenService:Create(notification, tweenInfo, {Position = targetPosition})
        tween:Play()
    end
end

function TiepUI:setDebugMode(enabled)
    self.debugMode = enabled
end

function TiepUI:debug(message)
    if self.debugMode then
        self:notify("Debug", message, 10, "warning")
        print("[TiepUI Debug]", message)
    end
end

function TiepUI:handleExploitError(err)
    local errorMessage = tostring(err)
    self:notify("Exploit Error", errorMessage, 10, "error")
    self:debug("Exploit error occurred: " .. errorMessage)
end

function TiepUI:parseJSON(jsonString)
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonString)
    end)
    
    if success then
        return result
    else
        self:debug("JSON parsing error: " .. tostring(result))
        return nil
    end
end

function TiepUI:toJSON(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if success then
        return result
    else
        self:debug("JSON encoding error: " .. tostring(result))
        return nil
    end
end

return TiepUI
