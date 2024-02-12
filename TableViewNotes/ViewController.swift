import UIKit

class AppData {
    static var itemsObject = Items()
    static var selectedItem = Item(id: UUID.init(), name: "Error", price: 0.00)
    static var selectedItemIndex = 0
}

struct Item: Identifiable, Codable {
    let id: UUID
    var name: String
    var price: Double
}

class Items: NSObject {
    var items = [Item]() {
        didSet {
            saveItems()
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "Items")
        }
    }
    
    override init() {
        super.init()
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([Item].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
    
    func itemExists(_ checkItem: Item) -> Bool {
        for item in items {
            if item.name.lowercased() == checkItem.name.lowercased() {
                return true
            }
        }
        return false
    }
    
    func findItem(_ name: String) -> Item? {
        var index = 0;
        for item in items {
            // there shouldn't be duplicates, since users can't add the same item twice
            if item.name.lowercased() == name.lowercased() {
                // bad practice, should probably be changed
                AppData.selectedItemIndex = index
                return items[index]
            }
            index += 1
        }
        return nil
    }
    
    func sort() {
        items = items.sorted() { $1.name > $0.name }
    }
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.dataSource = self
        tableViewOutlet.delegate = self
    }
    
    // return length of data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.itemsObject.items.count
    }
    
    // load data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let item = AppData.itemsObject.items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(format: "$%.02f", item.price)
        return cell
    }
    
    // cell selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemName = tableView.cellForRow(at: indexPath)?.textLabel?.text {
            if let item = AppData.itemsObject.findItem(itemName) {
                print(item.id)
                AppData.selectedItem = item
                performSegue(withIdentifier: "editSegue", sender: nil)
            }
        }
    }
    
    // swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AppData.itemsObject.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewOutlet.reloadData()
    }
    
    // add item
    @IBAction func addItemBarButton(_ sender: UIBarButtonItem) {
        let name = itemTextField.text
        let price = priceTextField.text
        
        let validInput = price != "" && name != ""
        
        if (validInput) {
            let newItem = Item(id: UUID(), name: name!, price: Double(price!)!)
            if (!AppData.itemsObject.itemExists(newItem)) {
                AppData.itemsObject.items.append(newItem)
            } else {
                let alertController = UIAlertController(title: "Error", message: "That item already exists", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alertController, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter non-empty values", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alertController, animated: true)
        }
        
        itemTextField.text = ""
        priceTextField.text = ""
        
        itemTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
        
        tableViewOutlet.reloadData()
    }
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        AppData.itemsObject.sort()
        tableViewOutlet.reloadData()
    }
}
