//
//  QRScanViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/21/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import AVFoundation

struct PaymentInfo {
    // Nano amount as RAW
    let amount: String?
    let address: String?
    // Non-RAW amount
    var nanoAmount: String? {
        guard let amount = self.amount else { return nil }
        let mxrb = amount.decimalNumber.mxrbAmount
        return nanoFormatter(12).string(from: mxrb) ?? "0"
    }
}

class QRScanViewController: UIViewController {

    @IBOutlet weak var qrScanTipLabel: UILabel?
    @IBOutlet weak var qrImageView: UIImageView?
    @IBOutlet weak var qrIndicatorView: UIView?
    @IBOutlet weak var blurView: UIVisualEffectView?
    @IBOutlet weak var boundaryImageView: UIImageView?
    fileprivate var captureSession: AVCaptureSession = AVCaptureSession()
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var onQRCodeScanned: ((PaymentInfo) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrScanTipLabel?.text = .localize("qr-scan-tip")
        qrIndicatorView?.layer.cornerRadius = 25.0
        qrIndicatorView?.layer.borderWidth = 1.0
        qrIndicatorView?.layer.borderColor = UIColor.clear.cgColor
        qrImageView?.tintColor = .white
        qrImageView?.image = #imageLiteral(resourceName: "scan_address_l").withRenderingMode(.alwaysTemplate)
        
        setupNavBar()
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                        self.viewDidLayoutSubviews()
                    }
                }
            })
        case .denied, .restricted:
            Banner.show(.localize("no-cam-access"), style: .danger)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.layer.bounds
        view.layoutIfNeeded()
        guard let blur = blurView, let boundary = boundaryImageView else { return }
        view.mask(viewToMask: blur, maskRect: boundary.frame, invert: true, cornerRadius: 25.0)
    }
    
    // MARK: - Setup
    
    fileprivate func setupCamera() {
        let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDuoCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceSession.devices.first else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            captureMetadataOutput.metadataObjectTypes = [.qr]
        } catch {
            Lincoln.log(error.localizedDescription)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        captureSession.startRunning()
    }
    
    fileprivate func setupNavBar() {
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close2"), style: .plain, target: self, action: #selector(closeTapped(_:)))
        leftBarItem.tintColor = .white
        navigationItem.leftBarButtonItem = leftBarItem
    }
    
    // MARK: - Actions
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, metadataObject.type == .qr else {
            qrIndicatorView?.layer.borderColor = UIColor.clear.cgColor
            return }
        guard let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject), let qrView = qrIndicatorView else { return }
        guard qrView.frame.contains(barCodeObject.bounds) else { return }
        if let value = metadataObject.stringValue {
            var address: String?
            var amount: String?
            
            // First check if the QR code scanned is an address, if that's the case, ignore parsing a request QR code
            if let _ = WalletUtil.derivePublic(from: value) {
                address = value
            }
            qrIndicatorView?.layer.borderColor = UIColor.green.cgColor
            // Example format: xrb:xrb_3wm37qz19zhei7nzscjcopbrbnnachs4p1gnwo5oroi3qonw6inwgoeuufdp?amount=1000
            if let paymentInfo = URLHandler.parse(urlString: value), let _ = WalletUtil.derivePublic(from: paymentInfo.address ?? "") {
                address = paymentInfo.address
                amount = paymentInfo.amount
            }
            guard let addr = address else {
                qrIndicatorView?.layer.borderColor = UIColor.red.cgColor
                return
            }
            // 
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.onQRCodeScanned?(PaymentInfo(amount: amount, address: addr))
                self.dismiss(animated: true)
            })
        }
    }
}
