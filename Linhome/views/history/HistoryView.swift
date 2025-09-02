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

class HistoryView: MainViewContent, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var noHistory: UILabel!
	@IBOutlet weak var eventsTable: UITableView!
	
	var model = HistoryViewModel()
    var bottomContainerView: UIView?
    var cancelButton: UIButton!
    var deleteButton: UIButton!
    var selectedAll: UIButton!
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		isRoot = true
		onTopOfBottomBar = false
		titleTextKey = "history"
        
		manageModel(model)
		
		noHistory.prepare(styleKey: "view_sub_title",textKey: "history_empty_list_title")
		noHistory.isHidden = model.history.value!.count != 0
		
		selectedAll = UIButton()
        selectedAll.prepareRoundRect(effectKey : "secondary_color", tintColor: "color_c", textKey: "history_select_all")
		self.view.addSubview(selectedAll)
        selectedAll.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview().offset(-20)
			make.centerX.equalToSuperview()
			make.height.equalTo(40)
			make.leftMargin.rightMargin.equalTo(20)
			make.width.lessThanOrEqualTo(320)
		}
		
        selectedAll.onClick {
			self.model.toggleSelectAllForDeletion()
		}

		model.selectedForDeletion.observe { (items) in
            
			if (self.model.editing.value! && items!.count == 0) {
                self.deleteButton.isEnabled = false
			} else {
                self.deleteButton.isEnabled = true
			}
            
            if #available(iOS 15.0, *) {
                guard var currentConfig = self.selectedAll.configuration else { return }
                if items!.count == self.model.history.value!.count {
                    currentConfig.title = Texts.get("history_select_all")
                    currentConfig.image = UIImage(named: "checkbox_ticked")
                } else {
                    currentConfig.title = Texts.get("history_select_all")
                    currentConfig.image = UIImage(named: "checkbox_unticked")
                }
                
                currentConfig.image = currentConfig.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14))
                
                self.selectedAll.configuration = currentConfig
            }
            
            self.deleteButton.prepareRoundRectWihIcon(effectKey: self.deleteButton.isEnabled ? "delete_device" : "delete_device_disable", tintColor: self.deleteButton.isEnabled ? "text_delete_btn" : "color_text_label_input", textKey: items!.count == 0 ? "\(Texts.get("delete_history")) \(Texts.get("delete_history_event"))" : "\(Texts.get("delete_history")) \(self.model.selectedForDeletion.value!.count) \(Texts.get("delete_history_event"))", iconName: "icons/trash", iconSizeWidth: 18, iconSizeHeight: 18)
		}
		
		model.history.observe { (list) in
			self.noHistory.isHidden = list!.count != 0
            NavigationManager.it.mainView?.toolbarViewModel.btnDeleteItemVisible.value = list!.count != 0
			self.eventsTable.reloadData()
		}
		
		model.editing.readCurrentAndObserve { (editing) in
            self.selectedAll.isHidden = !editing!
		}
		
		eventsTable.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
		eventsTable.register(UINib(nibName: "HistoryCellLand", bundle: nil), forCellReuseIdentifier: "HistoryCellLand")
		
		NavigationManager.it.mainView!.tabbarViewModel.unreadCount.observe { _ in
			self.eventsTable.reloadData()
		}
        
        eventsTable.rowHeight = 100
		
	}
	
	override func onToolbarRightButtonClicked() {
		if (model.editing.value!) {
			DialogUtil.confirm(messageTextKey: "delete_history_confirm_message",oneArg: "\(model.selectedForDeletion.value!.count)", confirmAction: {
				self.model.deleteSelection()
				self.eventsTable.reloadData()
				NavigationManager.it.mainView!.tabbarViewModel.updateUnreadCount()
                NavigationManager.it.mainView?.activeOrDisableDeleteItems(forceDisable: true)
				self.exitEdition()
			})
		} else {
			enterEdition()
		}
	}
    
    override func onBtnExitDeleteItemClicked() {
        exitEdition()
    }
    
    override func onBtnDeleteItemClicked() {
        if (model.editing.value!) {
            if (model.selectedForDeletion.value!.count == 0) {
                exitEdition()
                return
            }
            DialogUtil.confirm(messageTextKey: "delete_history_confirm_message",oneArg: "\(model.selectedForDeletion.value!.count)", confirmAction: {
                self.model.deleteSelection()
                self.eventsTable.reloadData()
                NavigationManager.it.mainView!.tabbarViewModel.updateUnreadCount()
                self.exitEdition()
            })
        } else {
            enterEdition()
        }
    }
	
	override func onToolbarLeftButtonClicked() {
		exitEdition()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        NavigationManager.it.showHomeOptions()
		NavigationManager.it.mainView!.left.prepare(iconName: "icons/cancel",effectKey: "primary_color",tintColor: "color_c", textStyleKey: "toolbar_action", text: Texts.get("cancel"))
		NotificationCenter.default.addObserver(self,
											   selector: #selector(applicationDidBecomeActive),
											   name: UIApplication.didBecomeActiveNotification,
											   object: nil)
		eventsTable.reloadData()
	}
	
	func enterEdition() {
        let bottomPadding: CGFloat = 150
        self.eventsTable.contentInset.bottom = bottomPadding
        self.eventsTable.scrollIndicatorInsets.bottom = bottomPadding
        
        if #available(iOS 15.0, *) {
            self.setupBottomButtons()
        }
		model.editing.value = true
		model.notifyDeleteSelectionListUpdated()
	}
	
	func exitEdition() {
        let bottomPadding: CGFloat = 0
        self.eventsTable.contentInset.bottom = bottomPadding
        self.eventsTable.scrollIndicatorInsets.bottom = bottomPadding
		NavigationManager.it.mainView?.toolbarViewModel.leftButtonVisible.value = false
		model.editing.value = false
		model.selectedForDeletion.value!.removeAll()
		model.notifyDeleteSelectionListUpdated()
        bottomContainerView!.removeFromSuperview()
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		model.markEventsAsRead()
		NavigationManager.it.mainView!.tabbarViewModel.updateUnreadCount()
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = false
		NotificationCenter.default.removeObserver(self,
												  name: UIApplication.didBecomeActiveNotification,
												  object: nil)
		super.viewWillDisappear(animated)
	}
	
	
	
	// UITableView delegates & data
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return model.historySplit.value!.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.historySplit.value![Array(model.historySplit.value!.keys.sorted().reversed())[section]]!.count
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.contentView.backgroundColor = .clear
			headerView.backgroundView?.backgroundColor = .clear
			headerView.textLabel?.prepare(styleKey: "history_list_day_name")
            
            headerView.textLabel?.text = headerView.textLabel?.text?.capitalized
            
			model.editing.readCurrentAndObserve { (editing) in
				headerView.alpha = editing! ? 0.3 : 1.0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
		return todayYesterdayRealDay(epochTimeDayUnit: Int(Array(model.historySplit.value!.keys.sorted().reversed())[section]))
	}
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 25.0
        } else {
            return 30.0
        }
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:HistoryCell = tableView.dequeueReusableCell(withIdentifier: UIDevice.ipad() && UIScreen.isLandscape ? "HistoryCellLand" : "HistoryCell") as! HistoryCell
		cell.set( model: HistoryEventViewModel(callLog: model.historySplit.value![Array(model.historySplit.value!.keys.sorted().reversed())[indexPath.section]]![indexPath.row], historyViewModel: model))
		cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (!model.editing.value! ) {
			//NavigationManager.it.navigateTo(childClass: Viewer.self, asRoot: false, argument: DeviceStore.it.devices[indexPath.row])
		}
	}
	
	func todayYesterdayRealDay(epochTimeDayUnit: Int) -> String {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		if (epochTimeDayUnit == Int(Date().timeIntervalSince1970 / 86400)) {
			return Texts.get("today")
		} else if (epochTimeDayUnit == Int(Date().timeIntervalSince1970 / 86400 - 1)) {
			return Texts.get("yesterday")
		} else {
			return formatter.string(from: Date(timeIntervalSince1970:Double(epochTimeDayUnit) * 86400))
		}
	}
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if (UIDevice.ipad()) {
			coordinator.animate(alongsideTransition: { context in
				self.eventsTable.reloadData()
			}, completion: { context in
			})
			
		}
	}
	
	@objc func applicationDidBecomeActive() {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
			self.model.refresh()
		}
	}
    
    @available(iOS 15.0, *)
    func setupBottomButtons(add: Bool = true) {
        if !add {
            bottomContainerView?.removeFromSuperview()
            return
        }
        
        let container = UIView()
        container.backgroundColor = .white
        self.view.addSubview(container)
        self.bottomContainerView = container

        container.layer.cornerRadius = 24
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: -3)
        container.layer.shadowRadius = 4
        container.layer.masksToBounds = false
        
        container.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        container.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        
        selectedAll = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = Texts.get("history_select_all")
        config.image = UIImage.init(named: "checkbox_unticked")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14)) // Icono del sistema
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .label
        config.cornerStyle = .medium
        config.titleAlignment = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        selectedAll.configuration = config
        selectedAll.contentHorizontalAlignment = .leading
        
        selectedAll.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        mainStackView.addArrangedSubview(selectedAll)
        
        selectedAll.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        let bottomButtonsStackView = UIStackView()
        bottomButtonsStackView.axis = .horizontal
        bottomButtonsStackView.spacing = 16
        bottomButtonsStackView.distribution = .fill
        mainStackView.addArrangedSubview(bottomButtonsStackView)
        
        deleteButton = UIButton(type: .custom)
        deleteButton.setTitle(Texts.get("save"), for: .normal)
        deleteButton.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        
        deleteButton.isEnabled = false
        deleteButton.prepareRoundRectWihIcon(effectKey: deleteButton.isEnabled ? "delete_device" : "delete_device_disable", tintColor: deleteButton.isEnabled ? "text_delete_btn" : "color_text_label_input", textKey: "\(Texts.get("delete_history")) \(Texts.get("delete_history_event"))", iconName: "icons/trash", iconSizeWidth: 18, iconSizeHeight: 18)
        
        deleteButton.layer.cornerRadius = 12
        
                
        cancelButton = UIButton(type: .custom)
        cancelButton.setTitle(Texts.get("cancel"), for: .normal)
        cancelButton.setTitleColor(ColorManager.color_primary, for: .normal)
        cancelButton.backgroundColor = ColorManager.color_background_primary_button
        cancelButton.layer.cornerRadius = 12
        cancelButton.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        
        
        bottomButtonsStackView.addArrangedSubview(cancelButton)
        bottomButtonsStackView.addArrangedSubview(deleteButton)
        
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(142)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        selectedAll.addTarget(self, action: #selector(didTapSelectedAll), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    @objc private func didTapSelectedAll() {
        print("is dele: didTapSelectedAll")
        self.model.toggleSelectAllForDeletion()
    }
    
    @objc private func didTapDeleteButton() {
        print("is dele: didTapDeleteButton")
        self.onToolbarRightButtonClicked()
    }
    
    @objc private func didTapCancelButton() {
        print("is dele: didTapCancelButton")
        NavigationManager.it.mainView?.activeOrDisableDeleteItems(forceDisable: true)
        
        self.exitEdition()
    }
	
	
}
