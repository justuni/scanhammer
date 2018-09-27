script "group xpdf"
on xpdf_show theFile
   XPDFViewer_Open "pdfViewer",the windowID of this stack
   XPDFViewer_Set "pdfViewer","rect",the rect of grc "pdfViewArea" of group "pdfViewer"
   XPDFViewer_Set "pdfViewer","filename",theFile 
   XPDFViewer_Set "pdfViewer","visible",true
   call "pdfUpdatePageDisplay" of grp "pdfViewer"
   call "pdfUpdateZoomDisplay" of grp "pdfViewer"
   call "GenerateThumbnails" of grp "pdfViewer"
end xpdf_show
