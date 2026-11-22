--!strict
-- Types.lua - Tipos compartilhados do Arquipélago das Feras

export type ElementType =
	| "Fire"
	| "Water"
	| "Nature"
	| "Earth"
	| "Air"
	| "Shadow"
	| "FireWater"
	| "EarthAir"
	| "NatureShadow"

export type RarityType = "Common" | "Rare" | "Epic" | "Legendary"

export type CreatureState = "Wild" | "Captured" | "InParty" | "InStorage" | "Battling" | "Evolving"

export type CreatureStats = {
	HP: number,
	MaxHP: number,
	Attack: number,
	Defense: number,
	SpecialAttack: number,
	SpecialDefense: number,
	Speed: number,
}

export type IVs = {
	HP: number,
	Attack: number,
	Defense: number,
	SpecialAttack: number,
	SpecialDefense: number,
	Speed: number,
}

export type EVs = {
	HP: number,
	Attack: number,
	Defense: number,
	SpecialAttack: number,
	SpecialDefense: number,
	Speed: number,
}

export type Move = {
	Id: string,
	Name: string,
	Type: ElementType,
	Category: "Physical" | "Special" | "Status",
	Power: number?,
	Accuracy: number,
	PP: number,
	MaxPP: number,
	Priority: number,
	Effect: MoveEffect?,
}

export type MoveEffect = {
	Type: "StatChange" | "Status" | "Heal" | "Damage" | "MultiHit" | "Charge" | "Recoil",
	Params: {[string]: any},
	Chance: number,
}

export type CreatureData = {
	Id: string,
	SpeciesId: string,
	Nickname: string?,
	Level: number,
	Experience: number,
	Stats: CreatureStats,
	IVs: IVs,
	EVs: EVs,
	Nature: string,
	Ability: string,
	Moves: {Move},
	CurrentHP: number,
	Status: StatusCondition?,
	State: CreatureState,
	CaughtAt: number,
	CaughtLocation: string?,
	OriginalTrainer: string,
	IsShiny: boolean,
	Gender: "Male" | "Female" | "Genderless",
	EvolutionStage: 1 | 2 | 3,
	Friendship: number,
}

export type StatusCondition = "Burn" | "Poison" | "Paralysis" | "Sleep" | "Freeze" | "Confusion" | "None"

export type SpeciesData = {
	Id: string,
	Name: string,
	Element: ElementType,
	Rarity: RarityType,
	BaseStats: CreatureStats,
	Abilities: {string},
	Learnset: {[number]: string},
	Evolutions: EvolutionData?,
	Height: number,
	Weight: number,
	Description: string,
}

export type EvolutionData = {
	Method: "Level" | "Item" | "Friendship" | "Trade" | "TimeOfDay" | "Location",
	Requirement: any,
	TargetSpecies: string,
}

export type PlayerData = {
	UserId: number,
	Username: string,
	Money: number,
	Party: {CreatureData},
	Storage: {{CreatureData}},
	CurrentZone: string,
	PlayTime: number,
	Badges: {string},
	Settings: PlayerSettings,
}

export type PlayerSettings = {
	MusicVolume: number,
	SFXVolume: number,
	BattleSpeed: number,
	AutoSave: boolean,
	Language: string,
}

export type BattleState = "Waiting" | "TurnStart" | "PlayerTurn" | "EnemyTurn" | "MoveExecution" | "TurnEnd" | "BattleEnd"

export type BattleParticipant = {
	Creature: CreatureData,
	IsPlayer: boolean,
	StatStages: {[string]: number},
	VolatileStatus: {[string]: any},
	LastMoveUsed: string?,
	TurnsAsleep: number,
	TurnsFrozen: number,
}

export type BattleData = {
	Id: string,
	State: BattleState,
	PlayerSide: {BattleParticipant},
	EnemySide: {BattleParticipant},
	Weather: WeatherType?,
	Terrain: TerrainType?,
	TurnCount: number,
	Seed: number,
}

export type WeatherType = "None" | "Sunny" | "Rain" | "Sandstorm" | "Hail" | "Fog" | "Windy"
export type TerrainType = "None" | "Electric" | "Grassy" | "Misty" | "Psychic"

export type RemoteEvents = {
	CaptureCreature: (creatureId: string, ballType: string) -> (success: boolean, creatureData: CreatureData?),
	ReleaseCreature: (creatureId: string) -> boolean,
	SwapPartyMember: (index1: number, index2: number) -> boolean,
	StartBattle: (enemyType: "Wild" | "Trainer", enemyData: any) -> BattleData,
	BattleAction: (action: BattleAction) -> BattleResult,
	EvolveCreature: (creatureId: string) -> (success: boolean, newSpeciesId: string?),
	LearnMove: (creatureId: string, moveId: string, replaceIndex: number?) -> boolean,
	UseItem: (itemId: string, targetId: string?) -> (success: boolean, result: any),
	SaveGame: () -> boolean,
	LoadGame: () -> PlayerData?,
}

export type BattleAction = {
	Type: "Move" | "Switch" | "Item" | "Run",
	MoveId: string?,
	TargetIndex: number?,
	SwitchIndex: number?,
	ItemId: string?,
}

export type BattleResult = {
	Success: boolean,
	Damage: number?,
	EffectMessages: {string},
	Fainted: boolean?,
	StateChange: BattleState?,
}

export type ItemData = {
	Id: string,
	Name: string,
	Description: string,
	Type: "Ball" | "Medicine" | "Battle" | "Evolution" | "Berry" | "Key",
	Effect: ItemEffect,
	Price: number,
	Stackable: boolean,
	MaxStack: number,
}

export type ItemEffect = {
	Type: "Heal" | "CureStatus" | "BoostStat" | "Capture" | "Evolve" | "TeachMove" | "PPRestore",
	Params: {[string]: any},
}

export type ZoneData = {
	Id: string,
	Name: string,
	Biome: ElementType,
	LevelRange: {Min: number, Max: number},
	SpawnTable: {SpeciesWeight},
	NPCs: {NPCData},
	Connections: {string},
}

export type SpeciesWeight = {
	SpeciesId: string,
	Weight: number,
	TimeOfDay: {"Day" | "Night" | "Dawn" | "Dusk"}?,
	Weather: {WeatherType}?,
	MinLevel: number,
	MaxLevel: number,
}

export type NPCData = {
	Id: string,
	Name: string,
	Type: "Trainer" | "Shopkeeper" | "Healer" | "QuestGiver",
	Position: Vector3,
	Dialogue: {string},
	Team: {CreatureData}?,
	ShopInventory: {string}?,
	QuestId: string?,
}

export type QuestData = {
	Id: string,
	Name: string,
	Description: string,
	Type: "Capture" | "Defeat" | "Collect" | "Explore" | "Evolve",
	Objectives: {QuestObjective},
	Rewards: {QuestReward},
	Prerequisites: {string}?,
	Repeatable: boolean,
}

export type QuestObjective = {
	Type: string,
	Target: string,
	Count: number,
	Current: number,
}

export type QuestReward = {
	Type: "Item" | "Money" | "Experience" | "Creature" | "Unlock",
	ItemId: string?,
	Amount: number,
}

export type GameConfig = {
	MaxPartySize: number,
	MaxStorageBoxes: number,
	StorageBoxSize: number,
	BaseCaptureRate: number,
	ExpCurve: "Fast" | "Medium" | "Slow" | "Erratic" | "Fluctuating",
	EvolutionLevels: {[string]: number},
	ShinyRate: number,
	DayNightCycle: number,
	WeatherChangeInterval: number,
}

return nil