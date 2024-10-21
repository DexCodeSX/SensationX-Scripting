-- TiepUI: Advanced Notification System for Roblox Exploits
-- Version 2.0

local TiepUI = {}
TiepUI.__index = TiepUI

-- Constants
local SCREEN_GUI_NAME = "TiepUINotifications"
local FONT = Enum.Font.GothamSemibold
local TEXT_SIZE = 14
local PADDING = 10
local CORNER_RADIUS = 8
local ANIMATION_DURATION = 0.5
local MAX_NOTIFICATIONS = 5

-- Notification Types
TiepUI.NotificationType = {
    INFO = {Color = Color3.fromRGB(52, 152, 219), Icon = "rbxassetid://6031071053"},
    SUCCESS = {Color = Color3.fromRGB(46, 204, 113), Icon = "rbxassetid://6031068420"},
    WARNING = {Color = Color3.fromRGB(230, 126, 34), Icon = "rbxassetid://6031071057"},
    ERROR = {Color = Color3.fromRGB(231, 76, 60), Icon = "rbxassetid://6031071054"}
}

-- Utility Functions
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function createTween(instance, properties, duration)
    return game:GetService("TweenService"):Create(
        instance,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
end

-- JSON Functions
local function encodeJSON(tab)
    local function serializeImpl(obj, buf)
        local t = typeof(obj)
        if t == "table" then
            table.insert(buf, "{")
            local first = true
            for k, v in pairs(obj) do
                if first then first = false else table.insert(buf, ",") end
                table.insert(buf, string.format("%q:", tostring(k)))
                serializeImpl(v, buf)
            end
            table.insert(buf, "}")
        elseif t == "string" then
            table.insert(buf, string.format("%q", obj))
        else
            table.insert(buf, tostring(obj))
        end
    end
    local buf = {}
    serializeImpl(tab, buf)
    return table.concat(buf)
end

local function decodeJSON(jsonStr)
    local function parseValue(str, pos)
        local ch = str:sub(pos, pos)
        if ch == '{' then
            local obj = {}
            pos = pos + 1
            while true do
                local key, value
                pos = str:find('"', pos) + 1
                key, pos = str:match('(.-)"%s*:%s*', pos)
                value, pos = parseValue(str, pos)
                obj[key] = value
                pos = str:find('[,}]', pos)
                if str:sub(pos, pos) == '}' then return obj, pos + 1 end
                pos = pos + 1
            end
        elseif ch == '"' then
            return str:match('"(.-)"', pos)
        else
            local num = tonumber(str:match('%S+', pos))
            if num then return num end
            if str:sub(pos, pos + 3) == 'true' then return true, pos + 4 end
            if str:sub(pos, pos + 4) == 'false' then return false, pos + 5 end
            if str:sub(pos, pos + 3) == 'null' then return nil, pos + 4 end
        end
    end
    return (parseValue(jsonStr, 1))
end

-- Core Functions
function TiepUI.new()
    local self = setmetatable({}, TiepUI)
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = SCREEN_GUI_NAME
    self.screenGui.Parent = game:GetService("CoreGui")
    self.notifications = {}
    return self
end

function TiepUI:createNotification(title, message, notificationType, duration)
    if #self.notifications >= MAX_NOTIFICATIONS then
        self:removeNotification(self.notifications[1])
    end

    local typeInfo = self.NotificationType[notificationType] or self.NotificationType.INFO
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, 20, 1, -90 * #self.notifications - 90)
    notification.BackgroundColor3 = typeInfo.Color
    notification.BackgroundTransparency = 0.1
    notification.Parent = self.screenGui

    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, CORNER_RADIUS)
    cornerRadius.Parent = notification

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 32, 0, 32)
    icon.Position = UDim2.new(0, PADDING, 0, PADDING)
    icon.Image = typeInfo.Icon
    icon.Parent = notification

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, TEXT_SIZE)
    titleLabel.Position = UDim2.new(0, 50, 0, PADDING)
    titleLabel.Font = FONT
    titleLabel.TextSize = TEXT_SIZE
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 1, -40)
    messageLabel.Position = UDim2.new(0, PADDING, 0, 40)
    messageLabel.Font = FONT
    messageLabel.TextSize = TEXT_SIZE - 2
    messageLabel.TextColor3 = Color3.new(1, 1, 1)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.Parent = notification

    table.insert(self.notifications, notification)
    self:animateNotification(notification, duration)
    return notification
