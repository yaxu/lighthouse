var fs=require("fs");





var oData = JSON.parse(fs.readFileSync("./sourcedata/uk_lighthouses.geojson").toString());

//console.log(oData);

	var LatLon    = require('geodesy').LatLonEllipsoidal;
	var OsGridRef = require('geodesy').OsGridRef;
	var Dms       = require('geodesy').Dms;
	

var basicCSV = require("basic-csv");

basicCSV.readCSV("./sourcedata/cwtb04ab_uksite_201411.csv", {dropHeader: true}, function (error, rows) {
  //console.log(rows); // displays a nested array of arrays
  
  var aSites = rows.map(function(aRow){
	 console.log(aRow);
	 try {
		 var grid = OsGridRef.parse(aRow[2])
		 var latlong = OsGridRef.osGridToLatLon(grid); // p.toString(): 52°39′29″N, 001°42′58″E
		 
		 console.log(latlong);
		 var oSite = {
			 "site_name":aRow[1],
			 "lat":latlong.lat,
			 "lon":latlong.lon,
			 "e-coli": aRow[8],
			 "enterocci":aRow[12]
		 }
		 return oSite;
	 } catch (e) {
		 console.log(aRow[1], "failed");
	 }
  });

	console.log(aSites);
	
	fs.writeFileSync("./data/cwtb04ab_uksite_201411.json", JSON.stringify(aSites));
});
