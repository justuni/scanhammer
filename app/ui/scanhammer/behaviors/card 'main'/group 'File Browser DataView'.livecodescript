script "group 'File Browser Dataview'" with behavior "File Browser DataView Tree Behavior"

local sHilitedRow # currently hilited row
local sFilename # name of the file for the currently hilited row
local sFilePath # path of the currently hilited row
local sPathOfFileBelow # the paths of the files directly above and below the selected one, used to look up the rows if we navigate off the one selected.


getProp selectedFilename
return sFilename
end selectedFilename



getProp selectedFilePath
return sFilePath
end selectedFilePath



on selectedRowChanged pRowNumber
  put pRowNumber into sHilitedRow

  #<get the filename and the path for the line selected>
    put getValueForKeyInRow(sHilitedRow,"filename") into sFilename
    put the dvPathOfRow[sHilitedRow] of me into sFilePath
    put the dvPathOfRow[sHilitedRow+1] of me into sPathOfFileBelow #move down one in the list on a delete or in other cases where we want to iterate after an operation
  #</get the filename and the path for the line selected>

  pass selectedRowChanged
end selectedRowChanged



#<workaround for https://github.com/trevordevore/levurehelper-dataview/issues/>
  # manually changing hilighted rows doesn't fire selectedRowChanged.  Fire this instead until it does.
  on handleChangedHilight pRowNumber
    put pRowNumber into sHilitedRow
    #get the filename and the path for the line selected
    put getValueForKeyInRow(sHilitedRow,"filename") into sFilename
    put the dvPathOfRow[sHilitedRow] of me into sFilePath
    put the dvPathOfRow[sHilitedRow+1] of me into sPathOfFileBelow #move down one in the list on a delete or in other cases where we want to iterate after an operation
  end handleChangedHilight
#</workaround for https://github.com/trevordevore/levurehelper-dataview/issues/>




on mouseDown pWhichButton # fileBrowser moves the selection on mouseDown not mouseUp, so do our thing there, too.
	dvMouseDown pWhichButton # select row, if necessary

	if pWhichButton is 3 then #right-click
		put _popChoose("Open,-,Delete,-,Duplicate") into choice
		if choice is "Open" then
			launch document sFilePath
		else if choice is "Delete" then
			answer "Delete"&& quote&sFilename&quote with "Cancel" or "OK"
			if it is "OK" then 
				_moveToTrash sFilePath
      	end if #it is "OK"
      else if choice is "Duplicate" then
      	_duplicateFile sFilePath
    	end if #Choice is "Open"

    	if the result is not empty then
    		answer the result
		end if #the result is not empty
		pass mouseDown
  end if #pWhichButton is 3
end mouseDown



on loadThisLine 
	put "loadThisLine"&cr after msg #debugx
	if there is a file sFilePath then
		put sFilename into oldFilename
      #<remove leading spaces>
      	repeat until char 1 of oldFilename is not space
      		delete char 1 of oldFilename
         end repeat #until char 1 of oldFilename is not space
      #</remove leading spaces>
      put sFilePath into oldFullFilename

      if oldFullFilename contains comma then
      	answer "Cannot render this file at this time because the name contains a comma."
      else #oldFullFilename does not contain comma
      	showPDF oldFullFilename
      end if #oldFullFilename contains comma
      
      select after field "filename"
   else #there is not a file sFilename
   	set the hilitedLine of me to 0
   end if #there is a file sFilename
 end loadThisLine




 on mouseDoubleUp pBtnNumber
   if pBtnNumber is 1 and sFilePath is not empty then launch document sFilePath
 end mouseDoubleUp



 private function _popChoose
  /* Original from Peter Brigham
  Reworked by Mikey
  Creates a popup menu with the choices listed in the first parameter (i.e. no need to create an invisible one)

  popChoose() can accept a cr-delimited list of choices.
  or a space-comma-space delimited list or a comma-delimited list
  e.g. put popChoose(choice1 & cr & choice2 & cr & choice3) into userChoice
  or: put popChoose(choice1,choice2,choice3) into userChoice
  or: put popChoose("Vera","Chuck","Dave") into userChoice
  or: put popChoose("Open,Close,Save,-,Quit") into userChoice
  or: put popChoose("Open , Close , Save , - , Quit") into userChoice
  */

  #<parse the list>
  	put the params into tList
  	put offset("(",tList) into q
  	delete char 1 to q of tList
  	delete char -1 of tList
  	replace comma & space & quote with comma & quote in tList
  	replace quote & comma & quote with cr in tList
  	replace space & comma & space with cr in tList
  	replace comma with cr in tList

  	if char 1 of tList = quote then delete char 1 of tList
  	if char -1 of tList = quote then delete char -1 of tList
  #</parse the list>


   #<create button on the fly>
   	put empty into tButtonName
    repeat until tButtonName is not empty and there is not a button tButtonName # keep creating UUID's until we get one that doesn't exist for a button
    	put uuid("random") into tButtonName
    end repeat #until buttonName is not empty and there is not a button buttonName
    lock screen
    create invisible button tButtonName
    set the style of button tButtonName to "Menu"
    set the menuMode of button tButtonName to "Popup"
    put tList into btn tButtonName 
    set the menuPick of btn tButtonName to empty #This is the only way to get a pick or no pick - with a script...
    set the script of btn tButtonName to "on menuPick what ; set the menuPick of me to what ; end menuPick" # No other way to determine if the user made a pick or not
    popup btn tButtonName 
  #</create button on the fly>

  put the menuPick of btn tButtonName into tMenuPick
  if tMenuPick is empty then exit to top
  delete button tButtonName
  return tMenuPick
