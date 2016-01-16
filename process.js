var fs=require("fs");
var oData = JSON.parse(fs.readFileSync("./sourcedata/uk_lighthouses.geojson").toString());
var LatLon    = require('geodesy').LatLonEllipsoidal;
var OsGridRef = require('geodesy').OsGridRef;
var Dms       = require('geodesy').Dms;


var basicCSV = require("basic-csv");

basicCSV.readCSV("./sourcedata/cwtb04ab_uksite_201411.csv", {dropHeader: true}, function (error, rows) {
	  //console.log(rows); // displays a nested array of arrays
	  
	  var aSites = rows.map(function(aRow){
		 //console.log(aRow);
		 try {
			 var grid = OsGridRef.parse(aRow[2])
			 var latlong = OsGridRef.osGridToLatLon(grid); // p.toString(): 52°39′29″N, 001°42′58″E
			 
			 //console.log(latlong);
			 var oSite = {
				 "site_name":aRow[1],
				 "lat":latlong.lat,
				 "lon":latlong.lon,
				 "e-coli": aRow[8],
				 "enterocci":aRow[12]
			 }
			 return oSite;
		 } catch (e) {
			 console.log(aRow[1], "Bathing site OS Grid Ref "+aRow[2]+" failed to parse.");
		 }
	  });
	  
	  aSites = aSites.filter(function(rSite){
		  
		 return (typeof rSite  !== "undefined") && (typeof rSite.lat !== "undefined"); 
		  
	  });

	//console.log(aSites);
	
	fs.writeFileSync("./data/cwtb04ab_uksite_201411.json", JSON.stringify(aSites, null, 4));
	
	
	var aWithNearest = oData.features.map(function(oLighthouse){
		var oLPos =  new LatLon(oLighthouse.geometry.coordinates[1], oLighthouse.geometry.coordinates[0]);
		var aDists = aSites.map(function(oSite){
			var oSPos =  new LatLon(oSite.lat, oSite.lon);
		
			oSite.dist = Math.round(oLPos.distanceTo(oSPos) / 1000);
			
			return oSite;
		});
		
		aDists.sort(function(a,b){
			if(a.dist < b.dist) {
				return -1;
			} else if(a.dist > b.dist) {
				return 1;
			}
			return 0;
		});
			
		oLighthouse.bathing_data = aDists[0];
		
		return oLighthouse;
	});
	
	oData.features = aWithNearest;
	
	fs.writeFileSync("./data/lighthouses.geojson", JSON.stringify(oData, null, 4));
	
});


