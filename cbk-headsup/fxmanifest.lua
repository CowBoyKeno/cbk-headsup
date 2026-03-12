fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'cbk-headsup'
author 'CowBoyKeno / FiveM Script God'
description 'Standalone secure premium RP chat bubble system'
version '1.0.1'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/server.lua'
}