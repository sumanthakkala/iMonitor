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

class ViewController: NSViewController {

    @objc dynamic var foldersList:[FolderPath] = []
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
    }
    
    static var appDelegate = NSApplication.shared.delegate as! AppDelegate
    static var context = appDelegate.persistentContainer.viewContext
    
    
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
                
                
                //alert.runModal()
                
                
                let folderEntity = NSEntityDescription.entity(forEntityName: "FolderPaths", in: ViewController.context)
                let newFolderPath = NSManagedObject(entity: folderEntity!, insertInto: ViewController.context)
                newFolderPath.setValue(path, forKey: "folderPath")
                newFolderPath.setValue(folderName, forKey: "folderName")
                newFolderPath.setValue(Date(), forKey: "createdAt")
                
                do{
                    try ViewController.context.save()
                    alert.messageText = "\(String.init(folderName ?? "")) folder added successfully."
                    alert.informativeText = "Selected Path: " + path
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                    updateUITable()
                }
                catch{
                    alert.messageText = "Failed Saving"
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
            else{
                
            }
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

