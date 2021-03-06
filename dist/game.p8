pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
-- scumm-8 (return of the scumm)
-- paul nicholas

-- 7004 tokens (5206 is engine!) - leaving 1188 tokens spare
-- now 6979 tokens (1213 spare)
-- now 6758 tokens (after "packing" - 1434 spare)
-- now 6723 tokens (after packing actors)
-- now 6860 tokens (after adding library)
-- now 6906 tokens (after adding "use" object/actor & fix shake crop)
-- now 6805 tokens (after also converting flags/enums to strings)
-- now 6845 tokens (after adding switch chars via inventory)
-- now 6944 tokens (after adding in landing & error reporting)
-- now 6977 tokens (after adding new use_pos & error check for nil doors)
-- now 7489 tokens (after adding mini-game & door classes)
-- now 7595 tokens (after stairs, door teleports, b4 tweak to pathfinding)
-- now 7646 tokens (after b4 tweak to pathfinding)
-- now 8052 tokens (after intro, lightswitch and final game elements)

-- debugging
show_debuginfo = false
show_collision = false
--show_pathfinding = true
show_perfinfo = false
enable_mouse = true
d = printh



-- game verbs (used in room definitions and ui)
verbs = {
	--{verb = verb_ref_name}, text = display_name
	{ { open = "open" }, text = "open" },
	{ { close = "close" }, text = "close" },
	{ { give = "give" }, text = "give" },
	{ { pickup = "pickup" }, text = "pick-up" },
	{ { lookat = "lookat" }, text = "look-at" },
	{ { talkto = "talkto" }, text = "talk-to" },
	{ { push = "push" }, text = "push" },
	{ { pull = "pull" }, text = "pull"},
	{ { use = "use" }, text = "use"}
}
-- verb to use when just clicking aroung (e.g. move actor)
verb_default = {
	{ walkto = "walkto" }, text = "walk to"
} 


function reset_ui()
	verb_maincol = 12  -- main color (lt blue)
	verb_hovcol = 7    -- hover color (white)
	verb_shadcol = 1   -- shadow (dk blue)
	verb_defcol = 10   -- default action (yellow)
end



-- 
-- room & object definitions
-- 

-- title "room"
	-- objects
	rm_title = {
		data = [[
			map = {0,16}
		]],
		objects = {
		},
		enter = function(me)

			cutscene(
				3, -- no verbs & no follow, 
				function()
					if not me.gameover then
						print_line("return of the...",64,40,8,1)
						for x=1,11 do
							print_line(sub("   scumm", 1, x),55,45,11,1,true)
						end
						change_room(rm_outside, 1) -- iris fade
					else
					-- win game
						print_line("congratulations!:you've completed the game!",64,45,8,1)
						fades(1,1)	-- fade out
						while true do
							break_time(10) 
						end
					end
				end) -- end cutscene
		end,
		exit = function()
			-- todo: anything here?
		end,
	}

-- [ ground floor ]
	-- outside (front)
		-- objects
			obj_outside_stairs = {
				data = [[
					x=1
					y=1
					classes = {class_untouchable}
				]],
				draw = function(me)
					-- switch transparency
					set_trans_col(8, true)
					-- draw stairs
					map(56,23, 136,60, 6,1)
				end,
			}

			obj_rail_left = {		
				data = [[
					state=state_here
					x=80
					y=24
					w=1
					h=2
					state_here=47
					trans_col=8
					repeat_x = 8
					classes = {class_untouchable}
				]],
			}

			obj_rail_right = {		
				data = [[
					state=state_here
					x=176
					y=24
					w=1
					h=2
					state_here=47
					trans_col=8
					repeat_x = 8
					classes = {class_untouchable}
				]],
			}

			obj_front_door = {		
				data = [[
					name = front door
					state=state_closed
					x=152
					y=8
					w=1
					h=3
					state_closed=78
					flip_x = true
					classes = {class_openable,class_door}
					use_dir = face_back
				]],
				init = function(me)
					me.target_door = obj_front_door_inside
				end
			}

			obj_bucket = {		
				data = [[
					name = bucket
					state = state_open
					x=208
					y=48
					w=1
					h=1
					state_closed=143
					state_open = 159
					trans_col=15
					use_with=true
					classes = {class_pickupable}
				]],
				verbs = {
					lookat = function(me)
						say_line("it's an old bucket")
					end,
					pickup = function(me)
						pickup_obj(me)
					end,
					use = function(me, noun2)
						if noun2 == obj_fire then
							put_at(obj_fire, 0, 0, rm_void)
							put_at(obj_key, 88, 32, rm_library)
							obj_bucket.state = "state_open"
							say_line("the fire's out now")
						elseif noun2 == obj_pool then
							say_line("let's fill this up...")
							me.state = "state_closed"
							me.name = "full bucket"
							say_line("that's better!")
						end
					end
				}
			}


		rm_outside = {
			data = [[
				map = {0,24,31,31}
			]],
			objects = {
				obj_outside_stairs,
				obj_rail_left,
				obj_rail_right,
				obj_front_door,
				obj_bucket
			},
			enter = function(me)
				-- 
				-- initialise game in first room entry...
				-- 
				if not me.done_intro then
					-- don't do this again
					me.done_intro = true
					-- set which actor the player controls by default
					selected_actor = main_actor
					-- init actor
					put_at(selected_actor, 30, 55, rm_outside)
					-- make camera follow player
					-- (setting now, will be re-instated after cutscene)
					camera_follow(selected_actor)
					-- do cutscene
					cutscene(
						1, -- no verbs
						-- cutscene code (hides ui, etc.)
						function()
							camera_at(144)
							camera_pan_to(selected_actor)
							wait_for_camera()
							say_line("wow! look at that old house:i wonder if anyone's home...")
						end
					)
				end
			end,
			exit = function(me)
				-- todo: anything here?
			end,
		}

	-- hall
		-- objects
			obj_front_door_inside = {		
				data = [[
					name = front door
					state = state_closed
					x=8
					y=16
					z=1
					w=1
					h=4
					state_closed=79
					classes = {class_openable}
					use_pos = pos_right
					use_dir = face_left
				]],
				verbs = {
					walkto = function(me)
						come_out_door(me, obj_front_door)
					end,
					open = function(me)
						open_door(me, obj_front_door)
					end,
					close = function(me)
						close_door(me, obj_front_door)
					end
				}
			}

			obj_clock = {		
				data = [[
					name=clock
					x=32
					y=0
					w=2
					h=5
					z=2
				]],
				draw = function(me)
					-- switch transparency
					set_trans_col(8, true)
					-- draw computer + table
					map(56,16, 32,16, 2,6)
				end,
				verbs = {
					lookat = function(me)
						say_line("wow. that is impressive...:must've taken ages to code that!")
					end,
				}
			}

			obj_pendulum= {		
				data = [[
					x=40
					y=20
					w=1
					z=1
				]],
				draw = function(me)
					rectfill(35, 20, 43, 56, 0)
					line(me.x, me.y, obj_pendulum.bobx, obj_pendulum.boby, 9)
  				circfill(obj_pendulum.bobx, obj_pendulum.boby, 2)
				end
			}

			obj_inside_stairs = {
				data = [[
					x=1
					y=1 
					w=1
					h=1
					state=state_here
					state_here=3
					classes = {class_untouchable}
				]],
				draw = function(me)
					-- switch transparency
					set_trans_col(8, true)
					-- draw stairs
					map(56,23, 68,52, 6,1)
				end,
			}

			obj_hall_rail = {		
				data = [[
					state=state_here
					x=1
					y=1
					w=1
					h=2
					z=30
					state_here=3
					classes = {class_untouchable}
				]],
				draw = function(me)
					-- switch transparency
					set_trans_col(8, true)
					-- draw stairs
					map(59,19, 100,12, 4,4)
				end,
			}

			obj_hall_exit_landing = {		
				data = [[
					name=upstairs
					state=state_open
					x=106
					y=0
					w=3
					h=2
					use_pos = pos_center
					use_dir = face_back
				]],
				verbs = {
					walkto = function(me)
						come_out_door(me, obj_landing_exit_hall)
					end
				}
			}

			obj_hall_door_library = {		
				data = [[
					name=library
					state=state_open
					x=136
					y=16
					w=1
					h=3
					use_dir = face_back
				]],
				verbs = {
					walkto = function(me)
						come_out_door(me, obj_library_door_hall)
					end
				}
			}

			obj_hall_door_kitchen = {		
				data = [[
					name = kitchen
					state = state_open
					x=176
					y=16
					w=1
					h=4
					use_pos = pos_left
					use_dir = face_right
				]],
				verbs = {
					walkto = function(me)
						come_out_door(me, obj_kitchen_door_hall)
					end
				}
			}


		rm_hall = {
			data = [[
				map = {32,24,55,31}
				col_replace = {5,2}
			]],
			objects = {
				--obj_spinning_top,
				obj_clock,
				obj_pendulum,
				obj_front_door_inside,
				obj_inside_stairs,
				obj_hall_rail,
				obj_hall_exit_landing,
				obj_hall_door_library,
				obj_hall_door_kitchen,
			},
			enter = function(me)
				-- animate clock
				start_script(me.scripts.anim_clock, true) -- bg script
			end,
			exit = function(me)
				-- pause clock while not in room
				stop_script(me.scripts.anim_clock)
			end,
			scripts = {
				anim_clock = function()
					local angle = 0.5149 --3.1415 / 6.101
					local avel = 0
					local val = -10
					local played = false

					while true do
						local aacc = -6.81 / 31 * sin(angle)  -- -9.81

						avel += aacc * 0.1 * 0.2
						angle += avel * 0.1
						obj_pendulum.bobx = obj_pendulum.x + sin(angle) * 31
						obj_pendulum.boby = obj_pendulum.y - cos(angle) * 31
						
						if angle <= 0.4850
						 and not played then
							sfx(0)
							played = true
						elseif angle >= 0.5140
						 and not played then
							sfx(1)
							played = true
						elseif angle > 0.49 and angle < 0.50 then
							played = false
						end

						break_time()
					end
				end
			}
		}

	-- library
		-- objects
			
			obj_library_door_hall = {		
				data = [[
					name=hall
					state=state_open
					x=48
					y=16
					w=1
					h=3
					state_open=128
					use_dir = face_back
					classes = { class_door }
					lighting = 1
				]],
				init = function(me)  
					me.target_door = obj_hall_door_library
				end
			}

			obj_lightswitch = {		
				data = [[
					name=light switch
					state=state_here
					x=56
					y=23
					w=1
					h=1
					state_here=125
					lighting=0.6
				]],
				verbs = {
					use = function(me)
						if me.on then
							rm_library.lighting = 0.25
							obj_library_door_hall.lighting = 1
							obj_lightswitch.lighting = 0.6
							me.on = false
						else
							rm_library.lighting = 1
							obj_library_door_hall.lighting = 0
							obj_lightswitch.lighting = 1
							me.on = true
						end
					end
				}
			}
			
			obj_fire = {
				data = [[
					name=fire
					x=88
					y=32
					w=1
					h=1
					state=1
					states={81,82,83}
					use_pos={97,42}
					lighting = 1
				]],
				-- dependent_on = obj_front_door_inside,
				-- dependent_on_state = "state_open",
				verbs = {
					lookat = function()
						say_line("it's a nice, warm fire...")
						break_time(10)
						do_anim(selected_actor, "anim_face", "face_front")
						say_line("ouch! it's hot!:*stupid fire*")
					end,
					talkto = function()
						say_line("'hi fire...'")
						break_time(10)
						do_anim(selected_actor, "anim_face", "face_front")
						say_line("the fire didn't say hello back:burn!!")
					end,
					pickup = function(me)
						pickup_obj(me)
					end
				}
			}

			obj_library_secret_panel = {		
				data = [[
					state=state_closed
					x=120
					y=16
					z=-1
					w=1
					h=3
					state_closed=80
					state_open=80
					classes = {class_untouchable}
					use_dir = face_back
				]],
				verbs = {
				}
			}

			obj_library_door_secret = {		
				data = [[
					name=secret passage
					state=state_closed
					x=120
					y=16
					z=-10
					w=1
					h=3
					state_closed=77
					use_dir = face_back
					dependent_on_state = state_open
				]],
				dependent_on = obj_library_secret_panel,
				dependent_on_state = "state_open",
				verbs = {
					walkto = function(me)
	 					rm_title.gameover = true
						change_room(rm_title, 1)
					end
				}
			}

			obj_book = {		
				data = [[
					name=loose book
					state=state_gone
					x=136
					y=16
					w=1
					h=1
					state_gone=66
					state_here=65
					use_pos={144,40}
					classes = {class_pickupable}
				]],
				verbs = {
					lookat = function(me)
						if me.state == "state_gone" then
							say_line("this book sticks out")
						else
							say_line("it's a secret lock that was hidden behind the book")
						end
					end,
					pull = function(me)
						me.state = "state_here"
						me.name = "secret lock"
					end,
					pickup = function(me)
						me.verbs.pull(me)
					end
				}
			}

			obj_key = {		
				data = [[
					name=gold key
					state=state_gone
					x=1
					y=1
					z=30
					w=1
					h=1
					state_gone=32
					state_here=173
					use_with=true
					classes = {class_pickupable}
				]],
				verbs = {
					lookat = function(me)
						say_line("it's a gold key")
					end,
					pickup = function(me)
						me.state = "state_here"
						pickup_obj(me)
					end,
					use = function(me, noun2)
						if (noun2 == obj_book) then
							put_at(me, 0,0, rm_void)
							obj_library_secret_panel.state = "state_open"
							shake(true)
							while (obj_library_secret_panel.y > -8) do
								obj_library_secret_panel.y -= 1
								break_time(10)
							end
							shake(false)
						end
					end,
				}
			}


		rm_library = {
			data = [[
				map = {56,24,79,31}
				trans_col = 10
				col_replace={7,4}
				lighting=0.25
			]],
			objects = {
				obj_library_door_hall,
				obj_lightswitch,
				obj_fire,
				obj_library_door_secret,
				obj_library_secret_panel,
				obj_book
			},
			enter = function(me)
				-- animate fireplace
				start_script(me.scripts.anim_fire, true) -- bg script
			end,
			exit = function(me)
				-- pause fireplace while not in room
				stop_script(me.scripts.anim_fire)
			end,
			scripts = {
				anim_fire = function()
					while true do
						for f=1,3 do
							obj_fire.state = f
							break_time(8)
						end
					end
				end
			}
		}
		
	-- kitchen
		-- objects

			obj_spinning_top = {		
				data = [[
					name=spinning top
					x=148
					y=50
					w=1
					h=1
					state=1
					states={158,174,190}
					col_replace={12,7}
					trans_col=15
				]],
				scripts = {
					spin_top = function()
						dir=-1				
						while true do	
							for x=1,3 do					
								for f=1,3 do
									obj_spinning_top.state = f
									break_time(4)
								end
								-- move top
								--top = find_object("spinning top")
								obj_spinning_top.x -= dir					
							end	
							dir *= -1
						end				
					end,
				},
				verbs = {
					use = function(me)
						if script_running(me.scripts.spin_top) then
							stop_script(me.scripts.spin_top)
							me.state = 1
						else
							start_script(me.scripts.spin_top)
						end
					end
				}
			}


			obj_kitchen_door_hall = {		
				data = [[
					name = hall
					state=state_open
					x=8
					y=16
					w=1
					h=4
					use_pos = pos_right
					use_dir = face_left
					classes = { class_door }
				]],
				init = function(me)  
					me.target_door = obj_hall_door_kitchen
				end
			}

			obj_back_door = {		
				data = [[
					name=back door
					state=state_closed
					x=176
					y=16
					z=1
					w=1
					h=4
					state_closed=79
					flip_x=true
					classes = { class_openable, class_door }
					use_pos = pos_left
					use_dir = face_right
				]],
				init = function(me)  
					me.target_door = obj_garden_door_kitchen
				end
			}

		rm_kitchen = {
			data = [[
				map = {80,24,103,31}
			]],
			objects = {
				obj_spinning_top,
				obj_kitchen_door_hall,
				obj_back_door
			},
			enter = function(me)
				start_script(me.scripts.tentacle_guard, true) -- bg script
			end,
			exit = function(me)
				stop_script(me.scripts.tentacle_guard)
			end,
			scripts = {	  -- scripts that are at room-level
				tentacle_guard = function()
				
					while true do
						if proximity(main_actor, obj_back_door) < 40 
						 and not purp_tentacle.alerting
						 and purp_tentacle.in_room == selected_actor.in_room then
							purp_tentacle.alerting = true
							purp_tentacle.stopped_player = true
							cutscene(2,
								function()
									stop_actor(selected_actor)
									say_line(purp_tentacle, "stop!:come back here!", true)
									walk_to(selected_actor, purp_tentacle.x-8, purp_tentacle.y)
									do_anim(selected_actor, "anim_face", purp_tentacle)
									purp_tentacle.alerting = false
								end
							)
						end
						break_time(10)
					end
				end,
			},
		}

	-- back garden
		-- objects
			obj_garden_door_kitchen = {		
				data = [[
					name=kitchen
					state=state_closed
					x=104
					y=8
					w=1
					h=3
					state_closed=78
					classes = { class_openable, class_door }
					use_dir = face_back
				]],
				init = function(me)  
					me.target_door = obj_back_door
				end
			}

			obj_pool = {		
				data = [[
					name=swimming pool
					x=96
					y=48
					w=3
					h=2
					use_pos = pos_above
					use_dir = face_front
				]],
				verbs = {
					walkto = function(me)
						say_line("i can't swim!")
					end,
					lookat = function(me)
						say_line("it's filled with water")
					end,
				}
			}

		rm_garden = {
			data = [[
				map = {104,24,127,31}
			]],
			objects = {
				obj_garden_door_kitchen,
				obj_pool,
			},
			enter = function()
					-- todo: anything here?
			end,
			exit = function()
				-- todo: anything here?
			end,
		}

