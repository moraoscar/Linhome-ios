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

class MainView: ViewWithModel, UIDynamicAnimatorDelegate {
	
	@IBOutlet weak var topBar: UIView!
	@IBOutlet weak var bottomBar: UIView!
	@IBOutlet weak var content: UIView!
	@IBOutlet weak var burger: UIButton!
	@IBOutlet weak var back: UIButton!
	@IBOutlet weak var left: UIButton!
	@IBOutlet weak var right: UIButton!
	@IBOutlet weak var devicesTab: UIView!
	@IBOutlet weak var devicesLabel: UILabel!
//	@IBOutlet weak var devicesIcon: UIImageView!
	@IBOutlet weak var historyTab: UIView!
	@IBOutlet weak var historyLabel: UILabel!
//	@IBOutlet weak var historyIcon: UIImageView!
	@IBOutlet weak var navigationTitle: UILabel!
	@IBOutlet weak var unreadCount: UILabel!
    @IBOutlet weak var nuoTitle: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeDescriptionLabel: UILabel!
    @IBOutlet weak var borderHistory: UIView!
    @IBOutlet weak var borderDevices: UIView!
    @IBOutlet weak var btnDeleteItems: UIButton!
    
    
	var toolbarViewModel = ToolbarViewModel()
	var tabbarViewModel = TabbarViewModel()
	var toobarButtonClickedListener: ToobarButtonClickedListener? = nil
	private var observer: MutableLiveDataOnChangeClosure<GlobalState>? = nil
	var isDeletingItems: Bool = false
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NavigationManager.it.mainView  = self
		
		topBar.snp.makeConstraints { (make) in
			make.size.height.equalTo(UIDevice.hasNotch() ? 174 : 117)
			make.left.right.top.equalToSuperview()
		}
		
        bottomBar.snp.makeConstraints { (make) in
            make.size.height.equalTo(UIDevice.hasNotch() ? 84 : 50)
            make.left.right.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
        }

        content.snp.makeConstraints { (make) in
            make.top.equalTo(bottomBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
		
		// Top / Status bar
		
        topBar.backgroundColor = ColorManager.color_a
        
//		back.prepare(iconName: "icons/back",effectKey: "primary_color",tintColor: "color_c")
//		
		burger.onClick {
			NavigationManager.it.navigateTo(childClass: SideMenu.self)
		}
		
		back.onClick {
			NavigationManager.it.navigateUp()
		}
		
		toolbarViewModel.burgerButtonVisible.observe { (visible) in
			self.burger.isHidden = !visible!
		}
		
        toolbarViewModel.leftButtonVisible.observe { (visible) in
			self.left.isHidden = !visible!
			self.burger.isHidden = !self.left.isHidden
		}
        
        toolbarViewModel.titleVisible.observe { (visible) in
            self.nuoTitle.isHidden = !visible!
            self.welcomeDescriptionLabel.isHidden = !visible!
            self.welcomeLabel.isHidden = !visible!
            self.burger.isHidden = !visible!
            
            let newHeight = visible! ? (UIDevice.hasNotch() ? 174 : 117) : 100
            let newHeightBottombar = visible! ? (UIDevice.hasNotch() ? 74 : 50) : 0
            self.topBar.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(newHeight)
            }
            
            self.bottomBar.snp.remakeConstraints { (make) in
                make.size.height.equalTo(newHeightBottombar)
                make.left.right.equalToSuperview()
                make.top.equalTo(self.topBar.snp.bottom)
            }
            self.view.layoutIfNeeded()
        }
        
//      mostrar u ocultar botones izquierda y derecha
//		toolbarViewModel.backButtonVisible.observe { (visible) in
//			self.back.isHidden = !visible!
//		}
		toolbarViewModel.rightButtonVisible.observe { (visible) in
			self.right.isHidden = !visible!
		}
        
        toolbarViewModel.btnDeleteItemVisible.observe { (visible) in
            self.btnDeleteItems.isHidden = !visible!
        }
		
		left.onClick {
			self.toobarButtonClickedListener.map{$0.onToolbarLeftButtonClicked()}
		}
        
        btnDeleteItems.onClick {
            self.activeOrDisableDeleteItems()
        }
		
		right.onClick {
			self.toobarButtonClickedListener.map{$0.onToolbarRightButtonClicked()}
		}
    
        nuoTitle.textColor = ColorManager.color_primary
        nuoTitle.text = "NÜO W&M"
        nuoTitle.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)
        
        welcomeLabel.textColor = ColorManager.color_tertiary
        welcomeLabel.text = "Bienvenido"
        welcomeLabel.font = UIFont(name: FontKey.BOLD.rawValue, size: 30)
        
