#Requires Autohotkey v2
#SingleInstance Force

#Include ../lib/jsongo.v2.ahk

; Run script as Administrator to avoid UAC prompts
if !A_IsAdmin {
	Run '*RunAs "' A_ScriptFullPath '"'
	ExitApp
}

; =====================
; ===== GUI CODES =====
; =====================
global MAIN := 'main'

; ===========================
; ===== VISO UI classes =====
; ===========================
global VISO_EXE_CLASS := 'ahk_exe VISO.exe'
global VISO_LOGIN_WINDOW := 'Zaloguj się'
global VISO_MAIN_WINDOW := 'VISO Standard v2.1.2.39775. Program zarejestrowany dla: nie zarejestrowano. Roger sp. z o.o. sp. k.; http://www.roger.pl'
global VISO_ADD_PERSON_WINDOW := 'Dodaj Osobę'
global VISO_ADD_IDENTIFICATOR_WINDOW := 'Dodaj Identyfikator'
global VISO_ADD_IDENTIFICATOR_MEDIA_SELECT_WINDOW := 'Wybierz'
global VISO_WINDOW := 'ahk_class WindowsForms10.Window.8.app.0.3bb52ed_r6_ad1'
global VISO_LOGIN_FIELD_USERNAME := 'WindowsForms10.Window.b.app.0.3bb52ed_r6_ad110'
global VISO_LOGIN_FIELD_PASSWORD := 'WindowsForms10.Window.b.app.0.3bb52ed_r6_ad18'
global VISO_ADD_PERSON_SUBMIT_BUTTON := 'WindowsForms10.Window.b.app.0.3bb52ed_r6_ad114'
global VISO_ADD_IDENTIFICATOR_SUBMIT_BUTTON := 'WindowsForms10.Window.b.app.0.3bb52ed_r6_ad120'

; ==============================
; ===== Default parameters =====
; ==============================
global MARGIN_NONE := 0
global MARGIN_DEFAULT := 5
global MARGIN_VERTICAL_DEFAULT := 5
global MARGIN_VERTICAL_BETWEEN_GROUPBOXES := 16
global BASE_X := 32
global BASE_X_ABSOLUTE := 16
global BASE_Y := 32
global BASE_Y_TABS := 48
global DEFAULT_HEIGHT := 21
global BUTTON_HEIGHT := 23

; =======================================
; ===== Default parameters for MAIN =====
; =======================================
global MAIN_GUI_WIDTH := 500
global MAIN_GUI_HEIGHT := 250
global MAIN_GROUPBOX_WIDTH := 468
global MAIN_WIDTH_SM := 150
global MAIN_WIDTH_LG := 286
global MAIN_WIDTH_FULL := 436

; ============================
; ===== JSON files paths =====
; ============================
global json_translations_path := 'translations.json'
global json_languages_path := 'languages.json'
global json_settings_path := 'settings.json'
global json_secret_path := 'secret.json'
global json_people_path := 'people.json'

; =============================================================
; ===== Load JSON files and convert them to usable arrays =====
; =============================================================
translations := LoadJSON(json_translations_path)
languages := LoadJSON(json_languages_path)
settings := LoadJSON(json_settings_path)
secret := LoadJSON(json_secret_path)
people := LoadJSON(json_people_path)

; Build GUI for the first time
app_gui := BuildGUI(MAIN, settings['language'])
ShowGUI(app_gui, MAIN_GUI_WIDTH, MAIN_GUI_HEIGHT)

