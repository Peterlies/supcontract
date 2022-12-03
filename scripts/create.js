const fs = require('fs');


let data = "hello"

fs.writeFileSync("2.json",data);

console.log("File written successfully\n");
console.log("The written has the following contents:");
console.log(fs.readFileSync("programming.txt", "utf8"));