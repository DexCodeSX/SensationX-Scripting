local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local NotificationSystem = {}

-- Constants
local DEFAULT_OPTIONS = {
    Buttons = {
        {
            Title = "Dismiss",
            ClosesUI = true,
            Callback = function() end
        }
    },
    Title = "Notification Title",
    Content = "Placeholder notification content",
    Length = 5,
    NeverExpire = false
}

-- Helper Functions
local function mergeOptions(userOptions, defaultOptions)
    local mergedOptions = {}
    for key, value in pairs(defaultOptions) do
        mergedOptions[key] = userOptions[key] or value
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

-- Main Functions
function NotificationSystem.setup()
    local notifUI = createGuiObject("ScreenGui", {
        Name = "NotifUI",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local holder = createGuiObject("ScrollingFrame", {
        Name = "Holder",
        Parent = notifUI,
        Active = true,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.25, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    createGuiObject("UIListLayout", {
        Parent = holder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10)
    })

    return holder
end

function NotificationSystem.createNotification(options)
    options = mergeOptions(options, DEFAULT_OPTIONS)
    local holder = NotificationSystem.setup()

    local notification = createGuiObject("Frame", {
        Name = "Notification",
        Parent = holder,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 262, 0, 132),
        Visible = true
    })

    createGuiObject("UICorner", {
        Parent = notification
    })

    createGuiObject("TextLabel", {
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.057, 0, 0.053, 0),
        Size = UDim2.new(0, 194, 0, 29),
        Font = Enum.Font.GothamMedium,
        Text = options.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    createGuiObject("TextLabel", {
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.057, 0, 0.303, 0),
        Size = UDim2.new(0, 233, 0, 52),
        Font = Enum.Font.Gotham,
        Text = options.Content,
        TextColor3 = Color3.fromRGB(234, 234, 234),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    if options.Buttons[1] then
        local button = createGuiObject("TextButton", {
            Parent = notification,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Position = UDim2.new(0.057, 0, 0.697, 0),
            Size = UDim2.new(0, 233, 0, 29),
            Font = Enum.Font.GothamMedium,
            Text = options.Buttons[1].Title,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 16
        })

        createGuiObject("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = button
        })

        button.MouseButton1Click:Connect(function()
            if options.Buttons[1].Callback then
                task.spawn(options.Buttons[1].Callback)
            end
            if options.Buttons[1].ClosesUI then
                notification:Destroy()
            end
        end)
    end

    if not options.NeverExpire then
        task.delay(options.Length, function()
            if not notification then return end
            for _, descendant in ipairs(notification:GetDescendants()) do
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    TweenService:Create(descendant, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                elseif descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
                    TweenService:Create(descendant, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                end
            end
            task.wait(0.4)
            notification:Destroy()
        end)
    end
end

return NotificationSystem
