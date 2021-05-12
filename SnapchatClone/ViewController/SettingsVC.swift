import UIKit
import Firebase
class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signOutButtonClicked(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toSignInVC", sender: nil)

        } catch  {
            let alert = SignInVC()
            alert.makeAlert(title: "Error", message: "Sign Out unsuccessful")
        }
    }
}
