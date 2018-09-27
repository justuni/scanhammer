script "card 'main'"
global oldFilename, oldFullFilename #original filename


on preOpenCard   
   cls
end preOpenCard



on cls
   set the url of widget "browser" to empty
   put empty into field "path"
   put empty into field "wasFilename"
   put empty into field "filename"
   put empty into field "filenames"

   put empty into oldFilename
   put empty into oldFullFilename

   select line 0 of field "filenames"
   
   send "mouseUp" to button "docPDF_Close"
end cls



on loadFileList lineNumberToHiliteAndLoad
   put files(field "path") into filenames
   sort lines of filenames
   put 1 into i
   repeat while i<=the number of lines in filenames
      if char -4 to -1 of line i of filenames is not ".pdf" then delete line i of filenames else add 1 to i
   end repeat #while i<=the number of lines in filenames
   put filenames into field "filenames"
   select line lineNumberToHiliteAndLoad of field "filenames"
   send "forceReload" to field "filenames"
end loadFileList



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
   send "arrowKey"&& what to field "filenames"
end arrowKey



on guessNewFilename
   put oldFilename into newFilename

   #<xxx> replace with parsing routine
      # parsing DOC092018-09202018140934
      if char 1 to 3 of newFilename is "DOC" and char 10 of newFilename is "-" then #only parse if it meets the above format, otherwise just put the existing filename in the new filename
         set the itemDelimiter to "-"
         put item 2 of newFilename into newFilename
         put char 1 to 2 of newFilename into month
         put char 3 to 4 of newFilename into day
         put char 5 to 8 of newFilename into year
         put year&"."&month&"."&day&space into newFilename
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
   
   put slash after what
   set the text of field "path" to what
end updatePath



######################################################################################################################
#<xpdf stuff>
on resizeStack
  put the width of me into pNewWidth
  put the height of me into pNewHeight
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
