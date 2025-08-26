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

class DeviceEditorView: MainViewContentWithScrollableForm {
	
	var nameInput : LTextInput?
	var addressInput : LTextInput?
	var model = DeviceEditorViewModel()
	
    var saveButton: UIButton!
    var cancelButton: UIButton!
    var bottomContainerView: UIView?

    
	override func viewDidLoad() {
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "devices"
		hideSubtitle()
		
		let landScapeIpad = UIDevice.ipad() && UIScreen.isLandscape
		
		manageModel(model)
		model.device = NavigationManager.it.nextViewArgument as! Device?
		
		if (UIDevice.ipad()) {
			let yourDevice = UILabel()
			form.addArrangedSubview(yourDevice)
			yourDevice.prepare(styleKey: "section_title",textKey:"your_device")
			if (!landScapeIpad) {
				yourDevice.snp.makeConstraints { (make) in
					make.height.equalTo(40)
				}
			}
		}
		
        let bottomPadding: CGFloat = 150
        self.scrollView.contentInset.bottom = bottomPadding
        self.scrollView.scrollIndicatorInsets.bottom = bottomPadding
        
		nameInput = LTextInput.addOne(titleKey: "device_name", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.name, inForm: form)
		addressInput = LTextInput.addOne(titleKey: "device_address", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.sipUri, liveInfo: model.address, inForm: form, hintKey: "device_address_hint")
		
		// device type
		let deviceTypeTitle = UILabel()
		form.addArrangedSubview(deviceTypeTitle)
		deviceTypeTitle.snp.makeConstraints { (make) -> Void in
			make.top.equalTo(addressInput!.view.snp.bottom)
		}
		deviceTypeTitle.prepare(styleKey: "section_title",textKey:"device_type_select")
		let deviceSpinner = LSpinner.addOne(titleKey: nil, targetVC: self, options:model.availableDeviceTypes, liveIndex: model.deviceType, form:form)
		
        deviceTypeTitle.textColor = ColorManager.color_text_label_input
        deviceTypeTitle.font = UIFont.init(name: FontKey.SEMIBOLD.rawValue, size: 14)
		
		if (landScapeIpad) {
			addSecondColumn()
			nameInput?.view.snp.makeConstraints({ (make) in
				make.top.equalToSuperview().offset(80)
			})
		}
		
		// Method type
		let actionsTitle = UILabel()
		(landScapeIpad ? formSecondColumn : form).addArrangedSubview(actionsTitle)
		actionsTitle.snp.makeConstraints { (make) -> Void in
			make.top.equalTo(landScapeIpad ? viewSubtitle.snp.bottom : deviceSpinner.view.snp.bottom)
			make.height.equalTo(landScapeIpad ? 80 : 30)
		}
		actionsTitle.prepare(styleKey: "section_title",textKey:"method_type_select")
		let _ = LSpinner.addOne(titleKey: "action_method", targetVC: self, options:model.availableMethodTypes, liveIndex: model.actionsMethod, form:landScapeIpad ? formSecondColumn : form)
		
        let newAction = UIRoundRectButton(container:contentView, placedBelow: landScapeIpad ? formSecondColumn : form, effectKey: "primary_color", tintColor: "color_c", textKey: "device_action_add", topMargin: 27, width: 200, alignment: .right)
		newAction.onClick {
			self.doAddAction(action: nil, model: self.model, form: landScapeIpad ? self.formSecondColumn : self.form)
		}
		
		let delete = UIRoundRectButton(container:contentView, placedBelow:newAction, effectKey: "primary_color", tintColor: "color_c", textKey: "delete_device", topMargin: 40, isLastInContainer: true)
//        LINEA ORIGINAL
//        delete.isHidden = model.device == nil
		delete.isHidden = true
		
		if (landScapeIpad) {
			delete.snp.makeConstraints { (make) in
				make.top.greaterThanOrEqualTo(deviceSpinner.view.snp.bottom).offset(40)
			}
		}
		
		if (model.device != nil) {
			viewTitle.setText(text: model.device!.name)
			model.device!.actions?.forEach { it in
				self.doAddAction(action: it,model: model, form:landScapeIpad ? formSecondColumn : form)
			}
		} else {
			viewTitle.setText(textKey:"new_device")
			self.doAddAction(action: nil, model: model, form:landScapeIpad ? formSecondColumn : form)
		}
		
        viewTitle.textAlignment = .left
		delete.onClick {
			DialogUtil.confirm(messageTextKey: "delete_device_confirm_message",oneArg: self.model.device?.name, confirmAction: {
				DeviceStore.it.removeDevice(device:self.model.device!)
				NavigationManager.it.navigateTo(childClass: DevicesView.self,asRoot: true)
			})
		}
		
		newAction.isEnabled = self.model.actionsViewModels.count <= 2
		model.refreshActions.observe { (_) in
			newAction.isEnabled = self.model.actionsViewModels.count <= 2
			for (index, actionViewModel) in self.model.actionsViewModels.enumerated() {
				actionViewModel.displayIndex.value = index+1
			}
		}
        
        self.setupBottomButtons()
		
        NavigationManager.it.hiddenHomeOptions()
	}
	
	private func doAddAction(action: Action?, model: DeviceEditorViewModel, form:UIStackView) {
		let actionViewModel = DeviceEditorActionViewModel(owningViewModel: model, displayIndex: MutableLiveData(model.actionsViewModels.count + 1))
		if (action != nil) {
			actionViewModel.code.first.value = action!.code
			actionViewModel.type.value = model.availableActionTypes.firstIndex{$0.backingKey == action!.type}
		}
		model.actionsViewModels.append(actionViewModel)
		actionViewModel.actionRow = ActionRow.addOne(targetVC: self, actionViewModel:actionViewModel, form:form)
		model.refreshActions.value = true
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NavigationManager.it.hiddenHomeOptions()
	}
	
	override func onToolbarLeftButtonClicked() {
		NavigationManager.it.navigateUp()
	}
    
    @objc private func didTapSaveButton() {
        nameInput?.validate()
        addressInput?.validate()
        model.actionsViewModels.forEach { it in
            if (it.type.value != 0) {
                it.actionRow?.code?.validate()
            }
        }
        DeviceStore.it.findDeviceByAddress(address: model.address.first.value).map { it in
            if (model.device?.id != it.id) {
                addressInput?.setError(
                    Texts.get(
                        "device_address_already_exists",
                        oneArg: "\(it.name)"
                    )
                )
                return
            }
        }
        if (model.saveDevice()) {
            NavigationManager.it.nextViewArgument = model.device
            NavigationManager.it.navigateUp()
        }
    }
	
    @objc private func didTapCancelButton() {
        NavigationManager.it.navigateUp()
    }
    
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = true
		
		NavigationManager.it.navigateUp()
		NavigationManager.it.navigateTo(childClass: DeviceEditorView.self, asRoot: false, argument: model.device)
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bottomContainerView?.removeFromSuperview()
    }
    
    func setupBottomButtons() {
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

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        container.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        let saveButton = UIButton(type: .custom)
        saveButton.setTitle(Texts.get("save"), for: .normal)
        saveButton.backgroundColor = ColorManager.color_primary
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        stackView.addArrangedSubview(saveButton)
          
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle(Texts.get("cancel"), for: .normal)
        cancelButton.setTitleColor(ColorManager.color_text_danger_button, for: .normal)
        cancelButton.backgroundColor = ColorManager.color_background_danger_button
        cancelButton.layer.cornerRadius = 12
        cancelButton.titleLabel?.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)!
        stackView.addArrangedSubview(cancelButton)
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
}
