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

class AccountController: MainViewContent {
	
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitleDescription: UILabel!
    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var accountViewContent: UIView!
    @IBOutlet weak var connectionViewContent: UIView!
    @IBOutlet weak var lblConnection: UILabel!
    @IBOutlet weak var lblAccountValue: UILabel!
    @IBOutlet weak var lblConnectionValue: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var btnDisconnect: UIButton!
    var model: AccountViewModel = AccountViewModel()
    
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		isRoot = false
        
        titleTextKey = "My account"
        lblTitle.text = titleTextKey
        lblTitle.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 26)
        
        lblTitleDescription.text = "This assistant will help you configure your account"
        lblTitleDescription.font = UIFont(name: FontKey.REGULAR.rawValue, size: 14)
        lblTitleDescription.textColor = ColorManager.color_secondary
        
        lblAccount.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 14)
        lblAccount.text = "Account"
        lblAccount.textColor = ColorManager.color_text_label_input
        
        lblConnection.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 14)
        lblConnection.text = "SIP connection"
        lblConnection.textColor = ColorManager.color_text_label_input
		
        manageModel(self.model)
		
        accountViewContent.layer.cornerRadius = 10
        connectionViewContent.layer.cornerRadius = 10
        accountViewContent.backgroundColor = ColorManager.color_c
        connectionViewContent.backgroundColor = ColorManager.color_c
        lblAccountValue.textColor = ColorManager.color_secondary
        lblConnectionValue.textColor = ColorManager.color_secondary
        
        lblAccountValue.font = UIFont(name: FontKey.MEDIUM.rawValue, size: 14)
        lblConnectionValue.font = UIFont(name: FontKey.MEDIUM.rawValue, size: 14)
        
        if #available(iOS 15.0, *) {
            btnRefresh.configuration = nil
            btnDisconnect.configuration = nil
        }
        
        btnRefresh.setTitle("Refresh connection", for: .normal)
        btnDisconnect.setTitle("Disconnect account", for: .normal)
        btnRefresh.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        btnDisconnect.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        
        
        btnRefresh.setTitleColor(ColorManager.color_primary, for: .normal)
        btnDisconnect.setTitleColor(ColorManager.color_primary, for: .normal)
        btnRefresh.setTitleColor(ColorManager.color_primary, for: .highlighted)
        btnDisconnect.setTitleColor(ColorManager.color_primary, for: .highlighted)
        
        btnRefresh.backgroundColor = ColorManager.color_background_primary_button
        btnDisconnect.backgroundColor = ColorManager.color_background_primary_button
        
        btnRefresh.layer.cornerRadius = 16
        btnDisconnect.layer.cornerRadius = 16
        
        model.accountDesc.readCurrentAndObserve { (text) in
            let components1 = text!.components(separatedBy: "\rSIP connection: ")
            let connectionValue = components1.count > 1 ? components1[1] : ""
            let accountPart = components1[0]
            let accountValue = accountPart.replacingOccurrences(of: "Account: ", with: "")
            self.lblAccountValue.text = accountValue
            self.lblConnectionValue.text = connectionValue
        }
		
		if (model.account != nil) {
//			let refresh = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "secondary_color", tintColor: "color_c", textKey: "refresh_registers", topMargin: 0)
//			var deleteaccount : UIRoundRectButton? = nil
            
//            se usa con cuenta propia de linhome
//			if (model.isLinhome()) {
//				let changepass = UIRoundRectButton(container:contentView, placedBelow:refresh, effectKey: "secondary_color", tintColor: "color_c", textKey: "change_password", topMargin: 23)
//				deleteaccount = UIRoundRectButton(container:contentView, placedBelow:changepass, effectKey: "secondary_color", tintColor: "color_c", textKey: "delete_account", topMargin: 23)
//				changepass.onClick {
//					self.gotoFreeSip()
//				}
//				deleteaccount?.onClick {
//					self.gotoFreeSip()
//				}
//			}
//           FIN se usa con cuenta propia de linhome
            

//			refresh.onClick {
//				model.refreshRegisters()
//			}
//			disconnect.onClick {
//				DialogUtil.confirm(titleTextKey: "menu_disconnect", messageTextKey: "disconnect_confirm_message", confirmAction: {
//					LinhomeAccount.it.disconnect()
//					NavigationManager.it.navigateUp()
//				})
//			}
		}
	}
	
    override func isCallView() -> Bool {
        return true
    }
	
	func gotoFreeSip() {
		DialogUtil.confirm(titleTextKey: "account_manage_on_freesip_title", messageTextKey: "account_manage_on_freesip_message", confirmAction: {
			if let url = URL(string: Config.get().getString(section: "assistant", key: "freesip_url", defaultString: "https://subscribe.linhome.org/login")) {
				UIApplication.shared.open(url)
			}
		})
	}
    
    @IBAction func back(_ sender: Any) {
        NavigationManager.it.navigateUp()
    }
	
    @IBAction func resfreshConnection(_ sender: Any) {
        self.model.refreshRegisters()
    }
    
    @IBAction func disconnect(_ sender: Any) {
        DialogUtil.confirm(titleTextKey: "menu_disconnect", messageTextKey: "disconnect_confirm_message", confirmAction: {
            LinhomeAccount.it.disconnect()
            NavigationManager.it.navigateUp()
        })
    }
}
