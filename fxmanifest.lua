fx_version 'cerulean'
game 'gta5'

author 'Dei'
description 'Simple hud :)'
version '1.1'
lua54 'yes'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/*.lua'
}

ui_page {
    'html/index.html',
}

files {
    'html/index.html',
    'html/assets/js/app.js',
    'html/assets/img/*.png',
    'html/assets/css/styles.css',
    'html/assets/fonts/*.otf',
}