        welcomeDescriptionLabel.textColor = ColorManager.color_secondary
        welcomeDescriptionLabel.text = "Consulta tus dispositivos y tu historial"
        welcomeDescriptionLabel.font = UIFont(name: FontKey.REGULAR.rawValue, size: 14)
        
        self.borderHistory.backgroundColor = ColorManager.color_primary
        self.borderDevices.backgroundColor = ColorManager.color_primary
		
		// Bottom/Tab bar
		
		bottomBar.backgroundColor = ColorManager.color_a
		
		devicesLabel.prepare(styleKey: "tabbar_option",textKey: "devices")
		
		historyLabel.prepare(styleKey: "tabbar_option",textKey: "history")
		unreadCount.prepare(styleKey: "tabbar_unread_count")
        
        devicesLabel.textAlignment = .center
        historyLabel.textAlignment = .center
        
		unreadCount.backgroundColor = Theme.getColor("primary")
		unreadCount.layer.masksToBounds = true
		unreadCount.layer.cornerRadius = 10.0
		
        historyLabel.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 14)
        devicesLabel.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 14)
        
		manageModel(tabbarViewModel)
		tabbarViewModel.unreadCount.readCurrentAndObserve{ (unread) in
			if (unread! > 0) {
				self.unreadCount.isHidden = false
				self.unreadCount.text = unread! < 100 ? String(unread!) : "99+"
//				self.unreadCount.startBouncing(offset: 6)
				
			} else {
				self.unreadCount.isHidden = true
			}
		}
		
		
		devicesTab.onClick {
			NavigationManager.it.navigateTo(childClass: DevicesView.self)
            self.devicesLabel.textColor = ColorManager.color_primary
            self.historyLabel.textColor = ColorManager.color_secondary
            self.borderHistory.isHidden = true
            self.borderDevices.isHidden = false
            self.activeOrDisableDeleteItems(forceDisable: true)
            self.btnDeleteItems.isHidden = true
		}
		historyTab.onClick {
            NavigationManager.it.navigateTo(childClass: HistoryView.self)
            self.historyLabel.textColor = ColorManager.color_primary
            self.devicesLabel.textColor = ColorManager.color_secondary
            self.borderHistory.isHidden = false
            self.borderDevices.isHidden = true
            self.btnDeleteItems.isHidden = false
		}
        
		// Content
		
        self.content.backgroundColor = ColorManager.color_c
		
		observer = MutableLiveDataOnChangeClosure<GlobalState> { state in
			if (state == .On) {
				if ((UIApplication.shared.delegate as! AppDelegate).historyNotifTapped) {
					self.historyTab.performTap()
					(UIApplication.shared.delegate as! AppDelegate).historyNotifTapped = false
				}
			}
		}
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		(UIApplication.shared.delegate as! AppDelegate).coreState.addObserver(observer: observer!)
		if ((UIApplication.shared.delegate as! AppDelegate).historyNotifTapped) {
			self.historyTab.performTap()
			(UIApplication.shared.delegate as! AppDelegate).historyNotifTapped = false
		} else {
            self.historyTab.performTap()
		}
        
        self.historyTab.performTap()
        self.historyTab.performTap()
        
        NavigationManager.it.showHomeOptions()
		// Configuración inicial no realizada de momento comentada TODO
//		if (!LinhomeAccount.it.configured()) {
//			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
//				NavigationManager.it.navigateTo(childClass: AssistantRoot.self)
//			}
//		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		(UIApplication.shared.delegate as! AppDelegate).coreState.removeObserver(observer: observer!)
		super.viewWillDisappear(animated)
	}
	
	func bottomBarButtonClicked(_ clicked: UIView, _ unClicked:UIView) {
		if (unClicked.alpha == 0.3) {
			return
		}
		UIView.animate(withDuration: 0.2) {
			clicked.alpha = 1.0
			unClicked.alpha = 0.3
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	}
    
    func activeOrDisableDeleteItems(forceDisable: Bool = false) {
        if (forceDisable || isDeletingItems) {
            self.btnDeleteItems.setImage(UIImage(named: "delete_items"), for: .normal)
            self.isDeletingItems = false
            self.toobarButtonClickedListener.map{$0.onBtnExitDeleteItemClicked()}
            return
        }
        self.toobarButtonClickedListener.map{$0.onBtnDeleteItemClicked()}
        self.isDeletingItems = !self.isDeletingItems
        print("is deleting items: \(self.isDeletingItems)")
        
        if (!self.isDeletingItems) { //ocultamos
            self.btnDeleteItems.setImage(UIImage(named: "delete_items"), for: .normal)
        } else {
            self.btnDeleteItems.setImage(UIImage(named: "delete_items_active"), for: .normal)
        }
    }
	
	
}
