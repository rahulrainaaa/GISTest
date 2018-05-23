//
//  RoutingViewController.swift
//  GISTest
//
//  Created by Mobility on 5/23/18.
//  Copyright © 2018 Mobility. All rights reserved.
//

import UIKit
import ArcGIS

/// Class to show routing demo.
class RoutingViewController: UIViewController, AGSGeoViewTouchDelegate {
    
    // MARK: Outlets
    @IBOutlet private weak var mapView: AGSMapView!
    
    // MARK: Data Members
    private var map:AGSMap!
    var routeTask:AGSRouteTask!
    var routeParameters:AGSRouteParameters!
    var stopGraphicsOverlay = AGSGraphicsOverlay()
    var routeGraphicsOverlay = AGSGraphicsOverlay()
    var stop1Geometry:AGSPoint!
    var stop2Geometry:AGSPoint!
    var generatedRoute:AGSRoute!

    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting base map.
        self.mapView.map = AGSMap(basemap: AGSBasemap.imageryWithLabelsVector())
        self.map = AGSMap(basemap: AGSBasemap.topographic())
        self.mapView.map = map
        self.mapView.touchDelegate = self
    
        //add graphicsOverlays to the map view
        self.mapView.graphicsOverlays.addObjects(from: [routeGraphicsOverlay, stopGraphicsOverlay])
        
        //zoom to viewpoint
        self.mapView.setViewpointCenter(AGSPoint(x: -13041154.715252, y: 3858170.236806, spatialReference: AGSSpatialReference(wkid: 3857)), scale: 1e5, completion: nil)
        
        //initialize route task
        self.routeTask = AGSRouteTask(url: URL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/Route")!)
        
        //get default parameters
        self.getDefaultParameters()
        
    }
    
    
    @IBAction func showButtonClick(_ sender: Any) {
        
        route()
    }
    
    func addStops() {
        
        self.stop1Geometry = AGSPoint(x: -13041171.537945, y: 3860988.271378, spatialReference: AGSSpatialReference(wkid: 3857))
        self.stop2Geometry = AGSPoint(x: -13041693.562570, y: 3856006.859684, spatialReference: AGSSpatialReference(wkid: 3857))
        
        let startStopGraphic = AGSGraphic(geometry: self.stop1Geometry, symbol: self.stopSymbol(withName: "Origin", textColor: UIColor.blue), attributes: nil)
        let endStopGraphic = AGSGraphic(geometry: self.stop2Geometry, symbol: self.stopSymbol(withName: "Destination", textColor: UIColor.red), attributes: nil)
        
        self.stopGraphicsOverlay.graphics.addObjects(from: [startStopGraphic, endStopGraphic])
    }
    
    //method provides a text symbol for stop with specified parameters
    func stopSymbol(withName name:String, textColor:UIColor) -> AGSTextSymbol {
        return AGSTextSymbol(text: name, color: textColor, size: 20, horizontalAlignment: .center, verticalAlignment: .middle)
    }
    
    //method provides a line symbol for the route graphic
    func routeSymbol() -> AGSSimpleLineSymbol {
        let symbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.red, width: 5)
        return symbol
    }
    
    //MARK: - Route logic
    
    /// Method to get the default parameters for the route task
    func getDefaultParameters() {
        
        self.routeTask.defaultRouteParameters { [weak self] (params: AGSRouteParameters?, error: Error?) -> Void in
            if let error = error {
                print(error)
            }
            else {
                //on completion store the parameters
                self?.routeParameters = params
                //add stops
                self?.addStops()
            }
        }
    }
    
    // MARK: Route event
    
    /// Method to route the task.
    func route() {
        //route only if default parameters are fetched successfully
        if self.routeParameters == nil {
            print("Default route parameters not loaded")
        }
        
        //set parameters to return directions
        self.routeParameters.returnDirections = true
        
        //clear previous routes
        self.routeGraphicsOverlay.graphics.removeAllObjects()
        
        //clear previous stops
        self.routeParameters.clearStops()
        
        //set the stops
        let stop1 = AGSStop(point: self.stop1Geometry)
        stop1.name = "Origin"
        let stop2 = AGSStop(point: self.stop2Geometry)
        stop2.name = "Destination"
        self.routeParameters.setStops([stop1, stop2])
        
        self.routeTask.solveRoute(with: self.routeParameters) { (routeResult: AGSRouteResult?, error: Error?) -> Void in
            if let error = error {
                print(error)
            }
            else {
                //show the resulting route on the map
                //also save a reference to the route object
                //in order to access directions
                self.generatedRoute = routeResult!.routes[0]
                let routeGraphic = AGSGraphic(geometry: self.generatedRoute.routeGeometry, symbol: self.routeSymbol(), attributes: nil)
                self.routeGraphicsOverlay.graphics.add(routeGraphic)
            }
        }
    }

}
