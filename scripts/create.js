const fs = require('fs');

for(let i = 0 ; i < 5000 ; i ++){
let name = '"name" :'+'"FireSeed #' +i +'"';
let image = '"image" :' + '"https://raw.githubusercontent.com/henry-maker-commits/supcontract/master/contracts/FDao/PIC/0.png"'
let data = '{'+'"id":'+i +','+name+',' +image
            +'}';

fs.writeFileSync(i+".json",data);

console.log(fs.readFileSync("2.json", "utf8"));
}
console.log("File written successfully\n");
