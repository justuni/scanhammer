script "card 'main'"
global oldFilename, oldFullFilename #original filename
local datePickerVisible
local fileList


constant expandIcon = 200086 # boxed +
constant collapseIcon = 200087 # boxed -


on preOpenCard
	cls
end preOpenCard



on openCard
	loadDefaultPath
end openCard



on cls
	set the url of widget "browser" to empty
	put empty into field "path"
	put empty into field "wasFilename"
	put empty into field "filename"
	put empty into field "filenames"

	put empty into oldFilename
	put empty into oldFullFilename

	put empty into fileList
	set the fullPaths of field "filenames" to empty

	select line 0 of field "filenames"

	send "mouseUp" to button "docPDF_Close"
	hideDatePicker
end cls



on loadDefaultPath lineNumber #get the default path, populate the path field, load filenames, and display first file in the directory
	put prefsGetPref("default path") into defaultPath
	if defaultPath is not empty then
		updatePath defaultPath
		set the defaultFolder to defaultPath
		if lineNumber is empty then put 1 into lineNumber
		loadFileList lineNumber
  end if #currentPath is not empty
end loadDefaultPath



on loadFileList lineNumberToHiliteAndLoad
	lock screen
	put field "path" into baseDirectory
	if baseDirectory ends with slash then delete last char of baseDirectory
	put empty into fileList
	set the fullPaths of field "filenames" to empty
	directoryWalk baseDirectory, "pdf"
	set the text of field "filenames" to fileList # do this now b/c also have to set the imageSource for folder lines
	put fileList into fullFilePaths # going to be the full paths that correspond to the indented/shortened filenames going into the list.
	#<modify the list for presentation in the field>
		#<remove base directory prefix from each line>
			put length(baseDirectory)+1 into charsToNuke #above we remove the trailing slash before directoryWalk, but we want to remove it here
			repeat with i = 1 to the number of lines in field "filenames"
				delete char 1 to charsToNuke of line i of field "filenames"
			end repeat #with i = 1 to the number of lines in fileList
		#<remove base directory prefix from each line>

		#<visually offset directories>
			put 1 into i
			put empty into parentDirectory #i.e. under the base directory
			put 0 into levelsIn # number of directory levels down from base
			put 2 into indentChars # 2* (indentLevel+1)
			set the itemDelimiter to slash
			repeat until i > the number of lines in field "filenames"
				if line i of field "filenames" contains parentDirectory or parentDirectory is empty then # this file is inside of parentDirectory (or base directory), i.e. we're not out of files in parentDirectory
					delete item 1 to levelsIn of line i of field "filenames" #remove the parentDirectory path
					#<file is either in the current subdirectory or the first file in a deeper subdirectory>
						if line i of field "filenames" contains slash then #first file of a deeper subdirectory
							put cr & line i of field "filenames" after line i of field "filenames" # make a copy of the line on the next line.  This line is going to be the next indented directory name
							put cr before line i of fullFilePaths # moving the next filename down a line to make way for a directory display
							put item 1 of line i of field "filenames" after parentDirectory # new parent directory
							delete item 2 to -1 of line i of field "filenames" # remove everything but the directory name from this line.  This will auto-delete the trailing slash.
							put makeString(space, indentChars) before line i of field "filenames" # 2 space indent for each directory level
							set the imageSource of char (indentChars-1) of line i of field "filenames" to collapseIcon # minus sign with a box
							add 1 to levelsIn
							add 2 to indentChars
						else # doesn't contain slash, not a subdirectory
							put makeString(space, indentChars) before line i of field "filenames" # 2 space indent for each directory level
						end if #line i of field "filenames" contains slash 
					#</file is either in the current subdirectory or the first file in a deeper subdirectory>
					add 1 to i
				else if levelsIn >0 then # file is a level up from parentDirectory
					subtract 1 from levelsIn
					subtract 2 from indentChars
					delete last item of parentDirectory
					#don't add 1 to i, i.e. not finished with this line.  Have to go up a level and try again.
				end if #line i of levels in contains parentDirectory
			end repeat #ntil i > the number of lines in field "filenames"
		#</visually offset directories>
	#</modify the list for presentation in the field>
	set the fullPaths of field "filenames" to fullFilePaths
	#was put pdfsInDirectory() into field "filenames"
	select line lineNumberToHiliteAndLoad of field "filenames"
	send "loadThisLine" to field "filenames"
end loadFileList



private command directoryWalk whatFolder, filterFor
	#builds the list of all files in the directory with full paths, puts into fileList
	set the directory to whatFolder
	put the files into theFiles
	sort theFiles
	repeat for each line theFile in theFiles
		if theFile begins with "." then next repeat
      #<filter>
      	if filterFor is not empty then
				set the itemDelimiter to "."
				put the last item of theFile into theSuffix
				set the itemDelimiter to comma
      		if theSuffix is not among the items of filterFor then next repeat
         end if #filterFor is not empty
      #</filter>
      put whatFolder & slash & theFile & cr after fileList
   end repeat #for each line x in theFiles
   put the folders into theFolders
   sort theFolders
   repeat for each line theFolder in theFolders
   	if theFolder is "." or theFolder is ".." then next repeat
   	directoryWalk (whatFolder & slash & theFolder), filterFor
   end repeat #for each line x in theFolders
end directoryWalk




function pdfsInDirectory #used by some XPDF code.  Will leave for now, even though I'm not using it for anything.  Note that this does not dive into subfolders.
	put files(field "path") into filenames
	sort lines of filenames
	put 1 into i
	repeat while i<=the number of lines in filenames
		if char -4 to -1 of line i of filenames is not ".pdf" then delete line i of filenames else add 1 to i
   end repeat #while i<=the number of lines in filenames
   return filenames
