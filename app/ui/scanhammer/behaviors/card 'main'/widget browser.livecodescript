script "widget 'browser'"
# <NONE OF THESE WORK YET IN LC 9.0.1.  BUG REPORTS FILED>
	on browserDocumentLoadFailed purl, perror
		if perror is "plug-in handled load" then 
		   focus on nothing
		else #error is something else
			put pError&CR&pURL into theError
			set the clipboardData to theError
		   answer "The following error was also copied to the clipboard:"&CR&theError
		end if #perror is "plug-in handled load"
	end browserDocumentLoadFailed


	on browserDocumentLoadComplete
	   focus on nothing #want arrows to go to the file list, and intercepting arrowKey in here doesn't seem to do it...yet
	end browserDocumentLoadComplete



	on browserFrameDocumentLoadComplete
	   focus on nothing
	end browserFrameDocumentLoadComplete



	on arrowKey
		pass arrowKey
	end arrowKey
# </NONE OF THESE WORK YET IN LC 9.0.1.  BUG REPORTS FILED>