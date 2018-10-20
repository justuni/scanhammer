script "button 'set default'"
on mouseUp
	prefsSetPref "default path", field "path"
	set the defaultFolder to field "path"
end mouseUp