-- [ second floor ]
	-- landing
		-- objects
			obj_rail_left = {		
				data = [[
					state=state_here
					x=0
					y=47
					w=1
					h=2
					state_here=47
					trans_col=8
					repeat_x = 16
					classes = { class_untouchable }
				]],
			}

			obj_rail_right= {		
				data = [[
					state=state_here
					x=144
					y=47
					w=1
					h=2
					state_here=47
					trans_col=8
					repeat_x = 6
					classes = { class_untouchable }
				]],
			}

			obj_landing_exit_hall = {		
				data = [[
					name=hall
					state=state_open
					x=124
					y=56
					w=3
					h=2
					use_pos = pos_center
					use_dir = face_front
					classes = { class_door }
				]],
				init = function(me)					
					me.target_door = obj_hall_exit_landing
				end
			}

		obj_landing_door_computer = {		
			data = [[
				name = computer room
				state = state_open
				x=176
				y=16
				w=1
				h=4
				use_pos = pos_left
				use_dir = face_right
				classes = { class_door }
			]],
			init = function(me)  
				me.target_door = obj_computer_door_landing
			end
		}

		obj_landing_door_room1 = {		
				data = [[
					name = door #1
					state = state_closed
					x=8
					y=16
					z=1
					w=1
					h=4
					state_closed=79
					state_open=0
					classes = {class_openable}
					use_pos = pos_right
					use_dir = face_left
				]],
				verbs = {
					open = function(me)
						rm_landing.scripts.door_teleport(me, obj_landing_door_room3)
					end
				}
			}

		obj_landing_door_room2 = {		
				data = [[
					name = door #2
					state = state_closed
					x=48
					y=16
					z=1
					w=1
					h=3
					state_closed=78
					classes = {class_openable}
					use_pos = pos_infront
					use_dir = face_back
				]],
				verbs = {
					open = function(me)
						rm_landing.scripts.door_teleport(me, obj_landing_door_room3)
					end
				}
			}
		
		obj_landing_door_room3 = {		
				data = [[
					name = door #3
					state = state_closed
					x=136
					y=16
					z=1
					w=1
					h=3
					state_closed=78
					state_open=0
					classes = {class_openable}
					use_pos = pos_infront
					use_dir = face_back
				]],
				verbs = {
					open = function(me)
						rm_landing.scripts.door_teleport(me, obj_landing_door_room1)
					end
				}
			}
		

		rm_landing = {
			data = [[
				map = {32,16,55,31}
			]],
			objects = {
				obj_rail_left,
				obj_rail_right,
				obj_landing_exit_hall,
				obj_landing_door_room1,
				obj_landing_door_room2,
				obj_landing_door_room3,
				obj_landing_door_computer
			},
			enter = function(me)
				
			end,
			exit = function(me)

			end,
			scripts = {	  
				door_teleport = function(door1, door2)
					cutscene(
						2, -- quick-cut
						function()
							open_door(door1)
							break_time(10)
							put_at(selected_actor,0,0,rm_void)
							close_door(door1)
							camera_pan_to(door2)
							wait_for_camera()
							open_door(door1, door2)
							break_time(10)
							come_out_door(door1, door2)
							close_door(door1,door2)
							camera_follow(selected_actor)
						end)
				end
			},
		}

	-- computer room
		-- objects
			obj_computer_door_landing = {		
				data = [[
					name = first floor
					state=state_open
					x=8
					y=16
					w=1
					h=4
					use_pos = pos_right
					use_dir = face_left
					classes = { class_door }
				]],
				init = function(me)
					me.target_door = obj_landing_door_computer
				end
			}

			obj_computer = {		
				data = [[
					name=computer
					state=state_here
					state_here=1
					x=56
					y=16
					z=1
					w=2
					h=2
					use_pos={64,40}
					use_dir = face_back
				]],
				draw = function(me)
					-- switch transparency
					set_trans_col(8, true)
					-- draw computer + table
					map(58,16, 40,28, 6,4, 0x80)
				end,
				verbs = {
					lookat = function(me)
						say_line("it's old \"286\" pc-compatible")
					end,
					use = function(me)
						me.played = true
						change_room(rm_mi_title, 1)					
					end
				}
			}

			obj_cursor = {		
				data = [[
					x=56
					y=12
					w=1
					h=1
					trans_col=8
					state=1
					states={74,76}
					classes = {class_untouchable}
				]],
				verbs = {
				}
			}


			obj_window = {		
				data = [[
					name=window
					state=state_closed
					x=32
					y=8
					w=2
					h=2
					state_closed=68
					state_open=70
					classes = {class_openable}
				]],
				verbs = {
					open = function(me)
						me.state = "state_open"
					end,
					close = function(me)
						me.state = "state_closed"
					end,

						-- if not me.done_cutscene then
						-- 	cutscene(
						-- 		1, -- no verbs 
						-- 		function()
						-- 			me.done_cutscene = true
						-- 			-- cutscene code
						--	 			me.state = "state_open"
						-- 			me.z = -2
						-- 			print_line("*bang*",40,20,8,1)
						-- 			change_room(rm_kitchen, 1)
						-- 			selected_actor = purp_tentacle
						-- 			walk_to(selected_actor, 
						-- 				selected_actor.x+10, 
						-- 				selected_actor.y)
						-- 			say_line("what was that?!")
						-- 			say_line("i'd better check...")
						-- 			walk_to(selected_actor, 
						-- 				selected_actor.x-10, 
						-- 				selected_actor.y)
						-- 			change_room(rm_hall, 1)
						-- 			-- wait for a bit, then appear in room1
						-- 			break_time(50)
						-- 			put_at(selected_actor, 115, 44, rm_hall)
						-- 			walk_to(selected_actor, 
						-- 				selected_actor.x-10, 
						-- 				selected_actor.y)
						-- 			say_line("intruder!!!")
						-- 			do_anim(main_actor, "anim_face", purp_tentacle)
						-- 		end,
						-- 		-- override for cutscene
						-- 		function()
						-- 			--if cutscene_curr.skipped then
						-- 			--d("override!")
						-- 			change_room(rm_hall)
						-- 			put_at(purp_tentacle, 105, 44, rm_hall)
						-- 			stop_talking()
						-- 			do_anim(main_actor, "anim_face", purp_tentacle)
						-- 		end
						-- 	)
						-- end --if
						-- (code here will not run, as room change nuked "local" scripts)
				}
			}

			obj_floppy_disk = {	
				data = [[
					name=pico-8
					x=60
					y=44
					w=1
					h=1
					state=state_here
					state_here=189
					trans_col=11
					use_with=true
					classes={class_pickupable}
				]],
				verbs = {
					lookat = function(me)
						say_line("it's a licenced copy of pico-8:\"a fantasy console for making, sharing and playing tiny games and other computer programs\":sounds like fun!")
					end,
					pickup = function(me)
						pickup_obj(me)
					end,
					use = function(me, noun2)
						if (noun2 == obj_computer) then
							say_line("there's already a disk inserted")
						end
					end,
					give = function(me, noun2)
						if noun2 == purp_tentacle then
							say_line("do you like programming?")
							say_line(purp_tentacle, "yes, why?")
							say_line("give pico-8 a go,;see what you can make")
							me.owner = purp_tentacle
							say_line(purp_tentacle, "this is perfect!", true)
							say_line(purp_tentacle, "thank you!:i shall start making a game right now...")
							stop_script(rm_kitchen.scripts.tentacle_guard)
							walk_to(purp_tentacle, obj_kitchen_door_hall.x+4, obj_kitchen_door_hall.y+30)
							put_at(purp_tentacle, 0,0, rm_void)
						else
							say_line("i might need this")
						end
					end,
				}
			}


		rm_computer = {
			data = [[
				map = {64,16}
			]],
			objects = {
				obj_computer_door_landing,
				obj_computer,
				obj_cursor,
				obj_window,
				obj_floppy_disk,
			},
			enter = function(me)
				-- just exited the game?
				start_script(me.scripts.anim_cursor, true) 

				if obj_computer.played then
					obj_computer.played = false
					cutscene(
						3, -- no verbs & no follow, 
						function()
							-- reset gfx,ui & player (to restore after playing mini-game)
							reload()
							reset_ui()
							selected_actor = main_actor
							camera_follow(selected_actor)
							do_anim(selected_actor, "anim_face", "face_front")
							say_line("well, that was short!:developers are so lazy...")
							--say_line("test")
						end
					) -- end cutscene
				end
			end,
			exit = function(me)
				stop_script(me.scripts.anim_cursor)
			end,
			scripts = {	  
				anim_cursor = function()
					while true do
						for f=1,2 do
							obj_cursor.state = f
							break_time(15)
						end
					end
				end				
			},
		}








