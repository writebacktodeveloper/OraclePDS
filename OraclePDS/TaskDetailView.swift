//
//  TaskDetailView.swift
//  OraclePDS
//
//  Created by Arun CP on 24/05/21.
//

import Foundation
import  UIKit
import Photos
import MapKit
import CoreLocation

class TaskDetailView: UIViewController, UIGestureRecognizerDelegate, GlobalDelegate{
    
    //MARK:- Outlets
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lblTitleNotation: UILabel!
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
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK:- Variables
    var user = User()
    var task = Task()
    var taskStatus : TaskStatus?
    var taskDetailViewPresenter = TaskDetailViewPresenter()
    //MARK:- Default methods
    override func viewDidLoad() {
        self.setViewElements()
        self.setMapView()
        //add tapgestures
        let tapgestureProductImage = UITapGestureRecognizer(target: self, action: #selector(productImageTapAction))
        tapgestureProductImage.delegate = self
        tapgestureProductImage.numberOfTapsRequired = 1
        self.imageViewProduct.addGestureRecognizer(tapgestureProductImage)
    }
    //MARK:- Set Map view
    func setMapView() {
    
        //Get users current location.
        LocationManager.shared.getUserLocation { [weak self] location in
            //Save use location to db in background thread
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                guard let strongSelf = self else {return}
                strongSelf.taskDetailViewPresenter.setUserLocationToHistoricRecords(user: strongSelf.user.username!, id:strongSelf.task.id, location: location)
            }
            //Set user location in map using main thread
            DispatchQueue.main.async { [self] in
                guard let strongSelf = self else {return}
                strongSelf.addPinToMap(with: location)
            }
        }
        //Get historic locations in background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else {return}
            let locations = strongSelf.taskDetailViewPresenter.getHistoricRecords(user: strongSelf.user.username!, id: strongSelf.task.id)
            print("Numberof historic locations \(locations.count)")
            
            for each in locations{
                DispatchQueue.main.async { [self] in
                    guard let strongSelf = self else {return}
                    strongSelf.addPinToMap(with: each)
                    print("Location++++++++++")
                    print("Location \(each.coordinate.latitude)")
                    print("Location \(each.coordinate.longitude)")
                }
            }
        }
    }
    
    func addPinToMap(with location:CLLocation){
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate,
                                             span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)),
                          animated: true)
        mapView.addAnnotation(pin)
        LocationManager.shared.resolveLocationName(with: location) { locationName in
            let addressArray = locationName?.components(separatedBy: "")
            pin.title = addressArray?.first
            pin.subtitle = addressArray?.last
        }
    }
    
    //MARK:- Set view elements
    func setViewElements(){
        self.imageViewAvatar.bringSubviewToFront(self.view)
        self.btnAvatar.bringSubviewToFront(self.view)
        if task.barcode == nil {
            self.btnBarcodeScanner.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        }else{
            self.btnBarcodeScanner.setImage(UIImage(systemName: ""), for: .normal)
        }
        //Set place holder image for camera
        if task.image == nil {
            self.btnCamera.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        }else{
            self.btnCamera.setImage(UIImage(systemName: ""), for: .normal)
        }
        self.btnBarcodeScanner.setButtonEnabledTheme()
        self.btnCamera.setButtonEnabledTheme()
        guard let firstName = user.firstname, let lastName = user.lastname else {
            return
        }
        self.lblTaskName.text = "\(firstName.capitalized)  \(lastName.capitalized)"
        self.lblTitleNotation.text = "\(taskDetailViewPresenter.highlightTaskStatus(status: task.status))"
        self.lblTitle.text = "\(self.task.name!)"
        self.lblLatitude.text = String(self.task.lat)
        self.lblLongitude.text = String(self.task.long)
        self.lblBarcode.text = self.task.barcode
        self.btnAvatar.setTitle(Global.sharedInstance.createAvatar(user: user), for: .normal)
        self.imageViewAvatar.layer.cornerRadius = self.imageViewAvatar.frame.width / 2
        self.imageViewAvatar.clipsToBounds = true
        if let imageString = task.image{
            self.imageViewProduct.image = taskDetailViewPresenter.decodeImage(imageString: imageString)
        }
        self.btnCamera.setButtonDisabledTheme()
        self.btnBarcodeScanner.setButtonDisabledTheme()
        self.enableOrDisableButtons()
    }
    
    func enableOrDisableButtons(){
        let buttonStatus = taskDetailViewPresenter.setButtonStatus(status: task.status)
        (buttonStatus.0 == true) ? self.btnStart.setButtonEnabledTheme() : self.btnStart.setButtonDisabledTheme()
        (buttonStatus.1 == true) ? self.btnCancel.setButtonEnabledTheme() : self.btnCancel.setButtonDisabledTheme()
        (buttonStatus.2 == true) ? self.btnComplete.setButtonEnabledTheme() : self.btnComplete.setButtonDisabledTheme()
    }
    //MARK:-Tap gesture actions
    @objc func productImageTapAction(_ sender: UITapGestureRecognizer) {
        if self.imageViewProduct.image != nil {
            self.performSegue(withIdentifier: "toPreviewPage", sender: self)
        }
    }

    //MARK:-Button actions
    @IBAction func btnActionAvatar(_ sender: UIButton) {
        self.avatarButtonTapped(user: self.user)
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
        self.lblTitleNotation.text = "\(taskDetailViewPresenter.highlightTaskStatus(status: task.status))"
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: true)
    }
    @IBAction func btnActionCancel(_ sender: UIButton) {
        self.task.status = TaskStatus.cancel.rawValue
        self.lblTitleNotation.text = "\(taskDetailViewPresenter.highlightTaskStatus(status: task.status))"
        self.enableOrDisableButtons()//This should be called after setting task
        taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        Global.sharedInstance.setGlobalStatusFlag(status: false)
    }
    @IBAction func btnActionComplete(_ sender: UIButton) {
        
        //When user tap on complete button enable camera and barcode buttons.
        self.btnCamera.setButtonEnabledTheme()
        self.btnBarcodeScanner.setButtonEnabledTheme()
        //Aler the user to add barcode and product image.
        let barCode = self.lblBarcode.text
        let productImage = self.imageViewProduct.image
        if barCode == nil {
            let alert = Global.sharedInstance.showAlert(title: "Attention!", message: "Please scan the product barcode.")
            self.present(alert, animated: true, completion: nil)
        } else if productImage == nil {
            let alert = Global.sharedInstance.showAlert(title: "Attention!", message: "Please take photo of the product.")
            self.present(alert, animated: true)
        }else{
            //Update and save task details once image and barcode are added.
            self.task.status = TaskStatus.complete.rawValue
            self.enableOrDisableButtons()//This should be called after setting task.status
            taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
            Global.sharedInstance.setGlobalStatusFlag(status: false)
            //When task is complete disable camera and barcode buttons.
            self.btnCamera.setButtonDisabledTheme()
            self.btnBarcodeScanner.setButtonDisabledTheme()
            self.lblTitleNotation.text = "\(taskDetailViewPresenter.highlightTaskStatus(status: task.status))"
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
            let logArray = Global.sharedInstance.readLogFromFile()
            let vc = segue.destination as! LogViewController
            vc.dataSource = logArray
        }
    }
    func avatarButtonTapped(user:User){
        let global = Global.sharedInstance
        global.delegate = self
        let alert = Global.sharedInstance.avatarTapped(user: user)
        self.present(alert, animated: true, completion: nil)
    }
    func logout(){
        Global.sharedInstance.deleteLogFile()
        self.navigationController?.popToRootViewController(animated: true)
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
        self.task.barcode = value
        self.taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
        self.btnBarcodeScanner.setImage(UIImage(systemName: ""), for: .normal)
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
        self.task.image = encodedImageString //Assing image string to task object
        self.imageViewProduct.image = imageCaptured //Assign image to image view
        self.btnCamera.setImage(UIImage(systemName: ""), for: .normal)
        self.taskDetailViewPresenter.changeTaskState(updatedTask: self.task)//update db with image string
    }
    
}
