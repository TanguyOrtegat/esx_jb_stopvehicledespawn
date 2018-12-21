# esx_jb_stopvehicledespawn

this script does work, but has got some fps issues. need to optimise or make it better. 

I was inspired by 

- https://github.com/itsJarrett/FiveM-boot_vehicles

- https://github.com/Chocoleight/StopDespawn/tree/master/builds

- https://forum.fivem.net/t/trying-to-understand-how-network-works-for-entities/20587


this is what you need to put in you garage script when player puts a car in his garage:

```
networkid = NetworkGetNetworkIdFromEntity(vehicle)
TriggerServerEvent('vehicleenteredingarage', networkid)
```

was made by Jager Bom. All rights go to him. If you reupload please keep the readme like this to mentions all peaple i was inspired by
