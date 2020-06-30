script "card 'main'"
global oldFilename, oldFullFilename #original filename
local datePickerVisible
local fileList



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

	send "resetView" to group "File Browser DataView"

	put empty into oldFilename
	put empty into oldFullFilename

	put empty into fileList

	send "mouseUp" to button "docPDF_Close"
	hideDatePicker
end cls



on selectedRowChanged
	#<load the PDF and the filenames>
		put the selectedFilePath of group "File Browser DataView" into thePath
		if there is a file thePath then 
			put the selectedFilePath of group "file browser dataView" into oldFullFilename #don't populate oldFilename, that's done below
			showPDF thePath #could also be a folder
		end if #there is a file thePath
	#</load the pdf and the filenames>

	pass selectedRowChanged
end selectedRowChanged



on loadDefaultPath lineNumber #get the default path, populate the path field, load filenames, and display first file in the directory
	put prefsGetPref("default path") into defaultPath
	put the dvHilitedID of group "file browser dataView" into selectedID
	if defaultPath is not empty then
		updatePath defaultPath
		set the defaultFolder to defaultPath
		if lineNumber is empty then put 1 into lineNumber

		set the expandAllNodes of group "File Browser DataView" to true
		set the allowedExtensions of group "File Browser DataView" to ".pdf,.PDF"
		set the dvRootFolder of group "File Browser DataView" to defaultPath
		dispatch "RenderView" to group "File Browser DataView" #redraw
		set the dvHilitedID of group "file browser dataView" to selectedID
  end if #currentPath is not empty
end loadDefaultPath



on showPDF what
	lock screen
	#debugx set the url of widget "browser" to fileConvertToFileURL(what)
	send "xpdf_show"&&what to group "xpdf"
	getshortFilenameFromLongFilename
	select after field "filename"
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
   if the platform is "MacOS" then replace colon with slash in field "wasFilename" # macos replaces slash with colon in the name and colons are illegal in names
   guessNewFilename
end getShortFilenameFromLongFilename



on arrowKey what
	if what is "left" or what is "right" then pass arrowKey else send "dvArrowKey"&& what to group "File Browser DataView"
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
   if the platform is "MacOS" then replace colon with slash in field "filename" #macos substitutes colon for slash, and colons are illegal
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
