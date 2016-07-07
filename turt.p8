pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
--turt
--by mike age 27

-- game obj
global_game = {}

-- built-in functions -----------------------------------------------------
function _init()
    global_game = title_screen.new()
end

function _update()
    global_game:update()
end

function _draw()
    global_game:draw()
end

-- define our data types ------------------------------------------------------
-- game state objects ---------------------------------------------------------

-- title screen ---------------------------------------------------------------
title_screen = { turt_y = -16,
                 anim_counter = 0,
                 time_counter = 1
                }
title_screen.__index = title_screen

function title_screen.new()
    local self = setmetatable({}, title_screen)
    
    sfx(-1, 3)
    music(-1)
    music(0, 0, 7)
    return self
end

function title_screen.update(self)
    if (btnp(4) or btnp(5)) then
        global_game = play_screen.new()
    end
end

function title_screen.draw(self)
    cls()
    rectfill(0, 0, 128, 128, 12)
    
    -- flares
    -- top left
    circfill(   80 +  8 * sin((self.anim_counter % 80) / 80 + 0.5),
                12 + 10 * cos((self.anim_counter % 80) / 80 + 0.5),
                12,
                10)
    circfill(   82 +  6 * sin((self.anim_counter % 80) / 80 + 0.5),
                15 +  11 * cos((self.anim_counter % 80) / 80 + 0.5),
                16,
                12)
    
    -- top right
    circfill(  106 +  8 * sin((self.anim_counter % 65) / 65 ),
                8 + 10 * cos((self.anim_counter % 65) / 65 ),
                18,
                10)
    circfill(   103 +  10 * sin((self.anim_counter % 65) / 65 ),
                 12 +  12 * cos((self.anim_counter % 65) / 65 ),
                22,
                12)
    
    -- bottom right
    circfill(   98 + 6 * sin((self.anim_counter % 60 ) / 60), 
                34 + 4 * cos((self.anim_counter % 60 ) / 60), 
                 8, 
                10)
    circfill(   96 + 4 * sin((self.anim_counter % 60 ) / 60 + 0.05), 
                32 + 4 * cos((self.anim_counter % 60 ) / 60 + 0.05), 
                10, 
                12)
    
    -- bottom left
    circfill(   72 + 6 * sin((self.anim_counter % 60 ) / 60 + 0.3), 
                29 + 4 * cos((self.anim_counter % 60 ) / 60 + 0.3), 
                 8, 
                10)
    circfill(   74 + 4 * sin((self.anim_counter % 60 ) / 60 + 0.35), 
                27 + 4 * cos((self.anim_counter % 60 ) / 60 + 0.35), 
                10, 
                12)
                
            -- bottom
    circfill(   85 + 6 * sin((self.anim_counter % 80 ) / 80 + 0.6), 
                30 + 4 * cos((self.anim_counter % 80 ) / 80 + 0.6), 
                 8, 
                10)
    circfill(   85 + 4 * sin((self.anim_counter % 80 ) / 80 + 0.6), 
                27 + 4 * cos((self.anim_counter % 80 ) / 80 + 0.6), 
                10, 
                12)
    
    -- the sun
    circfill(85, 20, 10, 10)
    
    -- clouds
    map(16, 0, -128 + ((self.anim_counter / 25) + 128) % 256, 0, 16, 16)
    map(16, 0, -128 + ((self.anim_counter / 25) + 256) % 256, 0, 16, 16)
    
    map(32, 0, -128 + ((self.anim_counter / 60) + 128) % 256, 4, 16, 16)
    map(32, 0, -128 + ((self.anim_counter / 60) + 256) % 256, 4, 16, 16)
    
    -- birds
    spr(234,
        128 - (self.anim_counter / 20),
        50 + -0.34 * (self.anim_counter / 20))
    spr(234,
        140 - (self.anim_counter / 25),
        45 + -0.40 * (self.anim_counter / 20))
    spr(234,
        168 - (self.anim_counter / 20),
        90 + -0.34 * (self.anim_counter / 20))
    
    -- draw the turtle
    palt(0, false)
    palt(12, true)
    spr(128, 
        0, 80,
        16, 8)
    palt(0, true)
    palt(12, false)
    
    local kerning = 8
    
    spr(224, 64 - 32 - (kerning * 1.5), self.turt_y, 2, 2)
    spr(226, 64 - 16 - (kerning * 0.5), self.turt_y, 2, 2)
    spr(228, 64 + (kerning * 0.5),      self.turt_y, 2, 2)
    spr(224, 64 + 16 + (kerning * 1.5), self.turt_y, 2, 2)
    
    if (self.turt_y < 45) then
        self.turt_y+=0.5
    end
    
    if (self.turt_y >= 45) then
        print("any key to start", 33, 70, 5)
        print("any key to start", 32, 69, 7)
    end
    
    self.anim_counter += 1
end

-- play screen-----------------------------------------------------------------
play_screen = { anim_counter = 0,
                time_counter = 1,
                
                score = 0,
                prev_score = 0,
                lives = 3,
                game_over = false,
                selected_turtle = {},
                --turtle_speedup = 0,
                
                egg_anim_num = 3,
                egg_anim_frame = 0,
              }
play_screen.__index = play_screen

function play_screen.new()
    local self = setmetatable({}, play_screen)
    
    self.crabs = {}
    self.pelicans = {}
    self.turtles = {}
    self.dead_turtles = {}
    self.death_particles = {}
    self.blood_pools = {}
    
    self.turtles[1] = turtle.new(64, 120)
    self.turtles[1].selected = true
    self.selected_turtle = self.turtles[1]
    self.crabs[1]   = crab.new(64, 64)
    self.crabs[2]   = crab.new(32, 48)
    self.crabs[2].flip = true
    
    sfx(5, 3)
    return self
