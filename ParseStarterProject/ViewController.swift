/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import CoreBluetooth

let CHARACHTERISTIC_UUID = "FFF3"
let SERVICE_UUID = "FFF0"

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate {
	@IBOutlet weak var showDisoveredDevices: UITableView!
    var centralManager : CBCentralManager?
    var discoveredPeripheral : CBPeripheral?
    var bluetoothON = false
	var datareceived : String = "No-Data"
	var bluetoothStatus : String?
	var btlog : String?
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
	
	

    override func viewDidLoad() {
		
		super.viewDidLoad()
		self.showDisoveredDevices.isHidden = true
        self.spinner.hidesWhenStopped = true
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.showDisoveredDevices.allowsSelection=true
		
    }
	

    @IBAction func goButtonPressed(_ sender: UIButton) {
        
        startScan()
		showDisoveredDevices.reloadData()
        
		
        
    }
    
    func startScan() {
        
        if (self.bluetoothON && discoveredPeripheral == nil){
		 
        spinner.startAnimating()
			let srvcuuid = CBUUID(string :SERVICE_UUID)
			self.centralManager?.scanForPeripherals(withServices: [srvcuuid], options: nil)
		
		}
		
		else if (self.bluetoothON && self.discoveredPeripheral != nil) {
			
			self.btlog = "Already connected to \(self.discoveredPeripheral!.name!)"
		}
		
		else {
			
			self.btlog = "Error performing this action"
		}
		self.showDisoveredDevices.isHidden = false
		self.showDisoveredDevices.reloadData()
    }
    
    // MARK - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
        self.discoveredPeripheral = peripheral
        self.centralManager?.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        if((error) != nil){
        
            print(error!.localizedDescription)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        self.spinner.stopAnimating()
		showDisoveredDevices.reloadData()
        centralManager?.stopScan()
        peripheral.discoverServices(nil)

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if (error != nil ) {
            self.btlog = error.debugDescription
			self.showDisoveredDevices.reloadData()
        }
        
        for  service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error != nil) {
            self.btlog = error.debugDescription
			self.showDisoveredDevices.reloadData()
        }
        
        for characteristic in service.characteristics! {
            
            let uuidFromString = CBUUID(string: CHARACHTERISTIC_UUID)
            if characteristic.uuid.isEqual(uuidFromString){
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if( error != nil ) {
            
            self.btlog = error.debugDescription
        
        }
        let stringFromData = String(data : characteristic.value! , encoding : .utf8)
		
		self.datareceived = stringFromData!
		showDisoveredDevices.reloadData()
		
		/* let testObject = PFObject(className: "TestObject")
		testObject[stringFromData!] = stringFromData!
		testObject.saveInBackground { (success, error) in
		self.showLog(msg:"Object saved to cloud.")
		}
		*/
    }
	
	func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
		self.btlog = "\(peripheral.name!) is now disconnected"
		btlog = " "
		self.datareceived = " "
		self.centralManager?.cancelPeripheralConnection(peripheral)
		self.discoveredPeripheral = nil
		self.showDisoveredDevices.isHidden=true
		self.showDisoveredDevices.reloadData()
	}
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
        switch central.state {
        
        case .poweredOn:
            self.bluetoothON = true
            self.bluetoothStatus = "ON"
			self.showDisoveredDevices.reloadData()
			startScan()
        case .poweredOff:
            self.bluetoothON = false
            self.bluetoothStatus = "OFF"
			self.showDisoveredDevices.reloadData()
			spinner.stopAnimating()
        case .unsupported:
            self.bluetoothStatus = "unsupported"
			self.showDisoveredDevices.reloadData()
        case .unauthorized:
            self.bluetoothStatus = "unauthorized"
			self.showDisoveredDevices.reloadData()
            
            
        default:
            break
        }
    }
	// MARK - TableView Data Source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.discoveredPeripheral != nil { return 5 }
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell : DeviceInfoCell = showDisoveredDevices.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DeviceInfoCell
		
		switch (indexPath.row) {
		
			case 0 :
			
			cell.cellTitle.text = " blueTooth Status : "
			cell.deviceName.text = self.bluetoothStatus
			
			case 1 :
				
					cell.cellTitle.text = " Connected to : "
					cell.deviceName.text = self.discoveredPeripheral?.name
			
			case 2 :
				
					cell.cellTitle.text = " Data : "
					cell.deviceName.text = self.datareceived
				
			case 3 :
					
					cell.cellTitle.text = " UUID "
					cell.deviceName.text = self.discoveredPeripheral?.identifier.uuidString
			case 4 :
			
					cell.cellTitle.text = self.btlog
					cell.deviceName.text = " "
			
		default : break
			
		}
		
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
