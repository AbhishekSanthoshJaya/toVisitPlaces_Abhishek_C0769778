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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
            loadData()
            self.tableView.reloadData()
            
        }
        
        func getDataFilePath() -> String {
               let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
               let filePath = documentPath.appending("/places-data.txt")
               return filePath
           }
        
        func loadData() {
            places = [FavoritePlace]()
            
            let filePath = getDataFilePath()
            
            if FileManager.default.fileExists(atPath: filePath){
                do{
                    //creating string of file path
                 let fileContent = try String(contentsOfFile: filePath)
                    
                    let contentArray = fileContent.components(separatedBy: "\n")
                    for content in contentArray{
                       
                        let placeContent = content.components(separatedBy: ",")
                        if placeContent.count == 6 {
                            let place = FavoritePlace(placeLat: Double(placeContent[0]) ?? 0.0, placeLong: Double(placeContent[1]) ?? 0.0, placeName: placeContent[2], city: placeContent[3], postalCode: placeContent[4], country: placeContent[5])
                            places?.append(place)
                        }
                }
                   
    //                print(self.places?.count)
                }
                catch{
                    print(error)
                }
            }
        }
        
        func deleteRow() {
            let filePath = getDataFilePath()

            var saveString = ""
            for place in self.deleteArray!{
               saveString = "\(saveString)\(place.placeLat),\(place.placeLong),\(place.placeName),\(place.city),\(place.country),\(place.postalCode)\n"
                do{
               try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                }
                catch{
                    print(error)
                }
            }
        }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places?.count ?? 0
    }
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let place = self.places![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "tblCell")
            cell?.textLabel?.text = place.placeName + " , " + place.city
            cell?.detailTextLabel?.text = place.country + " , " + place.postalCode
            return cell!
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let editedPlace =  self.places![indexPath.row]
            
            defaults.set(editedPlace.placeLat, forKey: "latitude")
            defaults.set(editedPlace.placeLong, forKey: "longitude")
            defaults.set(true, forKey: "bool")
            
            let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapViewVC") as! MapViewController
            mapVC.dragablePin()
            self.navigationController?.pushViewController(mapVC, animated: true)
        }

        /*
        // Override to support conditional editing of the table view.
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }
        */
        
       
        // Override to support editing the table view.
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            if editingStyle == .delete {
                
                self.places?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                self.deleteArray = self.places
                deleteRow()
                
            } else if editingStyle == .insert {
            
            }
        }
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