end

function play_screen.update(self)
    if (not self.game_over) then
        -- control to cycle through turtles
        if (btnp(2)) then
            local newsel = self:get_prev_turtle()
            
            if (newsel != nil) then
                self.selected_turtle.selected = false
                self.selected_turtle = newsel
                self.selected_turtle.selected = true
            end
        end
        if (btnp(3)) then
            local newsel = self:get_next_turtle()
            
            if (newsel != nil) then
                self.selected_turtle.selected = false
                self.selected_turtle = newsel
                self.selected_turtle.selected = true
            end
        end
        
        -- spawn a crab
        if (self.score ~= self.prev_score and
            self.score % 3 == 0) then
                local new_crab = crab.new(-32, 32 + rnd(72))
                new_crab:set_destination(24 + rnd(48), new_crab.y)
                add(self.crabs, new_crab)
        end
        for c,inst in pairs(self.crabs) do
            inst:update(self)
        end
        
        for p,inst in pairs(self.pelicans)do
            inst:update(self)
        end
        
        self.prev_score = self.score
        for t,inst in pairs(self.turtles) do
            self.turtles[t]:update(self)
            if (inst.state == "escaped") then
                self.turtles[t] = nil
            end
        end
        
        for t,inst in pairs(self.dead_turtles) do
            self.dead_turtles[t]:update(self)
        end
        
        for p,inst in pairs(self.death_particles) do
            inst:update(self)
            
            if (inst.t > inst.lifetime) then 
                self.death_particles[p] = nil
            end
        end
        
        if (self.time_counter % 350 == 0) then
            local newturtle = turtle.new(32 + rnd(64), 120)
            local turtle_speed_factor = rnd(5)
            newturtle.jump_freq -= flr(turtle_speed_factor)
            newturtle.jump_speed += turtle_speed_factor / 10
            add(self.turtles, newturtle)
            
            if (self.selected_turtle.state == "dying" or
                self.selected_turtle.state == "escaped") then
                self.selected_turtle = newturtle
                newturtle.selected = true
            end
        end
    elseif (self.game_over) then
        for t,inst in pairs(self.dead_turtles) do
            self.dead_turtles[t]:update(self)
        end
        if (btnp(4) or btnp(5)) then
            global_game = title_screen.new()
        end
        
        for p,inst in pairs(self.death_particles) do
            inst:update(self)
            
            if (inst.t > inst.lifetime) then 
                self.death_particles[p] = nil
            end
        end
    end
    
    self.time_counter += 1
end

function play_screen.draw(self)
    map(0, 0, 0, 0, 16, 16)
    
    -- water
    local water_anim = flr(self.anim_counter / 48) % 5
    for water_num = 0,8 do
        spr(70 + (water_anim * 2), 
            water_num * 16, 0,
            2, 2)
    end
    
    for p,inst in pairs(self.blood_pools) do
        inst:draw(self)
    end
    
    for c,inst in pairs(self.crabs) do
        self.crabs[c]:draw(self)
    end
    
    for t,inst in pairs(self.turtles) do
        self.turtles[t]:draw(self)
    end
    
    for t,inst in pairs(self.dead_turtles) do
        self.dead_turtles[t]:draw(self)
    end
    
    -- eggs
    self.egg_anim_frame = flr(self.anim_counter / 16) % 4
    if (self.egg_anim_frame == 0) then
        self.egg_anim_num = flr(rnd(8))
    end
    
    for egg_num = 0,8 do
        if (egg_num == self.egg_anim_num) then
            spr(102 + (self.egg_anim_frame * 2),
                egg_num * 16, 112,
                2, 2)
        else
            spr(102, 
                egg_num * 16, 112,
                2, 2)
        end
    end
    
    -- leaves
    for grass_num = 0,4 do
        spr(66, 96, grass_num * 32, 4, 4)
        spr(66, 0,  grass_num * 32, 4, 4, true)
    end
    
    for p,inst in pairs(self.pelicans)do
        inst:draw(self)
    end
    
    -- blood
    for p,inst in pairs(self.death_particles) do
        self.death_particles[p]:draw(self)
    end
    
    -- lives
    for i=1,self.lives do
        spr(36, 2  + ((i-1) * 10), 119)
    end
    
    -- scoreboard
    print("escaped", 100, 122, 1)
    print("escaped", 101, 122, 1)
    print("escaped", 100, 121, 12)
    
    local score_offset = 0
    if (flr(self.score/10) < 1) then score_offset = 4 end
    print(self.score, 119 + score_offset, 115,  1)
    print(self.score, 120 + score_offset, 115,  1)
    print(self.score, 119 + score_offset, 114,  12)
    
    pset(2, 8 + sin((self.anim_counter % 115)/115) * 8, 8)
    
    if (self.game_over) then
        print("game over", 44, 56, 8)
        print("continue?", 44, 64, 6)
    end
    
    self.anim_counter += 1
end

function play_screen.get_next_turtle(self)
    local newsel = nil
    local foundturt = nil
    for t,inst in pairs(self.turtles) do
        if (inst.state == "alive") then
            if (newsel == nil) then
                newsel = inst
            end
            if (foundturt != nil) then
                newsel = inst
                break
            end
        end
        if (inst == self.selected_turtle) then
            foundturt = t 
        end
    end
    return newsel
end

function play_screen.get_prev_turtle(self)
    local newsel = nil
    for t,inst in pairs(self.turtles) do
        if (inst == self.selected_turtle and
            newsel != nil) then 
            break 
        end
        if (inst.state == "alive") then
            newsel = inst
        end
    end
    return newsel
end

-- game actors ----------------------------------------------------------------

