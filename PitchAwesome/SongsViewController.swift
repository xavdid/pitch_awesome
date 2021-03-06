//
//  SongsController.swift
//  PitchAwesome
//
//  Created by David Brownman on 9/21/15.
//  Copyright © 2015 DB. All rights reserved.
//

import UIKit

class SongsViewController: UITableViewController {
  var dataModel: DataModel!
  let tonePlayer = TonePlayer()

  // MARK: Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.allowsSelectionDuringEditing = true
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.songs.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Song", forIndexPath: indexPath)
    let song = dataModel.songs[indexPath.row]
    
    configureTextForCell(cell, song: song)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let song = dataModel.songs[indexPath.row]
    if editing {
      performSegueWithIdentifier("EditSong", sender: song)
    } else {
      tonePlayer.playTones(song)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    dataModel.songs.removeAtIndex(indexPath.row)
    
    let paths = [indexPath]
    tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Automatic)
    dataModel.saveData()
  }

  override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    dataModel.songs.insert(dataModel.songs.removeAtIndex(sourceIndexPath.row), atIndex: destinationIndexPath.row)
    dataModel.saveData()
  }
  
  // MARK: IBActions
  @IBAction func toggleEditing() {
    if editing {
      navigationItem.leftBarButtonItem?.title = "Edit"
      setEditing(false, animated: true)
    } else {
      navigationItem.leftBarButtonItem?.title = "Done"
      setEditing(true, animated: true)
    }
  }
  
  // MARK: View Stuff
  func configureTextForCell(cell: UITableViewCell, song: Song) {
    // could also just subclass UITableViewCell instead of grabbing labels as identifiers a la P3
    let titleLabel = cell.viewWithTag(1000) as! UILabel
    let pitchLabel = cell.viewWithTag(1001) as! UILabel
    
    titleLabel.text = song.title
    pitchLabel.text = song.notes.joinWithSeparator(", ")
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let navigationController = segue.destinationViewController as! UINavigationController
    let controller = navigationController.topViewController as! SongDetailsViewController
    controller.delegate = self
    
    if segue.identifier == "EditSong" {
      controller.songToEdit = (sender as! Song)
    }
  }
}

extension SongsViewController: SongDetailsViewControllerDelegate {
  func songDetailViewControllerDidCancel(controller: SongDetailsViewController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func songDetailViewController(controller: SongDetailsViewController, didFinishAddingItem song: Song) {
    let newRowIndex = dataModel.songs.count
    
    dataModel.songs.append(song)
    
    let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
    let indexPaths = [indexPath]
    tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    
    dismissViewControllerAnimated(true, completion: nil)
    dataModel.saveData()
    if editing {
      toggleEditing()
    }
  }
  func songDetailViewController(controller: SongDetailsViewController, didFinishEditingItem song: Song) {
    tableView.reloadData()
    dismissViewControllerAnimated(true, completion: nil)
    dataModel.saveData()
    // probably want to only edit one at a time?
    toggleEditing()
  }
}


