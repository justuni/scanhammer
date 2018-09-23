script "button 'rename'"
on mouseUp
   global oldFilename, oldFullFilename #old filename
   put field "filename" into newFilename
   if newFilename is not oldFilename then #filename changed
      put field "path" into thePath
      put thePath&newFilename&".pdf" into newFullFilename
      rename oldFullFilename to newFullFilename
      #<reload list and select the line for the renamed file>
         lock screen
         send "mouseUp" to button "Load File List"
         select line (lineoffset(newFilename,field "filenames")) of field "filenames"
         send "forceReload" to field "filenames"
      #</reload list and select the line for the renamed file>
   end if #field "filename" is not theFile
end mouseUp
