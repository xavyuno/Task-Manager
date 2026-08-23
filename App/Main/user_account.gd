extends Control

func _on_db_data_update(resource):
	System.DatabaseLoaded = true
	$ScrollContainer/Output.text += "Data Updated!" + "\n"

func _ready():
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	$Email.text = Settings.Data["Email"]
	$HBoxContainer/Password.text = Settings.Data["Password"]

func _on_FirebaseAuth_login_succeeded(auth):
	System.Db_ref = Firebase.Database.get_database_reference("Data", {})
	System.Db_ref.new_data_update.connect(_on_db_data_update)
	System.Db_ref.patch_data_update.connect(_on_db_data_update)
	System.Db_ref.delete_data_update.connect(_on_db_data_update)
	$ScrollContainer/Output.text += "Login Succeeded" + "\n"
	
func on_login_failed(error_code, message):
	$ScrollContainer/Output.text += "error code: " + str(error_code) + "\n"
	$ScrollContainer/Output.text += "message: " + str(message) + "\n"

func on_signup_failed(error_code, message):
	$ScrollContainer/Output.text += ("error code: " + str(error_code)) + "\n"
	$ScrollContainer/Output.text += ("message: " + str(message)) + "\n"

func _on_login_pressed() -> void:
	Firebase.Auth.login_with_email_and_password(Settings.Data["Email"], Settings.Data["Password"])

func _on_signup_pressed() -> void:
	Firebase.Auth.signup_with_email_and_password(Settings.Data["Email"], Settings.Data["Password"])

func _on_data_2_pressed() -> void:
	System.SaveOnline()

func _on_data_3_pressed() -> void:
	System.LoadOnline()

func _on_email_text_changed(new_text: String) -> void:
	Settings.Data["Email"] = new_text

func _on_password_text_changed(new_text: String) -> void:
	Settings.Data["Password"] = new_text

func _on_button_pressed() -> void:
	$HBoxContainer/Password.secret = !$HBoxContainer/Password.secret

func _on_logout_pressed() -> void:
	Firebase.Auth.logout()
