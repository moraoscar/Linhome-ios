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

class AssistantRoot: MainViewContentWithScrollableForm {
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
        
		viewTitle.setText(textKey: "assistant_welcome_title")
		viewSubtitle.setText(textKey: "my_account_subtitle")
        
        viewTitle.textAlignment = .left
        viewSubtitle.textAlignment = .left
		
//		let createLinhomeAccount = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "bg_secondary_btn", tintColor: "primary", textKey: "assistant_create_linhome_account", topMargin: 5)
//		let loginLinhome = UIRoundRectButton(container:contentView, placedBelow:createLinhomeAccount, effectKey: "bg_secondary_btn", tintColor: "primary", textKey: "assistant_use_linhome_account", topMargin: 23)
//		let loginSip = UIRoundRectButton(container:contentView, placedBelow:loginLinhome, effectKey: "bg_secondary_btn", tintColor: "primary", textKey: "assistant_use_sip_account", topMargin: 23)
		
        let remoteConfig = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "bg_secondary_btn", tintColor: "primary", textKey: "assistant_remote_prov", topMargin: 5, isLastInContainer : true)
		
        NavigationManager.it.hiddenHomeOptions()
        
//		createLinhomeAccount.onClick {
//			self.navigateToComponent(childClass: CreateLinhomeAccountView.self)
//		}
//		
//		loginLinhome.onClick {
//			self.navigateToComponent(childClass: LoginLinhomeAccountView.self)
//		}
//		
//		loginSip.onClick {
//			self.navigateToComponent(childClass: LoginSipAccountView.self)
//		}
		
		remoteConfig.onClick {
			self.navigateToComponent(childClass: RemoteRoot.self)
		}
		
	}
	
	private func navigateToComponent(childClass: ViewWithModel.Type) {
		if (LinhomeAccount.it.configured()) {
			DialogUtil.confirm(titleTextKey: "assistant_using_will_disconnect_title", messageTextKey: "assistant_using_will_disconnect_message", confirmAction: {
				LinhomeAccount.it.disconnect(deletePushAccount: childClass == RemoteRoot.self)
				NavigationManager.it.navigateTo(childClass: childClass)
			})
		} else {
			NavigationManager.it.navigateTo(childClass: childClass)
		}
	}
	
}
