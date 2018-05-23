//
//  ViewController.swift
//  GISTest
//
//  Created by Mobility on 5/22/18.
//  Copyright © 2018 Mobility. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController, AGSGeoViewTouchDelegate {

    // MARK: Outlets
    @IBOutlet private weak var mapView: AGSMapView!
    
    // MARK: Data Members
    private var map:AGSMap!
    private var locatorTask:AGSLocatorTask!
    private var geocodeParameters:AGSGeocodeParameters!
    private var graphicsOverlay:AGSGraphicsOverlay!
    
    // MARK: Constant Data
    private let locatorURL = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
    
    // MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting base map.
        self.mapView.map = AGSMap(basemap: AGSBasemap.imageryWithLabelsVector())
        self.map = AGSMap(basemap: AGSBasemap.topographic())
        self.mapView.map = map
        self.mapView.touchDelegate = self
        
        //initialize the graphics overlay and add to the map view
        self.graphicsOverlay = AGSGraphicsOverlay()
        self.mapView.graphicsOverlays.add(self.graphicsOverlay)
        
        //initialize locator task
        self.locatorTask = AGSLocatorTask(url: URL(string: self.locatorURL)!)
        
        //initialize geocode parameters
        self.geocodeParameters = AGSGeocodeParameters()
        self.geocodeParameters.resultAttributeNames.append(contentsOf: ["*"])
        self.geocodeParameters.minScore = 75
        
        // Search Test in GIS map.
        self.geocodeSearchText("Pune")
        
    }
    
    // MARK: Miscelleneous functions
    
    /// Method to search address in GIS maps.
    private func geocodeSearchText(_ text:String) {
        //clear already existing graphics
        self.graphicsOverlay.graphics.removeAllObjects()
        
        //dismiss the callout if already visible
        self.mapView.callout.dismiss()
        
        //perform geocode with input text
        self.locatorTask.geocode(withSearchText: text, parameters: self.geocodeParameters, completion: { [weak self] (results:[AGSGeocodeResult]?, error:Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                if let results = results , results.count > 0 {
                    //create a graphic for the first result and add to the graphics overlay
                    let graphic = self?.graphicForPoint(results[0].displayLocation!, attributes: results[0].attributes as [String : AnyObject]?)
                    self?.graphicsOverlay.graphics.add(graphic!)
                    //zoom to the extent of the result
                    if let extent = results[0].extent {
                        self?.mapView.setViewpointGeometry(extent, completion: nil)
                    }
                }
                else {
                    //provide feedback in case of failure
                    print("No results found")
                }
            }
        })
    }
    
    /// Method that returns a graphic object for the specified point and attributes
    /// also sets the leader offset and offset.
    private func graphicForPoint(_ point: AGSPoint, attributes: [String: AnyObject]?) -> AGSGraphic {
     
        let markerImage = UIImage(named: "pin")!
        let symbol = AGSPictureMarkerSymbol(image: markerImage)
        symbol.leaderOffsetY = markerImage.size.height/2
        symbol.offsetY = markerImage.size.height/2
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: attributes)
        return graphic
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

