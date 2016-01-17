//Processes the data files to produce the static JSON data the musical front end uses
var fs=require("fs");

var LatLon    = require('geodesy').LatLonEllipsoidal;
var OsGridRef = require('geodesy').OsGridRef;
var Dms       = require('geodesy').Dms;

var basicCSV = require("basic-csv");
//basicCSV is not great but because the data we had coming it was labelled badly it seemed the best fit

//Data sources 

//Light house data a GEO JSON file from OpenStreetMap using overpass turbo
// http://overpass-turbo.eu/s/dMO 
/* Query:
[out:json][timeout:25];
{{geocodeArea:UK}}->.searchArea;
(
  node["man_made"="lighthouse"](area.searchArea);
);
out body;
>;
out skel qt;
*/ 
var sLighthouseFile = "./sourcedata/uk_lighthouses.geojson";

//Bathing water quality data
//We would have been better using the API directly but currenty have a csv
// TODO : #2 on github
var sBWQ_File = "./sourcedata/cwtb04ab_uksite_201411.csv"

var oIncomingLighthouses = JSON.parse(fs.readFileSync(sLighthouseFile).toString());


basicCSV.readCSV(sBWQ_File, {dropHeader: true}, function (error, rows) {
	  
	  // Calc the LAT /Lon for each sampling site (the API data has this)
	  var aSites = rows.map(function(aRow){
		 try {
			 var grid = OsGridRef.parse(aRow[2]);
			 var latlong = OsGridRef.osGridToLatLon(grid);
			 
			 //console.log(latlong);
			 var oSite = {
				 "site_name":aRow[1],
				 "dist":null,
				 "lat":latlong.lat,
				 "lon":latlong.lon,
				 "e-coli": aRow[8],
				 "enterocci":aRow[12]
			 };
			 return oSite;
		 } catch (e) {
			 console.log(aRow[1], "Bathing site OS Grid Ref "+aRow[2]+" failed to parse.");
		 }
	  });
	  
	  //Drop sites we couldn't find at lon for
	  aSites = aSites.filter(function(rSite){
		 return (typeof rSite  !== "undefined") && (typeof rSite.lat !== "undefined"); 
	  });

	//Dump the modified BWQ data in case we need it in the UI
	fs.writeFileSync("./data/cwtb04ab_uksite_201411.json", JSON.stringify(aSites, null, 4));
	
	//Create a parallel list of lat lon for sites to ease calculation later 
	var aSitesWithPoint = aSites.map(function(oSite){
		return  new LatLon(oSite.lat, oSite.lon);//, "OSGB36");
		//return oSite;
	});
	
	//Add the neardt BWQ sample to each lighthouse
	var aWithNearest = oIncomingLighthouses.features.map(function(oLighthouse){
		var oLPos =  new LatLon(oLighthouse.geometry.coordinates[1], oLighthouse.geometry.coordinates[0]);
		
		//Calc the distance for each BWQ site to this lighthouse
		var aDists = aSites.map(function(oSite, iKey){
			
			oSite.dist = Math.round(aSitesWithPoint[iKey].distanceTo(oLPos)/1000); //km
			//console.log("oLPos",oLPos.lat, oLPos.lon, "aSitesWithPoint[iKey]", aSitesWithPoint[iKey].lat, aSitesWithPoint[iKey].lon, "oSite.dist", oSite.dist);
			return oSite;
		});
		
		//sort the BWQ site by distance to this lighthouse
		aDists.sort(function(a,b){
			return a.dist - b.dist;
		});
		
		//Attach the mearset (first in the list) to this lighthouse
		oLighthouse.bathing_data = aDists[0];
		return oLighthouse;
	});
	
	//Reattach the modified lighthouses to the geojson
	oIncomingLighthouses.features = aWithNearest;
	
	//Write to disk
	fs.writeFileSync("./data/lighthouses.geojson", JSON.stringify(oIncomingLighthouses, null, 4));
	
});


