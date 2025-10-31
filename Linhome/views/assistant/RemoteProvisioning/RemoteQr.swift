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
import AVFoundation

class RemoteQr: MainViewContentWithScrollableForm {
	
	
	@IBOutlet weak var captureView: UIView!
	@IBOutlet weak var scanAreaMask: UIImageView!
	@IBOutlet weak var fullScreenMaskView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
		
		viewTitle.setText(textKey: "assistant_remote_from_qr")
        viewTitle.font = UIFont(name:FontKey.SEMIBOLD.rawValue, size: 26)
		viewSubtitle.setText(textKey: "assistant_remote_from_qr_desc")
        viewSubtitle.textColor = Theme.getColor("color_secondary")
        
        viewTitle.textAlignment = .justified
        viewSubtitle.textAlignment = .justified
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.42
        viewSubtitle.attributedText = NSMutableAttributedString(string: viewSubtitle.text!, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])


        NavigationManager.it.hiddenHomeOptions()
        
        viewSubtitle.snp.updateConstraints { (make) in
            make.top.equalTo(viewTitle.snp.bottom).offset(6)
        }
		
		let model = RemoteAnyViewModel()
		manageModel(model)
		
		model.qrCodeFound.observeAsUniqueObserver { found in
			self.showProgress()
		}
		
		model.configurationResult.observeAsUniqueObserver(onChange : { status in
			if (status != ConfiguringState.Successful) {
				self.hideProgress()
				NavigationManager.it.doNavigateUp()
				DialogUtil.error("remote_configuration_failed")
			}
		})
		
		model.pushReady.observeAsUniqueObserver(onChange: { pushready in
			self.hideProgress()
			NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
			if (pushready!) {
				DialogUtil.info("remote_configuration_success")
			} else {
				DialogUtil.error("failed_creating_pushgateway")
			}
		})
		
		addMask()
	}
	
	func setBackCamera() {
		guard let backDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .back) else {
			return
		}
		Core.get().videoDevicesList.forEach {
			if ($0.contains(backDevice.uniqueID)) {
				try?Core.get().setVideodevice(newValue: $0)
			}
		}
		
	}
	
	func addMask() {
		fullScreenMaskView.backgroundColor =  Theme.getColor("color_c")
		scanAreaMask.autoresizingMask = [.flexibleRightMargin,.flexibleLeftMargin]
		scanAreaMask.backgroundColor = UIColor.clear
		scanAreaMask.prepare(iconName: "icons/qrcode_mask.png", fillColor: nil, bgColor: nil) // PNG fall back, as both PocketSVG and SwiftSVG fail to render properly
	}
	
	
	func startScanner() {
		setBackCamera()
		Core.get().qrcodeVideoPreviewEnabled = true
		Core.get().videoPreviewEnabled = true
	}
	
	#if !targetEnvironment(simulator)
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		Core.get().nativePreviewWindowId = UnsafeMutableRawPointer(Unmanaged.passUnretained(self.captureView).toOpaque())
		startScanner()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		Core.get().nativePreviewWindowId = nil
		Core.get().qrcodeVideoPreviewEnabled = false
		Core.get().videoPreviewEnabled = false
    self.hideProgress()
		super.viewWillDisappear(animated)
	}
	
	#endif
	
	
	override func viewDidLayoutSubviews() {
		
		// Create square hole for the image mask
		
		let path = UIBezierPath(rect: fullScreenMaskView.bounds)
		let croppedPath = UIBezierPath(roundedRect: scanAreaMask.frame, cornerRadius: 0)
		path.append(croppedPath)
		path.usesEvenOddFillRule = true
		
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		mask.fillRule = .evenOdd
		fullScreenMaskView.layer.mask = mask
	}
}
