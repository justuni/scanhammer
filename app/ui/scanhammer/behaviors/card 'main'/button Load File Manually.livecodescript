script "button 'Load File Manually'"
on mouseUp
   global oldFilename, oldFullFilename #original filename
   #<get the file>
   local tFile
   answer file "Please choose the file you would like to display" with type "PDF document|pdf|PDF"
   if it is empty then exit mouseUp
   put it into oldFullFilename #for modifying the name
   #</get the file>
   
   
   #<display the pdf>
   put it into tFile #for url instead of for modifying
   replace " " with "%20" in filenameForURL
   set the url of widget "browser" to tFile
   #</display the pdf>
   
   
   #<split the oldFullFilename into a path and filename>
   put oldFullFilename into oldFilename
   delete char -4 to -1 of oldFilename #".PDF"
   set the itemDelimiter to "/"
   put oldFilename into thePath
   delete last item of thePath
   delete item 1 to -2 of oldFilename
   put thePath&slash into field "path"
   put oldFilename into field "filename"
   #</split the oldFullFilename into a path and filename>
end mouseUp
