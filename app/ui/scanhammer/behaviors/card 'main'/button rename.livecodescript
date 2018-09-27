script "button 'rename'"
on mouseUp
   global oldFilename, oldFullFilename #old filename
   put field "filename" into newFilename
   if newFilename is not oldFilename then #filename changed
      put the text of line (the hilitedLine of field "filenames" + 1) of field "filenames" into nextFilenameToHilite # hilite the next line in the list after we rename this file
      
      #<rename the file>
      put field "path" into thePath
      put thePath&newFilename&".pdf" into newFullFilename
      rename oldFullFilename to newFullFilename
      #</rename the file>
      
      #<reload list and select the line for the renamed file>
      #debugx lock screen
      loadFileList lineOffest(nextFilenameToHilite,field "filenames")
      #debugx testing loadFileList with line number select line (lineoffset(newFilename,field "filenames")) of field "filenames"
      #debugxsend "forceReload" to field "filenames"
      #</reload list and select the line for the renamed file>
   end if #field "filename" is not theFile
end mouseUp



on arrowKey what
   if what is "up" or what is "down" then pass arrowKey #to card, which will send it to the 'filenames' field
end arrowKey
