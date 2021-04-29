//
//  ViewController.swift
//  DrawingApp
//
//  Created by Shivansh Khera on 28/04/21.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController,PKCanvasViewDelegate,PKToolPickerObserver {

    @IBOutlet weak var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvasOverScrollHeight: CGFloat = 500
    
    var drawing = PKDrawing()
    var toolPicker: PKToolPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput
        
        
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            // Set up the tool picker, using the window of our parent because our view has not
            // been added to a window yet.
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    
 
// Stores the drawing to the photo library of the user
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Drawing saved in photos library", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { (action) in
            
            UIGraphicsBeginImageContextWithOptions(self.canvasView.bounds.size, false, UIScreen.main.scale)
        
            self.canvasView.drawHierarchy(in: self.canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil{
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            } completionHandler: { success, error in
//                deal with success or error
                }
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func clearPressed(_ sender: UIBarButtonItem) {
        canvasView.drawing = PKDrawing()
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    
    func updateContentSizeForDrawing(){
        let drawing = canvasView.drawing
        let contentHeight:CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height,(drawing.bounds.maxY + self.canvasOverScrollHeight) * canvasView.zoomScale)
        }else{
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
    
}

