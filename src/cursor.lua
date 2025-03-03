cursor = {}

cursor.currentObj = nil
cursor.x, cursor.y = 0, 0

function cursor:moved(x, y, dx, dy)
    if self.currentObj then
        self.currentObj:moved(x, y, dx, dy)
    end

    self.x, self.y = x, y
end

function cursor:grab(obj)
    self.currentObj = obj
    self.currentObj.grabbed = true
    self.currentObj:moved(x, y)
end

function cursor:release()
    if self.currentObj then
        self.currentObj.grabbed = false
        self.currentObj = nil
    end
end