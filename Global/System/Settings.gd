extends Node

signal SettingsChanged

var BackgroundCol: = Color.ROYAL_BLUE
var UpdatePath: String = "user://TaskManager.exe"
var ItemLimit := 10000
var LoadDur := 0.1
var OptionsEnabled := false
var ShowCenter := true
var QuickOptions := ["PreviewNotes", "OptionsBar"]
var DefaultFontSize := 15
var DefaultTtileSize := 15
var UrlAPIKey := ""
var ProgressiveLoading := false
var TotalBoards := 0
var SelectCol := Color.BLACK
var CanSelectCol := true
var DragCol := Color.WHITE
var GridSnap := false
var GridSize := 16
var GridCol := Color.WHITE

var SavedKeybinds := {
	"Bold" : [],
	"Move" : [],
	"Resize" : [],
	"Cut" : [],
	"SelectAll" : [],
	"Paste" : [],
	"Duplicate" : [],
	"Copy" : [],
	"Undo" : [],
	"ResetCam" : [],
	

}

func GetSettings():
	return [
		BackgroundCol, 
		UpdatePath,
		LoadDur,
		ItemLimit,
		OptionsEnabled,
		ShowCenter,
		QuickOptions,
		DefaultFontSize,
		DefaultTtileSize,
		UrlAPIKey,
		ProgressiveLoading,
		TotalBoards,
		SelectCol,
		CanSelectCol,
		SavedKeybinds,
		User.SavedEvents,
		GridSize,
		GridCol

	]
