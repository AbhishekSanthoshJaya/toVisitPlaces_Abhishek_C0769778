//
//  PlacesListTableViewController.swift
//  FindWay_Abhishek_C0769778
//
//  Created by user166476 on 6/14/20.
//  Copyright © 2020 user166476. All rights reserved.
//

import UIKit

class PlacesListTableViewController: UITableViewController {
    
    var places : [FavoritePlace]?
    var deleteArray : [FavoritePlace]?
    let defaults = UserDefaults.standard
    

    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        loadData()
        self.tableView.reloadData()
            
    }
        
    func getDataFilePath() -> String
    {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = documentPath.appending("/places-data.txt")
        return filePath
    }
        
    func loadData()
    {
        
        places = [FavoritePlace]()
        let filePath = getDataFilePath()
        if FileManager.default.fileExists(atPath: filePath)
        {
                do
                {
            
                 let fileContent = try String(contentsOfFile: filePath)
                 let contentArray = fileContent.components(separatedBy: "\n")
                     for content in contentArray
                     {
                        let placeContent = content.components(separatedBy: ",")
                        if placeContent.count == 6
                            {
                                let place = FavoritePlace(placeLat: Double(placeContent[0]) ?? 0.0, placeLong: Double(placeContent[1]) ?? 0.0, placeName: placeContent[2], city: placeContent[3], postalCode: placeContent[4], country: placeContent[5])
                                places?.append(place)
                            }
                     }
                }
                catch { print(error) }
         }
     }
        
    func deleteRow()
    {
            let filePath = getDataFilePath()

            var saveString = ""
            for place in self.deleteArray!
            {
               saveString = "\(saveString)\(place.placeLat),\(place.placeLong),\(place.placeName),\(place.city),\(place.country),\(place.postalCode)\n"
                do
                {
                    try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                }
                catch { print(error) }
            }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if places!.count == 0 {
        self.tableView.setEmptyMessage("No favorite places to show, press the add button to add a new one!")
        } else {
        self.tableView.restore()
        }
        return places?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
            
        let place = self.places![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblCell")
        if(places!.isEmpty)
        {
            cell?.textLabel?.text = "No favorites to show"
            cell?.detailTextLabel?.text = "Press the add button to open map"
        }
        else
        {
            cell?.textLabel?.text = place.placeName + " , " + place.city
            cell?.detailTextLabel?.text = place.country + " , " + place.postalCode
        }
        return cell!
     }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let editedPlace =  self.places![indexPath.row]
            defaults.set(editedPlace.placeLat, forKey: "latitude")
            defaults.set(editedPlace.placeLong, forKey: "longitude")
            defaults.set(true, forKey: "bool")
            defaults.set(indexPath.row, forKey: "edit")
            let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "editMarkerVC") as! EditMarkerViewController
            self.navigationController?.pushViewController(mapVC, animated: true)
        }

       
        // Deleting table contents
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            if editingStyle == .delete {
                
                self.places?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                self.deleteArray = self.places
                deleteRow()
                
            } else if editingStyle == .insert {
            
            }
        }

}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
