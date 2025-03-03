musicManager = {}

musicManager.music = nil
musicManager.pitchMod = 1
musicManager.originalPitch = 1

function musicManager.load()
    musicManager.music = love.audio.newSource("resources/sounds/music1.ogg", "stream")
    musicManager.music:setLooping(true)
    musicManager.music:play()
    musicManager.music:setPitch(0.7125)
    musicManager.music:setVolume(0.5)
end