; ====================================================
; ===== Function to build/rebuild the entire GUI =====
; ====================================================
BuildGUI(GUI_CODE, langCode) {
	global translations, languages, settings, presets, app_gui

	stringTable := translations[langCode]

	switch GUI_CODE {
		case MAIN:
			app_gui := Gui()
			app_gui.Opt('-MaximizeBox')

			; ----------------
			; ----- Tabs -----
			; ----------------
			Tab := app_gui.Add('Tab3', , [stringTable['tab_Main']])
			SetPos(
				Tab, , ,
				MAIN_GUI_WIDTH,
				MAIN_GUI_HEIGHT
			)

			; ===========================
			; ===== Tab (Main page) =====
			; ===========================
			Tab.UseTab(1)

			; -----------------------------
			; ----- Language switcher -----
			; -----------------------------

			; Text (Label)
			Label_Language := app_gui.Add('Text', '+0x200', stringTable['label_Language'])
			SetPos(
				Label_Language,
				BASE_X,
				BASE_Y_TABS,
				MAIN_WIDTH_SM,
				DEFAULT_HEIGHT
			)

			; DropDownList
			LanguagesDropDownList := app_gui.Add('DropDownList', , [])
			SetPos(
				LanguagesDropDownList,
				GetNextX(Label_Language, MARGIN_NONE),
				BASE_Y_TABS,
				MAIN_WIDTH_LG,
				DEFAULT_HEIGHT
			)

			; Insert values
			LanguagesList := []
			LanguagesListKeys := []
			for lang in languages {
				LanguagesList.Push(languages[lang]['display_name'])
				LanguagesListKeys.Push(languages[lang]['code'])
			}
			LanguagesDropDownList.Add(LanguagesList)

			; Set default value
			LanguagesDropDownList.Value := FindIndex(LanguagesListKeys, langCode)

			; Event listener
			LanguagesDropDownList.OnEvent('Change', OnLanguageChange.Bind(LanguagesListKeys, LanguagesDropDownList, app_gui))

			; ----- Function for changing language -----
			OnLanguageChange(LanguagesListKeys, LanguagesDropDownList, GUI, *) {
				settings['language'] := languages[LanguagesListKeys[LanguagesDropDownList.Value]]['code']
				settings_new := jsongo.Stringify(settings, , 4)
				FileDelete(json_settings_path)
				FileAppend(settings_new, json_settings_path, 'UTF-8')

				; Rebuild GUI with new language
				GUI.Destroy()
				GUI := BuildGUI(MAIN, settings['language'])
				ShowGUI(GUI, MAIN_GUI_WIDTH, MAIN_GUI_HEIGHT)
			}

			; --------------------
			; ----- Username -----
			; --------------------

			; Y value (Label)
			Y_Label_Username := GetNextY(LanguagesDropDownList, MARGIN_VERTICAL_DEFAULT)

			; Text (Label)
			Label_Username := app_gui.Add('Text', '+0x200 +Center', stringTable['label_Username'])
			SetPos(
				Label_Username,
				BASE_X,
				Y_Label_Username,
				MAIN_WIDTH_FULL,
				DEFAULT_HEIGHT
			)

			; Y value
			Y_Username := GetNextY(Label_Username, MARGIN_NONE)

			; Edit
			Username := app_gui.Add('Edit', , secret['user'])
			SetPos(
				Username,
				BASE_X,
				Y_Username,
				MAIN_WIDTH_FULL,
				DEFAULT_HEIGHT
			)

			; Add hint
			SendMessage(0x1501, true, StrPtr(stringTable['placeholder_Username']), Username.Hwnd)

			; --------------------
			; ----- Password -----
			; --------------------

			; Y value (Label)
			Y_Label_MasterPassword := GetNextY(Username, MARGIN_VERTICAL_DEFAULT)

			; Text (Label)
			Label_MasterPassword := app_gui.Add('Text', '+0x200 +Center', stringTable['label_MasterPassword'])
			SetPos(
				Label_MasterPassword,
				BASE_X,
				Y_Label_MasterPassword,
				MAIN_WIDTH_FULL,
				DEFAULT_HEIGHT
			)

			; Y value
			Y_MasterPassword := GetNextY(Label_MasterPassword, MARGIN_NONE)

			; Edit
			MasterPassword := app_gui.Add('Edit', 'Password', secret['password'])
			SetPos(
				MasterPassword,
				BASE_X,
				Y_MasterPassword,
				MAIN_WIDTH_LG - MARGIN_DEFAULT,
				DEFAULT_HEIGHT
			)

			; Add hint
			SendMessage(0x1501, true, StrPtr(stringTable['placeholder_MasterPassword']), MasterPassword.Hwnd)

			; Button
			MasterPasswordShow := app_gui.Add('Button', ,)
			SetPos(
				MasterPasswordShow,
				GetNextX(MasterPassword, MARGIN_DEFAULT),
				Y_MasterPassword,
				MAIN_WIDTH_SM,
				DEFAULT_HEIGHT
			)

			; Event listener
			MasterPasswordShow.OnEvent('Click', (*) => TogglePassword(MasterPassword, MasterPasswordShow, stringTable['button_ShowPassword'], stringTable['button_HidePassword']))
			TogglePassword(MasterPassword, MasterPasswordShow, stringTable['button_ShowPassword'], stringTable['button_HidePassword'])
			TogglePassword(MasterPassword, MasterPasswordShow, stringTable['button_ShowPassword'], stringTable['button_HidePassword'])

			; ---------------------------------
			; ----- Save general settings -----
			; ---------------------------------

			; Y value
			Y_GeneralSettingsSaveButton := GetNextY(MasterPasswordShow, MARGIN_VERTICAL_DEFAULT)

			; Button
			GeneralSettingsSaveButton := app_gui.Add('Button', '+Center', stringTable['button_Save'])
			SetPos(
				GeneralSettingsSaveButton,
				BASE_X,
				Y_GeneralSettingsSaveButton,
				MAIN_WIDTH_FULL,
				DEFAULT_HEIGHT
			)

			; Event listener
			GeneralSettingsSaveButton.OnEvent('Click', SaveExecutablePathHandler.Bind(Username, MasterPassword))

			SaveExecutablePathHandler(Ctrl, Ctrl2, *) {
				username := Ctrl.Value
				password := Ctrl2.Value
				if username != secret['user'] or password != secret['password'] {
					SaveLoginData(username, password, app_gui)
				}
			}

			; ----- Function for saving username and password -----
			SaveLoginData(user, password, GUI) {
				secret['user'] := user
				secret['password'] := password
				secret_new := jsongo.Stringify(secret, , 4)
				FileDelete(json_secret_path)
				FileAppend(secret_new, json_secret_path, 'UTF-8')

				; Rebuild GUI
				GUI.Destroy()
				GUI := BuildGUI(MAIN, settings['language'])
				ShowGUI(GUI, MAIN_GUI_WIDTH, MAIN_GUI_HEIGHT)
			}

			; --------------------------------------
			; ----- General settings group box -----
			; --------------------------------------

			; H value
			H_GeneralSettingsGroupBox := GetGroupBoxH(GeneralSettingsSaveButton, BASE_Y, MARGIN_VERTICAL_DEFAULT)

			; GroupBox
			GeneralSettingsGroupBox := app_gui.Add('GroupBox', , stringTable['section_Settings_General'])
			SetPos(
				GeneralSettingsGroupBox,
				BASE_X_ABSOLUTE,
				BASE_Y,
				MAIN_GROUPBOX_WIDTH,
				H_GeneralSettingsGroupBox
			)

			; --------------------------
			; ----- Connect button -----
			; --------------------------

			; Y value
			Y_ConnectButton := GetNextY(GeneralSettingsGroupBox, MARGIN_VERTICAL_BETWEEN_GROUPBOXES)

			; Button
			ConnectButton := app_gui.Add('Button', , stringTable['button_Continue'])
			SetPos(
				ConnectButton,
				BASE_X_ABSOLUTE,
				Y_ConnectButton,
				MAIN_GROUPBOX_WIDTH,
				BUTTON_HEIGHT
			)

			; Set default focus
			ConnectButton.Focus()

			; Event listener
			ConnectButton.OnEvent('Click', InitiateConnectionHandler)

			InitiateConnectionHandler(*) {
				if (WinExist(VISO_WINDOW) = 0 or WinExist(VISO_EXE_CLASS) = 0) {
					InitiateConnection(app_gui)
				} else {
					ErrorDialog(stringTable['error_CloseAllWinSCPWindows'], stringTable['title_ErrorCloseAllWinSCPWindows'], 48, false)
				}
			}

			; ----- Function for executing main code -----
			InitiateConnection(GUI) {

				; +++++ Initial part +++++

				; Close GUI
				GUI.Destroy()

				; Minimise all windows
				WinMinimizeAll

				; Run Roger VISO
				Run '"' . settings['viso_exe_path'] . '"'

				; Wait until login window appears
				if WinWait(VISO_LOGIN_WINDOW) {
					WinActivate VISO_LOGIN_WINDOW
				} else {
					ErrorDialog(stringTable['error_CannotFindSpecifiedWindow'] . ' ' . VISO_LOGIN_WINDOW, stringTable['title_CannotFindSpecifiedWindow'])
				}

				; Enter username and password, then send ENTER
				ControlSetText secret['user'], VISO_LOGIN_FIELD_USERNAME, VISO_LOGIN_WINDOW
				ControlFocus VISO_LOGIN_FIELD_PASSWORD, VISO_LOGIN_WINDOW
				SendText secret['password']
				Send '{Enter}'

				; Wait for app to fully load UI
				Sleep settings['app_loading_timeout']

				; Wait until main window appears
				if WinWait(VISO_MAIN_WINDOW) {
					WinActivate(VISO_MAIN_WINDOW)
				} else {
					ErrorDialog(stringTable['error_CannotFindSpecifiedWindow'] . ' ' . VISO_MAIN_WINDOW, stringTable['title_CannotFindSpecifiedWindow'])
				}

				; +++++ Repetitive part +++++

				; Added people counter
				added_people_count := 0

				for person in people {

					; Open "Osoby" tab
					MouseClick 'Left', 130, 56
					MouseClick 'Left', 56, 130

					; Give app time to load tab
					Sleep settings['tab_loading_timeout']

					; Click "Dodaj" to add new person
					MouseClick 'Left', 500, 140

					; Focus "Dodaj osobę" window
					if WinWait(VISO_ADD_PERSON_WINDOW) {
						WinActivate(VISO_ADD_PERSON_WINDOW)
					} else {
						ErrorDialog(stringTable['error_CannotFindSpecifiedWindow'] . ' ' . VISO_ADD_PERSON_WINDOW, stringTable['title_CannotFindSpecifiedWindow'])
					}

					; Create full name
					full_name := person['name'] . ' ' . person['lastname']

					; Wait for window to load
					WinWaitActive VISO_ADD_PERSON_WINDOW

					; Enter person's descriptive name
					Send '^A{BackSpace}'
					SendText full_name
					Send '{Tab}'

					; Enter person's name
					SendText person['name']
					Send '{Tab}'

					; Enter person's surname
					SendText person['lastname']
					Send '{Tab}'

					; Enter default group
					SendText 'Użytkownicy'
					Sleep settings['select_text_input_timeout']
					Send '{Enter}{Tab}{Tab}'

					; Enter person's position
					SendText person['position']
					Sleep settings['select_text_input_timeout']
					Send '{Enter}{Enter}'

					; Give app time to load tab
					Sleep settings['tab_loading_timeout']

					; Open "Identyfikatory" tab
					MouseClick 'Left', 130, 56
					MouseClick 'Left', 355, 95

					; Give app time to load tab
					Sleep settings['tab_loading_timeout']

					; Click "Dodaj" to add new person
					MouseClick 'Left', 500, 140

					; Focus "Dodaj osobę" window
					if WinWait(VISO_ADD_IDENTIFICATOR_WINDOW) {
						WinActivate(VISO_ADD_IDENTIFICATOR_WINDOW)
					} else {
						ErrorDialog(stringTable['error_CannotFindSpecifiedWindow'] . ' ' . VISO_ADD_IDENTIFICATOR_WINDOW, stringTable['title_CannotFindSpecifiedWindow'])
					}

					; Create identificator name
					id_name := person['name'] . '_' . person['lastname']

					; Wait for window to load
					WinWaitActive VISO_ADD_IDENTIFICATOR_WINDOW

					; Enter identificator name
					Send '^A{BackSpace}'
					SendText id_name
					Send '{Tab}{Tab}'

					; Enter identificator's owner
					SendText full_name
					Sleep settings['subtab_loading_timeout']
					Send '{Down}{Enter}{Enter}'

					; Wait for main window to focus
					WinWaitActive VISO_MAIN_WINDOW

					; Open "Nośniki" tab
					MouseClick 'Left', 732, 578

					; Give app time to load tab
					Sleep settings['subtab_loading_timeout']

					; Click "Z Zasobnika" button
					MouseClick 'Left', 844, 609

					; Focus "Wybierz" window
					if WinWait(VISO_ADD_IDENTIFICATOR_MEDIA_SELECT_WINDOW) {
						WinActivate(VISO_ADD_IDENTIFICATOR_MEDIA_SELECT_WINDOW)
					} else {
						ErrorDialog(stringTable['error_CannotFindSpecifiedWindow'] . ' ' . VISO_ADD_IDENTIFICATOR_MEDIA_SELECT_WINDOW, stringTable['title_CannotFindSpecifiedWindow'])
					}

					; Wait for window to load
					WinWaitActive VISO_ADD_IDENTIFICATOR_MEDIA_SELECT_WINDOW

					; Select the first position on the list and confirm
					Send '{Tab}{Space}{Enter}'

					; Wait before adding next person
					Sleep settings['tab_loading_timeout']

					; Increment counter
					added_people_count++
				}

				; +++++ Ending part +++++

				ErrorDialog(stringTable['error_FinishedSuccessfully'] . ' ' . added_people_count, stringTable['title_FinishedSuccessfully'], 0)
			}

			; ----- Window title -----
			SetTitle(app_gui, stringTable['appName'])

			; ----- Close button -----
			app_gui.OnEvent('Close', (*) => app_gui.Destroy())

			return app_gui
		default:
			ErrorDialog(stringTable['error_GUIBuilderInvalidParam'], stringTable['error_Error'])
	}
}

