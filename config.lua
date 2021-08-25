Config, KalaxConfig  				= {}, {}
Config.Locale 						= 'en'
KalaxConfig.DrawDistance			= 100
KalaxConfig.Zones = {
	-- Zone Name must be unique for each entry or the exit function will not work correctly
	['Weed_Processing'] = {
		-- Enter Marker , Outside World
		PosEnterMarker = vector3(-1128.2383, 2708.3411, 17.8504),
		PosExitMarker = vector3(1065.9082, -3183.5476, -40.1136),
		-- Enter Landing , Interior IPL
		PositionLand = vector4(1062.2153, -3185.5923,  -39.3648, 180.0), -- X, Y, Z, Heading
		-- Exit Landing , Outside World
		PositionExit = vector4(-1129.1232, 2709.7300, 18.2330, 127.3293),
		Jobs = {
			'any'
			--'any', -- SET THE 'any' TAG TO ALLOW ALL JOBS INCLUDING POLICE TO USE THE LOCATION
			--'miner',
			--'cardealer'
			--'police'
			-- and ETC
		},
		Size = {x = 0.8, y = 0.8, z = 0.8},
		Color = {r = 000, g = 255, b = 255}, 			-- Marker Color
		Type = 1										-- Marker Type
	},
	['Meth_Processing'] = {
		PosEnterMarker = vector3(1454.4922, -1651.9562, 66.0949),
		PosExitMarker = vector3(997.1924, -3200.7051, -37.3437),
		PositionLand = vector4(997.9114, -3198.9851, -36.3937, 354.7912),
		PositionExit = vector4(1451.2909, -1651.9031, 65.9933, 13.6064),
		Jobs = {
			'any'
		},
		Size = {x = 0.8, y = 0.8, z = 0.8},
		Color = {r = 000, g = 255, b = 255}, 
		Type = 1
	},
	['Coke_Processing'] = {
		PosEnterMarker = vector3(143.6410, -1656.3594, 28.3814),
		PosExitMarker = vector3(1088.7529, -3187.9114, -39.9435),
		PositionLand = vector4(1088.2407, -3189.4944, -38.9935, 182.0493),
		PositionExit = vector4(146.3263, -1658.6621, 29.3321, 216.1523),
		Jobs = {
			'any'
		},
		Size = {x = 0.8, y = 0.8, z = 0.8},
		Color = {r = 000, g = 255, b = 255}, 
		Type = 1
	}
}