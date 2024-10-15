local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local EnhancedNotificationSystem = {}

-- Constants
local FONT = Enum.Font.GothamSemibold
local COLORS = {
    BACKGROUND = Color3.fromRGB(40, 40, 40),
    TEXT = Color3.fromRGB(255, 255, 255),
    BUTTON = Color3.fromRGB(60, 60, 60),
    BUTTON_HOVER = Color3.fromRGB(80, 80, 80),
    SUCCESS = Color3.fromRGB(46, 204, 113),
    WARNING = Color3.fromRGB(241, 196, 15),
    ERROR = Color3.fromRGB(231, 76, 60)
}

local DEFAULT_OPTIONS = {
    Title = "Notification",
    Content = "This is a notification.",
    Type = "info", -- "info", "success", "warning", "error"
    Duration = 5,
    Buttons = {
        {
            Text = "OK",
            Callback = function() end
        }
    },
    Position = UDim2.new(0.98, 0, 0.98, 0),
    AnchorPoint = Vector2.new(1, 1),
    Width = UDim.new(0, 300),
    MaxNotifications = 5
}

local notificationHolder

-- Helper Functions
local function mergeOptions(userOptions, defaultOptions)
    local mergedOptions = table.clone(defaultOptions)
    for key, value in pairs(userOptions) do
        if type(value) == "table" and type(mergedOptions[key]) == "table" then
            mergedOptions[key] = mergeOptions(value, mergedOptions[key])
        else
            mergedOptions[key] = value
        end
    end
    return mergedOptions
end

local function createGuiObject(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    return object
end

local function setupNotificationHolder()
    if notificationHolder then return notificationHolder end

    local screenGui = createGuiObject("ScreenGui", {
        Name = "EnhancedNotificationSystem",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    notificationHolder = createGuiObject("Frame", {
        Name = "NotificationHolder",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })

    return notificationHolder
end

local function getTypeColor(notificationType)
    return COLORS[string.upper(notificationType)] or COLORS.BACKGROUND
end

local function animateNotification(notification, direction)
    local startPosition = notification.Position
    local endPosition = direction == "in" 
        and UDim2.new(startPosition.X.Scale, startPosition.X.Offset, startPosition.Y.Scale, startPosition.Y.Offset)
        or UDim2.new(1.5, 0, startPosition.Y.Scale, startPosition.Y.Offset)
    
    notification.Position = direction == "in" and UDim2.new(1.5, 0, startPosition.Y.Scale, startPosition.Y.Offset) or startPosition
    
    local tween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = endPosition
    })
    tween:Play()
    
    return tween
end

-- Main Functions
function EnhancedNotificationSystem.createNotification(userOptions)
    local options = mergeOptions(userOptions, DEFAULT_OPTIONS)
    local holder = setupNotificationHolder()
    
    -- Manage maximum number of notifications
    if #holder:GetChildren() >= options.MaxNotifications then
        holder:FindFirstChild("Notification"):Destroy()
    end
    
    local notification = createGuiObject("Frame", {
        Name = "Notification",
        Parent = holder,
        BackgroundColor3 = getTypeColor(options.Type),
        BorderSizePixel = 0,
        Size = UDim2.new(options.Width, UDim.new(0, 0)),
        Position = options.Position,
        AnchorPoint = options.AnchorPoint
    })
    
    local cornerRadius = createGuiObject("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notification
    })
    
    local contentPadding = createGuiObject("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = notification
    })
    
    local titleLabel = createGuiObject("TextLabel", {
        Name = "Title",
        Parent = notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = FONT,
        Text = options.Title,
        TextColor3 = COLORS.TEXT,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local contentLabel = createGuiObject("TextLabel", {
        Name = "Content",
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        Font = FONT,
        Text = options.Content,
        TextColor3 = COLORS.TEXT,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
    local buttonsHolder = createGuiObject("Frame", {
        Name = "ButtonsHolder",
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -40),
        Size = UDim2.new(1, 0, 0, 32),
        BorderSizePixel = 0
    })
    
    local buttonLayout = createGuiObject("UIListLayout", {
        Parent = buttonsHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    for i, buttonInfo in ipairs(options.Buttons) do
        local button = createGuiObject("TextButton", {
            Name = "Button" .. i,
            Parent = buttonsHolder,
            BackgroundColor3 = COLORS.BUTTON,
            Size = UDim2.new(0, 80, 1, 0),
            Font = FONT,
            Text = buttonInfo.Text,
            TextColor3 = COLORS.TEXT,
            TextSize = 14,
            BorderSizePixel = 0
        })
        
        createGuiObject("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = button
        })
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.BUTTON_HOVER}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.BUTTON}):Play()
        end)
        
        button.MouseButton1Click:Connect(function()
            if buttonInfo.Callback then
                buttonInfo.Callback()
            end
            animateNotification(notification, "out").Completed:Wait()
            notification:Destroy()
        end)
    end
    
    -- Adjust content label size
    local textSize = contentLabel.TextBounds
    contentLabel.Size = UDim2.new(1, 0, 0, textSize.Y)
    
    -- Adjust notification size
    notification.Size = UDim2.new(
        options.Width.Scale, options.Width.Offset,
        0, titleLabel.Size.Y.Offset + contentLabel.Size.Y.Offset + buttonsHolder.Size.Y.Offset + 24
    )
    
    -- Animate notification
    animateNotification(notification, "in")
    
    -- Auto-close timer
    if options.Duration > 0 then
        task.delay(options.Duration, function()
            if notification.Parent then
                animateNotification(notification, "out").Completed:Wait()
                notification:Destroy()
            end
        end)
    end
    
    return notification
end

-- Progress Bar Feature
function EnhancedNotificationSystem.createProgressNotification(userOptions)
    local options = mergeOptions(userOptions, DEFAULT_OPTIONS)
    options.Buttons = {} -- Remove default buttons for progress notifications
    
    local notification = EnhancedNotificationSystem.createNotification(options)
    
    local progressBar = createGuiObject("Frame", {
        Name = "ProgressBar",
        Parent = notification,
        BackgroundColor3 = Color3.fromRGB(80, 80, 80),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 4),
        AnchorPoint = Vector2.new(0, 1)
    })
    
    local progressFill = createGuiObject("Frame", {
        Name = "ProgressFill",
        Parent = progressBar,
        BackgroundColor3 = COLORS.SUCCESS,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0)
    })
    
    createGuiObject("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = progressBar
    })
    
    createGuiObject("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = progressFill
    })
    
    local function updateProgress(progress)
        TweenService:Create(progressFill, TweenInfo.new(0.2), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
    end
    
    return notification, updateProgress
end

return EnhancedNotificationSystem