; ===========================================================
; ===== Function for calculating next group box H value =====
; ===========================================================
GetGroupBoxH(Ctrl, startY, padding) {
	x := y := w := h := 0
	Ctrl.GetPos(&x, &y, &w, &h)
	return (y + h) - startY + (2 * padding)
}

; =========================================================
; ===== Function for calculating next element X value =====
; =========================================================
GetNextX(prevCtrl, space) {
	x := y := w := h := 0
	prevCtrl.GetPos(&x, &y, &w, &h)
	return x + w + space
}

; =========================================================
; ===== Function for calculating next element Y value =====
; =========================================================
GetNextY(prevCtrl, space) {
	x := y := w := h := 0
	prevCtrl.GetPos(&x, &y, &w, &h)
	return y + h + space
}

; ================================================================
; ===== Function for setting position and size of an element =====
; ================================================================
SetPos(Ctrl, x := 0, y := 0, w := 0, h := 0) {
	Ctrl.Move(x, y, w, h)
}

; ==========================================
; ===== Function for setting GUI title =====
; ==========================================
SetTitle(GUI, title) {
	GUI.Title := title
}

; ====================================
; ===== Function for showing GUI =====
; ====================================
ShowGUI(GUI, GUI_WIDTH, GUI_HEIGHT) {
	GUI.Show('w' . GUI_WIDTH . ' h' . GUI_HEIGHT)
}

; =====================================================
; ===== Function for toggling password visibility =====
; =====================================================
TogglePassword(Ctrl, CtrlBtn, textShow, textHide, *) {
	static togglePassVar := false
	togglePassVar := !togglePassVar
	if togglePassVar {
		Ctrl.Opt('-Password')
		CtrlBtn.Text := textHide
	} else {
		Ctrl.Opt('Password')
		CtrlBtn.Text := textShow
	}
}

; ==========================================================
; ===== Function for finding index of an array element =====
; ==========================================================
FindIndex(arr, value) {
	for i, v in arr
		if (v = value)
			return i
	return 0
}

; ==========================================
; ===== Function for loading JSON file =====
; ==========================================
LoadJSON(json_path) {
	json_contents := FileExist(json_path) ? FileRead(json_path, 'UTF-8') : ErrorDialog('JSON file does not exist!')
	json := jsongo.Parse(json_contents)
	if !IsObject(json)
		ErrorDialog('Parsed JSON is not an object!')
	return json
}

; =================================================
; ===== Function for displaying error message =====
; =================================================
ErrorDialog(message, title := 'Error', type := 16, appExit := true) {
	MsgBox(message, title, type)
	if appExit {
		ExitApp
	}
}