-- [ monkey island mini-game ]
	-- mi title "room"
		rm_mi_title = {
			data = [[
				map = {72,0}
			]],
			objects = {
			},
			enter = function(me)

				-- load embedded gfx (from sfx area)
				reload(0,0x3b00,0x800)
				-- load embedded gfx flags (from sfx area)
				reload(0x3000,0x3a00,0x100)

				-- demo intro
					cutscene(
						3, -- no verbs & no follow, 
						function()

							-- intro
							break_time(50)
							print_line("deep in the caribbean:on the isle of...; ;thimbleweed!",64,45,8,1,true)

							change_room(rm_mi_dock, 1)
							
						end
					) -- end cutscene
			end,
			exit = function()
				-- todo: anything here?
			end,
		}

	-- mi dock
		-- objects
			obj_mi_bg = {		
				data = [[
					x=0
					y=0
					w=1
					h=1
					z=-10
					classes = {class_untouchable}
					state=state_here
					state_here=1
				]],
				draw = function(me)
					map(88,0, 0,16, 40,7)
				end
			}

			obj_mi_poster = {		
				data = [[
					name=poster
					x=32
					y=40
					w=1
					h=1
				]],
				verbs = {
					lookat = function(me)
						say_line("\"re-elect governor marly\"")
					end
				}
			}

			obj_mi_scummdoor = {		
				data = [[
					name = door
					state=state_closed
					x=240
					y=40
					w=1
					h=2
					state_closed=43
					state_open=12
					classes = {class_openable}
					use_dir = face_back
				]],
				verbs = {
					walkto = function(me)
						if me.state == "state_open" then
							-- outro
							change_room(rm_computer, 1)
						else
							say_line("the door is closed")
						end
					end,
					open = function(me)
						open_door(me, obj_front_door_inside)
					end,
					close = function(me)
						close_door(me, obj_front_door_inside)
					end
				}
			}

		rm_mi_dock = {
			data = [[
				map = {88,8,127,15}
				trans_col = 11
			]],
			objects = {
				obj_mi_bg,
				obj_mi_poster,
				obj_mi_scummdoor
			},
			enter = function(me)
				-- 
				-- initialise game in first room entry...
				-- 
				verb_maincol = 11
				verb_hovcol = 10
				verb_shadcol = 0 
				verb_defcol = 10 

				-- set which actor the player controls by default
				selected_actor = mi_actor
				-- init actor
				put_at(selected_actor, 212, 60, rm_mi_dock)

				camera_at(0)
				break_time(30)
				camera_pan_to(212,60)
				wait_for_camera()
				camera_follow(selected_actor)
				
				say_line("this all seems very famililar...")

				camera_follow(selected_actor)
			end,
			exit = function(me)
				-- todo: anything here?
			end,
		}


-- "the void" (room)
-- a place to put objects/actors when not in a room	
	-- objects

		-- obj_switch_tent = {		
		-- 	data = [[
		-- 		name=purple tentacle
		-- 		state=state_here
		-- 		state_here=170
		-- 		trans_col=15
		-- 		x=1
		-- 		y=1
		-- 		w=1
		-- 		h=1
		-- 	]],
		-- 	verbs = {
		-- 		use = function(me)
		-- 			selected_actor = purp_tentacle
		-- 			camera_follow(purp_tentacle)
		-- 		end
		-- 	}
		-- }

		-- obj_switch_player= {		
		-- 	data = [[
		-- 		name=humanoid
		-- 		state=state_here
		-- 		state_here=209
		-- 		trans_col=11
		-- 		x=1
		-- 		y=1
		-- 		w=1
		-- 		h=1
		-- 	]],
		-- 	verbs = {
		-- 		use = function(me)
		-- 			selected_actor = main_actor
		-- 			camera_follow(main_actor)
		-- 		end
		-- 	}
		-- }

		-- obj_duck = {		
		-- 	data = [[
		-- 		name=rubber duck
		-- 		state=state_here
		-- 		state_here=142
		-- 		trans_col=12
		-- 		x=1
		-- 		y=1
		-- 		w=1
		-- 		h=1
		-- 		classes = {class_pickupable}
		-- 	]],
		-- 	verbs = {
		-- 		pickup = function(me)
		-- 			pickup_obj(me)
		-- 		end,
		-- 	}
		-- }


	rm_void = {
		data = [[
			map = {0,0}
		]],
		objects = {
			obj_key
			-- obj_switch_player,
			-- obj_switch_tent
		},
	}




-- 
-- active rooms list
-- 
rooms = {
	rm_void,
	rm_title,
	rm_outside,
	rm_hall,
	rm_kitchen,
	rm_garden,
	rm_library,
	rm_landing,
	rm_computer,

	rm_mi_title,
	rm_mi_dock
}



--
-- actor definitions
-- 

	-- initialize the player's actor object
	main_actor = { 	
		data = [[
			name = humanoid
			w = 1
			h = 4
			idle = { 193, 197, 199, 197 }
			talk = { 218, 219, 220, 219 }
			walk_anim_side = { 196, 197, 198, 197 }
			walk_anim_front = { 194, 193, 195, 193 }
			walk_anim_back = { 200, 199, 201, 199 }
			col = 12
			trans_col = 11
			walk_speed = 0.6
			frame_delay = 5
			classes = {class_actor}
			face_dir = face_front
		]],
		-- sprites for directions (front, left, back, right) - note: right=left-flipped
		inventory = {
			obj_switch_tent
		},
		verbs = {
			use = function(me)
				selected_actor = me
				camera_follow(me)
			end
		}
	}

	purp_tentacle = {
		data = [[
			name = purple tentacle
			x = 140
			y = 52
			w = 1
			h = 3
			idle = { 154, 154, 154, 154 }
			talk = { 171, 171, 171, 171 }
			col = 11
			trans_col = 15
			walk_speed = 0.4
			frame_delay = 5
			classes = {class_actor,class_talkable}
			face_dir = face_front
			use_pos = pos_left
		]],
		in_room = rm_kitchen,
		inventory = {
			obj_switch_player
		},
		verbs = {
				lookat = function()
					say_line("it's a weird looking tentacle, thing!")
				end,
				talkto = function(me)
					cutscene(
						1, -- no verbs
						function()
							--do_anim(purp_tentacle, anim_face, selected_actor)
							say_line(me,"what do you want?")
						end)

					-- dialog loop start
					while (true) do
						-- build dialog options
						dialog_set({ 
							(not me.stopped_player and "" or "why did you stop me?"),
							(me.asked_where and "" or "where am i?"),
							--"who are you?",
							(me.asked_woodchuck and "" or "how much wood would a wood-chuck chuck, if a wood-chuck could chuck wood?"),
							"nevermind"
						})
						dialog_start(selected_actor.col, 7)

						-- wait for selection
						while not selected_sentence do break_time() end
						-- chosen options
						dialog_hide()

						cutscene(
							1, -- no verbs
							function()
								say_line(selected_sentence.msg)
								
								if selected_sentence.num == 1 then
									say_line(me, "i need your help:i'm bored with this spinning top...:if you can you find something i can play with, i'd appreciate it")
									me.asked_why_stop = true

								elseif selected_sentence.num == 2 then
									say_line(me, "you are in paul's demo scumm-8 game, i think!")
									me.asked_where = true

								-- elseif selected_sentence.num == 3 then
								-- 	say_line(me, "it's complicated...")

								elseif selected_sentence.num == 3 then
									say_line(me, "a wood-chuck would chuck no amount of wood, coz a wood-chuck can't chuck wood!")
									me.asked_woodchuck = true

								elseif selected_sentence.num == 4 then
									say_line(me, "ok bye!")
									dialog_end()
									return
								end
							end)

						dialog_clear()

					end --dialog loop
				end, -- talkto
				use = function(me)
					selected_actor = me
					camera_follow(me)
				end
			}
	}

	mi_actor = { 	
		data = [[
			name = guybrush
			w = 1
			h = 2
			idle = { 47, 47, 15, 47 }
			walk_anim_side = { 44, 45, 44, 46 }
			col = 7
			trans_col = 8
			walk_speed = 0.5
			frame_delay = 8
			classes = {class_actor}
			face_dir = face_front
		]],
		-- sprites for directions (front, left, back, right) - note: right=left-flipped
		inventory = {
			-- obj_switch_tent
		},
		verbs = {
			-- use = function(me)
			-- 	selected_actor = me
			-- 	camera_follow(me)
			-- end
		}
	}


-- 
-- active actors list
-- 
actors = {
	main_actor,
	purp_tentacle,
	mi_actor
}


-- 
-- scripts
-- 

-- this script is execute once on game startup
function startup_script()	
	-- set ui colors
	reset_ui()

	-- set which room to start the game in 
	-- (e.g. could be a "pseudo" room for title screen!)
	change_room(rm_title, 1) -- iris fade

	-- set initial inventory (if applicable)
	-- pickup_obj(obj_switch_tent, main_actor)
	-- pickup_obj(obj_switch_player, purp_tentacle)
	
	-- pickup_obj(obj_bucket, main_actor)
	-- obj_bucket.state = "state_closed"
	
	-- set which actor the player controls by default
--	selected_actor = main_actor
	
	-- init actor
--	put_at(selected_actor, 100, 48, rm_kitchen)
	--put_at(selected_actor, 60, 48, rm_hall)
	--put_at(selected_actor, 16, 48, rm_computer)
--	put_at(selected_actor, 110, 38, rm_garden)
--	put_at(selected_actor, 110, 38, rm_library)
	
	-- make camera follow player
	-- (setting now, will be re-instated after cutscene)
--	camera_follow(selected_actor)



	--room_curr = rm_title
	--room_curr = rm_kitchen
	--room_curr = rm_hall
	--room_curr = rm_computer
--	room_curr = rm_garden
	--room_curr = rm_library
end


-- (end of customisable game content)





























-- ==============================
-- scumm-8 public api functions
-- 
-- (you should not need to modify anything below here!)


