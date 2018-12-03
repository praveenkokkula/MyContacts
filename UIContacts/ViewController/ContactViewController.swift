//
//  ViewController.swift
//  UIContacts
//
//  Created by Praveen on 28/11/18.
//

import UIKit
import  CoreData
class ContactViewController: UIViewController {
    var fetchedContacts: [Contact] = []
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var contactsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.fetchContactsFromStorage()
        self.hideKeyboard()
        self.searchBar.tintColor = UIColor.darkGray
    }
    func fetchContactsFromStorage() {
        fetchedContacts.removeAll()
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contacts")
        do {
            let details = try managedContext.fetch(fetchRequest)
            for items in details  {
                let contacts = Contact.init(detail: items)
                fetchedContacts.append(contacts)
            }
            contactsTableView.reloadData()
        } catch let error as NSError {
            print("Error in fetching the contacts from Storage \(error), \(error.userInfo)")
        }
    }
    }
extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  fetchedContacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = tableView.dequeueReusableCell(withIdentifier: ContactCellIdentifier) as? ContactsTableViewCell
        let contactDetails = fetchedContacts[indexPath.row]
        contactCell?.assignValues(contactCell: contactDetails)
        return contactCell!
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.05, 1.05, 1)
        }) { (finished) in
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.transform = CATransform3DMakeScale(1.05, 1.05, 1)
            })
        }
    }
}
extension ContactViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text , !(searchBar.text?.isEmpty)! {
            self.fetchResults(searchText: searchText)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text , !(searchBar.text?.isEmpty)! {
            self.fetchResults(searchText: searchText)
        } else {
            self.fetchContactsFromStorage()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.fetchContactsFromStorage()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Entered text is:\(String(describing: searchBar.text))")
        if let searchText = searchBar.text , !(searchBar.text?.isEmpty)! {
            self.fetchResults(searchText: searchText)
        }
    }
    func fetchResults(searchText: String) {
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: ContactEntity)
        let predicate =  NSPredicate(format: "(firstName BEGINSWITH[c] %@) OR (lastName BEGINSWITH[c] %@)",searchText,searchText)
        fetchRequest.predicate = predicate
        do {
            let details = try managedContext.fetch(fetchRequest)
            fetchedContacts.removeAll()
            for items in details  {
                let contacts = Contact.init(detail: items)
                fetchedContacts.append(contacts)
            }
            contactsTableView.reloadData()
        } catch let error as NSError {
            print("Error in fetching the contacts from Storage \(error), \(error.userInfo)")
        }
    }
}
extension ContactViewController {
    func hideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self,action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
