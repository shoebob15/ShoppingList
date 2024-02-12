//
//  EditItemViewController.swift
//  TableViewNotes
//
//  Created by BRENNAN REINHARD on 2/8/24.
//

import UIKit

class EditItemViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.text = AppData.selectedItem.name
        priceTextField.text = String(format: "%.02f", AppData.selectedItem.price)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        let name = nameTextField.text
        let price = priceTextField.text
        
        let nameEmpty = name?.isEmpty
        let priceEmpty = price?.isEmpty
        
        if (!nameEmpty! && !priceEmpty!) {
            AppData.selectedItem = Item(id: UUID.init(), name: name!, price: Double(price!)!)
            saveItem(index: AppData.selectedItemIndex, itemObject: AppData.itemsObject)
        }
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func saveItem(index: Int, itemObject: Items) {
        itemObject.items[index] = AppData.selectedItem
    }
}
