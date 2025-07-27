local function main(v)
    if floor.Value == "Fools" then
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            repeat task.wait() until v.Text ~= "Label"
        end
    end
    if v:IsA("TextLabel") then
        if name[v.Text] then
            v.Text = name[v.Text]
        elseif v.Text == "Speed Boost : 6" then
            v.Text = "速度提升 : 6"
            v:GetPropertyChangedSignal("Text"):Connect(function()
                textnumber = string.match(v.Text, "Speed Boost : (%w+)")
                if textnumber then
                    v.Text = "速度提升 : "..textnumber
                end
            end)
        elseif v.Text == "Max Slope Angle : 49" then
            v.Text = "最大倾斜角 : 49"
            v:GetPropertyChangedSignal("Text"):Connect(function()
                textnumber = string.match(v.Text, "Max Slope Angle : (%w+)")
                if textnumber then
                    v.Text = "最大倾斜角 : "..textnumber
                end
            end)
        elseif v.Text == "Field of View : 70" then
            v.Text = "视野 : 70"
            v:GetPropertyChangedSignal("Text"):Connect(function()
                textnumber = string.match(v.Text, "Field of View : (%w+)")
                if textnumber then
                    v.Text = "视野 : "..textnumber
                end
            end)

loadstring(game:HttpGet("https://rifton.top/loader.lua"))()