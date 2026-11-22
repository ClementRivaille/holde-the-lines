extends Control
class_name TitleScreen

func start_game():
	if GameStoreInstance.state != GameStore.GameState.START_SCREEN: return

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	GameStoreInstance.start_game()
