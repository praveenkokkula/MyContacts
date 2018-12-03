//
//  CountryViewController.swift
//  UIContacts
//
//  Created by Praveen on 01/12/18.
//

import UIKit

protocol CountryProtocol {
    func getCountryName(countryName: String)
}

class CountryViewController: UIViewController {
    var delegate: CountryProtocol?
    @IBOutlet var countryTableView: UITableView!
    @IBOutlet var countrySearchBar: UISearchBar!
    var countryNamesArray: [String] = []
    var searchCountry = [String] ()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryTableView.delegate = self
        countryTableView.dataSource = self
        countrySearchBar.delegate = self
        self.fetchCountries()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.countrySearchBar.tintColor = UIColor.darkGray
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func  fetchCountries()  {
        let url = URL(string: CountryListAPI)
        if let urlString = url {
            let task = URLSession.shared.dataTask(with: urlString) { (data, response, error) in
                if error != nil {
                    self.showDefaultAlert()
                } else {
                    if let usableData = data {
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: usableData, options : .allowFragments) as? [NSDictionary]
                            {
                                self.addCountries(countyDict: jsonArray)
                            } else {
                            }
                        } catch _ as NSError {
                            self.showDefaultAlert()
                        }
                    }
                }
                
            }
            task.resume()
        }
    }
    func addCountries(countyDict: [NSDictionary] ) {
        for item in countyDict {
            if let countryName = item.value(forKey: "name") as? String {
                self.countryNamesArray.append(countryName)
            }
        }
        DispatchQueue.main.async {
            self.countryTableView.reloadData()
        }
    }
    func showDefaultAlert() {
        let alert = UIAlertController(title: "Error loading the Countries", message: "Setting the default country as India", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: { (okAction) in
            self.dismiss(animated: true, completion: nil)
            self.delegate?.getCountryName(countryName: "India")
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CountryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchCountry.count
        } else {
            return countryNamesArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countryCell = countryTableView.dequeueReusableCell(withIdentifier: CountryCellIdentifier) as? CountryTableViewCell
        if searching {
            countryCell?.countryNameCell?.text = searchCountry[indexPath.row]
        } else {
            countryCell?.countryNameCell?.text = countryNamesArray[indexPath.row]
        }
        return countryCell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        if searching {
                self.delegate?.getCountryName(countryName: searchCountry[indexPath.row])
        } else {
                self.delegate?.getCountryName(countryName: countryNamesArray[indexPath.row])
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
extension CountryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text , !(searchBar.text?.isEmpty)! {
            self.getTheSearchResults(searchText: searchText)
        } else {
            searching = false
        }
        DispatchQueue.main.async {
            self.countryTableView.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text , !(searchBar.text?.isEmpty)! {
            self.getTheSearchResults(searchText: searchText)
        } else {
            searching = false
        }
        DispatchQueue.main.async {
            self.countryTableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        DispatchQueue.main.async {
            self.countryTableView.reloadData()
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text , !(searchBar.text?.isEmpty)! {
            self.getTheSearchResults(searchText: searchText)
        }
    }
    func getTheSearchResults(searchText: String) {
        searchCountry = countryNamesArray.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
    }
    
}


