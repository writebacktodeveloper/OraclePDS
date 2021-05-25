//
//  TaskDetailView.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import Foundation
import  UIKit
import Photos

class TaskDetailView: UIViewController, UIGestureRecognizerDelegate{
    
    //MARK:- Outlets
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var lblTaskName: UILabel!
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    @IBOutlet weak var lblBarcode: UILabel!
    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnBarcodeScanner: UIButton!
    //MARK:- Variables
    var user = User()
    var task = Task()
    var taskStatus : TaskStatus?
    var taskDetailViewPresenter = TaskDetailViewPresenter()
    
    //MARK:- Default methods
    override func viewDidLoad() {
        self.setViewElements()
        //add tapgestures
        let tapgestureProductImage = UITapGestureRecognizer(target: self, action: #selector(productImageTapAction))
        tapgestureProductImage.delegate = self
        tapgestureProductImage.numberOfTapsRequired = 1
        self.imageViewProduct.addGestureRecognizer(tapgestureProductImage)
    }
    //MARK:- Set view elements
    func setViewElements(){
        self.imageViewAvatar.bringSubviewToFront(self.view)
        self.btnAvatar.bringSubviewToFront(self.view)
        if task.barcode == 0 {
            self.btnBarcodeScanner.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        }else{
            self.btnBarcodeScanner.setImage(UIImage(systemName: ""), for: .normal)
        }
        self.btnBarcodeScanner.setButtonTheme()
        self.btnCamera.setButtonTheme()
        self.imageViewProduct.image = UIImage(systemName: "camera.viewfinder")
        guard let firstName = user.firstname, let lastName = user.lastname else {
            return
        }
        self.lblTaskName.text = "\(firstName) \(lastName)"
        self.lblTitle.text = "\( taskDetailViewPresenter.highlightTaskStatus(status: task.status))\(self.task.name!)"
        self.lblLatitude.text = String(self.task.lat)
        self.lblLongitude.text = String(self.task.long)
        self.lblBarcode.text = String(self.task.barcode)
        self.btnAvatar.setTitle(Global.sharedInstance.createAvatar(user: user), for: .normal)
        self.imageViewAvatar.layer.cornerRadius = self.imageViewAvatar.frame.width / 2
        self.imageViewAvatar.clipsToBounds = true
        if let imageString = task.image{
            self.imageViewProduct.image = taskDetailViewPresenter.decodeImage(imageString: imageString)
        }
        self.btnCamera.isEnabled = false
        self.btnBarcodeScanner.isEnabled = false
        self.enableOrDisableButtons()
    }
    
    func enableOrDisableButtons(){
        let buttonStatus = taskDetailViewPresenter.setButtonStatus(status: task.status)
        self.btnStart.isEnabled = buttonStatus.0
        self.btnCancel.isEnabled = buttonStatus.1
        self.btnComplete.isEnabled = buttonStatus.2
    }
    //MARK:-Tap gesture actions
    @objc func productImageTapAction(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "toPreviewPage", sender: self)
    }

