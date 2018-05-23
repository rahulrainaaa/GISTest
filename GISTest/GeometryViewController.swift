//
//  GeometryViewController.swift
//  GISTest
//
//  Created by Mobility on 5/23/18.
//  Copyright © 2018 Mobility. All rights reserved.
//

import UIKit
import ArcGIS

class GeometryViewController: UIViewController, AGSGeoViewTouchDelegate {
    
    // MARK: Outlet
    @IBOutlet weak var mapView: AGSMapView!
    
    // MARK: Data Members
    private var map:AGSMap!
    private var graphicsOverlay = AGSGraphicsOverlay()
    
    // MARK:  UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting base map.
        self.mapView.map = AGSMap(basemap: AGSBasemap.imageryWithLabelsVector())
        self.map = AGSMap(basemap: AGSBasemap.topographic())
        self.mapView.map = map
        self.mapView.touchDelegate = self
    
        //add graphics overlay to the map view
        self.mapView.graphicsOverlays.add(self.graphicsOverlay)
        
        //create symbols for drawing graphics
        let markerSymbol = AGSSimpleMarkerSymbol(style: .triangle, color: UIColor.blue, size: 14)
        let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.blue, width: 3)
        let fillSymbol = AGSSimpleFillSymbol(style: .cross, color: UIColor.blue, outline: nil)
        
        //add a graphic of point, multipoint, polyline and polygon
        self.graphicsOverlay.graphics.add(AGSGraphic(geometry: self.createPoint(), symbol: markerSymbol, attributes: nil))
        self.graphicsOverlay.graphics.add(AGSGraphic(geometry: self.createMultipoint(), symbol: markerSymbol, attributes: nil))
        self.graphicsOverlay.graphics.add(AGSGraphic(geometry: self.createPolyline(), symbol: lineSymbol, attributes: nil))
        self.graphicsOverlay.graphics.add(AGSGraphic(geometry: self.createPolygon(), symbol: fillSymbol, attributes: nil))
        
        //use the envelope to set the viewpoint of the map view
        self.mapView.setViewpointGeometry(self.createEnvelope(), padding: 100, completion: nil)
        
    }
    
    private func createEnvelope() -> AGSEnvelope {
        //create an envelope using minimum and maximum x,y coordinates and a spatial reference
        let envelope = AGSEnvelope(xMin: -123.0, yMin: 33.5, xMax: -101.0, yMax: 48.0, spatialReference: AGSSpatialReference.wgs84())
        return envelope
    }
    
    private func createPoint() -> AGSPoint {
        // create a point using x,y coordinates and a spatial reference
        let point = AGSPoint(x: 34.056295, y: -117.195800, spatialReference: AGSSpatialReference.wgs84())
        return point
    }
    
    private func createMultipoint() -> AGSMultipoint {
        // create a multi point geometry
        let multipointBuilder = AGSMultipointBuilder(spatialReference: AGSSpatialReference.wgs84())
        multipointBuilder.points.addPointWith(x: -121.491014, y: 38.579065) // Sacramento, CA
        multipointBuilder.points.addPointWith(x: -122.891366, y: 47.039231) // Olympia, WA
        multipointBuilder.points.addPointWith(x: -123.043814, y: 44.93326) // Salem, OR
        multipointBuilder.points.addPointWith(x: -119.766999, y: 39.164885) // Carson City, NV
        
        return multipointBuilder.toGeometry()
    }
    
    private func createPolyline() -> AGSPolyline {
        //create a polyline
        let polylineBuilder = AGSPolylineBuilder(spatialReference: AGSSpatialReference.wgs84())
        polylineBuilder.addPointWith(x: -119.992, y: 41.989)
        polylineBuilder.addPointWith(x: -119.994, y: 38.994)
        polylineBuilder.addPointWith(x: -114.620, y: 35.0)
        
        return polylineBuilder.toGeometry()
    }
    
    private func createPolygon() -> AGSPolygon {
        // create a polygon
        let polygonBuilder = AGSPolygonBuilder(spatialReference: AGSSpatialReference.wgs84())
        polygonBuilder.addPointWith(x: -109.048, y: 40.998)
        polygonBuilder.addPointWith(x: -102.047, y: 40.998)
        polygonBuilder.addPointWith(x: -102.037, y: 36.989)
        polygonBuilder.addPointWith(x: -109.048, y: 36.998)
        
        return polygonBuilder.toGeometry()
    }
}
    

