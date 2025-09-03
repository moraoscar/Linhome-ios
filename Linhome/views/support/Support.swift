/*
* Copyright (c) 2010-2020 Belledonne Communications SARL.
*
* This file is part of linhome
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/



import UIKit
import linphonesw
import Foundation

class Support: MainViewContent {

    @IBOutlet weak var linhomeIcon: UIImageView!
    @IBOutlet weak var linhomeText: UIImageView!
    @IBOutlet weak var linhomeTitle: UILabel!
    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var linhomeOrg: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isRoot = false
        onTopOfBottomBar = true
        titleTextKey = Texts.get("menu_support_module")
        
        headerView.backgroundColor = ColorManager.color_primary
        
        lblTitle.text = titleTextKey
        lblTitle.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 20)
        lblTitle.textColor = ColorManager.color_a

        linhomeTitle.text = Texts.get("support_information")
        linhomeTitle.textColor = ColorManager.color_secondary
        linhomeTitle.font = UIFont(name: FontKey.REGULAR.rawValue, size: 14)
    

        appVersion.text = "soporte@nuoplanet.com"
        appVersion.font = UIFont(name: FontKey.REGULAR.rawValue, size: 14)
        appVersion.textColor = ColorManager.color_primary
        appVersion.font = UIFont(name: FontKey.BOLD.rawValue, size: 14)
        
        linhomeOrg.font = UIFont(name: FontKey.BOLD.rawValue, size: 14)
        linhomeOrg.textColor = ColorManager.color_primary
        linhomeOrg.text =  "+34 918 707 193"
        
        linhomeOrg.onClick {
            self.linhomeOrg.text.map { urlString in
                if let url = URL(string: urlString.hasPrefix("http") ? urlString :  "https://\(urlString)") {
                    UIApplication.shared.open(url)
                }
            }
        }
        
    }
    
    override func isCallView() -> Bool {
        return true
    }
    
    @IBAction func back(_ sender: Any) {
        NavigationManager.it.navigateUp()
    }
    
}
