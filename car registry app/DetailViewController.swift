//
//  DetailViewController.swift
//  car registry app
//
//  Created by abdullah's Ventura on 29.04.2023.
//

import UIKit
import PhotosUI
import CoreData
class DetailViewController: UIViewController,PHPickerViewControllerDelegate{
    
    
    //Variables
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var carModelNameTF: UITextField!
    @IBOutlet weak var carModelYearTF: UITextField!
    @IBOutlet weak var CarModelBrandTF: UITextField!
        
    @IBOutlet weak var outlatSaveBtn: UIButton!
    
    var chosenCarName = ""
    var chosenCarId : UUID?
    //Functions
    override func viewDidLoad() {
        super.viewDidLoad()

       
        if chosenCarName != ""{
            outlatSaveBtn.isHidden = true
            
            //CoreData //core data process
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cars")
            fetchRequest.returnsObjectsAsFaults = false
            
            let idString = chosenCarId?.uuidString
            
            //filter(istedigimiz sarti saglayan verilerin cagrimi ***)
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do{
              let results =  try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as![NSManagedObject]{
                        if let carName = result.value(forKey: "carName") as? String{
                            carModelNameTF.text = carName
                        }
                        if let carYear = result.value(forKey: "carYear") as? Int{
                            carModelYearTF.text = String(carYear)
                        }
                        if let carBrand = result.value(forKey: "carBrand") as? String{
                            CarModelBrandTF.text = carBrand
                        }
                        if let imageData = result.value(forKey: "carImage") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                    }
                }
            }catch{
                outlatSaveBtn.isHidden = false
                outlatSaveBtn.isEnabled = false
                print(error.localizedDescription)
            }
        }
        
        
        //gestures
        let galleryGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(accessGallery))
        imageView.addGestureRecognizer(galleryGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        
        
    }
    

 
    //choose picture from gallery
    @objc func accessGallery(){
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker,animated: true)
    }
    //after picking tasks
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            dismiss(animated: true)
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
                let previousImage = imageView.image
                itemProvider.loadObject(ofClass: UIImage.self){[weak self] image, error in
                    DispatchQueue.main.async {
                        //select image process
                        guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else {return}
                        self.imageView.image = image
                    }
                }
        }
    }
  
  
    //keyboard visible
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func SaveButtonClicked(_ sender: Any) {
        //core data process
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newCar = NSEntityDescription.insertNewObject(forEntityName: "Cars",
                                                         into: context)
        //set Int value
        if let year = Int(carModelYearTF.text!){
            newCar.setValue(year, forKey: "carYear")
        }
        newCar.setValue(carModelNameTF.text,
                        forKey: "carName")
        newCar.setValue(CarModelBrandTF.text,
                        forKey: "carBrand")
       //set ID value
        newCar.setValue(UUID(), forKey: "id")
        
        //set Image Value
        let data = imageView.image?.jpegData(compressionQuality: 0.6)
        newCar.setValue(data, forKey: "carImage")
       
        do{
            try context.save()
            print("success")
        }catch{
            print(error.localizedDescription)
        }
        //is new data found notification
        NotificationCenter.default.post(name: NSNotification.Name("NewDataFound"),object: nil)
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

