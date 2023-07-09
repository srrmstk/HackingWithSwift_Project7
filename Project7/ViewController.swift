//
//  ViewController.swift
//  Project7
//
//  Created by srrmstk on 08.07.2023.
//

import UIKit

class ViewController: UITableViewController {

  var petitions = [Petition]()
  var filteredPetitions = [Petition]()
  var urlString: String = ""

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.rowHeight = 88.0

    if navigationController?.tabBarItem.tag == 0 {
      urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
    } else {
      urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
    }

    let filterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showFilterAlert))
    let clearButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(clearFilter))

    navigationItem.leftBarButtonItems = [clearButton, filterButton]

    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))

    fetchData(urlString: urlString)
  }

  func fetchData(urlString: String) {
    if let url = URL(string: urlString) {
      if let data = try? Data(contentsOf: url) {
        parse(json: data)
        return
      }
    }

    showError()
  }

  func parse(json: Data) {
    let decoder = JSONDecoder()

    if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
      petitions = jsonPetitions.results
      filteredPetitions = petitions
      tableView.reloadData()
    }
  }

  func showError() {
    let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }

  @objc
  func showFilterAlert() {
    let ac = UIAlertController(title: "Filter Petitions", message: "Prompt your string", preferredStyle: .alert)
    ac.addTextField()
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
      if let text = ac?.textFields?[0].text {
        self?.filterPetitions(value: text)
      }
    }))

    present(ac, animated: true)
  }

  func filterPetitions(value: String) {
    let filteredPetitions = petitions.filter { petition in
      petition.title.contains(value) || petition.body.contains(value)
    }
    self.filteredPetitions = filteredPetitions
    tableView.reloadData()
  }

  @objc
  func clearFilter() {
    filteredPetitions = petitions
    tableView.reloadData()
  }

  @objc
  func showCredits() {
    let ac = UIAlertController(title: "Credits", message: "All the data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredPetitions.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
    var content = cell.defaultContentConfiguration()
    let petition = filteredPetitions[indexPath.row]
    content.text = petition.title
    content.secondaryText = petition.body
    cell.contentConfiguration = content
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = DetailsViewController()
    vc.detailItem = filteredPetitions[indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
  }

}

