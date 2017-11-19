//
//  ViewController.swift
//  GestureDrivenTest
//
//  Created by Shani on 11/15/17.
//  Copyright © 2017 Shani Rivers. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, TableViewCellDelegate
{

  
    
    // Array to hold items
    var toDoItems = [ToDoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        
        if toDoItems.count > 0 {
            return
        }
        
        loadSampleData()
        
        // Set table view style to none
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.black
        tableView.rowHeight = 50.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return toDoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        cell.selectionStyle = .none
        
        // SETTING UP YOUR CELL
        let item = toDoItems[indexPath.row]
        //cell.textLabel?.text = item.text don't need to do this since it'll be set in the observer in the tableviewcell file
        
        // also apart of the protocol work
        cell.delegate = self
        cell.toDoItem = item
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.backgroundColor = colorForIndex(index: indexPath.row)
    }
    
    func toDoItemDeleted(todoItem: ToDoItem)
    {
        let index = (toDoItems as NSArray).index(of: todoItem)
        if index == NSNotFound { return }
        
        // could remove at index in loop but keep it here for when indexOf works
        toDoItems.remove(at: index)
        
        // Use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        let indexPathForRow = NSIndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPathForRow as IndexPath], with: .fade)
        tableView.endUpdates()
        
    }
    
    //MARK: Table view delegate
    
    // gives a gradient color dependent on what the index of the cell is
    func colorForIndex (index: Int) -> UIColor
    {
        let itemCount = toDoItems.count - 1
        
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        
        return UIColor(red: 0.3, green: val, blue: 1.0, alpha: 1.0)
    }
    
    func loadSampleData ()
    {
        toDoItems.append(ToDoItem(text: "Feed the cat"))
        toDoItems.append(ToDoItem(text: "Buy eggs"))
        toDoItems.append(ToDoItem(text: "Watch WWDC videos"))
        toDoItems.append(ToDoItem(text: "Rule the Web"))
        toDoItems.append(ToDoItem(text: "Buy a new iPhone"))
        toDoItems.append(ToDoItem(text: "Darn holes in socks"))
        toDoItems.append(ToDoItem(text: "Write this tutorial"))
        toDoItems.append(ToDoItem(text: "Master Swift"))
        toDoItems.append(ToDoItem(text: "Learn to draw"))
        toDoItems.append(ToDoItem(text: "Get more exercise"))
        toDoItems.append(ToDoItem(text: "Catch up with Mom"))
        toDoItems.append(ToDoItem(text: "Get a hair cut"))
    }
    


}

