script "stack 'scanhammer'"



/**
* From Trevor
* Converts a LiveCode filename to a file url.
* pFilename The filename to convert.
* Each item of the filename will be escaped and "file://" will be prefixed.
* return File url.
*/
function fileConvertToFileURL pFilename
	local theItem, i

	set the itemDelimiter to "/"

	repeat with i = 1 to the number of items of pFilename
		put item i of pFilename into theItem
      if i is 1 AND theItem contains ":" then next repeat # skip C:/

      put URLEncode(theItem) into theItem
      replace "+" with "%20" in theItem
      replace "*" with "%2A" in theItem
      put theItem into item i of pFilename
   end repeat

   # [case 1] Windows C:/ paths need to start with a "//"
   # [case 2] If path starts with "//" then it is a network path. Add
   # an extra "/" so that domain is considered localhost.
   if char 1 of pFilename is not "/" then
   	put "/" before pFilename
   else if pFilename begins with "//" then
   	delete char 1 to 2 of pFilename
   end if

   return "file://" & pFilename
end fileConvertToFileURL
