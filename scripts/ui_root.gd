extends Control

@onready var line_edit  = $ColorRect/HBoxContainer/LineEdit
@onready var send_btn   = $ColorRect/HBoxContainer/Button
@onready var chat_box   = $ColorRect/MarginContainer/ScrollContainer/ChatBox
@onready var http       = HTTPRequest.new()

func _ready():
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	send_btn.pressed.connect(_on_send_pressed)
	line_edit.grab_focus()

	chat_box.bbcode_enabled = true
	chat_box.scroll_following = true
	chat_box.autowrap_mode = TextServer.AUTOWRAP_WORD
	chat_box.add_theme_constant_override("line_separation", 6)
	chat_box.text = "[center][b][color=#00BFFF]🎧 DJ Oracle Online[/color][/b][/center]\n"


func _on_send_pressed():
	var msg = line_edit.text.strip_edges()
	if msg == "":
		return
	_append_user(msg)
	line_edit.text = ""

	var url = "http://127.0.0.1:5000/ask"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"message": msg})
	http.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_request_completed(result, code, headers, body):
	if code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		if data and data.has("reply"):
			_append_dj(data["reply"])
		else:
			_append_dj("⚠️ No reply received.")
	else:
		_append_dj("❌ Server error: " + str(code))

func _append_user(msg: String):
	chat_box.append_text("[right][color=#FFD700][b]You:[/b][/color] %s[/right]\n" % msg)
	chat_box.scroll_to_line(chat_box.get_line_count())

func _append_dj(reply: String):
	chat_box.append_text("[left][color=#00BFFF][b]DJ Oracle:[/b][/color] %s[/left]\n" % reply)
	chat_box.scroll_to_line(chat_box.get_line_count())
