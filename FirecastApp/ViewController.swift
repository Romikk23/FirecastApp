//
//  ViewController.swift
//  FirecastApp
//
//  Created by Roman on 11/30/21.
//  Copyright © 2021 Roman. All rights reserved.
//

import UIKit
import CoreBluetooth
import FlexColorPicker
var pickedColor = #colorLiteral(red: 0.6813090444, green: 0.253660053, blue: 1, alpha: 1)

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, UIColorPickerViewControllerDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    //@IBOutlet weak var pickerColorPreview: CircleShapedView!
    @IBOutlet weak var Slider: UISlider!
    @IBOutlet weak var On: UISwitch!
    @IBOutlet weak var Music: UISwitch!
    @IBOutlet weak var label: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var buttonConn: UIButton!
    @IBOutlet var datePicker: UIDatePicker!
    
    var peripherals = Array<CBPeripheral>()
    @IBOutlet weak var tableView: UITableView!
    
    private var Char: CBCharacteristic?
    var manager:CBCentralManager!
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.setTitleColor(UIColor.orange, for:UIControl.State())
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let name = UserDefaults.standard.string(forKey: "name")
        self.label.text = "Welcome home, \n" + name!
        print("View loaded")
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        datePicker.setValue(UIColor.white, forKey: "textColor")
        tableView.isHidden = true
        //pickerColorPreview.backgroundColor = pickedColor
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationColorPicker = segue.destination as? ColorPickerControllerProtocol {
            destinationColorPicker.selectedColor = pickedColor
            destinationColorPicker.delegate = self
        }
    }
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", Uuid.UUID);
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    peripherals.append(peripheral)
    tableView.reloadData()
    }
    }
    
    extension ViewController: ColorPickerDelegate  {
    func colorPicker(_: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        pickedColor = selectedColor
        button.setTitleColor(pickedColor, for:UIControl.State())
        let hexColor = pickedColor.hexValue()
        let data = Data("1:\(hexColor)".utf8)
        print("HEX:\(hexColor)")
        if(buttonConn.titleLabel?.text == "Connected"){
            writeLEDValueToChar( withCharacteristic: Char!, withValue: data)
        }
    }

    func colorPicker(_: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
    
    let peripheral = peripherals[indexPath.row]
    cell.textLabel?.text = peripheral.name
    
    return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)")
        self.centralManager.stopScan()
        // Connect!
        self.peripheral = peripherals[indexPath.row]
        self.peripheral.delegate = self
        self.centralManager.connect(peripherals[indexPath.row], options: nil)
    }
    // Handles the result of the scan
    /*
     func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // We've found it so stop scan
        self.centralManager.stopScan()
        
        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
        
    }
    */
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to your Particle Board")
            let ServiceUUID = CBUUID.init(string:peripheral.identifier.uuidString)
            print(ServiceUUID)
            peripheral.discoverServices([Uuid.UUID]);
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            print("Disconnected")
            buttonConn.setTitle("Disconnected", for: .normal)
            self.peripheral = nil
            
            // Start scanning again
            print("Central scanning for", Uuid.UUID);
            centralManager.scanForPeripherals(withServices: [Uuid.UUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == Uuid.UUID {
                    print("LED service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
        // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                        print("Characteristic found")
                        Char = characteristic
                    buttonConn.setTitle("Connected", for: .normal)
                    tableView.isHidden = true
                }
            }
        }
    private func writeLEDValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        
        // Check if it has the write property
        if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {
                        peripheral.writeValue(value, for: characteristic, type: .withoutResponse)

        }
        
    }
    @IBAction func colorPickerButton(_ sender: UIButton) {
        let colorPickerController = DefaultColorPickerViewController()
        colorPickerController.delegate = self
        let navigationController = UINavigationController(rootViewController: colorPickerController)
        navigationController.modalPresentationStyle = .popover
        navigationController.preferredContentSize = CGSize(width: 284, height: 446)
        if let popoverController = navigationController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
            navigationController.delegate = self
        }
        present(navigationController, animated: true, completion: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    @IBAction func onOff(_ sender: UISwitch) {
        if On.isOn == false {
            Music.setOn(false, animated: true)
            Slider.value = 50
            button.setTitleColor(UIColor.orange, for:UIControl.State())
            let someDateTime = Date(timeIntervalSince1970: 0)
            print(someDateTime)
            datePicker.setDate(someDateTime, animated: false)
        }
        let data = Data("3:\(sender.isOn)".utf8)
        print("\(data)")
        if(buttonConn.titleLabel?.text == "Connected"){
            writeLEDValueToChar( withCharacteristic: Char!, withValue: data)
        }
    }
    
    @IBAction func music(_ sender: UISwitch) {
        if On.isOn == false {
            Music.setOn(false, animated: true)
        }
        let data = Data("5:\(sender.isOn)".utf8)
        print("\(data)")
        if(buttonConn.titleLabel?.text == "Connected"){
            writeLEDValueToChar( withCharacteristic: Char!, withValue: data)
        }
        
    }
    
    @IBAction func firefan(_ sender: UISlider) {
        let data = Data("2:\(sender.value)".utf8)
        print("\(data)")
        if(buttonConn.titleLabel?.text == "Connected"){
            writeLEDValueToChar( withCharacteristic: Char!, withValue: data)
        }
    }
    @IBAction func timer(_ sender: UIDatePicker) {
        let data = Data("4:\(sender.date.timeIntervalSince1970+10800.0)".utf8)
        print("Time :\(sender.date.timeIntervalSince1970+10800.0)")
        if(buttonConn.titleLabel?.text == "Connected"){
            writeLEDValueToChar( withCharacteristic: Char!, withValue: data)
        }
    }
    @IBAction func connection(_ sender: UIButton) {
        tableView.isHidden = !tableView.isHidden
    }
}
