script "button 'rename'"
on mouseUp
   global oldFilename, oldFullFilename #old filename
   put field "filename" into newFilename
   if newFilename is not oldFilename then #filename changed
      put field "path" into thePath
      put thePath&newFilename&".pdf" into newFullFilename
      rename oldFullFilename to newFullFilename
      breakpoint #debugx

      #CODE BELOW SHOULD GO AWAY.  CALL OTHER CODE TO LOAD AFTER RELOADING THE LIST, THEN SELECT THE LINE THAT WAS THIS FILE
      put newfilename into oldFilename
      put newFullFilename into oldFullFilename
      
      put newFullFilename into tFile
      replace " " with "%20" in tFile
      set the url of widget "browser" to tFile
      
   end if #field "filename" is not theFile
end mouseUp