end pdfsInDirectory



on showPDF what
	lock screen
	set the url of widget "browser" to fileConvertToFileURL(what)
	send "xpdf_show"&&what to group "xpdf"
	getshortFilenameFromLongFilename
	click at the loc of field "filename"
	unlock screen
end showPDF



on getShortFilenameFromLongFilename
	#populates oldFilename (short filename) from oldFullFilename (includes the path)
	put oldFullFilename into oldFilename
   delete char -4 to -1 of oldFilename #".PDF"
   set the itemDelimiter to "/"
   put oldFilename into thePath
   delete last item of thePath
   delete item 1 to -2 of oldFilename
   put thePath&slash into field "path"
   put oldFilename into field "wasFilename"
   guessNewFilename
end getShortFilenameFromLongFilename



on arrowKey what
	if what is "left" or what is "right" then pass arrowKey else send "arrowKey"&& what to field "filenames"
end arrowKey



on commandKeyDown whatKey
	if whatKey is in"+=" then # shift key down or not
		send "mouseUp" to button "biggerText"
	else if whatKey is in"-_"  then #shift key down or not
		send "mouseUp" to button "smallerText"
	else if whatKey is in "Dd" then #date
		toggleDatePicker
	else #some other key
		pass commandKeyDown
	end if #whatKey is "+"
end commandKeyDown



on guessNewFilename
	if oldFilename is empty then exit guessNewFilename
	put oldFilename into newFilename

   #<xxx> replace with parsing routine
      # parsing DOC092018-09202018140934 or DOC092018-09202018140934/PAGE0001
      if (char 1 to 3 of newFilename is "DOC") and (char 4 to 9 of newFilename is a number) and (char 10 of newFilename is "-") and (char 11 to -1 of newFilename is a number) then #only parse if it meets the above format, otherwise just put the existing filename in the new filename
      	set the itemDelimiter to "-"
      	put item 2 of newFilename into newFilename
      	put char 1 to 2 of newFilename into month
      	put char 3 to 4 of newFilename into day
      	put char 5 to 8 of newFilename into year
      	put year&"."&month&"."&day&space into newFilename
      else if (char 1 to 4 of newFilename is "Page") and (char -4 to -1 of newFilename is a number) then #PAGE0001
      	set the itemDelimiter to slash
      	put item -2 of oldFullFilename into oldFilename # use the parent directory, which hopefully has the timestamp
      	guessNewFilename # guess again using the parent folder which should be the timestamp
	      exit guessNewFilename #only sort-of recursive.  Only after a success do we continue, which we will have via the other passes.
      end if #char 1 to 3 of newFilename is "DOC" and char 10 of newFilename is "-"
   #</xxx>

   put newFilename into field "filename"
   focus on field "filename"
end guessNewFilename



on updatePath what
   # takes either a folder or a file and crunches the path
   if char -4 to -1 of what is ".pdf" then # case-insensitive, so ".PDF" works, too - "what" is a filename
   	set the itemDelimiter to slash
   	delete last item of what
   end if #char -4 to -1 of what is ".pdf"
   
   if last char of what is not slash then put slash after what
   set the text of field "path" to what
end updatePath



######################################################################################################################
#<date picker>
	on showDatePicker
		put true into datePickerVisible
	end showDatePicker



	on hideDatePicker
		put false into datePickerVisible
	end hideDatePicker



	on toggleDatePicker
		if datePickerVisible then
			hideDatePicker
		else # not visible
			showDatePicker
		end if #datePickerVisible
	end toggleDatePicker
#</date picker>
######################################################################################################################



function makeString pChar, n
	if n is 0 then return empty
	set the linedel to pChar
	put pChar into line n of temp
	return temp
end makeString



######################################################################################################################
#<xpdf stuff>
	on resizeStack
		put the width of group "xpdf" into pNewWidth
		put the height of group "xpdf" into pNewHeight
		put the pdfThumbnails of control "pdfViewer" into tShowThumbnails
		put the pdfBookmarks of control "pdfViewer" into tShowBookmarks
		if tShowThumbNails OR tShowBookmarks then
			set the rect of grp "bookmarks" to (15,40,(15+width of grp "thumbnails"),(pNewHeight-10))
			set the rect of grp "thumbnails" to (15,40,(15+width of grp "thumbnails"),(pNewHeight-10))
			set the rect of grp "pdfViewer" to ((15+width of grp "thumbnails"),40,pNewWidth-10,pNewHeight-10)
			if tShowThumbNails then
				show grp "thumbnails"
				hide grp "bookmarks"
			end if
			if tShowBookmarks then
				show grp "bookmarks"
				hide grp "thumbnails"
			end if
		else
			hide grp "bookmarks"
			hide grp "thumbnails"
			set the rect of grp "pdfViewer" to (15,40,pNewWidth-10,pNewHeight-10)
		end if
	end resizeStack



	on XPDF_SelectionChanged pSelectionRange -- startPage,startChar,endPage,endChar
	  -- pSelectionRange is empty if no selection
	  -- insertion point has pages equal and endChar 1 less that startChar
	  if (item 1 of pSelectionRange = item 3 of pSelectionRange) AND \
	  item 2 of pSelectionRange > item 4 of pSelectionRange then
	    put empty into pSelectionRange -- insertion point
	 end if
	 set the pdfCurrentSelection of control "pdfViewer" to pSelectionRange
	end XPDF_SelectionChanged



	on XPDF_ImageSelectionChanged pSelectionRange -- page,left,top,right,bottom
	  -- pSelectionRange is empty if no selection
	  set the pdfCurrentSelection of control "pdfViewer" to pSelectionRange
	end XPDF_ImageSelectionChanged
#</xpdf stuff>
#######################################################################################################################
