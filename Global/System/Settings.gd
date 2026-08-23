extends Node

signal SettingsChanged

var AvailableQuickOptions := [
	"ShowCenter",
	"ResetCam",
	"Calendar",
	"Hide"
]

var Data = {
	"BackgroundCol": Color.ROYAL_BLUE,
	"UpdatePath": "user://TaskManager.exe",
	"ItemLimit": 10000,
	"LoadDur": 0.1,
	"OptionsEnabled": false,
	"ShowCenter": true,
	"QuickOptions": ["Hide", "Calendar", "ResetCam"],
	"DefaultFontSize": 15,
	"DefaultTitleSize": 15,
	"UrlAPIKey": "",
	"ProgressiveLoading": false,
	"TotalBoards": 0,
	"SelectCol": Color.BLACK,
	"CanSelectCol": true,
	"DragCol": Color.WHITE,
	"GridSnap": false,
	"GridSize": 16,
	"GridCol": Color.WHITE,
	"CamPosHome": Vector2(640, 352),
	"CamPosSettings": Vector2(840, 504),
	"CamPosCalendar": Vector2(640, 352),
	"CamPosCanvas": Vector2(640, 352),
	"CamZoomHome": Vector2(1, 1),
	"CamZoomSettings": Vector2(0.65, 0.65),
	"CamZoomCalendar": Vector2(0.65, 0.65),
	"WarnDeleteAllBoard": true,
	"Email": "",
	"Password": "",
	"SavedKeybinds" : {
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
	},
	"ToolbarVisible" : true,
	"DebugMode" : false,
	"OverrideText" : [],
	"CurrentPage" : "Home",
	"PageTitle" : "Home",
}
