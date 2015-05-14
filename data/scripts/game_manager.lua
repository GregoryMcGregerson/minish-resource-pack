-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

local dialog_box_manager = require("scripts/dialog_box")

local game_manager = {}

-- Sets initial values for a new savegame of this quest.
local function initialize_new_savegame(game)
  game:set_starting_location("test")
  game:set_max_money(100)
  game:set_max_life(12)
  game:set_life(game:get_max_life())
end

-- Creates a game ready to be played.
function game_manager:create(file)

  -- Create the game (but do not start it).
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  if not exists then
    -- This is a new savegame file.
    initialize_new_savegame(game)
  end
 
  local dialog_box

  -- Function called when the player runs this game.
  function game:on_started()

    dialog_box = dialog_box_manager:create(game)
  end

  -- Function called when the game stops.
  function game:on_finished()

    dialog_box:quit()
    dialog_box = nil
  end

  function game:on_paused()

    game:start_dialog("pause.save", function(answer)
      if answer == 2 then
        game:save()
      end
      game:set_paused(false)
    end)
  end

  local rupee_icon = sol.surface.create("hud/rupee_icon.png")
  local rupee_text = sol.text_surface.create()
  rupee_text:set_font("8_bit")

  function game:on_draw(dst_surface)

    rupee_icon:draw_region(0, 0, 12, 12, dst_surface, 10, 220)
    rupee_text:set_text(game:get_money())
    rupee_text:draw(dst_surface, 25, 225)
  end

  return game
end

return game_manager