function shake(bq) if bq then
br=1 end bs=bq end function bt(bu) local bv=nil if has_flag(bu.classes,"class_talkable") then
bv="talkto"elseif has_flag(bu.classes,"class_openable") then if bu.state=="state_closed"then
bv="open"else bv="close"end else bv="lookat"end for bw in all(verbs) do bx=get_verb(bw) if bx[2]==bv then bv=bw break end
end return bv end function by(bz,ca,cb) local cc=has_flag(ca.classes,"class_actor") if bz=="walkto"then
return elseif bz=="pickup"then if cc then
say_line"i don't need them"else say_line"i don't need that"end elseif bz=="use"then if cc then
say_line"i can't just *use* someone"end if cb then
if has_flag(cb.classes,class_actor) then
say_line"i can't use that on someone!"else say_line"that doesn't work"end end elseif bz=="give"then if cc then
say_line"i don't think i should be giving this away"else say_line"i can't do that"end elseif bz=="lookat"then if cc then
say_line"i think it's alive"else say_line"looks pretty ordinary"end elseif bz=="open"then if cc then
say_line"they don't seem to open"else say_line"it doesn't seem to open"end elseif bz=="close"then if cc then
say_line"they don't seem to close"else say_line"it doesn't seem to close"end elseif bz=="push"or bz=="pull"then if cc then
say_line"moving them would accomplish nothing"else say_line"it won't budge!"end elseif bz=="talkto"then if cc then
say_line"erm... i don't think they want to talk"else say_line"i am not talking to that!"end else say_line"hmm. no."end end function camera_at(cd) cam_x=ce(cd) cf=nil cg=nil end function camera_follow(ch) stop_script(ci) cg=ch cf=nil ci=function() while cg do if cg.in_room==room_curr then
cam_x=ce(cg) end yield() end end start_script(ci,true) if cg.in_room!=room_curr then
change_room(cg.in_room,1) end end function camera_pan_to(cd) cf=ce(cd) cg=nil ci=function() while(true) do if cam_x==cf then
cf=nil return elseif cf>cam_x then cam_x+=0.5 else cam_x-=0.5 end yield() end end start_script(ci,true) end function wait_for_camera() while script_running(ci) do yield() end end function cutscene(type,cj,ck) cl={cm=type,cn=cocreate(cj),co=ck,cp=cg} add(cq,cl) cr=cl break_time() end function dialog_set(cs) for msg in all(cs) do dialog_add(msg) end end function dialog_add(msg) if not ct then ct={cu={},cv=false} end
cw=cx(msg,32) cy=cz(cw) da={num=#ct.cu+1,msg=msg,cw=cw,db=cy} add(ct.cu,da) end function dialog_start(col,dc) ct.col=col ct.dc=dc ct.cv=true selected_sentence=nil end function dialog_hide() ct.cv=false end function dialog_clear() ct.cu={} selected_sentence=nil end function dialog_end() ct=nil end function get_use_pos(bu) local dd=bu.use_pos local x=bu.x local y=bu.y if type(dd)=="table"then
x=dd[1] y=dd[2] elseif dd=="pos_left"then if bu.de then
x-=(bu.w*8+4) y+=1 else x-=2 y+=((bu.h*8)-2) end elseif dd=="pos_right"then x+=(bu.w*8) y+=((bu.h*8)-2) elseif dd=="pos_above"then x+=((bu.w*8)/2)-4 y-=2 elseif dd=="pos_center"then x+=((bu.w*8)/2) y+=((bu.h*8)/2)-4 elseif dd=="pos_infront"or dd==nil then x+=((bu.w*8)/2)-4 y+=(bu.h*8)+2 end return{x=x,y=y} end function do_anim(ch,df,dg) dh={"face_front","face_left","face_back","face_right"} if df=="anim_face"then
if type(dg)=="table"then
di=atan2(ch.x-dg.x,dg.y-ch.y) dj=93*(3.1415/180) di=dj-di dk=di*360 dk=dk%360 if dk<0 then dk+=360 end
dg=4-flr(dk/90) dg=dh[dg] end face_dir=dl[ch.face_dir] dg=dl[dg] while face_dir!=dg do if face_dir<dg then
face_dir+=1 else face_dir-=1 end ch.face_dir=dh[face_dir] ch.flip=(ch.face_dir=="face_left") break_time(10) end end end function open_door(dm,dn) if dm.state=="state_open"then
say_line"it's already open"else dm.state="state_open"if dn then dn.state="state_open"end
end end function close_door(dm,dn) if dm.state=="state_closed"then
say_line"it's already closed"else dm.state="state_closed"if dn then dn.state="state_closed"end
end end function come_out_door(dp,dq,dr) if dq==nil then
ds("target door does not exist") return end if dp.state=="state_open"then
dt=dq.in_room if dt!=room_curr then
change_room(dt,dr) end local du=get_use_pos(dq) put_at(selected_actor,du.x,du.y,dt) dv={face_front="face_back",face_left="face_right",face_back="face_front",face_right="face_left"} if dq.use_dir then
dw=dv[dq.use_dir] else dw=1 end selected_actor.face_dir=dw selected_actor.flip=(selected_actor.face_dir=="face_left") else say_line("the door is closed") end end function fades(dx,bd) if bd==1 then
dy=0 else dy=50 end while true do dy+=bd*2 if dy>50
or dy<0 then return end if dx==1 then
dz=min(dy,32) end yield() end end function change_room(dt,dx) if dt==nil then
ds("room does not exist") return end stop_script(ea) if dx and room_curr then
fades(dx,1) end if room_curr and room_curr.exit then
room_curr.exit(room_curr) end eb={} ec() room_curr=dt if not cg
or cg.in_room!=room_curr then cam_x=0 end stop_talking() if dx then
ea=function() fades(dx,-1) end start_script(ea,true) else dz=0 end if room_curr.enter then
room_curr.enter(room_curr) end end function valid_verb(bz,ed) if not ed
or not ed.verbs then return false end if type(bz)=="table"then
if ed.verbs[bz[1]] then return true end
else if ed.verbs[bz] then return true end
end return false end function pickup_obj(bu,ch) ch=ch or selected_actor add(ch.bo,bu) bu.owner=ch del(bu.in_room.objects,bu) end function start_script(ee,ef,eg,eh) local cn=cocreate(ee) local scripts=eb if ef then
scripts=ei end add(scripts,{ee,cn,eg,eh}) end function script_running(ee) for ej in all({eb,ei}) do for ek,el in pairs(ej) do if el[1]==ee then
return el end end end return false end function stop_script(ee) el=script_running(ee) if el then
del(eb,el) del(ei,el) end end function break_time(em) em=em or 1 for x=1,em do yield() end end function wait_for_message() while en!=nil do yield() end end function say_line(ch,msg,eo,ep) if type(ch)=="string"then
msg=ch ch=selected_actor end eq=ch.y-(ch.h)*8+4 er=ch print_line(msg,ch.x,eq,ch.col,1,eo,ep) end function stop_talking() en,er=nil,nil end function print_line(msg,x,y,col,es,eo,ep) local col=col or 7 local es=es or 0 if es==1 then
et=min(x-cam_x,127-(x-cam_x)) else et=127-(x-cam_x) end local eu=max(flr(et/2),16) local ev=""for ew=1,#msg do local ex=sub(msg,ew,ew) if ex==":"then
ev=sub(msg,ew+1) msg=sub(msg,1,ew-1) break end end local cw=cx(msg,eu) local cy=cz(cw) ey=x-cam_x if es==1 then
ey-=((cy*4)/2) end ey=max(2,ey) eq=max(18,y) ey=min(ey,127-(cy*4)-1) en={ez=cw,x=ey,y=eq,col=col,es=es,fa=ep or(#msg)*8,db=cy,eo=eo} if#ev>0 then
fb=er wait_for_message() er=fb print_line(ev,x,y,col,es,eo) end wait_for_message() end function put_at(bu,x,y,fc) if fc then
if not has_flag(bu.classes,"class_actor") then
if bu.in_room then del(bu.in_room.objects,bu) end
add(fc.objects,bu) bu.owner=nil end bu.in_room=fc end bu.x,bu.y=x,y end function stop_actor(ch) ch.fd=0 ec() end function walk_to(ch,x,y) local fe=ff(ch) local fg=flr(x/8)+room_curr.map[1] local fh=flr(y/8)+room_curr.map[2] local fi={fg,fh} local fj=fk(fe,fi) ch.fd=1 for fl in all(fj) do local fm=(fl[1]-room_curr.map[1])*8+4 local fn=(fl[2]-room_curr.map[2])*8+4 local fo=sqrt((fm-ch.x)^2+(fn-ch.y)^2) local fp=ch.walk_speed*(fm-ch.x)/fo local fq=ch.walk_speed*(fn-ch.y)/fo if ch.fd==0 then
return end if fo>5 then
ch.flip=(fp<0) if abs(fp)<0.4 then
if fq>0 then
ch.fr=ch.walk_anim_front ch.face_dir="face_front"else ch.fr=ch.walk_anim_back ch.face_dir="face_back"end else ch.fr=ch.walk_anim_side ch.face_dir="face_right"if ch.flip then ch.face_dir="face_left"end
end for ew=0,fo/ch.walk_speed do ch.x+=fp ch.y+=fq yield() end end end ch.fd=2 end function wait_for_actor(ch) ch=ch or selected_actor while ch.fd!=2 do yield() end end function proximity(ca,cb) if ca.in_room==cb.in_room then
local fo=sqrt((ca.x-cb.x)^2+(ca.y-cb.y)^2) return fo else return 1000 end end fs=16 cam_x,cf,ci,br=0,nil,nil,0 ft,fu,fv,fw=63.5,63.5,0,1 fx={7,12,13,13,12,7} fy={{spr=208,x=75,y=fs+60},{spr=240,x=75,y=fs+72}} dl={face_front=1,face_left=2,face_back=3,face_right=4} function fz(bu) local ga={} for ek,bw in pairs(bu) do add(ga,ek) end return ga end function get_verb(bu) local bz={} local ga=fz(bu[1]) add(bz,ga[1]) add(bz,bu[1][ga[1]]) add(bz,bu.text) return bz end function ec() gb=get_verb(verb_default) gc,gd,o,ge,gf=nil,nil,nil,false,""end ec() en=nil ct=nil cr=nil er=nil ei={} eb={} cq={} gg={} dz,dz=0,0 gh=0 function _init() if enable_mouse then poke(0x5f2d,1) end
gi() start_script(startup_script,true) end function _update60() gj() end function _draw() gk() end function gj() if selected_actor and selected_actor.cn
and not coresume(selected_actor.cn) then selected_actor.cn=nil end gl(ei) if cr then
if cr.cn
and not coresume(cr.cn) then if cr.cm!=3
and cr.cp then camera_follow(cr.cp) selected_actor=cr.cp end del(cq,cr) if#cq>0 then
cr=cq[#cq] else if cr.cm!=2 then
gh=3 end cr=nil end end else gl(eb) end gm() gn() go,gp=1.5-rnd(3),1.5-rnd(3) go=flr(go*br) gp=flr(gp*br) if not bs then
br*=0.90 if br<0.05 then br=0 end
end end function gk() rectfill(0,0,127,127,0) camera(cam_x+go,0+gp) clip(0+dz-go,fs+dz-gp,128-dz*2-go,64-dz*2) gq() camera(0,0) clip() if show_perfinfo then
print("cpu: "..flr(100*stat(1)).."%",0,fs-16,8) print("mem: "..flr(stat(0)/1024*100).."%",0,fs-8,8) end if show_debuginfo then
print("x: "..flr(ft+cam_x).." y:"..fu-fs,80,fs-8,8) end gr() if ct
and ct.cv then gs() gt() return end if gh>0 then
gh-=1 return end if not cr then
gu() end if(not cr
or cr.cm==2) and gh==0 then gv() else end if not cr then
gt() end end function gm() if cr then
if(btnp(5) or stat(34)>0)
and cr.co then cr.cn=cocreate(cr.co) cr.co=nil return end return end if btn(0) then ft-=1 end
if btn(1) then ft+=1 end
if btn(2) then fu-=1 end
if btn(3) then fu+=1 end
if btnp(4) then gw(1) end
if btnp(5) then gw(2) end
if enable_mouse then
gx,gy=stat(32)-1,stat(33)-1 if gx!=gz then ft=gx end
if gy!=ha then fu=gy end
if stat(34)>0 then
if not hb then
gw(stat(34)) hb=true end else hb=false end gz=gx ha=gy end ft=mid(0,ft,127) fu=mid(0,fu,127) end function gw(hc) local hd=gb if not selected_actor then
return end if ct and ct.cv then
if he then
selected_sentence=he end return end if hf then
gb=get_verb(hf) elseif hg then if hc==1 then
if(gb[2]=="use"or gb[2]=="give")
and gc then gd=hg else gc=hg end elseif hh then gb=get_verb(hh) gc=hg fz(gc) gu() end elseif hi then if hi==fy[1] then
if selected_actor.hj>0 then
selected_actor.hj-=1 end else if selected_actor.hj+2<flr(#selected_actor.bo/4) then
selected_actor.hj+=1 end end return end if gc!=nil
then if gb[2]=="use"or gb[2]=="give"then
if gd then
elseif gc.use_with and gc.owner==selected_actor then return end end ge=true selected_actor.cn=cocreate(function() if(not gc.owner
and(not has_flag(gc.classes,"class_actor") or gb[2]!="use")) or gd then hk=gd or gc hl=get_use_pos(hk) walk_to(selected_actor,hl.x,hl.y) if selected_actor.fd!=2 then return end
use_dir=hk if hk.use_dir then use_dir=hk.use_dir end
do_anim(selected_actor,"anim_face",use_dir) end if valid_verb(gb,gc) then
start_script(gc.verbs[gb[1]],false,gc,gd) else if has_flag(gc.classes,"class_door") then
if gb[2]=="walkto"then
come_out_door(gc,gc.target_door) elseif gb[2]=="open"then open_door(gc,gc.target_door) elseif gb[2]=="close"then close_door(gc,gc.target_door) end else by(gb[2],gc,gd) end end ec() end) coresume(selected_actor.cn) elseif fu>fs and fu<fs+64 then ge=true selected_actor.cn=cocreate(function() walk_to(selected_actor,ft+cam_x,fu-fs) ec() end) coresume(selected_actor.cn) end end function gn() if not room_curr then
return end hf,hh,hg,he,hi=nil,nil,nil,nil,nil if ct
and ct.cv then for ej in all(ct.cu) do if hm(ej) then
he=ej end end return end hn() for bu in all(room_curr.objects) do if(not bu.classes
or(bu.classes and not has_flag(bu.classes,"class_untouchable"))) and(not bu.dependent_on or bu.dependent_on.state==bu.dependent_on_state) then ho(bu,bu.w*8,bu.h*8,cam_x,hp) else bu.hq=nil end if hm(bu) then
if not hg
or(not bu.z and hg.z<0) or(bu.z and hg.z and bu.z>hg.z) then hg=bu end end hr(bu) end for ek,ch in pairs(actors) do if ch.in_room==room_curr then
ho(ch,ch.w*8,ch.h*8,cam_x,hp) hr(ch) if hm(ch)
and ch!=selected_actor then hg=ch end end end if selected_actor then
for bw in all(verbs) do if hm(bw) then
hf=bw end end for hs in all(fy) do if hm(hs) then
hi=hs end end for ek,bu in pairs(selected_actor.bo) do if hm(bu) then
hg=bu if gb[2]=="pickup"and hg.owner then
gb=nil end end if bu.owner!=selected_actor then
del(selected_actor.bo,bu) end end if gb==nil then
gb=get_verb(verb_default) end if hg then
hh=bt(hg) end end end function hn() gg={} for x=-64,64 do gg[x]={} end end function hr(bu) eq=-1 if bu.ht then
eq=bu.y else eq=bu.y+(bu.h*8) end hu=flr(eq) if bu.z then
hu=bu.z end add(gg[hu],bu) end function gq() if not room_curr then
print("-error-  no current room set",5+cam_x,5+fs,8,0) return end rectfill(0,fs,127,fs+64,room_curr.hv or 0) for z=-64,64 do if z==0 then
hw(room_curr) if room_curr.trans_col then
palt(0,false) palt(room_curr.trans_col,true) end map(room_curr.map[1],room_curr.map[2],0,fs,room_curr.hx,room_curr.hy) pal() else hu=gg[z] for bu in all(hu) do if not has_flag(bu.classes,"class_actor") then
if bu.states
or(bu.state and bu[bu.state] and bu[bu.state]>0) and(not bu.dependent_on or bu.dependent_on.state==bu.dependent_on_state) and not bu.owner or bu.draw then hz(bu) end else if bu.in_room==room_curr then
ia(bu) end end ib(bu) end end end end function hw(bu) if bu.col_replace then
ic=bu.col_replace pal(ic[1],ic[2]) end if bu.lighting then
id(bu.lighting) elseif bu.in_room and bu.in_room.lighting then id(bu.in_room.lighting) end end function hz(bu) hw(bu) if bu.draw then
bu.draw(bu) else ie=1 if bu.repeat_x then ie=bu.repeat_x end
for h=0,ie-1 do local ig=0 if bu.states then
ig=bu.states[bu.state] else ig=bu[bu.state] end ih(ig,bu.x+(h*(bu.w*8)),bu.y,bu.w,bu.h,bu.trans_col,bu.flip_x) end end pal() end function ia(ch) ii=dl[ch.face_dir] if ch.fd==1
and ch.fr then ch.ij+=1 if ch.ij>ch.frame_delay then
ch.ij=1 ch.ik+=1 if ch.ik>#ch.fr then ch.ik=1 end
end il=ch.fr[ch.ik] else il=ch.idle[ii] end hw(ch) ih(il,ch.de,ch.ht,ch.w,ch.h,ch.trans_col,ch.flip,false) if er
and er==ch and er.talk then if ch.im<7 then
il=ch.talk[ii] ih(il,ch.de,ch.ht+8,1,1,ch.trans_col,ch.flip,false) end ch.im+=1 if ch.im>14 then ch.im=1 end
end pal() end function gu() io=""ip=verb_maincol iq=gb[2] if gb then
io=gb[3] end if gc then
io=io.." "..gc.name if iq=="use"then
io=io.." with"elseif iq=="give"then io=io.." to"end end if gd then
io=io.." "..gd.name elseif hg and hg.name!=""and(not gc or(gc!=hg)) and(not hg.owner or iq!=get_verb(verb_default)[2]) then io=io.." "..hg.name end gf=io if ge then
io=gf ip=verb_hovcol end print(ir(io),is(io),fs+66,ip) end function gr() if en then
it=0 for iu in all(en.ez) do iv=0 if en.es==1 then
iv=((en.db*4)-(#iu*4))/2 end outline_text(iu,en.x+iv,en.y+it,en.col,0,en.eo) it+=6 end en.fa-=1 if en.fa<=0 then
stop_talking() end end end function gv() ey,eq,iw=0,75,0 for bw in all(verbs) do ix=verb_maincol if hh
and bw==hh then ix=verb_defcol end if bw==hf then ix=verb_hovcol end
bx=get_verb(bw) print(bx[3],ey,eq+fs+1,verb_shadcol) print(bx[3],ey,eq+fs,ix) bw.x=ey bw.y=eq ho(bw,#bx[3]*4,5,0,0) ib(bw) if#bx[3]>iw then iw=#bx[3] end
eq+=8 if eq>=95 then
eq=75 ey+=(iw+1.0)*4 iw=0 end end if selected_actor then
ey,eq=86,76 iy=selected_actor.hj*4 iz=min(iy+8,#selected_actor.bo) for ja=1,8 do rectfill(ey-1,fs+eq-1,ey+8,fs+eq+8,verb_shadcol) bu=selected_actor.bo[iy+ja] if bu then
bu.x,bu.y=ey,eq hz(bu) ho(bu,bu.w*8,bu.h*8,0,0) ib(bu) end ey+=11 if ey>=125 then
eq+=12 ey=86 end ja+=1 end for ew=1,2 do jb=fy[ew] if hi==jb then
pal(7,verb_hovcol) else pal(7,verb_maincol) end pal(5,verb_shadcol) ih(jb.spr,jb.x,jb.y,1,1,0) ho(jb,8,7,0,0) ib(jb) pal() end end end function gs() ey,eq=0,70 for ej in all(ct.cu) do if ej.db>0 then
ej.x,ej.y=ey,eq ho(ej,ej.db*4,#ej.cw*5,0,0) ix=ct.col if ej==he then ix=ct.dc end
for iu in all(ej.cw) do print(ir(iu),ey,eq+fs,ix) eq+=5 end ib(ej) eq+=2 end end end function gt() col=fx[fw] pal(7,col) spr(224,ft-4,fu-3,1,1,0) pal() fv+=1 if fv>7 then
fv=1 fw+=1 if fw>#fx then fw=1 end
end end function ih(jc,x,y,w,h,jd,flip_x,je) set_trans_col(jd,true) spr(jc,x,fs+y,w,h,flip_x,je) end function set_trans_col(jd,bq) palt(0,false) palt(jd,true) if jd and jd>0 then
palt(0,false) end end function gi() for fc in all(rooms) do jf(fc) if(#fc.map>2) then
fc.hx=fc.map[3]-fc.map[1]+1 fc.hy=fc.map[4]-fc.map[2]+1 else fc.hx=16 fc.hy=8 end for bu in all(fc.objects) do jf(bu) bu.in_room=fc bu.h=bu.h or 0 if bu.init then
bu.init(bu) end end end for jg,ch in pairs(actors) do jf(ch) ch.fd=2 ch.ij=1 ch.im=1 ch.ik=1 ch.bo={} ch.hj=0 end end function ib(bu) local jh=bu.hq if show_collision
and jh then rect(jh.x,jh.y,jh.ji,jh.jj,8) end end function gl(scripts) for el in all(scripts) do if el[2] and not coresume(el[2],el[3],el[4]) then
del(scripts,el) el=nil end end end function id(jk) if jk then jk=1-jk end
local fl=flr(mid(0,jk,1)*100) local jl={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14} for jm=1,15 do col=jm jn=(fl+(jm*1.46))/22 for ek=1,jn do col=jl[col] end pal(jm,col) end end function ce(cd) if type(cd)=="table"then
cd=cd.x end return mid(0,cd-64,(room_curr.hx*8)-128) end function ff(bu) local fg=flr(bu.x/8)+room_curr.map[1] local fh=flr(bu.y/8)+room_curr.map[2] return{fg,fh} end function jo(fg,fh) local jp=mget(fg,fh) local jq=fget(jp,0) return jq end function cx(msg,eu) local cw={} local jr=""local js=""local ex=""local jt=function(ju) if#js+#jr>ju then
add(cw,jr) jr=""end jr=jr..js js=""end for ew=1,#msg do ex=sub(msg,ew,ew) js=js..ex if ex==" "
or#js>eu-1 then jt(eu) elseif#js>eu-1 then js=js.."-"jt(eu) elseif ex==";"then jr=jr..sub(js,1,#js-1) js=""jt(0) end end jt(eu) if jr!=""then
add(cw,jr) end return cw end function cz(cw) cy=0 for iu in all(cw) do if#iu>cy then cy=#iu end
end return cy end function has_flag(bu,jv) for be in all(bu) do if be==jv then
return true end end return false end function ho(bu,w,h,jw,jx) x=bu.x y=bu.y if has_flag(bu.classes,"class_actor") then
bu.de=x-(bu.w*8)/2 bu.ht=y-(bu.h*8)+1 x=bu.de y=bu.ht end bu.hq={x=x,y=y+fs,ji=x+w-1,jj=y+h+fs-1,jw=jw,jx=jx} end function fk(jy,jz) local ka,kb,kc,kd,ke={},{},{},nil,nil kf(ka,jy,0) kb[kg(jy)]=nil kc[kg(jy)]=0 while#ka>0 and#ka<1000 do local kh=ka[#ka] del(ka,ka[#ka]) ki=kh[1] if kg(ki)==kg(jz) then
break end local kj={} for x=-1,1 do for y=-1,1 do if x==0 and y==0 then
else local kk=ki[1]+x local kl=ki[2]+y if abs(x)!=abs(y) then km=1 else km=1.4 end
if kk>=room_curr.map[1] and kk<=room_curr.map[1]+room_curr.hx
and kl>=room_curr.map[2] and kl<=room_curr.map[2]+room_curr.hy and jo(kk,kl) and((abs(x)!=abs(y)) or jo(kk,ki[2]) or jo(kk-x,kl) or enable_diag_squeeze) then add(kj,{kk,kl,km}) end end end end for kn in all(kj) do local ko=kg(kn) local kp=kc[kg(ki)]+kn[3] if not kc[ko]
or kp<kc[ko] then kc[ko]=kp local h=max(abs(jz[1]-kn[1]),abs(jz[2]-kn[2])) local kq=kp+h kf(ka,kn,kq) kb[ko]=ki if not kd
or h<kd then kd=h ke=ko kr=kn end end end end local fj={} ki=kb[kg(jz)] if ki then
add(fj,jz) elseif ke then ki=kb[ke] add(fj,kr) end if ki then
local ks=kg(ki) local kt=kg(jy) while ks!=kt do add(fj,ki) ki=kb[ks] ks=kg(ki) end for ew=1,#fj/2 do local ku=fj[ew] local kv=#fj-(ew-1) fj[ew]=fj[kv] fj[kv]=ku end end return fj end function kf(kw,cd,fl) if#kw>=1 then
add(kw,{}) for ew=(#kw),2,-1 do local kn=kw[ew-1] if fl<kn[2] then
kw[ew]={cd,fl} return else kw[ew]=kn end end kw[1]={cd,fl} else add(kw,{cd,fl}) end end function kg(kx) return((kx[1]+1)*16)+kx[2] end function ds(msg) print_line("-error-;"..msg,5+cam_x,5,8,0) end function jf(bu) local cw=ky(bu.data,"\n") for iu in all(cw) do local pairs=ky(iu,"=") if#pairs==2 then
bu[pairs[1]]=kz(pairs[2]) else printh(" > invalid data: ["..pairs[1].."]") end end end function ky(ej,la) local lb={} local iy=0 local lc=0 for ew=1,#ej do local ld=sub(ej,ew,ew) if ld==la then
add(lb,sub(ej,iy,lc)) iy=0 lc=0 elseif ld!=" "and ld!="\t"then lc=ew if iy==0 then iy=ew end
end end if iy+lc>0 then
add(lb,sub(ej,iy,lc)) end return lb end function kz(le) local lf=sub(le,1,1) local lb=nil if le=="true"then
lb=true elseif le=="false"then lb=false elseif lg(lf) then if lf=="-"then
lb=sub(le,2,#le)*-1 else lb=le+0 end elseif lf=="{"then local ku=sub(le,2,#le-1) lb=ky(ku,",") lh={} for cd in all(lb) do cd=kz(cd) add(lh,cd) end lb=lh else lb=le end return lb end function lg(ic) for a=1,13 do if ic==sub("0123456789.-+",a,a) then
return true end end end function outline_text(li,x,y,lj,lk,eo) if not eo then li=ir(li) end
for ll=-1,1 do for lm=-1,1 do print(li,x+ll,y+lm,lk) end end print(li,x,y,lj) end function is(ej) return 63.5-flr((#ej*4)/2) end function ln(ej) return 61 end function hm(bu) if not bu.hq
or cr then return false end hq=bu.hq if(ft+hq.jw>hq.ji or ft+hq.jw<hq.x)
or(fu>hq.jj or fu<hq.y) then return false else return true end end function ir(ej) local a=""local iu,ic,kw=false,false for ew=1,#ej do local hs=sub(ej,ew,ew) if hs=="^"then
if ic then a=a..hs end
ic=not ic elseif hs=="~"then if kw then a=a..hs end
kw,iu=not kw,not iu else if ic==iu and hs>="a"and hs<="z"then
for jm=1,26 do if hs==sub("abcdefghijklmnopqrstuvwxyz",jm,jm) then
hs=sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",jm,jm) break end end end a=a..hs ic,kw=false,false end end return a end









__gfx__
0000000000000000000000000000000044444444440000004444444477777777f9e9f9f9ddd5ddd5bbbbbbbb5500000010101010000000000000000000000000
00000000000000000000000000000000444444404400000044444444777777779eee9f9fdd5ddd5dbbbbbbbb5555000001010101000000000000000000000000
00800800000000000000000000000000aaaaaa00aaaa000005aaaaaa77777777feeef9f9d5ddd5ddbbbbbbbb5555550010101010000000000000000000000000
0008800055555555ddddddddeeeeeeee999990009999000005999999777777779fef9fef5ddd5dddbbbbbbbb5555555501010101000000000000000000000000
0008800055555555ddddddddeeeeeeee44440000444444000005444477777777f9f9feeeddd5ddd5bbbbbbbb5555555510101010000000000000000000000000
0080080055555555ddddddddeeeeeeee444000004444440000054444777777779f9f9eeedd5ddd5dbbbbbbbb5555555501010101000000000000000000000000
0000000055555555ddddddddeeeeeeeeaa000000aaaaaaaa000005aa77777777f9f9feeed5ddd5ddbbbbbbbb5555555510101010000000000000000000000000
0000000055555555ddddddddeeeeeeee900000009999999900000599777777779f9f9fef5ddd5dddbbbbbbbb5555555501010101000000000000000000000000
0000000077777755666666ddbbbbbbee888888553333333313131344666666665888858866666666cbcbcbcb0000005510101044999999990000000088845888
00000000777755556666ddddbbbbeeee88888855333333333131314466666666588885881c1c1c1cbcbcbcbc0000555501010144444444440000000088845888
000010007755555566ddddddbbeeeeee88887777333333331313aaaa6666666655555555c1c1c1c1cbcbcbcb005555551010aaaa000450000000000088845888
0000c00055555555ddddddddeeeeeeee88886666333333333131999966666666888588881c1c1c1cbcbcbcbc5555555501019999000450000000000088845888
001c7c1055555555ddddddddeeeeeeee8855555533333333134444446666666688858888c1c1c1c1cbcbcbcb5555555510444444000450000000000088845888
0000c00055555555ddddddddeeeeeeee88555555333333333144444466666666555555551c1c1c1cbcbcbcbc5555555501444444000450000000000088845888
0000100055555555ddddddddeeeeeeee7777777733333333aaaaaaaa6666666658888588c1c1c1c1cbcbcbcb55555555aaaaaaaa000450000000000088845888
0000000055555555ddddddddeeeeeeee66666666333333339999999966666666588885887c7c7c7cbcbcbcbc5555555599999999000450000000000088845888
0000000055777777dd666666eebbbbbb558888885555555544444444777777777777777755555555444444454444444444444445000450008888888999999999
0000000055557777dddd6666eeeebbbb5588888855553333444444447777777777777777555555554444445c4444444444444458000450008888889444444444
0000000055555577dddddd66eeeeeebb7777888855333333aaaaaaaa777777777777777755555555444445cbaaaaaa4444444588000450008888894888845888
000c000055555555ddddddddeeeeeeee66668888533333339999999977777777777777775555555544445cbc9999994444445888000450008888948888845888
0000000055555555ddddddddeeeeeeee5555558853333333444444447777775555777777555555554445cbcb4444444444458888000450008889488888845888
0000000055555555ddddddddeeeeeeee555555885533333344444444777755555555777755555555445cbcbc4444444444588888000450008894588888845888
0000000055555555ddddddddeeeeeeee7777777755553333aaaaaaaa77555555555555770000000045cbcbcbaa44444445888888999999998944588888845888
0000000055555555ddddddddeeeeeeee6666666655555555999999995555555555555555000000005cbcbcbc9944444458888888555555559484588888845888
0000000055555555ddddddddbbbbbbbb555555555555555544444444cccccccc5555555677777777c77777776555555533333336633333338884588988845888
0000000055555555ddddddddbbbbbbbb555555553333555544444444cccccccc555555677777777ccc7777777655555533333367763333338884589488845888
0000000055555555ddddddddbbbbbbbb7777777733333355aaaaaa50cccccccc55555677777777ccccc777777765555533333677776333338884594488845888
0000000055555555ddddddddbbbbbbbb666666663333333599999950cccccccc5555677777777ccccccc77777776555533336777777633338884944488845888
0000000055555555ddddddddbbbbbbbb555555553333333544445000cccccccc555677777777ccccccccc7777777655533367777777763338889444488845888
0000000055555555ddddddddbbbbbbbb555555553333335544445000cccccccc55677777777ccccccccccc777777765533677777777776338894444488845888
0b03000055555555ddddddddbbbbbbbb7777777733335555aa500000cccccccc5677777777ccccccccccccc77777776536777777777777638944444499999999
b00030b055555555ddddddddbbbbbbbb666666665555555599500000cccccccc677777777ccccccccccccccc7777777667777777777777769444444455555555
00000000000000000000000000000000777777777777777777555555555555778888884444888888888888888888888888888888d00000004444444444444444
9f00d70000c0006500c0096500000000700000077000000770700000000007078888884004088888888888888888888888888888d50000004ffffff44ffffff4
9f2ed728b3c55565b3c5596500000000700000077000000770070000000070078888844444408888888888888888888888888888d51000004f4444944f444494
9f2ed728b3c50565b3c5946500000000700000077000000770006000000600078888440000440888888888888888888888888888d51000004f4444944f444494
9f2ed728b3c50565b3c5946500000000700000077000000770006000000600078884402222044088888666666666688888866666d51000004f4444944f444494
9f2ed728b3c55565b3c9456500000000700000077000000770006000000600078844025555404408888600000000688888860000d51000004f4444944f444494
9f2ed728b3c55565b3c94565000000007000000770000007700060000006000784402500aa540408888600000000688888860b00d51000004f4444944f444494
444444444444444444444444000000007777777777777777777760000006777784405aaaaaa50440888600000000688888860000d51000004f4444944f444494
00000000000000000000000000000000700000677600000770066000000660078440aa5555aa0440888600000000688800000000d51000004f4444944f444494
00cd006500000000000a000000000000700006077060000770606000000606078002a59aa95a2000888600000000688800000000d51000004f9999944f444494
b3cd826500000000000000000000000070000507705000077050600000060507884759a5aa950408888600000000688800000000d5100000444444444f449994
b3cd826500a0a000000aa000000a0a007000000770000007700060000006000788475aa5aaa50408888666666666688800000000d5100000444444444f994444
b3cd826500aaaa0000aaaa0000aaa0007000000770000007700500000000500788475aa955a50408888888555588888800000000d510000049a4444444444444
b3cd826500a9aa0000a99a0000aa9a0070000007700000077050000000000507884759aaaa950408866666666666666800000000d51000004994444444444444
b3cd826500a99a0000a99a0000a99a00777777777777777775000000000000778847a59aa95a0408866666666555666800000000d51000004444444449a44444
44444444004444000044440000444400555555555555555555555555555555558847aa5555aa0408866666666666666800000000d51000004ffffff449944444
9999999977777777777777777777777770000007777600007777777777777777884744aaaa4404088824a8888882450877777777d51000004f44449444444444
555555555555555555555555555555557000000777760000555555555555555588422222222224088824a8888882450855555555d51000004f4444944444fff4
444444441dd6dd6dd6dd6dd6d6dd6d517000000777760000444444444444444488000000000000088824a8888882450844444444d51000004f4444944fff4494
ffff4fff1dd6dd6dd6dd6dd6d6dd6d517000000766665555444ffffffffff44480444444444444008824a8888882450844444444d51000004f4444944f444494
444949441666666666666666666666517000000700007776444944444444944488000000000000088824a8888882450844444444d51000004f4444944f444494
444949441d6dd6dd6dd6dd6ddd6dd65170000007000077764449444aa444944488244444444445088824a2222222450844444444d51111114f4444944f444494
444949441d6dd6dd6dd6dd6ddd6dd651777777770000777644494444444494448824aaaaaaaa4508882444444444450844444444d55555554ffffff44f444494
44494944166666666666666666666651555555555555666644499999999994448824a88888824508882440000009450844444444dddddddd444444444f444494
444949441dd6dd600000000056dd6d516dd6dd6d0000000044494444444494448824a88888824508882440888889450888944488000000004f4444944f444494
444949441dd6dd650000000056dd6d51666666660000000044494444444494448824a88888824508888888888888888888944488000000004f4444944f444994
44494944166666650000000056666651d6dd6dd60000000044494444444494448824a88888824508888888888888888888944488006660004f4444944f499444
444949441d6dd6d5000000005d6dd651d6dd6dd60000000044494444444494448824a88888824508888888888888888888944488006760004f4444944f944444
444949441d6dd6d5000000005d6dd651666666660000000044494444444494448824a88888824508888888888888888888944488006560004f44449444444400
444949441666666500000000566666516dd6dd6d0000000044494444444494448824a88888824508888888888888888888944488006660004f44449444440000
999949991dd6dd650000000056dd6d516dd6dd6d0000000044499999999994448824a88888824508888888888888888888944488000000004f44449444000000
444444441dd6dd650000000056dd6d51666666660000000044444444444444448824a88888824508888888888888888888944488000000004f44449400000000
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccffffffff
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccf666677f
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc7cccccc7
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccaaccccd776666d
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000caaaccccf676650f
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccaaaaacf676650f
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccaaaaacf676650f
aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccff7665ff
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000fff76fffffffffff
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000fff76ffff666677f
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000fbbbbccf75555557
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000bbbcccc8d776666d
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000fccccc8ff676650f
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000fccc888ff676650f
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000fff22fff000000000000000000000000fff00ffff676650f
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ff0020ff000000000000000000000000fff00fffff7665ff
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ff2302ffff2302ff0000000000007aa0fff76fff00000094
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ffb33bffffb33bff00000000000070a0fff76fff00000944
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ff2bb2ffff2bb2ff000000000000aaa0f8888bbf00009440
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ff2222ffff2222ff00000000000a4440888bbbbc00094400
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000ff2bb2ffff2bb2ff0000000000a40000fbbbbbcf00044000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000f2b33b2ff2b33b2f000000000a400000fbbbcccf00400000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000f22bb22ff2b33b2f0000000074a90000fff00fff94000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000f222222ff22bb22f00000000007a0000fff00fff44000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000f222222f00000000000000000066060bfff76fffcccccccc
00000000000000000000000000000000000000000000000000000000000000000000000000000000f22bb22f000000000000000000660600fff76fffc000000c
00000000000000000000000000000000000000000000000000000000000000000000000000000000f2b33b2f000000000000000000666600fcccc88fc0c00c0c
0000000000000000000000000000000000000000000000000000000000000000000000000000000022b33b22000000000000000000000000ccc8888bc00cc00c
00000000000000000000000000000000000000000000000000000000000000000000000000000000222bb222000000000000000007777770f88888bfc00cc00c
0000000000000000000000000000000000000000000000000000000000000000000000000000000022222222000000000000000007777770f888bbbfc0c00c0c
0000000000000000000000000000000000000000000000000000000000000000000000000000000022222222000000000000000007777770fff00fffc000000c
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000008888880fff00fffcccccccc
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
00000000b444449bb444449bb444449bb494449bb494449bb494449bb999449bb999449bb999449b000000000000000000000000000000000000000000000000
00000000444044494440444944404449494444494944444949444449944444499444444994444449000000000000000000000000000000000000000000000000
00000000404000044040000440400004494400044944000449440004944444449444444494444444000000000000000000000000000000000000000000000000
0000000004ffff0004ffff0004ffff000440fffb0440fffb0440fffb444444444444444444444444000000000000000000000000000000000000000000000000
000000000f9ff9f00f9ff9f00f9ff9f004f0f9fb04f0f9fb04f0f9fb444444444444444444444444000000000000000000000000000000000000000000000000
000770000f5ff5f00f5ff5f00f5ff5f000fff5fb00fff5fb00fff5fb4444444044444440444444400f5ff5f000fff5fb44444440000000000000000000000000
007557004ffffff44ffffff44ffffff440ffffff40ffffff40ffffff0444444404444444044444444ffffff440ffffff04444444000000000000000000000000
07500570bff44ffbbff44ffbbff44ffbb0fffff4b0fffff4b0fffff4b044444bb044444bb044444bbff44ffbb0fffff4b044444b000000000000000000000000
77700777b6ffff6bb6ffff6bb6ffff6bb6fffffbb6fffffbb6fffffbb044444bb044444bb044444bb6ffff6bb6fffffbb044444b000000000000000000000000
00700700bbfddfbbbbfddfbbbbfddfbbbb6fffdbbb6fffdbbb6fffdbbb0000bbbb0000bbbb0000bbbbf00fbbbb6ff00bbb0000bb000000000000000000000000
00700700bbbffbbbbbbffbbbbbbffbbbbbbffbbbbbbffbbbbbbffbbbbbbffbbbbbbffbbbbbbffbbbbbf00fbbbbbff00bbbbffbbb000000000000000000000000
00777700bdc55cdbbdc55cdbbdc55cdbbbddcbbbbbbddbbbbbddcbbbbddddddbbddddddbbddddddbbbbffbbbbbbbbffbbddddddb000000000000000000000000
00555500dcc55ccddcc55ccddcc55ccdb1ccdcbbbb1ccdbbb1ccdcbbdccccccddccccccddccccccdbbbbbbbbbbbbbbbbdccccccd000000000000000000000000
00070000c1c66c1cc1c66c1dd1c66c1cb1ccdcbbbb1ccdbbb1ccdcbbc1cccc1cc1cccc1dd1cccc1c000000000000000000000000000000000000000000000000
00070000c1c55c1cc1c55c1dd1c55c1cb1ccdcbbbb1ccdbbb1ccdcbbc1cccc1cc1cccc1dd1cccc1c000000000000000000000000000000000000000000000000
00070000c1c55c1ccc155c1dd1c551ccb1ccdcbbbb1ccdbbb1ccdcbbc1cccc1ccc1ccc1dd1ccc1cc000000000000000000000000000000000000000000000000
77707770c1c55c1ccc155c1dd1c551ccb1ccdcbbbb1ccdbbb1ccdcbbc1cccc1ccc1ccc1dd1ccc1cc000000000000000000000000000000000000000000000000
00070000d1cddc1dbc1ddcdbbdcdd1cbb1dddcbbbb1dddbbb1dddcbbd1cccc1dbc1cccdbbdccc1cb000000000000000000000000000000000000000000000000
00070000fe1111efbfe1112bb2111efbbbff11bbbb2ff1bbbbff11bbfe1111efbfe1112bb2111efb000000000000000000000000000000000000000000000000
00070000bf1111fbbff111ebbe111ffbbbfe11bbbb2fe1bbbbfe11bbbf1111fbbff111ebbe111ffb000000000000000000000000000000000000000000000000
00000000bb1121bbbb1121bbbb1121bbbb2111bbbb2111bbbb2111bbbb1211bbbb1211bbbb1211bb000000000000000000000000000000000000000000000000
00777700bb1121bbbb1121bbbb1121bbbb1111bbbb2111bbbb2111bbbb1211bbbb1211bbbb1211bb000000000000000000000000000000000000000000000000
00755700bb1121bbbb1121bbbb1121bbbb1111bbbb2111bbbb2111bbbb1211bbbb1211bbbb1211bb000000000000000000000000000000000000000000000000
00700700bb1121bbbb1121bbbb1121bbbb1112bbbb2111bbbb21111bbb1211bbbb1211bbbb1211bb000000000000000000000000000000000000000000000000
77700777bb1121bbbb1121bbbb1121bbbb1112bbbb2111bbbb22111bbb1211bbbb1211bbbb1211bb000000000000000000000000000000000000000000000000
57500575bb1121bbbb1121bbbb1121bbb111122bbb2111bbb222111bbb1211bbbb121cbbbbc211bb000000000000000000000000000000000000000000000000
05700750bb1121bbbb1121bbbb1121bbc111222bbb2111bbb22211ccbb1211bbbb12cc7bb7cc11bb000000000000000000000000000000000000000000000000
00577500bbccccbbbb77c77bb77c77bb7ccc222bbbccccbbb222cc77bbccccbbbbcc677bb776ccbb000000000000000000000000000000000000000000000000
00055000b776677bbbbb677bb776bbbbb7776666bb6777bbb66677bbb776677bbb77bbbbbbbb77bb000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777777777777777777777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555555555555555555555555
0000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001dd6dd6dd6dd6dd6d6dd6dd6d6dd6dd6
0000000000000000000000000000c0000000000000000000000c000000000000000000000000000000000000000000001dd6dd6dd6dd6dd6d6dd6dd6d6dd6dd6
000000000000000000000000001c7c10000000000000000000000000000000000000000000000000000000000000000016666666666666666666666666666666
0000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000001d6dd6dd6dd6dd6d6dd6dd6d6dd6dd6d
0000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000001d6dd6dd6dd6dd6d6dd6dd6d6dd6dd6d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016666666666666666666666666666666
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd6dd60777777771dd6dd6077777777
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd6dd65700000071dd6dd6570000007
00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000016666665700000071666666570000007
00000000000c000000000000000000000000000000000000000000000000c000000000000000000000000000000c00001d6dd6d5700000071d6dd6d570000007
00000000000000000000000000000000000000000000000000000000001c7c10000000000000000000000000000000001d6dd6d5700000071d6dd6d570000007
000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000016666665700000071666666570000007
0000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000001dd6dd65700000071dd6dd6570000007
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd6dd65777777771dd6dd6577777777
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd6dd60700000071dd6dd6070000007
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd6dd65700000071dd6dd6570000007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016666665700000071666666570000007
000c000000000000000000000000000000000000000c0000000000000000000000000000000c000000000000000000001d6dd6d5700000071d6dd6d570000007
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d6dd6d5700000071d6dd6d570000007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016666665700000071666666570000007
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd6dd65777777771dd6dd6577777777
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd6dd65555555551dd6dd6555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000999999999999999999999999999999999999999999999999
0000000000000000000000000000000000000000000000000c000000000000000000000000000000444444444444444444444444444444444444444444444444
0000000000000000000000000000000000000000000000000c0000000000000000000000000000000004500000045000d6d45dd6d6d45dd6d6d45dd6d6d45dd6
0000000000000000000c00000004444490000000000000000c00000000000000000c0000000000000004500000045000d6d45dd6d6d45dd6d6d45dd6d6d45dd6
0000000000000000000000000044404449000000000000ccc0ccc000000000000000000000000000000450000004500066645666666456666664566666645666
0000000000000000000000000040400004000000000000000c00000000000000000000000000000000045000000450006dd45d6d6dd45d6d6dd45d6d6dd45d6d
0000000000000000000000000004ffff00000000000000000c00000000000000000000000000000000045000000450006dd45d6d6dd45d6d6dd45d6d6dd45d6d
000000000000000000000000000f9ff9f0000000000000000c000000000000000000000000000000000450000004500066645666666456666664566666645666
000000000000000000000000000f5ff5f00000000000000000000000000000000000000000000000000450555554555555545555555455555554555555545555
000000000000000000000000004ffffff40000000000000000000000000000000000000000000000000455555554555555545555555455555554555555545555
000000000000000000000000000ff44ff00000000000000000000000000000000000000000000000005455555554555555545555555455555554555555545555
0000000000000000000000000006ffff600000000000000000000000000000000000000000000000555455555554555555545555555455555554555555545555
0000000000000000000000000000fddf000000000000000000000000000000000000000000000000555455555554555555545555555455555554555555545555
00000000000000000000000000000ff0000000000000000000000000000000000000000000000000555455555554555555545555555455555554555555545555
0b0300000b0300000b0300000b0dc55cdb0300000b0300000b0300000b0300000b0300000b030000999999999999999999999999999999999999999999999999
b00030b0b00030b0b00030b0b0dcc55ccd0030b0b00030b0b00030b0b00030b0b00030b0b00030b0555555555555555555555555555555555555555555555555
33333333333333333333333333c1c66c1c3333333333333333333333333333333333333333333333588885885888858858888588588885885888858858888588
33333333333333333333333333c1c55c1c3333333333333333333333333333333333333333333333588885885888858858888588588885885888858858888588
33333333333333333333333333c1c55c1c3333333333333333333333333333333333333333333333555555555555555555555555555555555555555555555555
33333333333333333333333333c1c55c1c3333333333333333333333333333333333333333333333888588888885888888858888888588888885888888858888
33333333333333333333333333d1cddc1d3333333333333333333333333333333333333333333333888588888885888888858888888588888885888888858888
33333333333333333333333333fe1111ef3333333333333333333333333333333333333333333333555555555555555555555555555555555555555555555555
333333333333333333333333333f1111f33333333333333333333333333333333333333333333333588885885888858858888588588885885888858858888588
33333333333333333333333333331121333333333333333333333333333333333333333333333333588885885888858858888588588885885888858858888588
33333333333333333333333333331121333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333331121333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333331121333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333331121333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333331121333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333331121333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3333333333333333333333333333cccc333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333377667733333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000c0c0ccc0c000c0c00000ccc00cc0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000c0c0c0c0c000cc0000000c00c0c0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000ccc0ccc0c000c0c000000c00c0c0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000ccc0c0c0ccc0c0c000000c00cc00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cc0ccc0ccc0cc0000000000ccc0ccc00cc0c0c00000c0c0ccc00000ccc0c0c00cc0c0c000000000000001111111111011111111110111111111101111111111
c1c0c1c0c110c1c000000000c1c01c10c110c0c00000c0c0c1c00000c1c0c0c0c110c0c0000000cc000001111111111011111111110111111111101111111111
c0c0ccc0cc00c0c000000000ccc00c00c000cc10ccc0c0c0ccc00000ccc0c0c0ccc0ccc000000c11c00001111111111011111111110111111111101111111111
c0c0c110c100c0c000000000c1100c00c000c1c01110c0c0c1100000c110c0c011c0c1c00000c1001c0001111111111011111111110111111111101111111111
cc10c000ccc0c0c000000000c000ccc01cc0c0c000001cc0c0000000c0001cc0cc10c0c0000ccc00ccc001111111111011111111110111111111101111111111
11001000111010100000000010001110011010100000011010000000100001101100101000000c00c00001111111111011111111110111111111101111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000c00c00001111111111011111111110111111111101111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000cccc00001111111111011111111110111111111101111111111
0cc0c0000cc00cc0ccc00000c0000cc00cc0c0c00000ccc0ccc00000ccc0c0c0c000c00000000111100001111111111011111111110111111111101111111111
c110c000c1c0c110c1100000c000c1c0c1c0c0c00000c1c01c100000c1c0c0c0c000c00000000000000001111111111011111111110111111111101111111111
c000c000c0c0ccc0cc000000c000c0c0c0c0cc10ccc0ccc00c000000ccc0c0c0c000c00000000000000000000000000000000000000000000000000000000000
c000c000c0c011c0c1000000c000c0c0c0c0c1c01110c1c00c000000c110c0c0c000c00000000000000000000000000000000000000000000000000000000000
1cc0ccc0cc10cc10ccc00000ccc0cc10cc10c0c00000c0c00c000000c0001cc0ccc0ccc000000000000001111111111011111111110111111111101111111111
01101110110011001110000011101100110010100000101001000000100001101110111000000cccc00001111111111011111111110111111111101111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000c11c00001111111111011111111110111111111101111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000c00c00001111111111011111111110111111111101111111111
0cc0ccc0c0c0ccc000000000ccc0ccc0c000c0c00000ccc00cc00000c0c00cc0ccc00000000ccc00ccc001111111111011111111110111111111101111111111
c1101c10c0c0c110000000001c10c1c0c000c0c000001c10c1c00000c0c0c110c11000000001c1001c1001111111111011111111110111111111101111111111
c0000c00c0c0cc00000000000c00ccc0c000cc10ccc00c00c0c00000c0c0ccc0cc00000000001c00c10001111111111011111111110111111111101111111111
c0c00c00ccc0c100000000000c00c1c0c000c1c011100c00c0c00000c0c011c0c1000000000001cc100001111111111011111111110111111111101111111111
ccc0ccc01c10ccc0000000000c00c0c0ccc0c0c000000c00cc1000001cc0cc10ccc0000000000011000001111111111011111111110111111111101111111111
11101110010011100000000001001010111010100000010011000000011011001110000000000000000001111111111011111111110111111111101111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0001010101010100000000010000000000010101010101000000000101000000000101010101010101010101000000000001010101010100000000000000000000000000000000000000808000000000000000000000000000008080000000000000000000008080000000008000000000000000000000000000010180000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0707071717171717171717171707070717171708080808080808080808171717070707171717171717171717170707071717170808080808080808080817171700000000000000000000100000002000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101
0707071717171717171717171707070717171708080808080808080808171717070707171717171717171717170707071717170808080808080808080817171700000000000000002000000000000000002000000000100002020202020202020202020202020202020202020202020202020202020202020202020202020202
0700071717171717171717171707000717001708080808080808080808170017070007171717171717171717170700071700170808080808080808080817001700000000000000000101010101010101010101010101010103030303030303030303030303030303030303030303030303030303030303030303030303030303
0700071717171717171717171707000717001708080808080808080808170017070007171717171717171717170700071700170808080808080808080817001700000000000000000202020202020202020202020202020204040404040404040404040404040404040404040404040404040404040404040404040404040404
0700071717171717171717171707000717001708080808080808080808170017070007171717171717171717170700071700170808080808080808080817001700000000000000000303030303030303030303030303030305050505050505050505050505050505050505050505050505050505050505050505050505050505
0701113131313131313131313121010717021232323232323232323232220217070111313131313131313131312101071702123232323232323232323222021700000000000000000404040404040404040404040404040415151515151515151515151515151515151615151515151515151515151515151515151515151515
1131313131313131313131313131312112323232323232323232323232323222113131313131313131313131313131211232323232323232323232323232322200000000000000000505050505050505050505050505050539393939393939393939393939393939393a39393939393939393939393939393939393939393939
3131313131313131313131313131313132323232323232323232323232323232313131313131313131313131313131313232323232323232323232323232323200000000000000000606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000200000000000200707071717171717171717171707070717171708080808080808080808171717070707171717171717171717170707071717170808080808080808080817171700000000000000000017191a000000000000000000000000000000000000000000000000000000000000000000000000
0020000000000000000000000010000007070717171717171717171717070707171717080808080808080808081717170707071717171717171717171707070717171708080808080808080808171717000000000000000000270a2a000000000000000000000000000000000000000000000000000000000000000000000000
000000200000000000000000000000000700071717171717171717171707000717001708080808080808080808170017070007171717171717171717170700071700170808080808080808080817001700000000000000001718072a0000000000000000000000000000000000000000000000001718191a0000000000000000
00000000000000000000000000000000070007171717171717171717170700071700170808080808080808080817001707000717171717171717171717070007170017080808080808080808081700170000000000000000070a072a00000000000000000000000000000000000000000000000027070a2a0000000000000000
0000000000000000000000000000000007000717171717171717171717070007170017080808080808080808081700170700071717171717171717171707000717001708080808080808080808170017000000000000000007070707191a00000000000000000000000000000000000000001718071b072a0000000000000000
0000000000000000000000000000200007011131313131313131313131210107170212323232323232323232322202170701113131313131313131313121010717021232323232323232323232220217000000000000000007070707382a0000000000000000000000000000000000001718280a0a072b2a1718191a00000000
0000000000100000002000000000000011313131313131313131313131313121123232323232323232323232323232221131313131313131313131313131312112323232323232323232323232323222000000000000000007070707072a0000000000000000000000000000000000003737270707073b2a270a072a00000000
2000000000000000000020000000000031313131313131313131313131313131323232323232323232323232323232323131313131313131313131313131313132323232323232323232323232323232000000000000000021222122212221222122212221222122212221222122212221223233323332333233323332333233
00000000000000000020000000000020070707171717171717171717170707070707071a1a1a1a1a1a1a405040501a1a1a1a1a1a1a070707484900004a4b000007070709090909090909090909070707070707171717171717171717170707071717170808080808080808080817171707070717171717171717171717070707
00200000000000000000000000100000070707171717171717171717170707070707071a1a1a1a1a1a1a504050401a1a1a1a1a1a1a070707585900005a5b000007070709000009090909444509070707070707171717171717171717170707071717170808080808080808080817171707070717171717171717171717070707
00000020000000000000000000000000070007171717171717171717170700070700071a1a1a001a1a1a405040501a1a1a001a1a1a070007686966676c6c666707000709000009090909545509070707070007171717171717171717170700071700170808080808080808080817001707000717171717171717171717070007
000000000000000000000000000000000700071717171717171717171707000707000762626200626262666766676262620062626207000778797c002e1f3e7c07000709090909090909090909070707070007171717171717171717170700071700170808080808080808080817001707000717171717171717171717070007
00000000000000000000000000000000070007171717171717171717170700070700077474740074747476777677747474007474740700076a6b002e1f3e2a0007000709090909090909090909070707070007171717171717171717170700071700170808080808080808080817001707000717171717171717171717070007
00000000000000000000000000002000070111313131313131313131312101070701113131313131313131313131313131313131312101077a7b001f3e2a000007011131313131313131313131212807070111313131313131313131312101071702123232323232323232323222021707011131313131313131313131210107
00000000001000000020000000000000113131313131313131313131313131211131313131313125151515151515153531313131313131210000003e2c00000011313131313125151535313131313121113131313131313131313131313131211232323232323232323232323232322211313131313131313131313131313121
2000000000000000000020000000000031313131313131313131313131313131292929292929292929292929292929292626292929292929143434343424000031313131313131313131313131313131313131313131313131313131313131313232323232323232323232323232323231313131313131313131313131313131
00000010000020000000000061626262626262626262626262626263000000100707071a1a1a1a1a1a1a0c0c0c0c1c2b2a1a1a1a1a070707070707504050405040504040405040504050405040070707171717090909090909090909090909090909090909171717000000100000616262626262626262626262626200000010
00200000000000100000002071447144714473004e71447344734473000020000707071a1a1a1a1a1a1a0c0c0c1c2b2a1a1a1a1a1a07070707070740504050405040504050405040504050405007070717171709090909090909444444450909090909090917171700200000002071447474744473b271447474447400002000
20000000002000000020000071647164716473005e71647364736473200000000700071a1a1a1a1a1a1a0c0c1c2b2a1a4e001a1a1a070007070707504050005050504050405040004000405040070707170017656565656565655464645565656565656565170017181d1d1d1d1d71647474746473b27164747464741d1d1d18
00002000000000002000000062626262626273006e7162626262626300000020070007606060606060600c1c2b6060605e00606060070007070707606060006060606162636060006060606060070707170017666766676667666766676667666766676667170017182d2d2d2d2d61747474747473b27174747474742d2d2d18
303030303030303030301b3131313131313131253531313131313131310b3030070007707070707070703434347070706e00707070070007070707707070007070707172737070007070707070070707170017767776777677767776777677767776777677170017151515151515151515151515151515151515151515151515
151515151515151515151818181818181818183434181818181818181818151507011131313131313131313131313131313131313121010707271131313131313131313131313131313131313121280717021232323232323232323232323232323232323222021715153c191919191919191919343434191919193d15151515
1515151515151515151515151515151515151515151515151515151515151515113131313131312515151515151515353131313131313121113131313131312515151515151515353131313131313121123232323232323232323232323232323232323232323222153c3937373737378e373737373737373737373a3d151515
15151515151515151515151515151515151515151515151515151515151515153131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313232323232323232323232323232323232323232323232323c393737373737373737373737373737373737373a3d1515
__sfx__
010100001c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001f0500f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000100000000000000000000000000000000000000014000100000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001400
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10001000014000140001400014001c4011c4011c0611c0611c0611c061000000000004124041243be533be5300000000003ff773ff7711401114010000000000000000000008e4108a4000000000000000000000
0101010110001100011140111401017010170101f0401f04000000000004124041243b65430e5310640192003ff773ff7711e41196410000000000000000000018e4109a40000400020000400004000140001400
1111111111061110611c0611c0611c0611c061000000000004124041243b22000c53102501a2003ff773ff7721a522a2510000000000000000000018e4109a400080008000000000000000001000011000110001
1c1c1c1c11c0411c0401f0401f0400000000000412404124041000000000000000003ff773ff7721a522a2510000000000000000000008e4108a4000800080000100001000014000140001400014001c4011c401
c1c1c1c11c0611c061000000000004124041240000000000102501a2003ff773ff7721a522a2510000000000000000000008e7708a40000400020000000000001000010000100011000111401114010170101701
00000000000000000004124041240000000000102501a2003ff773ff7721a522a251000000000000000000003853707a40000000000000400004000140001400014000140011061110611c0611c0611c0611c061
444444440412404124000000000000000000003ff773ff7721a522a2510000000000000000000037537379400000000000000000000000001000011000110001114011140111c0411c0401f0401f040000000000
00bbbbbb000000000000000000003ff773ff7721a522a251000000000000000000003f53737b40000000000008a4008a401df651df6511401114011c0611c0611c0611c0611c0611c0613be533be533be533b224
bbbbbbbb3be533be53000000000021a522a251000000000000000000003f53737b40000000000008a4008a401df651df65114011140101f0401f0401f0401f0401f0401f043be533be533be5304100000003be53
00010100000000000021a522a251000000000000000000001f52030b40000000100008a4008a401df651df6511401114011c0611c0611c0611c0611c0611c0613be533be533b224000000000000c533be533be53
a1aaaa1a21a522a251000000000000000000001852000a40000000c00008a4008a401df651df65114011140101f0401f0421f0621f0621f0621f063be533be53041000000000000000003be533be530000000000
00000000000000000000000000001810000a4000c040770008a4008a401df651df6511401114011c0611c0612c0622c0622e0722e0723be533b2240000000000000000000000c533be53100001000021a522a251
0000000000000000000880000a40000000c00008a4008a401df651df65114011140101f0401f0422b1622b1622f4119a163be530410000000000000000000000000003be53004010100021a522a2510000000000
8887878808e3007a40000000100008a4008a401df651df6511401114012c0622c06229442294421ea522a6423b22400000000000000000000000000000000c53000000000021a522a25100000000000000000000
00000000000000000008a4008a401df651df6511401114012eb762eb7619e4119e4129a522aa510410000000000000000000000000000000000000000000000021a522a251000000000000000000000880000840
49490049114010050111020114013c96407b641ca6628b6619e4119e413be533be533b6540000000000000003be533be530000030e53114011140108e4109a4008e4109a4008e4109a4008e4109a400000000000
1010101009544095440cb640cb640eb740eb7419e4119e413be533be533b6540000000000000003be533be530000030e53010000000118e470fa4018e470fa4018e470fa4018e470fa4000000000001000110001
cccccccc0c7370c7370cb540cb5419e4119e413be533be533b6540000000000000003be533be530000030e53014000000119e770fa4018e770fa4018e770fa4018e770fa40008040000039500014000140001400
77cc99cc0eb740eb7419e4119e413be533be533b6540000000000000003be533be530000030e53014000000108e470fa4009e470fa4009e470fa4009e470fa4000000000000043110001391011000137d340cb64
9999999919e4119e413be533be533b6540000000000000003be533be530000030e5301400000010863708a400863708a400863708a400863708a400000000000004400000000430000000cb640cb640eb740eb74
bbbbbbbb3be533be533b6540000000000000003be533be530000030e5301400000013853707a403853707a403853707a403853707a400000000000000200000000440000000cb64375372cb762ca5219e4119e41
bb4b00003b6540000000000000003be533be530000030e5301400000013853737b403853707a403813707a403853707a400000000000000211c061000211c0610cb640cb640cb640cb6419e4119e413be533be53
0011000100000000003be533be530000030e5301401110013833737b403853627d703853637d703833737b400cb640cb643341333413000000000000000000000140001400000000000010401104013b65430e53
11111111117011d40111e062ef0101000000013833737b403f13727d702f53736d703833737b400cb640cb643341333413000000000000000000001000110001000000000011401114013b65430e531040111400
11aa1111110711e07101000100013877539b400f20009a400f62509a4038f7130b400cb640cb6433413334130000000000008051d3000140001400000000000011001110013b65430e53104021240011c6511c65
0100001001000000010862500a400820000a400862500a401852000a400cb640cb6433413334130000010f6501461114001000110001000000000011401114013b65430e53108070f40011401114011e4011e852
880080880862000a400820000a400862500a401810000a400cb640cb64334133341310f651d40110700000010140001400000000000010401104013b65430e5300c271f1000c3611140111071114010100000001
58850088185200084018520008400880000a400cb640cb6433413334131d4010100010000000001000110001000000000011401114013b65430e5310401114001140111401110511e05101000000010820000a40
7888008518d200084038d3006a400cb640cb643341333413010000000000000000000140001400000000000011001110013b65430e531040111020114010cb642170121a7201000000010820000a402894000830
6680608818e3006a400cb640cb643341333413000000000000000000001000110001000000000011401114013b65430e531000101500114011140111401114010100000001082361594008800289400880018940
__music__
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

