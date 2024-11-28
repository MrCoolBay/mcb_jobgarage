# MCB Job Garage

A FiveM resource that provides job-specific garages with vehicle spawning and return functionality.

## Features
- Job-specific vehicle access
- Easy configuration for multiple garages and vehicles
- Support for multiple languages (EN/FR)
- Optimized performance
- Uses ox_lib and ox_target

## Dependencies
- ox_lib
- ox_target

## Installation
1. Ensure you have the required dependencies installed
2. Place the resource in your server's resources folder
3. Add `ensure mcb_jobgarage` to your server.cfg
4. Configure the garages in config.lua

## Configuration
You can add new garages in the config.lua file following the existing format:

```lua
Config.Garages = {
    ['job_name'] = {
        label = 'Garage Label',
        job = 'job_name',
        spawnPoint = vec4(x, y, z, heading),
        returnPoint = vec3(x, y, z),
        vehicles = {
            {
                model = 'vehicle_spawn_name',
                label = 'Vehicle Display Name'
            }
        }
    }
}
```
