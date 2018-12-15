dirfolder = "SavedVehicles/"
filename = "vehicles.json"


Citizen.CreateThread( function()
    Citizen.Wait( 1000 ) -- just to reduce clutter in the console on startup 

    local exists = DoesPathExist( dirfolder )

    if ( not exists ) then 
        print( "SavedVehicles folder not found, attempting to create." )

        os.execute( "mkdir SavedVehicles" )
    else
        print( "SavedVehicles folder found!" )
    end 
	if ( DoesFileExist( filename ) )then
		print( "file".. filename .. " found!")
	else
		print( "Creating " .. filename .. " file")
		CreateFile( filename )
	end
end )

function DoesPathExist( path )
    if ( type( path ) ~= "string" ) then return false end 

    local response = os.execute( "cd " .. path )
    
    if ( response == true ) then
        return true
    end

    return false
end 

function DoesFileExist( name )
    local dir = dirfolder .. name
    local file = io.open( dir, "r" )

    if ( file ~= nil ) then 
        io.close( file )
        return true 
    else 
        return false 
    end 
end 

function CreateFile( name )

    local dir = dirfolder .. name
    local file, err = io.open( dir, 'w' )
    if ( not file ) then print( err ) end
    file:write( "{}" ) 
    file:close()
end 

function LoadVehiclesFile()
    local dir = dirfolder .. filename 
    local file, err = io.open( dir, 'rb' )

    if ( not file ) then print( err ) return nil end 

    local contents = file:read( "*all" )
    contents = json.decode( contents )

    file:close()

    return contents 
end 

function saveVehicleToFile(id, model, x, y, z, heading, vehicleProps)
	local dir = dirfolder .. filename
	
	local vehiclestable = LoadVehiclesFile() 
	local id = tostring(id)
	vehiclestable[id] = {model=model, x=x, y=y, z=z, heading=heading, vehicleProps=vehicleProps}
	local fileString = json.encode( vehiclestable )
	local file, err = io.open( dir, 'w+' )

	if ( not file ) then print( err ) return end 
	
	file:write( fileString )
	file:close()
end

function deleteVehicleId(oldid)
	local dir = dirfolder .. filename
	
	local vehiclestable = LoadVehiclesFile() 
	local oldid = tostring(oldid)
	
	vehiclestable[oldid] = nil
	local fileString = json.encode( vehiclestable )
	local file, err = io.open( dir, 'w+' )

	if ( not file ) then print( err ) return end 
	
	file:write( fileString )
	file:close()
end


function dump(o, nb)
  if nb == nil then
    nb = 0
  end
   if type(o) == 'table' then
      local s = ''
      for i = 1, nb + 1, 1 do
        s = s .. "    "
      end
      s = '{\n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
          for i = 1, nb, 1 do
            s = s .. "    "
          end
         s = s .. '['..k..'] = ' .. dump(v, nb + 1) .. ',\n'
      end
      for i = 1, nb, 1 do
        s = s .. "    "
      end
      return s .. '}'
   else
      return tostring(o)
   end
end