class_name TutorialPopupData
extends Resource

enum OffsetType
{
	UP,
	DOWN,
	LEFT,
	RIGHT,
	UP_LEFT,
	UP_RIGHT,
	DOWN_LEFT,
	DOWN_RIGHT
}

@export var title : String
@export_multiline var text : String
@export var highlighted_elements : Array[NodePath]
@export var arrows : Array[ArrowData]
@export var offset_type : OffsetType
@export var distance : float

var popup_path : String
