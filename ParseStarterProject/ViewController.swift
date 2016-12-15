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

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    
    var centralManager : CBCentralManager?
    var discoveredPeripheral : CBPeripheral?
    var bluetoothON = false
    @IBOutlet weak var btStateValueLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
	@IBOutlet weak var btLog: UITextView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        self.btLog.isEditable = false
        self.spinner.hidesWhenStopped = true
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        
        startScan()
        
		
        
    }
	
	func showLog(msg : String){
		let pref = "\r\n\r\n"
		self.btLog.text =  pref.appending(self.btLog.text)
		self.btLog.text = msg.appending(self.btLog.text)
	}
    
    func startScan() {
        
        if (self.bluetoothON && discoveredPeripheral == nil){
		 
        spinner.startAnimating()
			let srvcuuid = CBUUID(string :SERVICE_UUID)
			self.centralManager?.scanForPeripherals(withServices: [srvcuuid], options: nil)
		
		}
		
		else if (self.bluetoothON && self.discoveredPeripheral != nil) {
			
			showLog(msg: "Already connected to \(self.discoveredPeripheral!.name!)")
		}
		
		else {
			
			showLog(msg: "Error performing this action")
		}
    }
    
    // MARK - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        showLog(msg: "discovered \(peripheral.name!) with RSSI \(RSSI)")
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
        showLog(msg: "connected to peripheral name \(peripheral.name!)")
        self.spinner.stopAnimating()
        //centralManager?.stopScan()
        peripheral.discoverServices(nil)

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if (error != nil ) {
            showLog(msg: error.debugDescription)
        }
        
        for  service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error != nil) {
            showLog(msg: error.debugDescription)
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
            
            showLog(msg:error.debugDescription)
        
        }
        let stringFromData = String(data : characteristic.value! , encoding : .utf8)
        showLog(msg:"data received from the peripheral will be stored to cloud")
		
		 let testObject = PFObject(className: "TestObject")
		testObject[stringFromData!] = stringFromData!
		testObject.saveInBackground { (success, error) in
		self.showLog(msg:"Object saved to cloud.")
		}

    }
	
	func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
		showLog(msg: "peripheral with name \(peripheral.name!) has changed services and is now disconnected")
		self.centralManager?.cancelPeripheralConnection(peripheral)
		self.discoveredPeripheral = nil
	}
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
        switch central.state {
        
        case .poweredOn:
            self.bluetoothON = true
            self.btStateValueLabel.text = "ON"
        case .poweredOff:
            self.bluetoothON = false
            self.btStateValueLabel.text = "OFF"
        case .unsupported:
            self.btStateValueLabel.text = "unsupported"
        case .unauthorized:
            self.btStateValueLabel.text = "unauthorized"
            
            
        default:
            break
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
