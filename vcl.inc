
  {$IFDEF LUA52}
     Lua in 'src/lua52/Lua.pas',
     LuaPas in 'src/lua52/LuaPas.pas',
  {$ELSE}
     Lua in 'src/lua51/Lua.pas',
     LuaPas in 'src/lua51/LuaPas.pas',
  {$ENDIF}
  LuaStrings in 'src/LuaStrings.pas',
  LuaControl in 'src/LuaControl.pas',
  LuaProperties in 'src/LuaProperties.pas',
  LuaApplication in 'src/LuaApplication.pas',
  LuaForm in 'src/LuaForm.pas',
  {$I genericsrc/genuses.inc}
  LuaMenu in 'src/LuaMenu.pas',
  LuaActionList in 'src/LuaActionList.pas',
  LuaToolBar in 'src/LuaToolBar.pas',
  // LuaEditButton in 'src/LuaEditButton.pas',
  LuaStringGrid in 'src/LuaStringGrid.pas',
  LuaTrayIcon in 'src/LuaTrayIcon.pas',
  LuaStatusBar in 'src/LuaStatusBar.pas',
  LuaImage in 'src/LuaImage.pas',
  LuaImageList in 'src/LuaImageList.pas',
  LuaProgressBar in 'src/LuaProgressBar.pas',
  LuaDialogs in 'src/LuaDialogs.pas',
  LuaFileDialog in 'src/LuaFileDialog',
  LuaFindDialog in 'src/LuaFindDialog.pas',
  LuaDateEdit in 'src/LuaDateEdit.pas',
  LuaFileListBox in 'src/LuaFileListBox.pas',
  LuaTree in 'src/LuaTree.pas',
  LuaListView in 'src/LuaListView.pas',
  // moved from generic
  LuaListBox in 'src/LuaListBox.pas',
  LuaCheckListBox in 'src/LuaCheckListBox.pas',

  LuaPicture in 'src/LuaPicture',
  LuaBitmap in 'src/LuaBitmap',
  LuaGraphic in 'src/LuaGraphic',
  LuaCanvas in 'src/LuaCanvas.pas',

  LuaXMLConfig in 'src/LuaXMLConfig.pas',

  LuaSyn in 'src/LuaSyn.pas',
  LuaSynEdit in 'src/LuaSynEdit.pas',
  LuaPropertyGrid in 'src/LuaPropertyGrid.pas',

  LuaStream in 'src/LuaStream.pas',
  LuaMouse in 'src/LuaMouse.pas',
  LuaTable in 'src/LuaTable.pas';

const
  LUA_VCL_LIBNAME = 'vcl';
  LIB_COUNT = 44 + {$I genericsrc/genlibcount.inc};

var
   vcl_lib : array[0..LIB_COUNT] of lual_reg = (
		(name:'Application'; func:@CreateApplication),
		(name:'Form'; func:@CreateForm),

		(name:'MainMenu'; func:@CreateMainMenu),
		(name:'PopupMenu'; func:@CreatePopupMenu),
		(name:'MenuItem'; func:@CreateMenuItem),
		(name:'ToolBar'; func:@CreateToolBar),
		(name:'ToolButton'; func:@CreateToolButton),

		(name:'ActionList'; func:@CreateActionList),
		(name:'Action'; func:@CreateAction),
		(name:'StringGrid'; func:@CreateStringGrid),
		(name:'StatusBar'; func:@CreateStatusBar),
		(name:'TrayIcon'; func:@CreateTrayIcon),
		(name:'Image'; func:@CreateImage),
		(name:'ImageList'; func:@CreateImageList),
		(name:'ProgressBar'; func:@CreateProgressBar),

                {$I genericsrc/genlibs.inc}

		// Dialogs
		(name:'OpenDialog'; func:@CreateOpenDialog),
		(name:'SaveDialog'; func:@CreateSaveDialog),
		(name:'SelectDirectoryDialog'; func:@CreateSelectDirectoryDialog),
		(name:'ColorDialog'; func:@CreateColorDialog),
		(name:'FontDialog'; func:@CreateFontDialog ),
		(name:'FindDialog'; func:@CreateFindDialog),
		(name:'ReplaceDialog'; func:@CreateReplaceDialog),

		(name:'DateEdit'; func:@CreateDateEdit),
		(name:'FileListBox'; func:@CreateFileListBox),
                (name:'ListView'; func:@CreateListView),
                (name:'TreeView'; func:@CreateTreeView),

                // Listboxes
                (name:'ListBox'; func:@CreateListBox),
                (name:'CheckListBox'; func:@CreateCheckListBox),

		// builtin
		(name:'ShowMessage'; func:@LuaShowMessage),
		(name:'MessageDlg'; func:@LuaMessageDlg),
		(name:'XMLConfig'; func:@CreateXMLConfig),
                (name:'XMLFormToLua'; func:@XMLFormToLua),

		// SynEdit
		(name:'SynEdit'; func:@CreateSynEditor),

		// Help
		(name:'ListProperties'; func:@LuaListProperties),
                (name:'GetProperty'; func:@LuaGetProperty),
                (name:'PropertyGrid'; func:@CreatePropertyGrid),

		// LUA
		(name:'RunSeparate'; func:@RunSeparate),

		// OS
                (name:'ExeName'; func:@ApplicationExeName),
                (name:'ExePath'; func:@ApplicationExePath),
		(name:'FileExists'; func:@LuaFileExists),
		(name:'DirectoryExists'; func:@LuaDirectoryExists),
		(name:'GetScreenSize'; func:@GetScreenSize),
                (name:'GetCursorPos'; func:@GetCursorPos),

		// Stream
		(name:'Stream'; func:@CreateStream),

		(name:nil;func:nil)
   );

