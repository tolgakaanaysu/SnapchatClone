import Foundation

class UserSingleton {
    
    static let sharedUserInfo = UserSingleton()
    var email =  ""
    var username = ""
    
    private init(){
        
    }
    
}
