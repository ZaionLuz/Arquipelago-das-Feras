--!nonstrict
-- Biblioteca de componentes sem IDs de assets. O factory fornece make(name,kind,size,pos,color,rotation,joint,parent).
local F = {}
local V = Vector3.new
local A = CFrame.Angles
function F.face(make, d, head, position, scale, stage, headSize)
	local p = d.palette
	local kind = d.eyes
	local front = headSize.Z / scale * 0.5 + 0.04
	local sideWidth = headSize.X / scale * 0.5 + 0.03
	local sizes = {
		vertical = V(0.5, 0.65, 0.1),
		emberslit = V(0.55, 0.14, 0.1),
		fish = V(0.48, 0.55, 0.12),
		compound = V(0.48, 0.5, 0.18),
		crystal = V(0.5, 0.6, 0.12),
		blindmarks = V(0.6, 0.12, 0.1),
		barkmarks = V(0.35, 0.6, 0.1),
		electric = V(0.55, 0.36, 0.1),
		solar = V(0.6, 0.65, 0.13),
	}
	if kind == "cyclops" or kind == "lantern" then
		local eye = make(
			"EyeCenter",
			"sphere",
			V(0.9, 0.65, 0.16) * scale,
			position + V(0, 0.12, front) * scale,
			p[3],
			nil,
			true,
			head
		)
		make(
			"IrisCenter",
			"wedge",
			V(0.15, 0.4, 0.08) * scale,
			position + V(0, 0.12, front + 0.1) * scale,
			p[1],
			nil,
			false,
			eye
		)
	else
		for _, side in { -1, 1 } do
			local pos = position + V(side * 0.5, 0.15, front) * scale
			if kind == "fish" then
				pos = position + V(side * sideWidth, 0.12, 0.2) * scale
			end
			local shape = (kind == "crystal" or kind == "electric" or kind == "emberslit") and "wedge" or "sphere"
			local eye = make(
				"Eye" .. (side < 0 and "L" or "R"),
				shape,
				(sizes[kind] or V(0.6, 0.65, 0.13)) * scale,
				pos,
				p[3],
				kind == "fish" and A(0, side * math.pi / 2, 0) or nil,
				true,
				head
			)
			if kind == "compound" then
				for i = 1, 2 do
					make(
						"Facet" .. side .. i,
						"wedge",
						V(0.13, 0.18, 0.05) * scale,
						pos + V((i - 1.5) * 0.15, 0.05, 0.1) * scale,
						p[4],
						nil,
						false,
						eye
					)
				end
			elseif kind ~= "blindmarks" and kind ~= "barkmarks" and kind ~= "emberslit" then
				make(
					"Iris" .. side,
					"sphere",
					V(kind == "vertical" and 0.1 or 0.23, 0.34, 0.06) * scale,
					pos + V(0, 0, 0.09) * scale,
					p[1],
					nil,
					false,
					eye
				)
			end
		end
	end
	if stage >= 2 then
		make(
			"Mouth",
			"wedge",
			V(0.5, 0.1, 0.12) * scale,
			position + V(0, -0.38, front + 0.04) * scale,
			p[1],
			nil,
			false,
			head
		)
	end
