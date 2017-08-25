# DSLocationManager-IOS

Uses

        DSLocationManager.shared.updatedLocationCloser = { location in
            print(location)
        }
        
        DSLocationManager.shared.failureCloser = {  error in
            print(error.localizedDescription)
        }
