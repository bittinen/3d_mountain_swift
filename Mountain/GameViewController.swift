//
//  GameViewController.swift
//  Mountain
//
//  Created by bittinen on 13/02/16.
//  Copyright (c) 2016 Mika Leppinen.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTI
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// Warning: This was my fist Swift project
import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    var norms = [SCNVector3]()
    var verts = [SCNVector3]()
    var colors = [SCNVector3]()
    let size = 6
    var primitives = 0
    
    // Calculate Normal
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
    
    // Calculate center point
    internal func calcuC(A:SCNVector3, B:SCNVector3, C:SCNVector3)->SCNVector3
    {
        return SCNVector3((A.x+B.x+C.x)/3,(A.y+B.y+C.y)/3,(A.z+B.z+C.z)/3)
    }
    
    // Return max value
    internal func maxL(A:CGFloat, B:CGFloat, C:CGFloat)->CGFloat
    {
        if A > B {
            if A > C {
                return A
            }
            return C
        }
        if B > C {
            return B
        }
        return C
    }
    
    // Return min value
    internal func minL(A:CGFloat, B:CGFloat, C:CGFloat)->CGFloat
    {
        if A < B {
            if A < C {
                return A
            }
            return C
        }
        if B < C {
            return B
        }
        return C
    }
    
    // Calculate length of the sides
    internal func calcuL(A:SCNVector3, B:SCNVector3, C:SCNVector3)->SCNVector3
    {
        let x_max = maxL(A.x, B: B.x, C: C.x)
        let x_min = minL(A.x, B: B.x, C: C.x)
        let y_max = maxL(A.y, B: B.y, C: C.y)
        let y_min = minL(A.y, B: B.y, C: C.y)
        let z_max = maxL(A.z, B: B.z, C: C.z)
        let z_min = minL(A.z, B: B.z, C: C.z)
        
        return SCNVector3((x_max-x_min),(y_max-y_min),(z_max-z_min))
    }
    
    // recursive function to calculate sub-triangle
    internal func re(A:SCNVector3, B:SCNVector3, C:SCNVector3, levels: Int)
    {
        
        var y = CGFloat(0)
        
        // bottom triangle
        if levels == 0 {
            y = CGFloat(size)
            verts.append(A)
            verts.append(C)
            verts.append(B)
            let n = calcuN(A,B:B,C:C)
            norms.append(n)
            norms.append(n)
            norms.append(n)
            colors.append(SCNVector3(1.0, 0.0, 0.0))
            colors.append(SCNVector3(1.0, 0.0, 0.0))
            colors.append(SCNVector3(1.0, 0.0, 0.0))
            primitives++
        }
        else {
            let T = calcuC(A,B:B,C:C)
            y = T.y
        }
        
        // Calculate how much middle points are modified by random
        let p1 = CGFloat((CGFloat(arc4random_uniform(40))-20.0)/100.0)
        let p2 = CGFloat((CGFloat(arc4random_uniform(40))-20.0)/100.0)
        var P = calcuC(A,B:B,C:C)
        let len = calcuL(A, B:B, C:C)
        P.x = P.x + len.x*p1
        P.z = P.z + len.z*p2
        P.y = CGFloat(y);
        
        // Number of recursion layers
        if levels < 5 {
            re(A, B:B, C:P, levels:(levels+1)) // A, B, P
            re(A, B:P, C:C, levels:(levels+1)) // A, C, P
            re(P, B:B, C:C, levels:(levels+1)) // B, C, P
        }
        else {
            verts.append(P)
            verts.append(A)
            verts.append(B)
            let n1 = calcuN(A,B:B,C:P)
            norms.append(n1)
            norms.append(n1)
            norms.append(n1)
            colors.append(SCNVector3(3.0*P.y/CGFloat(size), 1.6, 0.5))
            colors.append(SCNVector3(3.0*A.y/CGFloat(size), 1.6, 0.5))
            colors.append(SCNVector3(3.0*B.y/CGFloat(size), 0.6, 0.5))
            primitives++
        
            verts.append(A)
            verts.append(P)
            verts.append(C)
            let n2 = calcuN(A,B:P,C:C)
            norms.append(n2)
            norms.append(n2)
            norms.append(n2)
            colors.append(SCNVector3(3.0*A.y/CGFloat(size), 1.6, 0.5))
            colors.append(SCNVector3(3.0*P.y/CGFloat(size), 1.6, 0.5))
            colors.append(SCNVector3(3.0*C.y/CGFloat(size), 0.6, 0.5))
            primitives++
        
            verts.append(P)
            verts.append(B)
            verts.append(C)
            let n3 = calcuN(P,B:B,C:C)
            norms.append(n3)
            norms.append(n3)
            norms.append(n3)
            colors.append(SCNVector3(3.0*P.y/CGFloat(size), 1.6, 0.5))
            colors.append(SCNVector3(3.0*B.y/CGFloat(size), 1.6, 0.5))
            colors.append(SCNVector3(3.0*C.y/CGFloat(size), 0.6, 0.5))
            primitives++
        }
    }
    
    override func awakeFromNib(){
        // create a new scene
        let a = SCNVector3(x: 0,y: 0,z: 0)
        let b = SCNVector3(x: CGFloat(size),y: 0,z: 0)
        let c = SCNVector3(x: CGFloat(size/2),y: 0,z: CGFloat(-size))
        re(a,B:b,C:c, levels:0)

        let src = SCNGeometrySource(vertices: &verts, count: verts.count)
        
        let colorData = NSData(bytes: colors, length: sizeof(SCNVector3) * colors.count)
        let colorSource = SCNGeometrySource(data: colorData, semantic: SCNGeometrySourceSemanticColor, vectorCount: colors.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(CGFloat), dataOffset: 0, dataStride: sizeof(SCNVector3))
        
        let norm = SCNGeometrySource(normals: &norms, count: norms.count)
        
        var indexes = [CInt]() // Calculate triangle indexes
        for var i=0; i < verts.count; i++ {
            indexes.append(CInt(i))
        }
        
        let dat  = NSData(
            bytes: indexes,
            length: sizeof(CInt) * indexes.count
        )
        
        let ele = SCNGeometryElement(
            data: dat,
            primitiveType: .Triangles,
            primitiveCount: primitives,
            bytesPerIndex: sizeof(CInt)
        )
        let geo = SCNGeometry(sources: [src, norm, colorSource], elements: [ele])
        
        let nd = SCNNode(geometry: geo)
        nd.name = "mountain"
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
        
        // retrieve the mountain node
        let ship = scene.rootNode.childNodeWithName("mountain", recursively: true)!
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(0), z: CGFloat(1), w: CGFloat(M_PI)*2))
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