end
function F.trait(make, d, position, stage, parent, body)
	local feature = d.feature
	local p = d.palette
	local rank = stage == 1 and 1 or stage == 2 and 2 or 4
	if feature == "stormcrown" then
		for _, side in { -1, 1 } do
			make(
				"StormFork" .. side,
				stage == 1 and "sphere" or "wedge",
				V(0.25, 0.4 + stage * 0.45, 0.35),
				position + V(side * 0.7, 1.0, -0.3),
				p[3],
				A(0, 0, side * 0.65),
				true,
				parent
			)
			if stage >= 2 then
				make(
					"StormCollar" .. side,
					"wedge",
					V(1.2, 0.25, 0.7),
					position + V(side * 0.7, -0.7, 0.2),
					p[4],
					A(0, 0, side * 0.4),
					false,
					body
				)
			end
		end
	elseif feature == "ribboncrest" then
		for _, side in { -1, 1 } do
			make(
				"RibbonStreamer" .. side,
				"wedge",
				V(0.2, 0.16, stage == 1 and 0.8 or 1.8 + stage * 0.7),
				position + V(side * 0.35, 0.65, -1),
				p[4],
				A(-0.3, side * 0.3, side * 0.2),
				true,
				parent
			)
		end
	elseif feature == "gillfans" then
		for _, side in { -1, 1 } do
			make(
				"GillFan" .. side,
				"wedge",
				V(0.14, 0.6 + stage * 0.25, 0.8),
				position + V(side * 1, 0.05, -0.3),
				p[2],
				A(0, side * 0.4, side * 0.3),
				true,
				parent
			)
		end
	elseif feature == "dorsalsail" then
		make(
			"DorsalSail",
			"wedge",
			V(0.15, stage == 1 and 0.4 or 1.3, 2),
			position + V(0, 0.5, -1.3),
			p[3],
			A(0.3, 0, 0),
			true,
			body
		)
	elseif feature == "chimney" then
		make(
			"FurnaceVent",
			"cylinder",
			V(0.5, 0.55, stage == 1 and 0.4 or 1.1),
			position + V(0, 0.7, -0.4),
			p[1],
			A(math.pi / 2, 0, 0),
			false,
			parent
		)
		if stage >= 2 then
			make("CoalCore", "sphere", V(0.3, 0.15, 0.3), position + V(0, 1.1, -0.4), p[3], nil, false, parent).Material =
				Enum.Material.Neon
		end
	elseif feature == "rockplates" then
		for i = 1, rank do
			make(
				"BasaltPlate" .. i,
				"corner",
				V(0.9, 0.5, 0.8),
				position + V(0, -0.3, -i * 0.7),
				p[2],
				A(0.2, 0, i % 2 * 0.3),
				false,
				body
			)
		end
	elseif feature == "royalcrown" then
		for i = 1, rank do
			make(
				"CrownLobe" .. i,
				stage == 1 and "sphere" or "corner",
				V(0.4, 0.4 + stage * 0.3, 0.3),
				position + V((i - (rank + 1) / 2) * 0.5, 1.2, -0.15),
				p[3],
				A(0, 0, (i - (rank + 1) / 2) * 0.2),
				true,
				parent
			)
		end
	elseif feature == "ashwings" then
		for _, side in { -1, 1 } do
			make(
				"AshSickle" .. side,
				"wedge",
				V(0.3, 1.1, 2.2),
				position + V(side * 1.1, 0.3, -1.3),
				p[4],
				A(-0.4, side * 0.4, side * 0.6),
				true,
				body
			)
		end
	elseif feature == "tusks" then
		for _, side in { -1, 1 } do
			make(
				"Tusk" .. side,
				stage == 1 and "sphere" or "wedge",
				V(0.25, stage == 1 and 0.25 or 0.8 + stage * 0.15, 0.3),
				position + V(side * 0.7, -0.1, 1),
				p[3],
				A(-0.3, 0, -side * 0.2),
				true,
				parent
			)
		end
	elseif feature == "antlers" or feature == "lichenantlers" then
		for _, side in { -1, 1 } do
			local antler = make(
				"Antler" .. side,
				stage == 1 and "sphere" or "cylinder",
				V(0.2, stage == 1 and 0.3 or 1.3, 0.25),
				position + V(side * 0.65, stage == 1 and 0.6 or 1.1, -0.3),
				p[2],
				A(0, 0, side * 0.35),
				true,
				parent
			)
			if stage >= 2 then
				make(
					"Branch" .. side,
					"wedge",
					V(0.8, 0.2, 0.25),
					position + V(side * 0.95, 1.5, -0.3),
					p[3],
					A(0, 0, side * 0.3),
					false,
					antler
				)
			end
		end
	elseif feature == "headdress" or feature == "shoulderarches" then
		for _, side in { -1, 1 } do
			make(
				"Panel" .. side,
				"wedge",
				V(stage == 1 and 0.4 or 0.7, 0.6 + stage * 0.35, 0.55),
				position + V(side * 1.0, -0.2, -0.35),
				p[3],
				A(0, 0, side * 0.15),
				false,
				parent
			)
		end
	elseif feature == "pincers" or feature == "pearlclaws" then
		for _, s in { -1, 1 } do
			make(
				"Claw" .. s,
				"wedge",
				V(0.7, stage == 1 and 0.5 or 1, 1.3),
				position + V(s * 1.7, -0.6, 1.3),
				p[2],
				A(0, s * 0.3, 0),
				true,
				parent
			)
		end
	elseif feature == "flower" or feature == "seedleaves" or feature == "leafears" or feature == "lichenantlers" then
		for i = 1, rank + 1 do
			local a = i * math.pi * 2 / (rank + 1)
			make(
				"Petal" .. i,
				"wedge",
				V(0.5, 0.9, 0.18),
				position + V(math.cos(a) * 0.7, 0.7 + math.sin(a) * 0.4, -0.1),
				p[i % 2 + 2],
				A(0, 0, -a),
				true,
				parent
			)
		end
	elseif feature == "lure" or feature == "antennalure" then
		make("LureStem", "cylinder", V(0.13, 1.3, 0.13), position + V(0, 0.95, 0.3), p[2], A(0.3, 0, 0), false, parent)
		make("LureGlow", "sphere", V(0.4, 0.5, 0.4), position + V(0, 1.6, 0.6), p[3], nil, true, parent)
	elseif feature == "cloudcollar" or feature == "steamvents" or feature == "mossmantle" then
		for i = 1, rank do
			make(
				"Cloud" .. i,
				"sphere",
				V(0.6, 0.35, 0.8),
				position + V((i - (rank + 1) / 2) * 0.45, 0.4, -0.7),
				p[i % 2 + 2],
				nil,
				false,
				parent
			)
		end
	elseif feature == "mothwings" then
		for _, s in { -1, 1 } do
			make(
				"MothWing" .. s,
				"wedge",
				V(0.2, 1.3 + stage * 0.4, 1.6),
				position + V(s * 1.4, 0.2, -0.5),
				p[2],
				A(0, 0, s * 0.7),
				true,
				parent
			)
		end
	else
		-- Chifres não aparecem no filhote; ele recebe apenas uma crista macia/placa.
		for i = 1, rank do
			local x = (i - (rank + 1) / 2) * 0.55
			make(
				"Crest" .. i,
				stage == 1 and "sphere" or "wedge",
				V(0.35, stage == 1 and 0.3 or 0.6 + stage * 0.25, 0.45),
				position + V(x, 0.75, -0.2),
				p[i % 2 + 2],
				A(0, 0, -x * 0.3),
				true,
				parent
			)
		end
	end
