script "list field 'filenames'"

global oldFilename, oldFullFilename




on mouseUp whichButton
   #<context button delete>
      if whichButton is 3 then 
         put popChoose("Delete" & cr & "-" & cr & "Duplicate") into choice
         if choice is "Delete" then
            answer "Delete"&& quote&oldFilename&quote with "OK" or "Cancel"
            if it is "OK" then 
               put the hilitedLine of me into currentlySelectedLine #so we can select the next one in the list
               moveToTrash oldFullFilename
            end if #it is "OK"
         else if choice is "Duplicate" then
            put "file:"&oldFullFilename into oldFullFilenameURL
            #<make a filename for the copied file>
               put oldFullFilenameURL into newFullFilenameURL
               put " - copy" before char -4 of newFullFilenameURL
            #</make a filename for the copied file>
            put url oldFullFilenameURL into url newFullFilenameURL
         end if #Choice is "Delete"

         if the result is not empty then answer the result #debugx
         loadFileList currentlySelectedLine
      else #not 3
         pass mouseUp
      end if #whichButton is 3
   #</context button delete>
end mouseUp



on mouseDown whichButton
   if me is empty or whichButton is 3 then exit mouseDown
   select the clickline
   loadThisLine
end mouseDown



on loadThisLine 
   put the hilitedLine of me into lineNumber
   put line lineNumber of the fullPaths of me into maybeFullFilename
   if there is a file maybeFullFilename then
      put line lineNumber of me into oldFilename
      #<remove leading spaces>
         repeat until char 1 of oldFilename is not space
            delete char 1 of oldFilename
         end repeat #until char 1 of oldFilename is not space
      #</remove leading spaces>
      put maybeFullFilename into oldFullFilename

      showPDF oldFullFilename
      click at the loc of field "filename"
   else #there is not a file maybefullfilename
      answer "Uh oh.  I can't find"&&maybeFullFilename
   end if #there is a file maybeFullFilename
end loadThisLine



on arrowKey what
   put the hilitedLine of me into currentlySelectedLine
   if what is "left" or what is "up" then # #up moves in negative direction, down in positive
   	subtract 1 from currentlySelectedLine 
   else #what is "down" or what is "right"
   	add 1 to currentlySelectedLine
   end if #what is "up"

   #<funky math>
      # "CSL" is "currentlySelectedLine"
      # calculate (from inside out) max(1,csl).  That way if CSL is <1 then we get 1.
      # Then calculate min (size of list, calculation above).  That way if we're past the end, we return the end.
      # combining the two of those gives a value that is between 1..size of list
      put min (the number of lines in me, max (1,currentlySelectedLine)) into currentlySelectedLine
      set the hilitedLine of me to currentlySelectedLine
   #</funky math>
   
   loadThisLine
end arrowKey



function popChoose
   # from Peter Brigham...
   -- paste the "contextualMenu" button into your mainstack or a library stack
   --    make it invisible when you're done, if you want
   -- enter the short name of the stack containing the button
   --    into the constant declaration below
   
   -- popChoose() can accept a cr-delimited list of choices
   -- or a comma-delimited list
   -- eg: put choice1 & cr & choice2 & cr & choice3 into choiceList
   --     put popChoose(choiceList) into userChoice
   -- or: put popChoose(choice1,choice2,choice3) into userChoice
   -- or: put popChoose("Vera","Chuck","Dave") into userChoice
   
   #constant pStackName = "stackContainingContextualMenuButton"
   
   put the params into tList
   put offset("(",tList) into q
   delete char 1 to q of tList
   delete char -1 of tList
   replace comma & space & quote with comma & quote in tList
   replace quote & comma & quote with cr in tList
   if char 1 of tList = quote then delete char 1 of tList
   if char -1 of tList = quote then delete char -1 of tList
   put empty into u
   set the uSelection of btn "contextualMenu" to empty 
   put tList into btn "contextualMenu" 
   popup btn "contextualMenu" 
   put the uSelection of btn "contextualMenu" into u
   set the uSelection of btn "contextualMenu" to empty
   put empty into btn "contextualMenu" 
   -- belt and suspenders, don't leave contents hanging around
   select empty
   if u = empty then
      exit to top
      -- equivalent of mouseRelease, no action
   end if
   return u
end popChoose



on MoveToTrash pFile
   #from Ken Ray
   -- Assumes pFile is full file path
   if there is not a file pFile then
      return "Error: File '" & pFile & "' does not exist." for error
   end if

   switch (the platform)
   case "MacOS"
      put "tell app `Finder`" & cr & \
      "move POSIX file `" & pFile & "` to trash" & cr & \
      "end tell" into tScript
      replace "`" with quote in tScript
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
      do tScript as "VBScript"
      -- VBS doesn't return any error codes for this action, so need to
      -- check file existence and return an error if necessary
      if there is a file pFile then
         return "Error: Could not move file '" & pFile & "' to the Recycle Bin." for error
      end if
      break
   end switch
   return empty
end MoveToTrash
