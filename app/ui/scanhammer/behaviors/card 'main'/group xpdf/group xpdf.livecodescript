script "group xpdf"
on xpdf_show theFile
   /* debug
   Getting page scrolling, maybe as the thumbnails are being created, before the first page appears.  That could be a problem for large files
   */
   #lock screen #debugy
   XPDFViewer_Set "pdfViewer","visible",false
   XPDFViewer_Open "pdfViewer",the windowID of this stack
   XPDFViewer_Set "pdfViewer","rect",the rect of grc "pdfViewArea" of group "pdfViewer"
   XPDFViewer_Set "pdfViewer","filename",theFile 
   XPDFViewer_Set "pdfViewer","visible",true #debugy
   call "pdfUpdatePageDisplay" of grp "pdfViewer"
   call "pdfUpdateZoomDisplay" of grp "pdfViewer"
   call "GenerateThumbnails" of grp "pdfViewer"
   #XPDFViewer_Set "pdfViewer","visible",true #debugy
   #unlock screen #debugy
end xpdf_show
