script "button 'rename'"
on mouseUp
   global oldFilename, oldFullFilename #old filename
   put field "filename" into newFilename
   if newFilename is not oldFilename then #filename changed
      put the hilitedLine of field "filenames" into currentlySelectedLine
      
      #<rename the file>
      put field "path" into thePath
      put thePath&newFilename&".pdf" into newFullFilename
      rename oldFullFilename to newFullFilename
      #</rename the file>
      
      loadFileList currentlySelectedLine
      send "arrowKey down" to field "filenames" #go down 1 in the list.  This will also check to make sure we don't walk off the list
   end if #field "filename" is not theFile
end mouseUp
