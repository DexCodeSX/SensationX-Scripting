local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local NotificationSystem = {}

local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "EnhancedNotificationUI"
    gui.ResetOnSpawn = false

    local holder = Instance.new("Frame")
    holder.Name = "NotificationHolder"
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.new(1, -30, 0, 30)
    holder.Size = UDim2.new(0, 320, 1, -60)
    holder.Parent = gui

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    listLayout.Padding = UDim.new(0, 15)
    listLayout.Parent = holder

    return gui
end

local function createNotification(options)
    local notification = Instance.new("Frame")
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.ClipsDescendants = true

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = notification

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification

    local title = Instance.new("TextLabel")
    title.Font = Enum.Font.GothamBold
    title.Text = options.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 15)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification

    local content = Instance.new("TextLabel")
    content.Font = Enum.Font.Gotham
    content.Text = options.Content
    content.TextColor3 = Color3.fromRGB(200, 200, 200)
    content.TextSize = 14
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -40, 1, -100)
    content.Position = UDim2.new(0, 20, 0, 50)
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = notification

    local button = Instance.new("TextButton")
    button.Font = Enum.Font.GothamSemibold
    button.Text = options.ButtonText or "Dismiss"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    button.Size = UDim2.new(1, -40, 0, 36)
    button.Position = UDim2.new(0, 20, 1, -56)
    button.AutoButtonColor = false
    button.Parent = notification

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    local buttonHoverEffect = Instance.new("Frame")
    buttonHoverEffect.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
    buttonHoverEffect.Size = UDim2.new(1, 0, 1, 0)
    buttonHoverEffect.Transparency = 1
    buttonHoverEffect.Parent = button

    local buttonHoverCorner = Instance.new("UICorner")
    buttonHoverCorner.CornerRadius = UDim.new(0, 8)
    buttonHoverCorner.Parent = buttonHoverEffect

    button.MouseEnter:Connect(function()
        TweenService:Create(buttonHoverEffect, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(buttonHoverEffect, TweenInfo.new(0.2), {Transparency = 1}):Play()
    end)

    return notification
end

function NotificationSystem.notify(options)
    local gui = Players.LocalPlayer:FindFirstChild("EnhancedNotificationUI") or createGui()
    gui.Parent = Players.LocalPlayer.PlayerGui

    local notification = createNotification(options)
    notification.Parent = gui.NotificationHolder

    local targetSize = UDim2.new(1, 0, 0, 140)
    notification.Size = UDim2.new(1, 0, 0, 0)
    
    local appearTween = TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize})
    appearTween:Play()

    notification.TextButton.MouseButton1Click:Connect(function()
        local disappearTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)

    if not options.NeverExpire then
        task.delay(options.Length or 5, function()
            if notification.Parent then
                local disappearTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
                disappearTween:Play()
                disappearTween.Completed:Connect(function()
                    notification:Destroy()
                end)
            end
        end)
    end
end

return NotificationSystem
