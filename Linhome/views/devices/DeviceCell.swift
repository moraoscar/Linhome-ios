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

class DeviceCell: UITableViewCell {
	
	static let spaceBetweenCells  = UIDevice.ipad() ? 0 : 10
	
	@IBOutlet weak var deviceImage: UIImageView?
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var typeIcon: UIImageView!
	@IBOutlet weak var callAudio: UIButton?
	@IBOutlet weak var callVideo: UIButton?
	@IBOutlet weak var ipadSeparator: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		contentView.backgroundColor = UIDevice.ipad() ? .clear : .clear
        
        name.textColor = ColorManager.color_tertiary
        name.font = UIFont(name: FontKey.SEMIBOLD.rawValue, size: 16)
        
        address.textColor = ColorManager.color_secondary
        address.font = UIFont(name: FontKey.REGULAR.rawValue, size: 12)
        deviceImage?.layer.cornerRadius = 8
        
        name.textAlignment = .left
        address.textAlignment = .left
        
		if (!UIDevice.ipad()) {
			contentView.layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "device_in_device_list_corner_radius", defaultValue: 0.0))
			contentView.clipsToBounds = true
		}
		deviceImage?.isHidden = true
		
		contentView.snp.makeConstraints { (make) in
			make.height.greaterThanOrEqualTo(120)
			make.left.equalToSuperview().offset(UIDevice.ipad()  ? 0 : 20)
            make.right.equalToSuperview().offset(UIDevice.ipad()  ? 0 :-30)
		}
		
		if (!UIDevice.ipad()) {
			name.snp.makeConstraints { (make) in
				make.left.equalToSuperview().offset(6)
				make.bottom.equalTo(address.snp.top).offset(-1)
			}
			address.snp.makeConstraints { (make) in
				make.left.equalToSuperview().offset(6)
				make.bottom.equalToSuperview().offset(-17)
			}
		} else {
			name.snp.makeConstraints { (make) in
				make.left.equalTo(typeIcon.snp.right).offset(6)
				make.top.equalTo(typeIcon.snp.top).offset(20)
			}
			
			address.snp.makeConstraints { (make) in
				make.left.equalTo(typeIcon.snp.right).offset(6)
				make.bottom.equalTo(typeIcon.snp.bottom).offset(-1)
			}
			ipadSeparator?.backgroundColor = Theme.getColor("color_h")
		}
		
	}
	
	func setDevice(device:Device) {
		name.setText(text: device.name)
		address.setText(text: device.address)
		callVideo?.isHidden = UIDevice.ipad() || !device.supportsVideo()
		callAudio?.isHidden = UIDevice.ipad() || !(callVideo?.isHidden ?? true)
		device.type.map { type in
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5)) {
				self.typeIcon.prepareSwiftSVG(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:type)!, fillColor: nil, bgColor: nil)
			}
		}
		callAudio?.onClick {
			device.call()
		}
		callVideo?.onClick {
			device.call()
		}
		
		if (device.hasThumbNail() && !UIDevice.ipad()) {
			deviceImage?.image = UIImage(contentsOfFile: device.thumbNail)
			deviceImage?.isHidden = false
			if let thumb = UIImage(contentsOfFile: device.thumbNail) {
				contentView.snp.updateConstraints { (make) in
					make.height.greaterThanOrEqualTo(158)
				}
			}
		} else {
			deviceImage?.isHidden = true
			contentView.snp.updateConstraints { (make) in
				make.height.greaterThanOrEqualTo(158)
			}
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if (!UIDevice.ipad()) {
			contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
		}
	}
	
}
