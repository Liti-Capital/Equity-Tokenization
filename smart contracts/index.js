const fs = require('fs');

let litiABI = fs.readFileSync('./upgradeable/contracts/__LITI_sol_LitiCapital.abi');
litiABI = JSON.parse(litiABI.toString())
let litiBYTECODE = fs.readFileSync('./upgradeable/contracts/__LITI_sol_LitiCapital.bin');
litiBYTECODE = litiBYTECODE.toString();

let litiProxyABI = fs.readFileSync('./upgradeable/contracts/__LITIProxy_sol_LitiProxy.abi');
litiProxyABI = JSON.parse(litiProxyABI.toString())
let litiProxyBYTECODE = fs.readFileSync('./upgradeable/contracts/__LITIProxy_sol_LitiProxy.bin');
litiProxyBYTECODE = litiProxyBYTECODE.toString();

let wlitiABI = fs.readFileSync('./upgradeable/contracts/__wLITI_sol_wLitiCapital.abi');
wlitiABI = JSON.parse(wlitiABI.toString());
let wlitiBYTECODE = fs.readFileSync('./upgradeable/contracts/__wLITI_sol_wLitiCapital.bin');
wlitiBYTECODE = wlitiBYTECODE.toString();


console.log(wlitiBYTECODE)