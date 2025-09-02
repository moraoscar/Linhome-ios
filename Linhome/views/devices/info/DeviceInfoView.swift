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
import DropDown

class DeviceInfoView: MainViewContent, UITableViewDataSource, UITableViewDelegate  {
	
	
	var device:Device?
	var name, address, typeName, actionsTitle : UILabel?
	var typeIcon:UIImageView?
	var actions:UITableView?
    var editButton: UIButton!
    var deleteButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "devices"
    
        editButton = UIButton(type: .custom)
        editButton.setTitle("Editar", for: .normal)
        editButton.backgroundColor = ColorManager.color_primary
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 12
        editButton.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        view.addSubview(editButton)
        
        deleteButton = UIButton(type: .custom)
        deleteButton.backgroundColor = ColorManager.color_background_danger_button
        deleteButton.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        view.addSubview(deleteButton)
        
        deleteButton.prepareRoundRectWihIcon(effectKey: "delete_device", tintColor: "text_delete_btn", textKey: Texts.get("delete_device"), iconName: "icons/trash", iconSizeWidth: 18, iconSizeHeight: 18)
        
        deleteButton.layer.cornerRadius = 12
        
        deleteButton.setTitleColor(ColorManager.color_text_danger_button, for: .normal)
        
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)

        
        // --- 2. Anclar los botones a la parte inferior de la PANTALLA ---
        deleteButton.snp.makeConstraints { make in
            // Anclado al final de la zona segura con un margen
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.height.equalTo(56)
            make.leading.equalToSuperview().offset(23)
            make.trailing.equalToSuperview().inset(23)
        }

        editButton.snp.makeConstraints { make in
            // Anclado justo encima del botón de eliminar
            make.bottom.equalTo(deleteButton.snp.top).offset(-16)
            make.height.equalTo(56)
            make.leading.equalToSuperview().offset(23)
            make.trailing.equalToSuperview().inset(23)
        }
    
		let scrollView = UIScrollView()
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view)
            make.bottom.equalTo(editButton.snp.top).offset(-10)
		}
		
		let contentView = UIView()
		scrollView.addSubview(contentView)
		contentView.snp.makeConstraints { make in
			make.top.equalTo(scrollView)
			make.bottom.equalTo(scrollView)
			make.left.right.equalTo(view)
		}
        
        typeIcon = UIImageView()
        contentView.addSubview(typeIcon!)
        typeIcon!.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(50)
            make.centerX.equalTo(view.snp.centerX)
            make.width.height.equalTo(158)
        }
        
		name = UILabel()
		contentView.addSubview(name!)
		name!.snp.makeConstraints { make in
            make.top.equalTo(typeIcon!.snp.bottom).offset(38)
			make.centerX.equalTo(view.snp.centerX)
		}
		
		address = UILabel()
		contentView.addSubview(address!)
		address!.snp.makeConstraints { make in
			make.top.equalTo(name!.snp.bottom).offset(5)
			make.centerX.equalTo(view.snp.centerX)
		}
				
		actionsTitle = UILabel()
		contentView.addSubview(actionsTitle!)
		actionsTitle!.snp.makeConstraints { make in
			make.top.equalTo(address!.snp.bottom).offset(37)
            make.leading.equalToSuperview().offset(23)
		}
				
		actions = UITableView()
		contentView.addSubview(actions!)
		actions!.register(UINib(nibName: "ActionInfoCell", bundle: nil), forCellReuseIdentifier: "ActionInfoCell")
		actions!.delegate = self
		actions!.dataSource = self
		actions?.rowHeight = 44
		actions?.insetsLayoutMarginsFromSafeArea = false
		actions?.insetsContentViewsToSafeArea = false
		actions?.separatorStyle = .none
        actions?.allowsSelection = false
        if #available(iOS 17.4, *) {
            actions?.bouncesVertically = false
        } 
		actions!.snp.makeConstraints { make in
			make.top.equalTo(actionsTitle!.snp.bottom).offset(14)
			make.height.equalTo(3*actions!.rowHeight)
            make.leading.equalToSuperview().offset(23)
            make.trailing.equalToSuperview().inset(23)
            make.bottom.equalToSuperview().inset(20)
        }
	
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        NavigationManager.it.hiddenHomeOptions()
        
		guard let device : Device = NavigationManager.it.nextViewArgument as? Device? ?? nil else {
			NavigationManager.it.navigateUp()
			return
		}
		
		self.device = device
		
		NavigationManager.it.mainView!.right.prepare(iconName: "icons/edit",effectKey: "primary_color",tintColor: "color_c", textStyleKey: "toolbar_action", text: Texts.get("edit"))
		
        editButton.isHidden = device.isRemotelyProvisionned
        
        NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = false
		NavigationManager.it.mainView?.toolbarViewModel.leftButtonVisible.value = false
        NavigationManager.it.mainView?.toolbarViewModel.titleVisible.value = false
		

		name!.prepare(styleKey: "view_device_info_name",text: device.name)
		address!.prepare(styleKey: "view_device_info_address",text: device.address)
		device.type.map { type in
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
//				self.typeIcon!.prepare(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:type)!, fillColor: nil, bgColor: nil)
			}
//			typeName!.prepare(styleKey: "view_device_info_type_name",text: device.typeName())
		}
        
        
        if (device.hasThumbNail()) {
            self.typeIcon!.image = UIImage(contentsOfFile: device.thumbNail)
            self.typeIcon!.isHidden = false
           
        } else {
            device.type.map { type in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
                    self.typeIcon!.prepare(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:type)!, fillColor: nil, bgColor: nil)
                }
            }
        }
        
        self.typeIcon?.layer.cornerRadius = 12
        self.typeIcon?.clipsToBounds = true
        
		actionsTitle!.prepare(styleKey: "view_device_info_actions_title",text: device.actions != nil && device.actions!.count > 0 ? Texts.get("device_info_actions_title") : Texts.get("device_info_no_actions_title"))
		actions!.reloadData()
		
	}
	
	override func onToolbarRightButtonClicked() {
		NavigationManager.it.navigateTo(childClass: DeviceEditorView.self, asRoot: false, argument: device)
	}
    
    @objc private func didTapEditButton() {
        NavigationManager.it.navigateTo(childClass: DeviceEditorView.self, asRoot: false, argument: device)
    }
        
    @objc private func didTapDeleteButton() {
        DialogUtil.confirm(messageTextKey: "delete_device_confirm_message",oneArg: self.device?.name, confirmAction: {
            DeviceStore.it.removeDevice(device:self.device!)
            NavigationManager.it.navigateTo(childClass: DevicesView.self,asRoot: true)
        })
    }
		
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return device?.actions?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let action = device!.actions![indexPath.row]
		let cell:ActionInfoCell = tableView.dequeueReusableCell(withIdentifier: "ActionInfoCell") as! ActionInfoCell
		cell.actionType.prepare(iconName: ActionTypes.it.iconNameForActionType(typeKey: action.type!), fillColor: "color_secondary", bgColor: nil)
		cell.actionName.text = action.typeName()
		cell.actionCode.text = action.code
		cell.topSep.isHidden = indexPath.row != 0
		cell.botSep.isHidden = false
		return cell
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func isCallView() -> Bool {
        return false
    }
    
    @IBAction func back(_ sender: Any) {
        NavigationManager.it.navigateUp()
    }
	
    override func onToolbarLeftButtonClicked() {
        NavigationManager.it.navigateUp()
    }
	
}
