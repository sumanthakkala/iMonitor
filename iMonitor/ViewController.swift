//
//  ViewController.swift
//  iMonitor
//
//  Created by Nirmal Sumanth on 26/02/20.
//  Copyright © 2020 Nirmal Sumanth. All rights reserved.
//

import Cocoa
import CoreData
import AppKit
import FileWatcher_macOS

class ViewController: NSViewController {

    @objc dynamic var foldersList:[FolderPath] = []
    dynamic var fileWatcher:FileWatcher = FileWatcher([""])
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var tableVIew: NSScrollView!
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            
        }
    }
    override func viewDidAppear(){
        updateUITable()
        startMonitoringFolders()
    }
    
    static var appDelegate = NSApplication.shared.delegate as! AppDelegate
    static var context = appDelegate.persistentContainer.viewContext
    
    
    func startMonitoringFolders(){
        fileWatcher.stop()
        var pathListAsNsString: [String] = []
        for folder in foldersList{
            pathListAsNsString.append(NSString(string: folder.folderPath).expandingTildeInPath)
        }
        fileWatcher = FileWatcher(pathListAsNsString)
        fileWatcher.callback = { event in
          print("Something happened here: " + event.path)
            
            // Create the notification and setup information
            let notification = NSUserNotification()
            //notification.identifier = "unique-id"
            notification.title = "iMonitor Notification"
            notification.subtitle = "Changes detected in the monitoring folders."
            notification.informativeText = "Path: " + event.path
            notification.soundName = NSUserNotificationDefaultSoundName
            // Manually display the notification
            let notificationCenter = NSUserNotificationCenter.default
            notificationCenter.deliver(notification)
        }

        fileWatcher.start()
        
    }
    func savePathToCoreData(path: String, folderName: String) -> Bool{
        let folderEntity = NSEntityDescription.entity(forEntityName: "FolderPaths", in: ViewController.context)
        let newFolderPath = NSManagedObject(entity: folderEntity!, insertInto: ViewController.context)
        newFolderPath.setValue(path, forKey: "folderPath")
        newFolderPath.setValue(folderName, forKey: "folderName")
        newFolderPath.setValue(Date(), forKey: "createdAt")
        do{
            try ViewController.context.save()
            return true
        }
        catch{
            return false
        }
    }
    
    
    @IBAction func chooseFileClick(_ sender: NSButton) {
        //File Panel
        let choosePanel = NSOpenPanel()
        choosePanel.title = "Select Folder"
        choosePanel.canChooseDirectories = true
        choosePanel.canChooseFiles = false
        choosePanel.allowsMultipleSelection = true
        let choosePanelResponse = choosePanel.runModal()
        
        if(choosePanelResponse == NSApplication.ModalResponse.OK){
            let result = choosePanel.url
            if(result != nil){
                //Path & Folder Name
                let path = result!.path
                let folderName = path.split(separator: "/").last
                //Alert code
                let alert = NSAlert.init()

                if savePathToCoreData(path: path, folderName: (String.init(folderName ?? ""))){
                    alert.messageText = "\(String.init(folderName ?? "")) folder added successfully."
                    alert.informativeText = "Selected Path: " + path
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                    updateUITable()
                    startMonitoringFolders()
                    
                } else{
                    alert.messageText = "Failed Saving"
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
            else{
                
            }
        }
    }
    
    @IBAction func pastePathTextBoxAction(_ sender: NSTextField) {
        let path = sender.stringValue
        
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists: Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        if exists && isDirectory.boolValue {
            // Exists. Directory.
            print("Exists")
            let folderName = path.split(separator: "/").last
            let alert = NSAlert.init()
            if savePathToCoreData(path: path, folderName: (String.init(folderName ?? ""))){
                alert.messageText = "\(String.init(folderName ?? "")) folder added successfully."
                alert.informativeText = "Selected Path: " + path
                alert.addButton(withTitle: "OK")
                alert.runModal()
                updateUITable()
                startMonitoringFolders()
            } else{
                alert.messageText = "Failed Saving"
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        } else {
            // Exists.
            print("Not Exists")
            let alert = NSAlert.init()
            alert.messageText = "Entered path does not exists. Please try again."
            alert.informativeText = "Selected Path: " + path
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @IBAction func removePathAction(_ sender: NSButton) {
        let path = sender.toolTip
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolderPaths")
        request.predicate = NSPredicate(format: "folderPath == %@", path!)
        do{
            let result = try ViewController.context.fetch(request)
            for selecetedFolders in result as! [NSManagedObject]{
                ViewController.context.delete(selecetedFolders)
            }
            try ViewController.context.save()
            updateUITable()
            startMonitoringFolders()
        }
        catch{
            print("Failed Delete")
        }
        
    }
    
    func updateUITable(){
        foldersList = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolderPaths")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        if isViewLoaded{
            do {
                let result = try ViewController.context.fetch(request)
                
                for data in result as! [NSManagedObject] {
                    let name = data.value(forKey: "folderName") as! String
                    let path = data.value(forKey: "folderPath") as! String
                    let folder = FolderPath(path: path, name: name)
                    foldersList.append(folder)
                    //let cell = tableVIew.de
                }
               //self.folderPathAC.addObject(foldersList)
                
            } catch {
                print("Failed")
            }
        }
        
    }
    
}