end _popChoose



private command _moveToTrash pFile
	#from Ken Ray
	-- Assumes pFile is full file path
	if there is not a file pFile then return "Error: File '" & pFile & "' does not exist." for error

	switch (the platform)
	case "MacOS"
		put "tell app `Finder`" & cr & \
		"move POSIX file `" & pFile & "` to trash" & cr & \
		"end tell" into tScript
		replace "`" with quote in tScript
		loggerlogmsg "Move" & tab & pFile & tab & "to" & tab & "Trash"
		do tScript as "AppleScript"
		if the result is "execution error" then return "Error: Could not move file '" & pFile & "' to the Trash." for error
		break
	case "Win32"
		replace "/" with "\" in pFile
		put "Const RECYCLE_BIN = &Ha&" & cr & \
		"Set objShell = CreateObject(`Shell.Application`)" & cr & \
		"Set recycleFolder = objShell.NameSpace(RECYCLE_BIN)" & cr & \
		"recycleFolder.MoveHere `" & pFile & "`" into tScript
		replace "`" with quote in tScript
		loggerlogmsg "Move" & tab & pFile & tab & "to" & tab & "Recycle"
		do tScript as "VBScript"
		-- VBS doesn't return any error codes for this action, so need to
		-- check file existence and return an error if necessary
		if there is a file pFile then
			return "Error: Could not move file '" & pFile & "' to the Recycle Bin." for error
		end if
		break
	end switch
	wait 1 milliseconds with messages #otherwise won't redraw
	set the dvRootFolder of me to the dvRootFolder of me #force redraw #_displayFolderInDataView (the dvRootFolder of me)

  selectNextRow
  return empty
end _moveToTrash



private command _duplicateFile pFilePath
  #<build new filename>
    #<break the new filename apart so we can check for uniqueness>
    	put char 1 to -5 of pFilePath into tNewFilenameWithoutExtension
    	put char -3 to -1 of pFilePath into tExtension
    	put 1 into tCopyCounter
    	put space & "- copy" && tCopyCounter after tNewFilenameWithoutExtension
      put tNewFilenameWithoutExtension & "." & tExtension into tNewFilename # e.g. /home/me/splat - copy 1.pdf
    #</break the new filename apart so we can check for uniqueness>

    repeat until there is not a file tNewFilename #i.e. find a unique filename so we don't overwrite an existing one
    	add 1 to tCopyCounter 
    	put tCopyCounter into last word of tNewFilenameWithoutExtension
    	put tNewFilenameWithoutExtension & "." & tExtension into tNewFilename
    end repeat #until there is not a file tNewFilename
  #</build new filename>

  put "file:"&pFilePath into tOldURL
  put "file:"&tNewFilename into tNewURL
  loggerlogmsg "Copy" & tab & tOldURL & tab & "to" & tab & tNewURL
  put url tOldURL into url tNewURL
  if the result is not empty then return the result for error
  wait 1 milliseconds with messages #otherwise won't redraw
  set the dvRootFolder of me to the dvRootFolder of me # force redraw

  #<select the row we just copied>
    put findRowNumber(pFilePath) into lineToHilight
    set the dvHilitedRow of me to tLineToHilight
    scrollRowIntoView tLineToHilight, "top"
  #</select the row we just copied>

  return empty
end _duplicateFile



on selectNextRow #select the row that was just below the one that was just hilited
  put findRowNumber(sPathOfFileBelow) into tLineToHilight
  set the dvHilitedRow of me to tLineToHilight
  dispatch "selectedRowChanged" to me with tLineToHilight #workaround for https://github.com/trevordevore/levurehelper-dataview/issues/
  scrollRowIntoView tLineToHilight, "top"
end selectNextRow



function findRowNumber pFullPath
  put the viewProp["Number of Rows"] of me into tMaxRows

  #<walk the list until we find pFullPath or we walk off the end>
    put 1 into tRowNumber
    put 0 into tFoundRowNumber

    repeat until (tFoundRowNumber > 0) or (tRowNumber > tMaxRows)
      put the dvPathOfRow[tRowNumber] of me into tFilePath
      if pFullPath = tFilePath then
        put tRowNumber into tFoundRowNumber
      else # pFullPath is not tFilePath
        add 1 to tRowNumber
      end if #pFullPath = tFilePath then
    end repeat #until tFound or (tRowNumber > tMaxRows)

    return tFoundRowNumber     
  #</walk the list until we find pFullPath or we walk off the end>
end findRowNumber