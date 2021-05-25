//
//  TaskDetailView.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import Foundation
import  UIKit
import Photos

class TaskDetailView: UIViewController, BarcodeScannerDelegate, UIGestureRecognizerDelegate{
    
    
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
    
    var user = User()
    var task = Task()
    var taskStatus : TaskStatus?
    var taskDetailViewPresenter = TaskDetailViewPresenter()

    override func viewDidLoad() {
        self.setViewElements()
        //add tapgesture
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapgesture.delegate = self
        tapgesture.numberOfTapsRequired = 1
        self.imageViewProduct.addGestureRecognizer(tapgesture)
    }
    func setViewElements(){
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
        self.enableOrDisableButtons()
        self.btnStart.isEnabled = !Global.sharedInstance.getGlobalStatusFlag()
    }
    
    func enableOrDisableButtons(){
        let buttonStatus = taskDetailViewPresenter.setButtonStatus(status: task.status)
        self.btnStart.isEnabled = buttonStatus.0
        self.btnCancel.isEnabled = buttonStatus.1
        self.btnComplete.isEnabled = buttonStatus.2
    }
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "toPreviewPage", sender: self)
    }
    
    @IBAction func btnActionScan(_ sender: UIButton) {
        if (task.status == TaskStatus.started.rawValue){
            self.performSegue(withIdentifier: "toBarcodeScanner", sender: self)
        }else{
            let alert = Global.sharedInstance.showAlert(title: "Attention", message: "Please start the task.")
            self.present(alert, animated: true, completion: nil)
        }
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
        self.task.status = TaskStatus.complete.rawValue
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: false)
    }
    
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
        }
    }
    
    func scannedValue(value: String) {
        self.lblBarcode.text = value
        if let myNumber = NumberFormatter().number(from: value) {
            let myInt = myNumber.intValue
            self.task.barcode = Int64(myInt)
            self.taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
          } else {}
    }
    
}
extension TaskDetailView:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage{
            self.evaluvateTheImage(newImage: editedImage)
        }else if let image = info[.originalImage] as? UIImage{
            self.evaluvateTheImage(newImage: image)
        }
         dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func evaluvateTheImage(newImage:UIImage){
        if (newImage.size.height < 1300 &&  newImage.size.height < 1300 ){
            let alert = Global.sharedInstance.showAlert(title: "Attention!", message: "Image size will be limited to 1300 x 1300.")
            self.present(alert, animated: true) {
                self.processTheImage(imageCaptured: newImage)
            }
        }
    }
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
