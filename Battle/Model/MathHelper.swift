//
//  MathHelper.swift
//  Battle
//
//  Created by Eric Hodgins on 2019-01-08.
//  Copyright © 2019 Eric Hodgins. All rights reserved.
//

import SpriteKit

class MathHelper {
    // Find Point off Screen for projectile to move to from some touched point on the screen
    static func trajectoryEndPoint(fromOrigin origin: CGPoint, toPoint: CGPoint, screenSize: CGSize) -> CGPoint {
        let xPointOffScreen: CGFloat
        let yPoint: CGFloat
        let angle: CGFloat
        if toPoint.x > origin.x {
            angle = MathHelper.angle(fromOrigin: origin, toPoint: toPoint)
            xPointOffScreen = screenSize.width + 10
            if toPoint.y > origin.y {
                yPoint = (tan(angle) * (xPointOffScreen - origin.x)) + origin.y
            } else {
                yPoint = origin.y - abs(((xPointOffScreen - origin.x) * tan(angle)))
            }
        } else {
            xPointOffScreen = -10
            angle = MathHelper.angle(fromOrigin: origin, toPoint: toPoint)
            if toPoint.y > origin.y {
                yPoint = (tan(angle) * abs((xPointOffScreen - origin.x))) + origin.y
            } else {
                yPoint = origin.y - abs(((xPointOffScreen - origin.x) * tan(angle)))
            }
        }
        
        return CGPoint(x: xPointOffScreen, y: yPoint)
    }
    
    // Radians
    static func angle(fromOrigin origin: CGPoint, toPoint: CGPoint) -> CGFloat {
        let deltaX: CGFloat
        let deltaY: CGFloat
        let angle: CGFloat
        
        if toPoint.x > origin.x {
            deltaX = toPoint.x - origin.x
            deltaY = toPoint.y - origin.y
            angle = atan((deltaY / deltaX))
        } else {
            deltaX = origin.x - toPoint.x
            deltaY = toPoint.y - origin.y
            angle = atan((deltaY / deltaX))
        }
        
        return angle
    }
    
    static func rotationAngle(fromOrigin origin: CGPoint, toPoint: CGPoint) -> CGFloat {
        let dy = toPoint.y - origin.y
        let dx = toPoint.x - origin.x
        let angle = atan2(dy, dx) - (.pi/2)
        return angle
    }
    
    // Radians
    static func calculateEmissionAngle(fromOrigin origin: CGPoint, toPoint: CGPoint) -> CGFloat {
        var angle = MathHelper.angle(fromOrigin: origin, toPoint: toPoint)
        
        if origin.x >= toPoint.x {
            return angle
        }
        
        angle = .pi - angle
        return angle
    }
    
    static func trajectoryDistance(pointOffScreen: CGPoint, origin: CGPoint) -> CGFloat {
        let distance = sqrt(pow((pointOffScreen.x - origin.x), 2) + pow((pointOffScreen.y - origin.y), 2))
        return distance
    }
    
    static func trajectoryDuration(distance: CGFloat, speed: CGFloat) -> Double {
        return Double(distance / speed)
    }

}
