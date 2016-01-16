var fs=require("fs");

var oData = JSON.parse(fs.readFileSync("./sourcedata/uk_lighthouses.geojson").toString());

console.log(oData);