end

function TiepUI:animateNotification(notification, duration)
    local initialPosition = notification.Position
    local targetPosition = UDim2.new(1, -320, initialPosition.Y.Scale, initialPosition.Y.Offset)

    local appearTween = createTween(notification, {Position = targetPosition}, ANIMATION_DURATION)
    appearTween:Play()

    if duration and duration > 0 then
        delay(duration, function()
            self:removeNotification(notification)
        end)
    end
end

function TiepUI:removeNotification(notification)
    local index = table.find(self.notifications, notification)
    if index then
        table.remove(self.notifications, index)
        local disappearTween = createTween(notification, {Position = UDim2.new(1, 20, notification.Position.Y.Scale, notification.Position.Y.Offset)}, ANIMATION_DURATION)
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            notification:Destroy()
        end)

        for i = index, #self.notifications do
            local notif = self.notifications[i]
            local newPosition = UDim2.new(notif.Position.X.Scale, notif.Position.X.Offset, 1, -90 * (i - 1) - 90)
            createTween(notif, {Position = newPosition}, ANIMATION_DURATION):Play()
        end
    end
end

function TiepUI:info(title, message, duration)
    return self:createNotification(title, message, "INFO", duration)
end

function TiepUI:success(title, message, duration)
    return self:createNotification(title, message, "SUCCESS", duration)
end

function TiepUI:warning(title, message, duration)
    return self:createNotification(title, message, "WARNING", duration)
end

function TiepUI:error(title, message, duration)
    return self:createNotification(title, message, "ERROR", duration)
end

function TiepUI:clearAll()
    for _, notification in ipairs(self.notifications) do
        self:removeNotification(notification)
    end
end

function TiepUI:setTheme(theme)
    for type, info in pairs(self.NotificationType) do
        if theme[type] then
            info.Color = theme[type].Color or info.Color
            info.Icon = theme[type].Icon or info.Icon
        end
    end
end

function TiepUI:exportConfig()
    local config = {
        notificationTypes = {},
        screenGuiName = SCREEN_GUI_NAME,
        font = tostring(FONT),
        textSize = TEXT_SIZE,
        padding = PADDING,
        cornerRadius = CORNER_RADIUS,
        animationDuration = ANIMATION_DURATION,
        maxNotifications = MAX_NOTIFICATIONS
    }
    
    for type, info in pairs(self.NotificationType) do
        config.notificationTypes[type] = {
            color = {info.Color.R, info.Color.G, info.Color.B},
            icon = info.Icon
        }
    end
    
    return encodeJSON(config)
end

function TiepUI:importConfig(jsonString)
    local success, config = pcall(decodeJSON, jsonString)
    if not success then
        self:error("Import Error", "Failed to parse JSON configuration.")
        return
    end
    
    -- Apply the imported configuration
    SCREEN_GUI_NAME = config.screenGuiName or SCREEN_GUI_NAME
    FONT = Enum.Font[config.font] or FONT
    TEXT_SIZE = config.textSize or TEXT_SIZE
    PADDING = config.padding or PADDING
    CORNER_RADIUS = config.cornerRadius or CORNER_RADIUS
    ANIMATION_DURATION = config.animationDuration or ANIMATION_DURATION
    MAX_NOTIFICATIONS = config.maxNotifications or MAX_NOTIFICATIONS
    
    for type, info in pairs(config.notificationTypes) do
        if self.NotificationType[type] then
            self.NotificationType[type].Color = Color3.new(unpack(info.color))
            self.NotificationType[type].Icon = info.icon
        end
    end
    
    self:success("Import Successful", "Configuration has been updated.")
end

function TiepUI:debug()
    print("TiepUI Debug Information:")
    print("Screen GUI Name:", SCREEN_GUI_NAME)
    print("Font:", FONT)
    print("Text Size:", TEXT_SIZE)
    print("Padding:", PADDING)
    print("Corner Radius:", CORNER_RADIUS)
    print("Animation Duration:", ANIMATION_DURATION)
    print("Max Notifications:", MAX_NOTIFICATIONS)
    print("Current Notifications:", #self.notifications)
    for type, info in pairs(self.NotificationType) do
        print(string.format("Notification Type %s: Color = (%d, %d, %d), Icon = %s",
            type, info.Color.R * 255, info.Color.G * 255, info.Color.B * 255, info.Icon))
    end
end

return TiepUI