--turtle ----------------------------------------------------------------------
turtle = { heading = 0, -- 0 degrees = north
           max_angle = 60,
           turning_speed = 4,
           jump_speed   = 0.5, 
           jump_freq    = 6,
           x = 64, 
           y = 120, 
           selected = false,
           state = "alive",
           time_since_death = 0,
           
           triggered_pelican = false}
turtle.__index = turtle

function turtle.new(x, y)
    local self = setmetatable({}, turtle)
    self.x = x
    self.y = y
    return self
end

function turtle.update(self, game)
    if (self.state == "alive") then
        turtle_anim = flr(game.anim_counter / self.jump_freq) % 9; -- only when flapping flippers
        if (turtle_anim > 2 and turtle_anim <=4) then
            local norm_heading = self.heading / 360
            
            self.y -= cos(norm_heading) * self.jump_speed
            self.x += sin(norm_heading) * self.jump_speed
        end
        
        -- control if selected
        if (self.selected) then
            if (btn(1)) then
                if (self.heading - self.turning_speed >= -self.max_angle) then
                    self.heading -= self.turning_speed
                else
                    self.heading = -self.max_angle
                end
            end
            if (btn(0)) then
                if (self.heading + self.turning_speed <= self.max_angle) then
                    self.heading += self.turning_speed
                else
                    self.heading = self.max_angle
                end
            end
        end
        
        -- death detector
        if (self:checkcollision(game)) then
            if (self.selected) then
                self.selected = false
                local prev_turtle = game:get_prev_turtle()
                if (prev_turtle != nil) then
                    game.selected_turtle = prev_turtle
                    game.selected_turtle.selected = true
                end
            end
            add(game.dead_turtles, self)
            del(game.turtles, self)
            self.state = "dying"
            sfx(3, 1)
            game.lives -= 1
            if (game.lives < 1) then
                music(-1)
                music(12, 0, 3)
                game.game_over = true
            end
        end
        
        -- this turtle gets to live past your visage!
        if (self.y < 14) then
            self.escape_anim = 0
            self.y -= 8
            sfx(1, 1)
            game.score += 1
            self.state = "escaping"
            if (self.selected) then
                self.selected = false
                local next_turtle = game:get_next_turtle()
                if (next_turtle != nil) then
                    game.selected_turtle = next_turtle
                    game.selected_turtle.selected = true
                end
            end
            self.plusone_t = game.anim_counter
        end
    elseif (self.state == "dying") then
        -- emit blood particles
        local particle_direction = rnd(120) - 60
        add(game.death_particles, death_particle.new(self.x, self.y, particle_direction))
        
        -- add to blood pool
        if (game.time_counter % 256 == 0 and self.time_since_death < 4) then
            self.time_since_death += 1
            if (self.time_since_death == 1) then
                add(game.blood_pools, blood_pool.new(self.x, self.y + 4))
            elseif (self.time_since_death == 2) then
                add(game.blood_pools, blood_pool.new(self.x - 6, self.y + 4))
                add(game.blood_pools, blood_pool.new(self.x + 6, self.y + 4))
            elseif (self.time_since_death == 3) then
                add(game.blood_pools, blood_pool.new(self.x - 12, self.y + 4))
                add(game.blood_pools, blood_pool.new(self.x + 12, self.y + 4))
            end
        end
    end
end

function turtle.draw(self, game)
    if (self.state == "alive") then
        turtle_anim = flr(game.anim_counter / self.jump_freq) % 9
        if (turtle_anim > 4) then
            spr(0, self.x, self.y)
        else
            spr(turtle_anim, self.x, self.y)
        end
        
        -- draw reticle if selected
        if (self.selected) then
            spr(5, 
                self.x + sin(self.heading / 360) * 12 , 
                self.y - cos(self.heading / 360) * 12)
        end
    elseif (self.state == "dying") then
        turtle_anim = flr(game.anim_counter / 2) % 2
        spr(16 + turtle_anim, self.x, self.y)
    elseif (self.state == "escaping") then
        spr(32 + self.escape_anim, self.x, self.y)
        print("+1", 
                self.x + 8, 
                self.y - flr((game.anim_counter - self.plusone_t) / 8), 
                game.anim_counter % 16)
        
        if (flr(game.anim_counter % 16) == 0) then
            self.escape_anim += 1
            if (self.escape_anim == 4) then
                self.state = "escaped"
            end
        end
    end
end

function turtle.checkcollision(self, game)
    local tbbox = { x = self.x + 1,
                    y = self.y,
                    w = 6,
                    h = 8 }
    if (not self.triggered_pelican) then
        if (tbbox.x + tbbox.w > 128) then
            self.triggered_pelican = true
            local new_pelican = pelican.new("right", self.y)
            add(game.pelicans, new_pelican)
        elseif (tbbox.x < 0) then
            self.triggered_pelican = true
            local new_pelican = pelican.new("left", self.y)
            new_pelican.flip = true
            add(game.pelicans, new_pelican)
        end
    end

    for c,inst in pairs(game.crabs) do
        local cbbox = inst:getboundingbox()
        if (tbbox.x           < cbbox.x + cbbox.w and
            tbbox.x + tbbox.w > cbbox.x           and
            tbbox.y           < cbbox.y + cbbox.h and
            tbbox.y + tbbox.h > cbbox.y) then
            
            return true
        end
    end
    
    for p,inst in pairs(game.pelicans)do
        local pbbox = inst:getboundingbox()
        if (tbbox.x           < pbbox.x + pbbox.w and
            tbbox.x + tbbox.w > pbbox.x           and
            tbbox.y           < pbbox.y + pbbox.h and
            tbbox.y + tbbox.h > pbbox.y) then
            
            return true
        end
    end
    
    return false
end

