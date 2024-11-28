Config = {}

Config.Debug = false
Config.DefaultLanguage = 'fr' -- 'en' for English, 'fr' for French

Config.Garages = {
    ['weazel'] = {
        label = 'Weazel News Garage',
        job = 'weazel',
        spawnPoint = vec4(-532.8920, -889.1475, 24.8994, 180.1365),
        returnPoint = vec3(-543.1555, -888.4750, 25.1232),
        ped = {
            model = 's_m_m_autoshop_02',
            coords = vec4(-537.0956, -886.4874, 24.2092, 177.9051),
            scenario = 'WORLD_HUMAN_CLIPBOARD' -- Le scénario que le ped va jouer
        },
        vehicles = {
            { 
                model = 'rumpo',
                label = 'Weazel News Van'
            },
            {
                model = 'newsvan',
                label = 'News Mobile Unit'
            }
        }
    },
}
