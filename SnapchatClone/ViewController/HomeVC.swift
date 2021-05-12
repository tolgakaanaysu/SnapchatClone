import UIKit
import Firebase
import SDWebImage

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let firestoreDatabase  = Firestore.firestore()
    var snapArray = [Snap]()
    
    var choosenSnap : Snap?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getSnapsFromFirebase()
        getUserInfo()
       
    }
    
    func getUserInfo(){
        
        firestoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot, error) in
            if error != nil {
                let alert = SignInVC()
                alert.makeAlert(title: "Error", message: error!.localizedDescription)

            }else {
                if snapshot != nil {
                    for document in snapshot!.documents {
                        if let username = document.get("username") as? String {
                            UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUserInfo.username = username
                        }
                    }
                }
            }
        }
    }
    
    func getSnapsFromFirebase(){
        firestoreDatabase.collection("Snaps").order(by: "snapDate", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                SignInVC().makeAlert(title: "Error", message: error!.localizedDescription)
                    
            } else {
                if snapshot?.isEmpty == true {
                    print("boş aq")
                }
                if snapshot?.isEmpty == false && snapshot != nil {
                    
                    self.snapArray.removeAll(keepingCapacity: false)
                        
                    for document in snapshot!.documents {
                        
                        let documentID = document.documentID
                        if let username = document.get("snapOwner") as? String {
                            if let snapDate = document.get("snapDate") as? Timestamp {
                                if let urlArray = document.get("imageUrlArray") as? [String] {
                                    if let difference = Calendar.current.dateComponents([.hour], from: snapDate.dateValue(), to: Date()).hour {
                                        
                                        if difference >= 24 {
                                            self.firestoreDatabase.collection("Snaps").document(documentID).delete()
                                            let storage = Storage.storage()
                                            let snapReferance = storage.reference().child("media").child("\(documentID).jpeg")
                                            
                                            snapReferance.delete(completion: nil)
                                            
                                        }else {
                                            
                                             let snap = Snap(username: username, imageUrlArray: urlArray, date: snapDate.dateValue(),timeLeft: 24 - difference)
                                             self.snapArray.append(snap)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell",for: indexPath) as! HomeCell
        cell.usernameLabel.text = snapArray[indexPath.row].username
        cell.ImageViewCell.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC" {
            
            let destionationVC = segue.destination as! SnapVC
            destionationVC.selectSnap = self.choosenSnap
     
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenSnap = snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
        
    }
    
}