--crab ------------------------------------------------------------------------
crab = {    flip = false,
            time_counter = 0,
            movement_frequency = 0,
            speed = 0.1,
            arrived_at_destination = true
       }
crab.__index = crab

function crab.new(x, y)
    local self = setmetatable({}, crab)
    self.x = x
    self.y = y
    self.destination = {}
    self.destination.x = x
    self.destination.y = y
    return self
end

function crab.update(self, game)
    if (game.score ~= game.prev_score and game.score % 3 == 0) then
        self.movement_frequency += 1
    end
    
    if ( self.time_counter % flr(400 / self.movement_frequency) == 0 and
         self.arrived_at_destination) then
        self:find_destination(game)
    end
    
    -- do movement
    if (self.x ~= self.destination.x or 
        self.y ~= self.destination.y) then
        
        local movement_unit_vector= {}
        movement_unit_vector.x = self.destination.x - self.x
        movement_unit_vector.y = self.destination.y - self.y
        
        local magnitude = sqrt(movement_unit_vector.x * movement_unit_vector.x + movement_unit_vector.y * movement_unit_vector.y)
        
        if (magnitude < self.speed) then
            self.x = self.destination.x
            self.y = self.destination.y
            self.arrived_at_destination = true
        else
            movement_unit_vector.x /= magnitude
            movement_unit_vector.y /= magnitude
            
            self.x += movement_unit_vector.x * self.speed
            self.y += movement_unit_vector.y * self.speed
        end
    end
    
    self.time_counter += 1
end

function crab.draw(self, game)
    -- control crab animation speed
    local crab_anim = flr(game.anim_counter / 8) % 2
    
    -- draw crab animation
    if (crab_anim == 0) then
        spr(14, self.x, self.y, 2, 1, self.flip)
    else
        spr(30, self.x, self.y, 2, 1, self.flip)
    end
end

function crab.find_destination(self, game)
    -- random angle, fixed radius
    local r = 8
    local theta = rnd(360)
    
    -- for consistency, north is 0 degrees
    local x_dest = self.x + r * sin(theta / 360)
    local y_dest = self.y + r * cos(theta / 360)
    
    if (x_dest > 72) then
        x_dest = 72
    elseif (x_dest < 24) then
        x_dest = 24
    end
    
    if (y_dest > 94) then
        y_dest = 94
    elseif (y_dest < 32) then
        y_dest = 32
    end
    
    self:set_destination(x_dest, y_dest)
end

function crab.set_destination(self, x, y)
    self.destination.x = x
    self.destination.y = y
    
    if (self.destination.y > self.y) then
        self.flip = true
    else
        self.flip = false
    end
    
    self.arrived_at_destination = false
end

function crab.getboundingbox(self)
    local bbox = { x = self.x + 1,
                   y = self.y + 1,
                   w = 16,
                   h = 6}
    return bbox
end

-- pelican --------------------------------------------------------------------
pelican = { x = 0,
            y = 0,
            x_center = 0,
            y_center = 0,
            side = "right",
            anim_counter = 0,
            anim_time = 10
        }
pelican.__index = pelican

function pelican.new(side, y)
    local self = setmetatable({}, pelican)
    if (side == "right") then
        self.x_center = 128
        self.x = 128
    else
        self.x_center = -8
        self.x = -8
    end
    self.y_center = y
    self.y = y - 16
    
    self.side = side
    
    sfx(2, 1)
    
    return self
end

function pelican.getboundingbox(self)
    local bbox = {}
    if (self.side == "right") then
        bbox = {x = self.x + 3,
                y = self.y + 5,
                w = 5,
                h = 10
                }
    else
        bbox = {x = self.x,
                y = self.y + 5,
                w = 5,
                h = 10}
    end
    return bbox
end

function pelican.update(self, game)
    if (self.side == "right") then
        self.x = self.x_center - 8 * min(self.anim_counter, self.anim_time / 2) / (self.anim_time / 2)
        --self.x = self.x_center - min(8, 12 * sin(self.anim_counter / self.anim_time / 2))
    else
        self.x = self.x_center + 8 * min(self.anim_counter, self.anim_time / 2) / (self.anim_time / 2)
        --self.x = self.x_center + min(8, 12 * sin(self.anim_counter / self.anim_time / 2))
    end
    
    self.y = self.y_center - 24 + 24 * (self.anim_counter / self.anim_time)
    --self.y = self.y_center - 24 * 
    --    (self.anim_time - max(self.anim_counter, self.anim_time / 2 + 2)) / 
    --    (self.anim_time / 2 - 2)
    --self.y = self.y_center - 8 * cos(self.anim_counter / self.anim_time / 2)
    
    -- no more bird
    if (self.anim_counter > self.anim_time) then
        del(game.pelicans, self)
    end
end

function pelican.draw(self, game)
    local flip = false
    if (self.side == "left") then
        flip = true
    end
    
    local sprite = 47
    if (self.anim_counter % 2 == 0) then
        sprite = 46
    end
    spr(sprite,
        self.x, self.y,
        1, 2,
        flip)
    
    self.anim_counter+=1
end

--death particle --------------------------------------------------------------
death_particle = {  x         = 0,
                    y         = 0,
                    t         = 0,
                    speed     = 2,
                    direction = 0, -- 0 = north
                    lifetime  = 8,
                    }
death_particle.__index = death_particle

function death_particle.new(x, y, direction)
    local self = setmetatable({}, death_particle)
    self.x = x
    self.y = y
    self.direction = direction
    return self
end

function death_particle.update(self, game)
    local norm_direction = self.direction / 360
            
    self.y -= cos(norm_direction) * self.speed
    self.x += sin(norm_direction) * self.speed
    
    self.t += 1
end

