//
//  FivePTrialViewController.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 23/12/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import UIKit
import WebKit
import MobileCoreServices
import AVKit
import AVFoundation
import QuickLook

class FivePaisaPwaViewController: UIViewController,
                                WKNavigationDelegate,
                                WKScriptMessageHandler,
                                UINavigationControllerDelegate,
                                UIImagePickerControllerDelegate,
                                QLPreviewControllerDataSource
{

    weak var delegate:FivePaisaPwaControllerDelegate?
    
    var documentUrl = URL(fileURLWithPath: "")
    
    var documentPreviewController = QLPreviewController()
    
    var params : [String : String]?
    
    private var showSmallcaseLoader: Bool

    private enum MessageHandlers {
        static let openNativeApp = "invokeAppCallBack"
        static let fetchImage = "fetchImage"
        static let fetchIPV = "fetchIPV"
        static let closeApp = "closeApp"
    }
    
    var webViewAnimated = false
    
    let defaults = UserDefaults.standard
    
    //MARK: UI Variables
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(images[ImageConstants.closeIconWhite]!, for: .normal)
        button.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        return button
    }()
    
    fileprivate var titleLabel: UILabel = {
        let label = PaddingLabel.init(withInsets: 0, 10, 0, 0)
        label.font = UIFont(name: "GraphikApp-Medium", size: 16 )
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.text = "Open Demat Account on 5Paisa"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        return view
    }()
    
    // Shows smallcase loading Icon
    fileprivate lazy var smallcaseLoaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGif(name: "smallcase-loader")
        return imageView
    }()
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: MessageHandlers.openNativeApp)
        configuration.userContentController.add(self, name: MessageHandlers.fetchImage)
        configuration.userContentController.add(self, name: MessageHandlers.fetchIPV)
        configuration.userContentController.add(self, name: MessageHandlers.closeApp)
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        configuration.preferences = preferences
            
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.backgroundColor = .clear
        webView.backgroundColor = .clear
        webView.layer.cornerRadius = 20.0
        webView.clipsToBounds = true
        
        return webView
        
    }()
    
    //MARK: - Initialisation
    
    init(params: [String: String]?, showSmallcaseLoader: Bool) {
        self.params = params
        self.showSmallcaseLoader = showSmallcaseLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // QuickLook document preview
        documentPreviewController.dataSource  = self
        
        setupUI()
        loadWebviewUrl()
    }
    
    func setupUI() {
        
        self.view.addSubview(containerView)
        containerView.addSubview(cancelButton)
        containerView.addSubview(titleLabel)

        self.view.addSubview(smallcaseLoaderImageView.withSize(.init(width: 127, height: 80)))
        smallcaseLoaderImageView.centerInSuperview()
//        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.view.addSubview(webView)

        if !self.showSmallcaseLoader {
            smallcaseLoaderImageView.isHidden = true
        }
        
        containerView.anchor(
            self.view.safeAreaLayoutGuide.topAnchor,
            left: self.view.safeAreaLayoutGuide.leftAnchor,
            bottom: nil,
            right: nil,
            topConstant: 10,
            leftConstant: 4,
            bottomConstant: 10,
            rightConstant: 0,
            widthConstant: self.view.bounds.width,
            heightConstant: 30
        )
        
        cancelButton.anchor(
            containerView.topAnchor,
            left: containerView.leftAnchor,
            bottom: containerView.bottomAnchor,
            right: nil,
            topConstant: 0,
            leftConstant: 10,
            bottomConstant: 10,
            rightConstant: 0,
            widthConstant: 20,
            heightConstant: 25
        )
            
        titleLabel.anchor(
            containerView.topAnchor,
            left: cancelButton.rightAnchor,
            bottom: containerView.bottomAnchor,
            right: nil,
            topConstant: 0,
            leftConstant: 10,
            bottomConstant: 0,
            rightConstant: 0
        )
        
        NSLayoutConstraint.activate([
            webView.topAnchor
                .constraint(equalTo: self.containerView.bottomAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
        
        containerView.alpha = 0
        webView.alpha = 0
    }
    
    func loadWebviewUrl() {
        
        SCGateway.shared.getFivePaisaLeadAuthToken(email: params!["email"]!, source: "ios") { result in
            
            switch result {
                
            case .success(let fivePaisaLeadGen):
                
                DispatchQueue.main.async {
                    self.initWebView(authToken: fivePaisaLeadGen.data!.token)
                }
                
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func initWebView(authToken: String) {
     
        let stringToBeSent = "FRM_PWA_DATA=\(authToken)"
        
        var request = URLRequest(url: URL(string: params!["pwaUrL"]!)!)
        
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postData: Data = stringToBeSent.data(using: String.Encoding.utf8)!
        request.httpBody = postData
        
        webView.load(request as URLRequest)

    }
    
    //MARK: - JS Callbacks
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let messageBody = message.body as? [String : Any] else {
            return
        }
        
        print(message.name)
        
        print(messageBody)
        
        switch message.name {
        case "invokeAppCallBack":
            defaults.set(messageBody["ClientCode"] as? String, forKey: "fivePClientCode")
        
        case "fetchImage":
            print("fetchImage called")
            print(messageBody["allowedSources"]!)
            
            if let array = messageBody["allowedSources"]! as? [Any] {
                
                if let firstObject = array.first {
                    // access individual object in array
                    if(array.count == 1 && firstObject as! String == "camera") {
                        pickMedia(sourceType: .camera, mimeType: "image")
                    } else {
                        pickMedia(sourceType: .photoLibrary, mimeType: "")
                    }
                }
            }
            
        case "fetchIPV":
            print("fetch IPV called")
            pickMedia(sourceType: .camera, mimeType: "video")
            
        case "closeApp":
            print("closeApp called")
            
            let timeDelay = Double((messageBody["time"] as? String)!)
            
            if(timeDelay != nil) {
            
                DispatchQueue.main.asyncAfter(deadline: .now() + timeDelay!) {
                    self.didTapDismiss()
                }
                
            }
            
        default:
            print(message.name)
        }
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            let url = navigationAction.request.url,
            let scheme = url.scheme else {
                decisionHandler(.cancel)
                return
        }
        
        if ((scheme.lowercased() == "mailto" || scheme.lowercased() == "tel")  && !url.absoluteString.contains("https://vars.hotjar.com")) {
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        
        if #available(iOS 13.0, *) {
         
            if(self.webViewAnimated == false) {
                
                self.webViewAnimated = true
                self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
                UIView.animate(withDuration: 0.3,
                                delay: 0,
                                 usingSpringWithDamping: 1.0,
                                 initialSpringVelocity: 1.0,
                                 options: .transitionCurlUp, animations: {
                                    
                                    self.containerView.alpha = 1
                                    webView.alpha = 1
                                    
                                    self.containerView.frame = CGRect(x: 0, y: 0, width: self.containerView.bounds.size.width, height: UIScreen.main.bounds.size.height - self.containerView.bounds.size.height)
                                    self.webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.webView.bounds.size.height)
                                 }, completion: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //add downloading file code here
        
        let url = navigationResponse.response.url
                if (openInDocumentPreview(url!)) {
                    let documentUrl = url?.appendingPathComponent(navigationResponse.response.suggestedFilename!)
                    loadAndDisplayDocumentFrom(url: documentUrl!)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
    }
    
    
    
    private func loadAndDisplayDocumentFrom(url downloadUrl : URL) {
        
        let localFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(downloadUrl.lastPathComponent)
        
        debugPrint("Downloading document from url=\(downloadUrl.absoluteString)")
        
        URLSession.shared.dataTask(with: downloadUrl) { data, response, err in
            guard let data = data, err == nil else {
                debugPrint("Error while downloading document from url=\(downloadUrl.absoluteString): \(err.debugDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                               debugPrint("Download http status=\(httpResponse.statusCode)")
            }
            
            do {
                try data.write(to: localFileURL, options: .atomic)
                
                debugPrint("Stored document from url=\(downloadUrl.absoluteString) in folder=\(localFileURL.absoluteString)")
                
                DispatchQueue.main.async {
                                        self.documentUrl = localFileURL
                                        self.documentPreviewController.refreshCurrentPreviewItem()
                                        self.present(self.documentPreviewController, animated: true, completion: nil)
                }
            } catch {
                debugPrint(error)
                return
            }
        }.resume()
    }
    
    func pickMedia(sourceType: UIImagePickerController.SourceType, mimeType: String) {
        
        guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        
        if sourceType == .photoLibrary {
            picker.mediaTypes = ["public.image"]
        } else {
            
            if mimeType == "video" {
                picker.mediaTypes = [kUTTypeMovie as String]
                picker.cameraCaptureMode = .video
                picker.cameraDevice = .front
            } else {
                picker.cameraCaptureMode = .photo
                picker.cameraDevice = .front
            }
            
        }
        
        picker.modalPresentationStyle = .overCurrentContext
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var dataToSend: String?
        var javascript: String = ""
        
        if(picker.sourceType == .photoLibrary || (picker.sourceType == .camera && picker.cameraCaptureMode == .photo)) {
           
            guard let image = info[.editedImage] as? UIImage else {return}

            var imageData: Data?
            
            if let jpegData = image.jpegData(compressionQuality: 0.1) {
                imageData = jpegData
            }
            
            let imagejson : [String: Any?] = [
                "bytes": imageData?.base64EncodedString(),
                "mimeType": "image/jpeg"
            ]
            
            let jsonData = (try? JSONSerialization.data(withJSONObject: imagejson, options: []))!

            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            
            dataToSend = jsonString.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            
            javascript = "window.fetchImageResponseiOS('\(dataToSend!)')"
            
            webView.evaluateJavaScript(javascript, completionHandler: nil)
            
            picker.dismiss(animated: true, completion: nil)
            
        } else {
            
            let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL

            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
            var compressedFileData : Data? =  nil
            
            compressVideo(inputURL: videoUrl!, outputURL: compressedURL, handler: { (_ exportSession: AVAssetExportSession?) -> Void in

                switch exportSession!.status {
                    case .completed:

                    print("Video compressed successfully")
                    do {
                        compressedFileData = try Data(contentsOf: exportSession!.outputURL!)
                        
                        dataToSend = compressedFileData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
                        // Call upload function here using compressedFileData
                        
                        javascript = "window.fetchIPVResponseiOS('\(dataToSend!)')"
                        
                        print("javascript \(javascript)")
                        
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true, completion: nil)
                            self.webView.evaluateJavaScript(javascript, completionHandler: nil)
//                            self.dismiss(animated: true)
                        }
                        
                        
                    } catch _ {
                        print ("Error converting compressed file to Data")
                    }

                    default:
                        print("Could not compress video")
                }
            } )
            
        }

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        
        let assetSize =  urlAsset.tracks(withMediaType: .video)[0].naturalSize
        
        print("Asset Size = \(assetSize)")
        
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetLowQuality) else {
            handler(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }


    @objc func didTapDismiss() {
        print("Dismiss button tapped")
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.calculationModeCubic], animations: {
            // Add animations
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.view.frame.origin.y += 32
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.view.alpha = 0
            })
        }, completion:{ _ in
            self.delegate?.dismissFivePaisaPwa()
        })

    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentUrl as QLPreviewItem
    }
    
    /*
     Checks if the given url points to a document provided by Vaadin FileDownloader and returns 'true' if yes
     */
    private func openInDocumentPreview(_ url : URL) -> Bool {
        return url.absoluteString.contains("downloadFile")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
