class_name Utils


static func load_directory_recursively(path: String) -> Array[String]:
	var result: Array[String] = []
	path += "/"
	var dir := DirAccess.open(path)
	for sub_dir in dir.get_directories():
		result.append_array(load_directory_recursively(path + sub_dir))
	for file in dir.get_files():
		result.append(path + file)
	return result


static func free_children(node: Node) -> void:
	for child in node.get_children():
		child.free()


static func find_custom_children(parent: Node, type) -> Array[Node]:
	var result: Array[Node] = []
	for child in parent.get_children():
		if is_instance_of(child, type):
			result.append(child)
		result.append_array(find_custom_children(child, type))
	return result
