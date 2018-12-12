script "button 'rename'"
on mouseUp
   global oldFilename, oldFullFilename #old filename
   put field "filename" into newFilename
   if the platform is "MacOS" then replace slash with colon in newFilename #macos substitutes colon for slash, but colons are illegal
   if newFilename is not oldFilename then #filename changed
   	put the hilitedLine of field "filenames" into currentlySelectedLine
   	
      #<rename the file>
         put field "path" into thePath
         put thePath&newFilename&".pdf" into newFullFilename
         loggerlogmsg "Rename"&&oldFullFilename&&"to"&&newFullFilename
         rename oldFullFilename to newFullFilename
         put the result into theResult
         if theResult is not empty then
            put the result into theResult
            loggerlogmsg "Error:"&&theResult
            answer theResult
         end if #theResult is not empty
      #</rename the file>
      
      loadDefaultPath currentlySelectedLine
      send "arrowKey down" to field "filenames" #go down 1 in the list.  This will also check to make sure we don't walk off the list
   end if #field "filename" is not theFile
end mouseUp
