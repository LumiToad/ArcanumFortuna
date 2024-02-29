@tool
class_name Track
extends Resource

var cached_name

var name:
	get:
		if cached_name:
			return cached_name
		if resource_name:
			cached_name = resource_name
			return resource_name
		cached_name = resource_name
		return ".".join(resource_path.simplify_path().split("/")[-1].split(".").slice(0, -1))
	
	
@export var layers: Array[AudioStream]