function death_particle.draw(self, game)
    local death_anim = (game.anim_counter / 2) % 3
    local size = ((self.lifetime - self.t) / self.lifetime) * 0.8 + 0.2 
    spr(18 + death_anim, self.x, self.y, size, size)
end

-- blood pool -----------------------------------------------------------------
blood_pool = {  x   = 0,
                y   = 0,
                age = 0
             }

blood_pool.__index = blood_pool

function blood_pool.new(x, y)
    local self = setmetatable({}, blood_pool)
    self.x = x
    self.y = y
    return self
end

function blood_pool.draw(self, game)
    local spr_offset = flr(self.age / 256)
    if (spr_offset > 2) then spr_offset = 2 end
    spr(48 + spr_offset, self.x, self.y)
    self.age += 1
end

__gfx__
00033000000330000003300000033000000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000330000003300000033000000bb000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000099999440000
000bb000000bb000300bb00333bb313300bb3100000dd00000000000000000000000000000000000000000000000000000000000000000000004449944442200
03bb313033bb313303bb313000b3310033b3313300d88d0000000000000000000000000000000000000000000000000000000000000000009994484448422992
30b3310300b3310000b3310000b3310000b3310000d88d0000000000000000000000000000000000000000000000000000000000000000002299944449999220
00b3310000b3310000b331000101101001011010000dd00000000000000000000000000000000000000000000000000000000000000000000292248884229022
31011013310110133101101330000003300000030000000000000000000000000000000000000000000000000000000000000000000000000229922222994242
30000003300000033000000330000003300000030000000000000000000000000000000000000000000000000000000000000000000000002020000000000242
00000000000330000000080000000000000808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000330000808000080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999440000
300bb003000bb0000000080000800080080008000000000000000000000000000000000000000000000000000000000000000000000000000004449944442200
03bb313003bb31300008008000008000000800800000000000000000000000000000000000000000000000000000000000000000000000009994484448422992
00b3310030b331030800000000000080008000000000000000000000000000000000000000000000000000000000000000000000000000002299944449999220
31b3311300b331000000080000808000000808000000000000000000000000000000000000000000000000000000000000000000000000000299948884999022
30011003310110130008008008000008080080800000000000000000000000000000000000000000000000000000000000000000000000000222222222224242
00000000300000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020000000000242
0000000000000000007777000cccccc000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000777760007777600
000000000077770007cccc70cc7777cc0aa33a900000000000000000000000000000000000000000000000000000000000000000000000000777776607777766
0077770007cccc707cc77cc7c7cccc7caaabbaa90000000000000000000000000000000000000000000000000000000000000000000000007777777777777777
07cccc707cc77cc77c7cc7c7c7cccc7ca3bb31390000000000000000000000000000000000000000000000000000000000000000000000007755776677557766
30b33103310110137cc77cc7cc7777ccaab331a90000000000000000000000000000000000000000000000000000000000000000000000006585766065857660
00b331003000000307cccc700cccccc0a1b3311900000000000000000000000000000000000000000000000000000000000000000000000006756dd006756d00
3101101300000000000000000000000009a11a900000000000000000000000000000000000000000000000000000000000000000000000000066eed00066eed0
3000000300000000000000000000000000999900000000000000000000000000000000000000000000000000000000000000000000000000000ffeed000ffeed
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fe00ed000ffeed
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000ed000ffedd
000080000808880008888808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000ed000ffed0
08000800088088008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000d000efed0
00080000008888808888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000d000ded00
0000880088888800808888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000e0000ed00
0800000008800880088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000e0000d000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000d0000d000
ff9ff7ffffff9fff0000000003bb1111111111331333311b11111ccccc11111111111ccccc111111111111111111111111111111111111111111111111111111
ffffffffffffffff00000000000000011111111b313b111311cccccccccccc1111cccccccccccc1111111ccccc11111111111ccccc11111111111ccccc111111
fffffff9f7f9ffff00000000000000000000111133311331ccccc77777cccccccccccccccccccccc11cccccccccccc1111ccc11111cccc1111cccccccccccc11
fff7ffffffffffff000000000000000000000111133111b3cc777777777777ccccccc77777cccccccccccccccccccccccc111ccccc1111cccccccccccccccccc
f9ff9ffff9ffffff00000000000000bbbbbb33bbbb33313377777ccccc777777cc777777777777cccccccccccccccccc11cccccccccccc11ccccc77777cccccc
fffffffffffff7ff00000000000bbbb3333333113bb331b177cccccccccccc7777777ccccc777777ccccc77777cccccccccccccccccccccccc777ccccc7777cc
ff9fff9f9ffff9ff00000000003333333333333113bb3333cccccccccccccccc77cccccccccccc77cc777ccccc7777ccccccc77777cccccc77ccc77777cccc77
ffffffffffffffff000000000000000003111133113bb333ccccc44444cccccccccccccccccccccc77cccccccccccc77cc777ccccc7777cccc777ccccc7777cc
ffffffffffffffff000000000000000000001111113bb333cc444ccccc4444cccccccccccccccccccccccccccccccccc77cccccccccccc7777cccccccccccc77
f9fffffff7fffff7000000000000000000000011111bbb3344ccc44444cccc44ccccc44444cccccccccccccccccccccccccccccccccccccccccccccccccccccc
ffff79ffffff9fff0000000000000033bbbbbbb11113bb33cc444444444444cccc444444444444ccccccccccccccccccccccccccccccccccccccc44444cccccc
fffffffffffff9ff000000000033bbbbbbbbbbbb1113b33144444444444444444444444444444444ccccc44444ccccccccccc44444cccccccc444444444444cc
f9fffffff9ffffff0000000003bbbb3111333bbb3311133144444fffff44444444444fffff444444cc444fffff4444cccc444fffff4444cc44444fffff444444
f7ffffffffffffff00000003bbb3111333311133b333111144fff9ffffffff4444fff9ffffffff4444fff9ffffffff4444fff9ffffffff4444fff9ffffffff44
ffff9ffff7ff9fff000000bbb3111333113b33b333333113fffffffffff9fffffffffffffff9fffffffffffffff9fffffffffffffff9fffffffffffffff9ffff
ffffffffffffffff000000b310000111333333333bbb33bb9ffffff9ffffffff9ffffff9ffffffff9ffffff9ffffffff9ffffff9ffffffff9ffffff9ffffffff
fff9ffffff7769ff00000b310000000111bbbb1b3bbbb33300000000000000000000000000000000000000000000000000000000000000000000000000000000
f9ff776ff776dfff0000b310000000000bbb33313333b33100000000000000000000000000000000000000000000000000000000000000000000000000000000
fff7677df66ddf9f0000b10000000000bb331111133333b300000000000000000000000000000000000000000000000000000000000000000000000000000000
ff67767677d776ff000000000000000bb00011313331133300000000000000000000000000000000000000000000000000000000000000000000000000000000
f767766d76d7d66f0000000000000000000001111133331b00000000000000000000000000000000000000000000000000000000000000000000000000000000
f776dddff67d66df000000000000000000033111111333bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffff9fff7766df9000003bbbbbbbb3333311101bbbbb33300000000077770000000000007766000000000000776600000000000077660000000000000000000
9ffffff9f9dddfff0000000333333bbbbb1331bbb33bbb3b00777000777777000077700077767700007770007776770000777000777677000000000000000000
000000000000000000000000001133bbbbb11bbb33333bb307777707777777000777770777777700077777077766770007777707777777000000000000000000
000000000000000000000000000313331111bb3311133333777776d777777600777776d777777600777776d776767600777776d7777776000000000000000000
000000000000000000000000031100000111b111111113b3677776d777777d76677776d777777d76677776d777777d76677776d777777d760000000000000000
0000000000000000000000031100000000011113311113336777776d67776d776777776d67776d776777776d67776d776777776d67776d770000000000000000
0000000000000000000000310000000000010011133313b36d77766d6666d7776d77766d6666d7776d77766d6666d7776d77766d6666d7770000000000000000
0000000000000000000000000000000000000000113331b16d7766dddd6d77776d7766dddd6d77776d7766dddd6d77776d7766dddd6d77770000000000000000
000000000000000000000000000000bbbbbb000000113311d6666dd77ddd7776d6666dd77ddd7776d6666dd77ddd7776d6666dd77ddd77760000000000000000
00000000000000000000000000bbbbbb3333333300013333dddddd77777d7766dddddd77777d7766dddddd77777d7766dddddd77777d77660000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc0000000000000000cc000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc00011331111113b3bb0011111111111000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc0000111133111113b3bbbbb0111dddddd1ddddd00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc003111111331111113bb0003b00511111ddd1ddddd0000ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc000cccccccccccccccccccc03b3111113b1111113b000003b30001111d111111dddd000ccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc00b000000ccccccccccccccc033b11111b3111111bb007003bbbb301111dd1111111dddd000cccccccccccccccccccccccccccccccccccccccccccccccccc
ccc0b7777bd00000cccccccccc00bb31111bbbbb111bb00700003bbbb30111dd111111111ddd6000cccccccccccccccccccccccccccccccccccccccccccccccc
ccc0bbbb77bbbdd000cccccccc0bbbb111bbbbbbbbbbb00000003bbbbb33111d1111111111ddd66000cccccccccccccccccccccccccccccccccccccccccccccc
ccc0a666666bbbbdd000cccccc0000bb1bbbbbbbbbbbb00000003bbbbbb1111d1111111111d6ddd66000cccccccccccccccccccccccccccccccccccccccccccc
ccc0aaa6666bbbbbddd000cccc0070bbbb00bbb0bbbbb00000002bbbbddb111116116111611666dd666000cccccccccccccccccccccccccccccccccccccccccc
ccc0aaaaaa66666bbbddd000cc00000bbb00b1b00bbbb000000322bbbbddb111111111111116116666666000cccccccccccccccccccccccccccccccccccccccc
cccc0aaaaaaaaa666bbdddd00000000bbbbb111bbbbabb0000033bbbbbddddbb11111161616161616616111000cccccccccccccccccccccccccccccccccccccc
cccc09999aaaaaaa666bdddddd000000bbbb1111ababa1b00112bbbbbbbdddddbb11161166666666616611111000cccccccccccccccccccccccccccccccccccc
cccc0009999aaaaaaa666dddddd00000bbbb1112babab12b3121bbbbbbdddddddddbb666000000000000000111100ccccccccccccccccccccccccccccccccccc
4f9477009999aaaaaaaa66dddddd0001aba12121ababa212bbb22bbbbbbbbdddbbbbbbd00666ddddddbbbbb00000000ccccccccccccccccccccccccccccccccc
499f44440099999aaaaaa666dddd0111bab2121ababab12121bb2bbbbbbabbbbbbbbbddddddddbddbbbbbbbddddd75500ccccccccccccccccccccccccccccccc
94ff444440009999999aaaa66ddd021bab2122abaaaaaa12222bbbbbbbbbababa99bdddddbbdbbdbbbbbbbddd77bbbbb000000cccccccccccccccccccccccccc
fff49f444440000009999aaa6669902aba222abaaaaaaaa22bbaaabbbababababa99dddbdbbdbbbbbddddddd777777bdd777bb0000cccccccccccccccccccccc
4449ff444444444400000999aa690212aaa22aaaaaaaaaaa2aaaaaa00baaaaaaa999dddbbbbbbbdddd6666dddd77777bbb777bbbb0000ccccccccccccccccccc
999ffff49f49ff444444000099990022aaa22aaaaaaaaaaaaaaaa9aa00aaaaaaaa999333bbbdddd666666666677777777bdd777bbbbb000000cccccccccccccc
f4f4499fff99ff999444444000099022aaaa22aaaaaaaaaaaaaa99aaa09aaaaaa99999333335555666666666777777777bbbb77bdddb77777000cccccccccccc
994999ff44f9ffff4f944444440000aaaaaa22aaaaaaaaaaa99900a9009aaaaaaa9999933aaaaa555555555dddddddddd333366bbbbb777777770000cccccccc
99f4ff994f444994ff44f9944444000aaaaaaa9999999aa99000aaa909aaaaaaa9a99999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa333bddd777777777000cccccc
f9ff4f9f9f9ff9f9f99f94a9444444009aaaa9000000099000aaaa99099aaaaaaa999999999999999999999900000000000aaaaaaaabbb3337777777bb000ccc
f99f994f99f99499f9f99f9f4444444009a9909aaaaaa00aaaaaa99009aaaaaaa9a99999290000000000000004444444440000000000000006667777bbbb000c
f94fff494f9f4ff9999f9fff94444444009009aaaaaaaaaaaaaa99009a9aaaaa9a99999292222222200044444444444444444444444444440000633bbbbbbbb0
fff49f9f99f4f9ff4ff9ff9fff94444440099aaaaaaaaaaaaaa99009a9a9a9a9a9999929292222200044444444444444444444444444444444400003333bbb30
494ff4ffffff9f4f99f4444fff9f44444409999aaaaaaaaaaa9990999a9a9a9a9999929222222200444444444444444444444444444444444444440000033300
ff4999ff9fff4ff499fff9f9999fe444440009999aaaaa999999029999999999992929222222204444944444444444444444444444444444444444444f00000f
99f99fffffff9f94f44949ff94ff9944444400099999999999000222992292929292222222220444444494444ffffffff4fffffffffffff4444444444fffffff
9494f9f9494f9f9f94449994fff44f4444444400000000000004000022222222222222222000444444444444ff4fffffffefeeeefefffffffefeffffffffffff
f999f99fff4f4fff494ff4ff494ff4ff44444444444444444444444000000000000000000044444494449f44949ff4494f49f949499f9f4fffff999fefffffff
949449f9449f9ff9ff499ff9f4449f9ff94444444444444444444444444444444444444444444444444f4f49f9f4f4944ff9ff94f4f49ff99fff99f49fff9fff
99ff4ff44ff9f99fff49f949949f44994ff49f944444444444444444444444944444444444444444f4e99444f94fff99f9f99f9f9949444f99f99fffffff9f94
49f44ffff9f499f49ff4949ff9499ff9ff44f4994ff4999f449444444444444444444494444444ff4f9f4ff94f94ff9f9f4f9f494f9ff4999ff9fff4ff499fff
4f49f4f494f4449fff9f4fff49ff44fff9fff499f4f99ffff9f999f94444444444449499949f4f4ff949949f499ff444999f49444499f9fff94f9fff44fffff4
9f4ff99f994f4ff4f9444949f499ff4494ff9f944949949ffffffff9f4f449449f944999ff9fff9999f449ffffff4f9ffff9999ff9ff4fff9ff4ff9f44f444ff
ff4ff9f44f444ff9f9fffff4ff9f9f994999ff9f9944f9999f9494f4ff9f4999ff9ff99f994f99f99499f9f99f9fff4f99f9ff49fffff9f9ff4f9f9f9ff9f9f9
f9f999f99fff4f4fff494ff4ff494ff4ffffff9f4f99f4444fff9f999f4994ff9f999f9f49999f49ff49f99ff9949ff4494f49f949499f9f4fffff999f4f9f49
9499f9f99f9fff4f99f9ff49fffff9f9ff4f9f9f9ff9f9f99f94ff9f99fff9fff49f9f9f994fff99ff4f994f9f4f44ff94f4f9f49ff449ff949ff4494fff4ff9
fff444f499ff9f4994ff4999f99ff49ffffff99f44ff4f9ff4fffff49fffff4fffff9ff9f9f4449ffff4f949499ff94499ffff44f99f999f99f999f99f9f9f4f
9ff4f9f9ff944ffff9ff994ff99ffffff9f9f9f999f9f49f99f4f999ff9994fff94f9449494ff9f9fff9f9f9f94f44ff4ff49f9f9f9ff4949f4ff44f949f4494
44ffff9f499f49ff4949ff9499ff9ff44f4994ff4ffff99fffff99ffff94f4f4f4f9f9f9994ff9f9f4ff94f94ff9f9f4f9f494f9ff4999ff9fff4ff499fff9f9
ff44f4ff4fff49f94f4449fff944ff444f9ff999ffffff4f494f9949ff49f9fff94f9f449f9f494494994f9f94499f9f99fffffff99499ff4f94fff49f944ff4
9f494494994f9f94499f9f99fffffff99499ff4f94fff49f944ff44ff4949fff4fff94f44f499f94ff9f4f4449f4fff4f49f44f4ff94fff4499f4ff4f4499fff
ff4f999f994f49ff999f44ff494fff9f4994f49f49999444f49f4f494f4449fff9f4fff49ff44fff9fff499f4f99ffff9f999f9f999ff94ff99449f999f4f4ff
49fff9ff9f99f944f949f9ff9ff494ffffff999ff94f94ff99fff9999f994fff9949f49f9f9f9f949f9fffff9944ff99f9f4f49fff9fff4f94ff44f4f949ff49
88888888888888884888800000088888488448888880000000dddd00000000000000000000000000000000000d6667777776d000000000000000000000000000
8888888848888888888880000004888888888448488880000d6666d00000ddd0000dd0000000000000000000d677777777776d00000000000000000000000000
424848884884484488888000000288888888822224888800d667776d000d666d0dd66dd00000000000001100d677777777776d000ddd00000dd00dd0dd000000
222228848882222248884000000288888888822222884880d677776d00d6776dd667766d0000000d00011000677777777776d6d0d666d000d66dd66d66dd0000
222224888822222248884000000488848848800002884840d67777760d677776677777760000000d00010000777777777776d6d067776d0067d66d767766dd00
000008888840000088488000000888848888800008888840d67777770d67777777777777000000d6000000007777777777776d0077776d0067677677777666d0
0000028888400000484880000004888488488888888484200d6677770d6677777777777700000d67000000007777777777776d0077776d0076777777777766d0
00000288282000008848800000088884842888884488422000dd677700dd677777777777000dd67700000000777777777776d0007776d000777777777777dd00
00000488824000008884880000888888848884488888220000000000000d67777777777700d666666666666666dd0000777776667776667777776dd000000000
0000028888200000288888888888488284888222488820000000066000d6777777777777000d666666666666dd00000077776666776777677777766d00000000
0000048888200000248882888884884288888222248880000006677600d67777777777770000dddddddddddd00000000777666dd777777677777776d00000000
0000048888400000024888228888882088888000248888000667776d0d6d67777777777700000000000000000000000076666d00777777777777777600000000
000002888840000002248888888442208888800002488880d6ddd6d00d6d677777777777000000000000000000000000666dd000766777777766777700000000
0000044844800000002224448482220044448000022444240000000000d677777777777700000000000000000000000077677d00677677777677677700000000
0000022222200000000222222222200022222000002222220000000000d677777777777700000000000000000000000077777d00777777777777677700000000
00000222222000000000022222200000222220000002222200000000000d6777777777770000000000000000000000007777d000777777777777777700000000
__gff__
0000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4647464746474647464746474647464700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5657565756575657565756575657565700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040505040504040515050505151414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
405150405051405041415050504150500000000000e9ef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40514050504150415141405040405140000000e9eeebfeed00000000000000000000000000000000000000e9eeed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40515141404051405140614041505040e9e8e8ebfdf8fcfb00000000000000000000000000000000000000f9fafb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40415151514141404040505050405040f9fafafafafafb0000000000000000000000000000000000f6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404041404050505141414150505050400000000000000000000000000000e9ed0000f6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40414040605141414050505040515040000000000000000000e9ed0000e9ebece9ef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4051404151405050504051405050514000000000f60000e9e8ebfeef00f9fafbf9fb000000000000000000000000e6ef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40515050404141505040514040515140000000000000e9ebf8fcfafb00000000000000000000000000f6000000e9ebfeed00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50405050415050415041515160514140000000000000f9fafafb000000000000000000000000000000000000e6ebfdfdec00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505150415050515140414040515140000000000000000000000000000000000000000000000000000000e7ebfdf8fcfb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50404041404161404040404040404140000000000000000000000000000000000000000000000000000000f9fafafafb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040404050404040414050404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404050504040405040404050405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300000b62018620266202f6202b62025620206201962017620136200e620066200362001620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106000001541025310353103521075710b5110f571145711b57122571136311a631216211b621136210b6210b620000000000000000290702907124071240712b0712b0712b0713007230072300720000000000
000200001f3401f3401a3400e600106001460003300013000130023600246002a6002c6002f6003260033600154701a470212702e230382503c2503d27037270154001a400214002e400394003c4003d4003b400
00050000144701f4712b471334713a4713e4713e4713e4713e4713e4713e4713f4713f4713f4713e4713c471394713647133471314712f4712e4012c4013f3713a37118321333013f4013f471383712b37113701
012400001807012605180701160523070240002307012605220702207022070220701f605126051d605116051e6051260520605116051f605126051f605126051e605126051e6051360520605146051e60513605
002101200161103611076110a6110e6111261115611186211b6211e6211f621206212162121621206211f6211d6211b621196111661113611106110e6110a6110761104611036110261101611016110161101611
01100018180751800518005180751f70524075180051f70518005180051f70524075180751f7051f7051807521005210751f705000001f705000001d7051f0751d705000001d7050000015705000001870500000
01100018306153c6001827518235306053c600306151f705306053c6153c6051f705306153c6003c0753c03530605306153c605000003c6153c6003c60530615306053c6003c60500000306053c6003c60524702
010c0000181330c7040c7020c7020c7020c7020c7020c70218133247050c7020c7021570215702157021570218133137021370213702137021370213702137021813324705117021170211702117021170411702
01100018306153c6001827518235306053c600306151f705306053c6153c6051f70530615306153c0753c035306153061530625306253c6353063530645306450000000000000000000000000000000000000000
01100018240451500018040240411f0001f045000001f0001c0450000000000180451f045180452104518045180051f0401804118001000000000000000180450000000000000000000000000000000000000000
01100018240451500018040240411f0001f045000001f0001c04500000000001804521045180452304518045180051f0453004518000000000000000000000000000000000000000000000000000000000000000
012400001807000000180700000017070000001707017071160711607216072160720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013200002456425564265642356424564255642256122562225621b561135210b521135010b501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100018240451500018040240411f0001f045000001f0001c045000000000018045210451c045230451a045180051f04530045240403c02030040240503c0401800000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 07080644
00 07080644
00 07080644
00 09080644
00 07080a44
00 07080b44
00 07080a44
02 09080e44
00 41424344
00 41424344
00 41424344
00 41424344
00 0c0d4344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

