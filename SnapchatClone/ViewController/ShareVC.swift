import UIKit
import Firebase
class ShareVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
     
    }
    
    @objc func chooseImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        shareButton.isEnabled = false
     
        //Storage
        
        let storage = Storage.storage()
        let storageRefereance = storage.reference()
        let mediaFolder = storageRefereance.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpeg")
        
            imageReference.putData(data, metadata: nil) { (metadata, error) in
              
                if error != nil {
                   
                    SignInVC().makeAlert(title: "Error", message: error!.localizedDescription)
                    
                }else {
                    imageReference.downloadURL { (url, error1) in
                    
                        if error1 != nil {
                            print(error1!)
                            
                            SignInVC().makeAlert(title: "Error", message: error1!.localizedDescription)
                        
                        } else {
                            let imageUrl = url?.absoluteString
                           
                            //Firestore
                             
                            let firestore = Firestore.firestore()
                            
                            
                            firestore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { (snapshot, error4) in
                                if error4 != nil {
                                    SignInVC().makeAlert(title: "Error", message: error4!.localizedDescription)
                               
                                } else {
                                    
                                    //Kullanıcının snapi varsa
                                    if snapshot != nil && snapshot?.isEmpty == false {
                                        for document in snapshot!.documents {
                                            let documentID = document.documentID
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                                imageUrlArray.append(imageUrl!)
                                                
                                                let additionalDictionary = ["imageUrlArray": imageUrlArray] as [String: Any]
                                                
                                                firestore.collection("Snaps").document(documentID).setData(additionalDictionary, merge: true) { (error5) in
                                                    
                                                    if error != nil {
                                                        print(error5!)
                                                        SignInVC().makeAlert(title: "Error", message: error5!.localizedDescription)
                                                    
                                                    } else {
                                                        self.imageView.image = UIImage(named: "selectimage")
                                                        self.tabBarController?.selectedIndex = 0
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        
                                    } else {
                                        
                                        // Kullacının snapi yoksa
                                        let snapDictionary = ["imageUrlArray": [imageUrl], "snapOwner": UserSingleton.sharedUserInfo.username, "snapDate": FieldValue.serverTimestamp() ] as [String : Any]
                                        
                                        firestore.collection("Snaps").addDocument(data: snapDictionary) { (error2) in
                                            if error2 != nil {
                                                SignInVC().makeAlert(title: "Error", message: error2!.localizedDescription)
                                         
                                            } else {
                                                self.imageView.image = UIImage(named: "selectimage")
                                                self.tabBarController?.selectedIndex = 0
                                           
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
