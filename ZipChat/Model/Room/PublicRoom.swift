import UIKit
import CoreLocation

class PublicRoom: Room {
    var name: String = ""
    var location: CLLocation = CLLocation()
    
    override var isPublic: Bool {
        return true
    }
    
    override init(dictionary:[String:AnyObject]) {
        super.init(dictionary:dictionary)
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let latitude = dictionary["latitude"] as? Double {
            if let longitude = dictionary["longitude"] as? Double {
                self.location = CLLocation(latitude: latitude, longitude: longitude)
            }
        }
    }
    
    class func getRoomsWithLocation(location: CLLocation, success:((rooms: [PublicRoom])->())?, failure:((error: NSError)->())?) {
        let clientManager = ClientManager.sharedManager
        let requestManager = RequestManager.sharedManager
        
        requestManager.operationManager.GET("test", parameters: ["lat":location.coordinate.latitude, "lon":location.coordinate.longitude], success: { (operation, response) -> Void in
            var rooms = [PublicRoom]()
            for roomData in (response as? [[String:AnyObject]] ?? []) {
                let room = PublicRoom(dictionary: roomData)
                rooms.append(room)
            }
            success?(rooms:rooms)
            return
            }) { (operation, error) -> Void in
                failure?(error: error)
                NSLog(error.localizedDescription)
        }
    }
    
}
