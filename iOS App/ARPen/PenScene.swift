//
//  PenScene.swift
//  ARPen
//
//  Created by Felix Wehnert on 16.01.18.
//  Copyright © 2018 RWTH Aachen. All rights reserved.
//

import SceneKit
import SceneKit.ModelIO

/**
 This is a subclass of `SCNScene`. It is used to hold the MarkerBox and centralize some methods
 */
class PenScene: SCNScene {
    
    /**
     The instance of the MarkerBox
     */
    var markerBox: MarkerBox!
    /**
     The pencil point is the node that corresponds to the real world pencil point.
     `pencilPoint.position` is always the best known position of the pencil point.
     */
    var pencilPoint: SCNNode
    
    //Node that carries all the drawing operations
    let drawingNode: SCNNode
    
    var penTrackingDelegate: PenTrackingDelegate?
    
    /**
     If a marker was found in the current frame the var is true
     */
    var markerFound = true {
        didSet {
            if(markerFound && !oldValue){
                penTrackingDelegate?.onFoundMarker()
            } else if (!markerFound && oldValue){
                penTrackingDelegate?.onAllMarkerLost()
            }
        }
    }
    
    /**
     Calling this method will convert the whole scene with every nodes in it to an stl file
     and saves it in the temporary directory as a file
     - Returns: An URL to the scene.stl file. Located in the tmp directory of the app
     */
    func share() -> URL {
        let filePath = URL(fileURLWithPath: NSTemporaryDirectory() + "/scene.stl")
        let asset = MDLAsset(scnScene: self)
        try! asset.export(to: filePath)
        return filePath
    }
    
    /**
     init. Should not be called. Is not called by SceneKit
     */
    override init() {
        self.pencilPoint = SCNNode()
        self.drawingNode = SCNNode()
        super.init()
        
        setupPencilPoint()
    }
    
    /**
     This initializer will be called after `init(named:)` is called.
     */
    required init?(coder aDecoder: NSCoder) {
        self.pencilPoint = SCNNode()
        self.drawingNode = SCNNode()
        super.init(coder: aDecoder)
        
        setupPencilPoint()
    }
    
    private func setupPencilPoint() {
        self.pencilPoint.geometry = SCNSphere(radius: 0.002)
        self.pencilPoint.name = "PencilPoint"
        self.pencilPoint.geometry?.materials.first?.diffuse.contents = UIColor.red
        
        self.rootNode.addChildNode(self.pencilPoint)
        self.rootNode.addChildNode(self.drawingNode)
    }
    
    var tipRadius: CGFloat = 0.002 {
        didSet {
            (self.pencilPoint.geometry as! SCNSphere).radius = tipRadius
        }
    }
    
    var hiddenTip: Bool = false {
        didSet {
            self.pencilPoint.isHidden = hiddenTip
        }
    }
    
    var tipColor = UIColor.red {
        didSet {
            self.pencilPoint.geometry?.materials.first?.diffuse.contents = tipColor
        }
    }
    
}

protocol PenTrackingDelegate {
    /**
     This method is called when no marker is found the first time
    */
    func onAllMarkerLost()
    
    /**
     This method is called when at least one marker is detected after no marker was found
    */
    func onFoundMarker()
}
