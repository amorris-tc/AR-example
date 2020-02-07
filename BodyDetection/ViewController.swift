/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARSCNView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [-1.0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    var tshirt: SCNNode?
    var headOffset: Float?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tshirt = addShirt()
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
         let configuration = ARBodyTrackingConfiguration()
         arView.session.run(configuration)
    }
    
    func arscn() {
            let scn = ARSCNView(frame: UIScreen.main.bounds)
            scn.delegate = self
            // scn.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
            let config = ARBodyTrackingConfiguration()
            let session = scn.session
            session.run(config)
        }
    
    func addShirt() -> SCNNode {
        let skNode = SKSpriteNode(imageNamed: "cool-shirt-cut")
        
        let scene = SKScene(size: CGSize(width: 1595, height: 1920))
        scene.backgroundColor = .clear
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .aspectFill
        scene.addChild(skNode)
    
        let mat = SCNMaterial()
        mat.diffuse.contents = scene
        mat.diffuse.contentsTransform = SCNMatrix4MakeScale(1.10, -1.10, 1)
        mat.transparencyMode = .aOne
        mat.diffuse.wrapT = .repeat
        mat.isDoubleSided = true
    
        let plane = SCNPlane(width: 1, height: 1)
    
        let node = SCNNode(geometry: plane)
        node.geometry?.firstMaterial = mat
        
        return node
    }
    
    func addCapsule() -> SCNNode {
        let cap = SCNCapsule(capRadius: 1.0, height: 1.0)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.red
        let node = SCNNode(geometry: cap)
        return node
    }
    

    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }

            tshirt?.position = SCNVector3(bodyAnchor.transform.columns.3.x, bodyAnchor.transform.columns.3.y, bodyAnchor.transform.columns.3.z)
            arView.scene.rootNode.addChildNode(tshirt!)
            
            let headTransform: simd_float4x4! = bodyAnchor.skeleton.modelTransform(for: .head)
            let headRelativeHeight = headTransform.columns.3.y
            headOffset = headRelativeHeight / 3
        }
    }
    
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            let newYPosition = bodyAnchor.transform.columns.3.y + headOffset!
            tshirt?.position = SCNVector3(bodyAnchor.transform.columns.3.x, newYPosition, bodyAnchor.transform.columns.3.z)
            tshirt?.rotation = SCNQuaternion(1, 0, 0, 0)
            
//            // Update the position of the character anchor's position.
//            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
//            characterAnchor.position = bodyPosition + characterOffset
//            // Also copy over the rotation of the body anchor, because the skeleton's pose
//            // in the world is relative to the body anchor's rotation.
//            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
//
//            if let character = character, character.parent == nil {
//                // Attach the character to its anchor as soon as
//                // 1. the body anchor was detected and
//                // 2. the character was loaded.
//                characterAnchor.addChild(character)
//            }
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            guard anchor is ARBodyAnchor else { continue }
            
            tshirt?.removeFromParentNode()
            print("Remove Anchor from scene")
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            print("node for anchor")
        guard anchor is ARBodyAnchor else { return nil }
            
    //        let anchorE = AnchorEntity(anchor: bodyAnchor)
            let tshirt = addShirt()
            
            return tshirt
        }
}

