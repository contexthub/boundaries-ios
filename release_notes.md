Geofences Release Notes
---

## 1.2.0 - August 2, 2014
- Add table view with list of geofences currently on ContextHub
- Add ability to update geofence name from list tab
- Add ability to delete geofence from list tab
- Update GFGeofence to make it easier to update a geofence (added name property as CLCircularRegion identifier is read-only)
- Update GFGeofenceStore to use asynchronous blocks if ContextHub calls fail due to network issues
- Update README to discuss geofences CRUD methods more and remove references to vault (vault is now covered in a separate sample app)
- Documented all methods

## 1.1.0 - July 30, 2014
- Update to ContextHub v1.1.3 framework
- Update README
- Add in complete version of CLCircularRegion+ContextHub
- Add ChaiOne.gpx file
- Add synchroniziation when geofence is created/deleted to avoid needing to restart the app
- Added MIT License

## 1.0.0 - July 11, 2014
- Initial release