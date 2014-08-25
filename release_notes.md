# Boundaries (Geofences) Release Notes

## 1.3.3 (Build 173) - August 25, 2014
- Remove BDYListTableViewController dependency on BDYMapViewController

## 1.3.2 (Build 172) - August 17, 2014
- Update to ContextHub v1.2.0 framework
- Add Table of Contents to README

## 1.3.1 (Build 171) - August 11, 2014
- Fix bug where app would alert an error when updating or deleting geofences
- Sort geofences in list by name
- Updated README

## 1.3.0 (Build 164) - August 5, 2014
- Rewrite sample app to more directly show how to use the SDK (previous version still available in separate branch)
- Add verbose logging from ContextHub responses
- Updated README

## 1.2.0 (Build 145) - August 2, 2014
- Add List tab which shows geofences currently on ContextHub with tag "geofence-tag"
- Add ability to update geofence name from List tab
- Add ability to delete geofence from List tab
- Add About tab
- Update GFGeofence to make it easier to update a geofence (added name property as CLCircularRegion identifier is read-only)
- Update GFGeofenceStore to use asynchronous blocks if ContextHub calls fail due to network issues
- Update README to discuss geofences CRUD methods more and remove references to vault (vault is now covered in a separate sample app)
- Further documented all methods

## 1.1.0 (Build 98) - July 30, 2014
- Update to ContextHub v1.1.3 framework
- Update README
- Add in complete version of CLCircularRegion+ContextHub
- Add ChaiOne.gpx file
- Add synchroniziation when geofence is created/deleted to avoid needing to restart the app
- Added MIT License

## 1.0.0 - July 11, 2014
- Initial release