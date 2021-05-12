import UIKit
import Firebase
class SignInVC: UIViewController {
    @IBOutlet weak var eMailText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func singInButtonClicked(_ sender: Any) {
        if eMailText.text == "" && passwordText.text == "" {
            makeAlert(title: "Error", message: "Email and password not empty")
            
        }else {
           
            Auth.auth().signIn(withEmail: eMailText.text!, password: passwordText.text!) { [self] (auth, error) in
                if error != nil {
                    makeAlert(title: "Error", message: error!.localizedDescription)
                }else {
                    performSegue(withIdentifier: "toHomeVC", sender: nil)
                    
                }
            }
        }
    }
    
    @IBAction func singUpButtonClicked(_ sender: Any) {
        if eMailText.text == "" && usernameText.text == "" && passwordText.text == "" {
            makeAlert(title: "Error", message: "Email, username and password not empty")

        }else {
            Auth.auth().createUser(withEmail: eMailText.text!, password: passwordText.text!) { [self] (auth, error) in
                if error != nil {
                    self.makeAlert(title: "Error", message: error!.localizedDescription)
                }else {
                    self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                    let firestore = Firestore.firestore()
                    
                    let userDictionary = ["email": eMailText.text!, "username": usernameText.text!] as [String:Any]
                    
                    firestore.collection("UserInfo").addDocument(data: userDictionary) { (error) in
                        if error != nil {
                            makeAlert(title: "Error", message: error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

