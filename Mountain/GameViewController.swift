//
//  GameViewController.swift
//  Mountain
//
//  Created by bittinen on 13/02/16.
//  Copyright (c) 2016 Mika Leppinen. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    var norms = [SCNVector3]()
    var verts = [SCNVector3]()
    var colors = [SCNVector3]()
    var first = true;
    
    internal func calcuN(A:SCNVector3, B:SCNVector3, C:SCNVector3)->SCNVector3
    {
        let AB = SCNVector3(A.x-B.x,A.y-B.y,A.z-B.z)
        let CB = SCNVector3(C.x-B.x,C.y-B.y,C.z-B.z)
        let ax = AB.y*CB.z-AB.z*CB.y
        let ay = AB.z*CB.x-AB.x*CB.z
        let az = AB.x*CB.y-AB.y*CB.x
        let len = sqrt(ax*ax+ay*ay+az*az)
        let cross = SCNVector3(ax/len,ay/len,az/len)
        return cross
    }
    
    internal func calcuC(A:SCNVector3, B:SCNVector3, C:SCNVector3)->SCNVector3
    {
        return SCNVector3((A.x+B.x+C.x)/3,(A.y+B.y+C.y)/3,(A.z+B.z+C.z)/3)
    }
    
    internal func re(A:SCNVector3, B:SCNVector3, C:SCNVector3)
    {
        
        var y = 0
        if first {
            first = false
            y = 6;
        }
        let p1 = CGFloat((arc4random_uniform(20)+90)/100)
        let p2 = CGFloat((arc4random_uniform(20)+90)/100)
        var P = calcuC(A,B:B,C:C)
        P.x = P.x*p1
        P.y = P.y*p2
        P.z = CGFloat(y);
        
        verts.append(A)
        verts.append(B)
        
        
    }
    
    override func awakeFromNib(){
        // create a new scene
        var verts = [SCNVector3(x: 0,y: 0,z: 0),SCNVector3(x: 6,y: 0,z: 0),SCNVector3(x: 0,y: 6,z: 0), SCNVector3(x: 0,y: 0,z: -6)]
        

        let src = SCNGeometrySource(vertices: &verts, count: 4)

        // Colors
        let colors: [SCNVector3] = [SCNVector3(1, 0, 1.0),SCNVector3(1, 1, 0.0),SCNVector3(1, 0, 0.0),
            SCNVector3(0, 1, 0),SCNVector3(0, 1, 0),SCNVector3(0, 1, 0),
            SCNVector3(0.0, 0.0, 1.0),SCNVector3(0.0, 0.0, 1.0),SCNVector3(0.0, 0.0, 1.0)]
        
        let colorData = NSData(bytes: colors, length: sizeof(SCNVector3) * colors.count)
        let colorSource = SCNGeometrySource(data: colorData, semantic: SCNGeometrySourceSemanticColor, vectorCount: colors.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(CGFloat), dataOffset: 0, dataStride: sizeof(SCNVector3))
        
        
        let indexes: [CInt] = [0,1,2,0,2,3,2,1,3] // Changed to CInt
        

        for var i=0; i < indexes.count; i=i+3 {
            let a = verts[Int(indexes[i])]
            let b = verts[Int(indexes[i+1])]
            let c = verts[Int(indexes[i+2])]
            let crossa = calcuN(a,B:b,C:c)
            norms.append(crossa)
        }
        let norm = SCNGeometrySource(normals: &norms, count: norms.count)
        
        let dat  = NSData(
            bytes: indexes,
            length: sizeof(CInt) * indexes.count // Changed to size of CInt * count
        )
        let ele = SCNGeometryElement(
            data: dat,
            primitiveType: .Triangles,
            primitiveCount: 3,
            bytesPerIndex: sizeof(CInt) // Changed to CInt
        )
        let geo = SCNGeometry(sources: [src, norm, colorSource], elements: [ele])
        //let geo = SCNGeometry(sources: [src, colorSource], elements: [ele])
        
        let nd = SCNNode(geometry: geo)
        nd.name = "ship"
        let scene = SCNScene()
        scene.rootNode.addChildNode(nd)
        
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 4, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        animation.duration = 20
        animation.repeatCount = MAXFLOAT //repeat forever
        ship.addAnimation(animation, forKey: nil)

        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.whiteColor()
    }
    
}
