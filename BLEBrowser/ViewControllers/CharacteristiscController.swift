//
//  CharacteristiscController.swift
//  BLEBrowser
//
//  Created by Max Sovalov on 22.04.2018.
//  Copyright © 2018 zirteam. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristiscController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var deviceNameLbl: UILabel!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    
    // MARK: - Properties
    
    var deviceName: String!
    var serviceName: String!
    var characteristics = [CBCharacteristic]()
    weak var connectManager: BLEConnectManager?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceNameLbl.text = deviceName
        serviceLbl.text = serviceName
        table.dataSource = self
    }
}

// MARK: - UITableViewDataSource implementation

extension CharacteristiscController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let charactiristic = characteristics[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacteristicCell", for: indexPath) as! CharacteristicCell

        cell.readBtn.isHidden = true
        cell.readBtnClosure = nil
        cell.writeBtn.isHidden = true
        cell.writeBtnClosure = nil

        var properties = "Properties: "
        if charactiristic.properties.contains(CBCharacteristicProperties.read) {
            properties = properties + " READ"
            cell.readBtn.isHidden = false
            cell.readBtnClosure = {
                self.connectManager?.readValue(for: charactiristic, callback: {(characteristic, error) in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        if let value = characteristic.value {
                            if let string = String(bytes: value, encoding: String.Encoding.utf8) {
                                self.showAlert(title: "Current Value", message: string)
                            } else {
                                self.showAlert(title: "Current Value", message: "Length: \(characteristic.value!.count)")
                            }
                        } else {
                            self.showAlert(title: "Error", message: "No value returned")
                        }
                    }
                })
            }
        }
        if charactiristic.properties.contains(CBCharacteristicProperties.write) {
            properties = properties + " WRITE"
            cell.writeBtn.isHidden = false
            cell.writeBtnClosure = {
                self.showAlert(title: "Sorry", message: "Not implemented yet")
            }
        }
        if charactiristic.properties.contains(CBCharacteristicProperties.notify) {
            properties = properties + " NOTIFY"
        }
        
        cell.nameLbl.text = GATTCharacteristicNameHelper.getCharacteristicName(uuid: charactiristic.uuid)
        cell.uuidLbl.text = "UUID: \(charactiristic.uuid.uuidString)"
        cell.propertiesLbl.text = properties
        return cell
    }
}