end
function F.surface(make, d, position, stage, parent)
	if stage == 1 then
		return
	end
	local p = d.palette
	local count = stage == 2 and 2 or 4
	local surface = d.surface
	for i = 1, count do
		local angle = i * 2.4
		local kind = "sphere"
		local size = V(0.3, 0.4, 0.12)
		local rotation = A(0, 0, angle * 0.3)
		local offset = V(math.cos(angle) * 0.8, math.sin(angle) * 0.5, 0.8)
		local material = Enum.Material.SmoothPlastic
		if surface == "cracks" or surface == "zigzag" then
			kind = "wedge"
			size = V(0.08, 0.7, 0.08)
			material = Enum.Material.Neon
		elseif surface == "plates" or surface == "scales" or surface == "ridges" then
			kind = "wedge"
			size = V(0.65, 0.25, 0.8)
			offset = V(0, 0.6, -i * 0.35)
			material = Enum.Material.Slate
		elseif surface == "runes" or surface == "facets" then
			kind = "corner"
			size = V(0.3, 0.5, 0.2)
			material = Enum.Material.Glass
		elseif surface == "bands" or surface == "rain" then
			kind = "block"
			size = V(0.12, 0.8, 0.1)
			rotation = A(0, 0, surface == "rain" and 0.3 or math.pi / 2)
		elseif surface == "leaves" or surface == "veins" or surface == "moss" then
			kind = "wedge"
			size = V(0.2, 0.65, 0.13)
			material = Enum.Material.Fabric
		elseif surface == "bark" then
			kind = "block"
			size = V(0.15, 0.8, 0.18)
			material = Enum.Material.Wood
		elseif surface == "clouds" then
			size = V(0.7, 0.4, 0.65)
			offset = V((i - (count + 1) / 2) * 0.4, 0.5, -0.5)
		elseif surface == "pearls" then
			size = V(0.35, 0.35, 0.35)
			material = Enum.Material.Glass
		elseif surface == "spirals" then
			kind = "cylinder"
			size = V(0.1, 0.4 + i * 0.1, 0.4 + i * 0.1)
			rotation = A(0, math.pi / 2, 0)
		elseif surface == "feathers" or surface == "layeredplumage" then
			kind = "wedge"
			size = V(0.3, 0.18, 0.7)
			offset = V((i - (count + 1) / 2) * 0.3, 0, 0.8)
		elseif surface == "ash" then
			size = V(0.5, 0.16, 0.3)
			material = Enum.Material.Basalt
		end
		local mark = make("Pattern" .. i, kind, size, position + offset, p[i % 2 + 2], rotation, false, parent)
		mark.Material = material
	end
end
return F
