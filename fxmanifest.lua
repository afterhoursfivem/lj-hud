fx_version 'cerulean'
games { 'gta5' }

description 'lj-hud'
version '1.0.0'

client_scripts {
	"config.lua",
	"client/*.lua",
}

server_scripts {
	"config.lua",
	"server/*.lua",
}

ui_page {
	'html/ui.html',	
}

files {
	'html/ui.html',
	'html/*.html',
	"html/img/*.svg",
	'html/js/*.js',
	'html/css/*.css',
	'html/css/*.otf',
}