script "button 'rename'"
on mouseUp
   global oldFilename, oldFullFilename #old filename
   put field "filename" into newFilename
   if the platform is "MacOS" then replace slash with colon in newFilename #macos substitutes colon for slash, but colons are illegal
   if newFilename is not oldFilename then #filename changed   	
      #<rename the file>
         put field "path" into thePath
         put thePath&newFilename&".pdf" into newFullFilename
         if there is a file newFullFilename then #file already exists
            answer "File already exists."
            exit mouseUp
         end if #there is a file newFullFilename
         loggerlogmsg "Rename"& tab & oldFullFilename& tab &"to"& tab &newFullFilename # make it easier to parse log later if we add extra columns for the operations, maybe?
         rename oldFullFilename to newFullFilename
         put the result into theResult
         if theResult is not empty then
            put the result into theResult
            loggerlogmsg "Error:"&&theResult
            answer theResult
         end if #theResult is not empty
      #</rename the file>
      
      loadDefaultPath

      dispatch "selectNextRow" to group "file browser dataView"
   end if #field "filename" is not theFile
end mouseUp
