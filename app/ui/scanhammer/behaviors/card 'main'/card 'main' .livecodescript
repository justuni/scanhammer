script "card 'main'"
on preOpenCard
   global oldFilename, oldFullFilename #original filename
   
   set the url of widget "browser" to empty
   put empty into field "path"
   put empty into field "filename"
   put empty into field "filenames"
   
   put empty into oldFilename
   put empty into oldFullFilename
   
   select line 0 of field "filenames"
end preOpenCard
