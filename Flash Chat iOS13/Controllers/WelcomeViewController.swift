

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(#function)
        
        titleLabel.text = ""
        var charLeft = 0.0
        let titleLabel = "⚡️FlashChat"
        
        for char in titleLabel {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charLeft, repeats: false) { (timer) in
                self.titleLabel.text?.append(char)
            }
            charLeft += 1
        }
    }
}
