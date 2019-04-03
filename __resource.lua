resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX script for stopping vehicle despawn and saving vehicles on their last locations made by Jager Bom'

version '1.0.0'

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/esx_jb_stopvehicledespawn_cl.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/esx_jb_stopvehicledespawn_sv.lua',
	'server/savevehicles.lua',
}
