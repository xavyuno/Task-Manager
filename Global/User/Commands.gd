extends Node

var ScanOverried := "John"

func CheckCommand(cmd : Array[String]):
	var Output = [true, ""]
	if ValidateCommand(cmd, ["goto"]):
		User.emit_signal("SearchByQuery", cmd[1])
	
	else:
		Output[0] = false
	return Output

func ValidateCommand(cmd : Array[String], Query : Array[String], Size = 2):
	var Output = false
	for i in Query:
		if cmd[0] in Query and cmd.size() >= Size:
			Output = true
	return Output