    //MARK:-Button actions
    @IBAction func btnActionAvatar(_ sender: UIButton) {
        func avatarButtonTapped(user:User)->UIAlertController{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { alert in
                self.logout()
            }))
            if user.adminuser {
                alert.addAction(UIAlertAction(title: "Show log", style: .cancel, handler: { alert in
                    self.navigateToLogs()
                }))
            }
            return alert
        }
    }
    
    @IBAction func btnActionScan(_ sender: UIButton) {
        self.checkAndOpenCameraForBarCodeScaning()
    }
    
    @IBAction func btnActionCamera(_ sender: UIButton) {
        if (task.status == TaskStatus.started.rawValue){
            self.openCamera()
        }else{
            let alert = Global.sharedInstance.showAlert(title: "Attention", message: "Please start the task.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func btnActionStart(_ sender: UIButton) {
        self.task.status = TaskStatus.started.rawValue
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: true)
    }
    @IBAction func btnActionCancel(_ sender: UIButton) {
        self.task.status = TaskStatus.cancel.rawValue
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: false)
    }
    @IBAction func btnActionComplete(_ sender: UIButton) {
        
        //When user tap on complete button enable camera and barcode buttons.
        self.btnCamera.isEnabled = true
        self.btnBarcodeScanner.isEnabled = true
        //Aler the user to add barcode and product image.
        if self.task.barcode == 0 {
            let alert = Global.sharedInstance.showAlert(title: "Attention!", message: "Please scan the product barcode.")
            self.present(alert, animated: true, completion: nil)
        } else if self.task.image == nil {
            let alert = Global.sharedInstance.showAlert(title: "Attention!", message: "Please take photo of the product.")
            self.present(alert, animated: true)
        }else{
            //Update and save task details once image and barcode are added.
            self.task.status = TaskStatus.complete.rawValue
            self.enableOrDisableButtons()//This should be called after setting task.status
            taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
            Global.sharedInstance.setGlobalStatusFlag(status: false)
            //When task is complete disable camera and barcode buttons.
            self.btnCamera.isEnabled = false
            self.btnBarcodeScanner.isEnabled = false

        }
    }
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBarcodeScanner"{
            let VC = segue.destination as! ScannerViewController
            VC.delegate = self
        }
        else if segue.identifier == "toPreviewPage"{
            guard let image = self.imageViewProduct.image else {
                return
            }
            let vc = segue.destination as! ImagePreviewController
            vc.image = image
        } else if segue.identifier == "navigateToLogs"{

            let vc = segue.destination as! LogViewController
            
        }
    }
    
    func logout(){
        self.navigationController?.navigationBar.popItem(animated: true)
    }
    func navigateToLogs(){
        self.performSegue(withIdentifier: "navigateToLogs", sender: nil)
    }
}

//MARK:- Class extenstion
extension TaskDetailView:BarcodeScannerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Barcode scanner
    func checkAndOpenCameraForBarCodeScaning(){
        if (task.status == TaskStatus.started.rawValue){
            self.performSegue(withIdentifier: "toBarcodeScanner", sender: self)
        }else{
            let alert = Global.sharedInstance.showAlert(title: "Attention", message: "Please start the task.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    //Barcode Scanner view delegate method
    func scannedValue(value: String) {
        self.lblBarcode.text = value
        if let myNumber = NumberFormatter().number(from: value) {
            let myInt = myNumber.intValue
            self.task.barcode = Int64(myInt)
            self.taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
            self.btnBarcodeScanner.setBackgroundImage(UIImage(systemName: ""), for: .normal)
        } else {}
    }
    //Image capturing
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status{
                case .authorized:
                    DispatchQueue.main.async {
                    let pickerController = UIImagePickerController()
                    pickerController.allowsEditing = true
                    pickerController.sourceType = .camera
                    pickerController.delegate = self
                    self.present(pickerController, animated: true)
                    }
                default:
                        break
                }
            }
        }
    }
    //Image capturing delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage{
            self.evaluvateTheImage(newImage: editedImage)
        }else if let image = info[.originalImage] as? UIImage{
            self.evaluvateTheImage(newImage: image)
        }
         dismiss(animated: true)
    }
    //Image capturing cancel delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    //Evaluvate the captured image
    func evaluvateTheImage(newImage:UIImage){
        if (newImage.size.height < 1300 &&  newImage.size.height < 1300 ){
            let alert = Global.sharedInstance.showAlert(title: "Attention!", message: "Unable to process the image. Maximum image size allowed is 1300 x 1300.")
            self.present(alert, animated: true)
        }
        self.processTheImage(imageCaptured: newImage)
    }
    //Save image to task instance and update db
    func processTheImage(imageCaptured:UIImage){
        guard let encodedImageString = taskDetailViewPresenter.encodeImage(image: imageCaptured) else {
            self.imageViewProduct.image = UIImage(named: "")
            return
        }
        self.task.image = encodedImageString
        self.imageViewProduct.image = imageCaptured
        self.taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
    }
    
}
