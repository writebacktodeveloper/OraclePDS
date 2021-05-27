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
        LocationManager.shared.getUserLocation { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else {return}
                strongSelf.addPinToMap(with: location)
                let cordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude + 1, longitude: location.coordinate.latitude)
                let secondLocation : CLLocation = CLLocation(latitude: cordinates.latitude, longitude: cordinates.longitude)
                strongSelf.addSecondPinToMap(with: secondLocation)
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
        LocationManager.shared.resolveLocationName(with: location) { [weak self] locationName in
            pin.title = locationName
            pin.subtitle = locationName
        }
    }
    func addSecondPinToMap(with location:CLLocation){
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate,
                                             span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)),
                          animated: true)
        mapView.addAnnotation(pin)
        LocationManager.shared.resolveLocationName(with: location) { [weak self] locationName in
            print("Local address \(locationName ?? "")")
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
        self.lblTitle.text = "\( taskDetailViewPresenter.highlightTaskStatus(status: task.status))\(self.task.name!)"
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
        self.btnCamera.setButtonEnabledTheme()
        self.btnBarcodeScanner.setButtonEnabledTheme()
        //Aler the user to add barcode and product image.
        if self.task.barcode == nil {
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
            self.btnCamera.setButtonDisabledTheme()
            self.btnBarcodeScanner.setButtonDisabledTheme()

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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if user.adminuser {
            alert.addAction(UIAlertAction(title: "Show log", style: .cancel, handler: { alert in
                self.navigateToLogs()
            }))
        }
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { alert in
            self.logout()
        }))
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
            self.taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
            self.btnBarcodeScanner.setBackgroundImage(UIImage(systemName: ""), for: .normal)
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
        self.btnCamera.setImage(UIImage(systemName: ""), for: .normal)
        self.taskDetailViewPresenter.changeTaskState(updatedTask: self.task)
    }
    
}
