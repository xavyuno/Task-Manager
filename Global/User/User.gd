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
signal SearchByID
signal RecieveByID

var SearchQueries := ["Note:", "Title:", "ID:", "Board:", "Type:", "Dir:", "ItemID:"]
var SearchResults := []
var SearchSen := 0.5

var OptionsEnabled := true

var RemovedHistory: = []
var StoredHistory: = []
var StillLoading: = true

var MouseInCanvas: = false
var CanvasHidden = false

var MousePos: Vector2
var CamPos: Vector2
var CamZoom: Vector2
var InFocus: = false
var DragSelecting := false
var DraggingObject: = false
var DraggedObject: PackedScene

var CurrentPage: = "Home"
var PageTitle: = "Home"
var PreviousPage: = "Home"
var PreviousTitle: = "Home"
var Boards: = {}

var SelectedObject = null
var MultiSelectedObjects = []
var MultiCopiedObjects := []
var MultiSelecting = false
var AllSameSelectedObjects = false
var CopiedObject = null

var LoadDur: = 0.05
var PreviewingNotes := false
var TotalItems := 0

var TestingMode := false

var CamPosBoard := Vector2(640, 352)
var CamPosSettings := Vector2(640, 352)
var CamPosCalendar := Vector2(640, 352)

var SelectedDate := [0, 0, 0]
var SavedEvents := {}
