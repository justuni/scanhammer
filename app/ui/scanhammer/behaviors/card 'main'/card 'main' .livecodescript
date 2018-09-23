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
end cls


on loadFile what
   set the url of widget "browser" to fileConvertToFileURL(what)
   getshortFilenameFromLongFilename
end loadFile



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
   click at the loc of field "filename"
end guessNewFilename
