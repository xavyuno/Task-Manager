extends Node

signal StartedDragging
signal StoppedDragging
signal ObjectAdded
signal ObjectRemoved
signal SaveObjectData
signal ChangeBoard
signal StoppedSelecting
signal Searched
signal PreviewNotes
signal ItemFocused
signal ItemFocusLost
signal ChangedOptionsBar
signal AllFocusLost
signal SearchResultSend
signal SearchByQuery
signal DeleteAllItemsByBoard
signal ApplySaveFile

var SearchQueries := ["Note:", "Title:", "ID:", "Board:", "Type:", "Dir:", "ItemID:", "Tags:"]
var SearchResults := []
var SearchSen := 0.5

var OptionsEnabled := true

var RemovedHistory: = []
var StoredHistory: = []
var StillLoading: = true

var MouseInCanvas: = false
var CanvasHidden = false
var MouseInOpen := true

var MousePos: Vector2
var CamPos: Vector2
var CamZoom : Vector2
var InFocus: = false
var DragSelecting := false
var DraggingObject: = false
var DraggedObject: PackedScene

var PreviousPage: = "Home"
var PreviousTitle: = "Home"
var PreviousPos := Vector2.ZERO
var Boards: = {}

var SelectedObject = null
var MultiSelectedObjects = []
var MultiCopiedObjects := []
var MultiSelecting = false
var AllSameSelectedObjects = false
var CopiedObject = null

var LoadDur: = 0.05
var TotalItems := 0

var TestingMode := false

var SelectedDate := [0, 0, 0]
var SavedEvents := {}
var CopiedData = {
	"Data" : null,
	"Size" : Vector2.ZERO
}
