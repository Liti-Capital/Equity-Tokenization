require('dotenv').config();
const fs = require('fs');
const Web3 = require('web3');

async function main() {
    let litiABI = fs.readFileSync('./upgradeable/contracts/__LITI_sol_LitiCapital.abi');
    litiABI = JSON.parse(litiABI.toString());
    let litiBYTECODE = fs.readFileSync('./upgradeable/contracts/__LITI_sol_LitiCapital.bin');
    litiBYTECODE = litiBYTECODE.toString();

    let litiProxyABI = fs.readFileSync('./upgradeable/contracts/__LITIProxy_sol_LitiProxy.abi');
    litiProxyABI = JSON.parse(litiProxyABI.toString());
    let litiProxyBYTECODE = fs.readFileSync('./upgradeable/contracts/__LITIProxy_sol_LitiProxy.bin');
    litiProxyBYTECODE = litiProxyBYTECODE.toString();

    let wlitiABI = fs.readFileSync('./upgradeable/contracts/__wLITI_sol_wLitiCapital.abi');
    wlitiABI = JSON.parse(wlitiABI.toString());
    let wlitiBYTECODE = fs.readFileSync('./upgradeable/contracts/__wLITI_sol_wLitiCapital.bin');
    wlitiBYTECODE = wlitiBYTECODE.toString();

    const web3 = new Web3(process.env.WEB3_PROVIDER);

    const sharesContract = new web3.eth.Contract(litiABI);
    const proxyContract = new web3.eth.Contract(litiProxyABI);
    const wlitiContract = new web3.eth.Contract(wlitiABI);

    let data = sharesContract.deploy({ data: litiBYTECODE }).encodeABI();
    let tx = {
        gasLimit: 8000000,
        data: data,
    }
    const sharesContractTx = await web3.eth.accounts.signTransaction(tx, process.env.TOKEN_ADMIN_PRIVATEKEY);
    web3.eth.sendSignedTransaction(sharesContractTx.rawTransaction)
        .on('confirmation', async (number, receipt) => {
            if (number == 1) {
                console.log(receipt)
                sharesContract.options.address = receipt.contractAddress;
                console.log('Shares contract deployed')

                let initializeCode = sharesContract.methods.initialize().encodeABI();
                let data = proxyContract.deploy({
                    data: litiProxyBYTECODE,
                    arguments: [sharesContract.options.address, process.env.PROXY_ADMIN_PUBLICKEY, initializeCode]
                }).encodeABI();
                let tx = {
                    gasLimit: 8000000,
                    data: data,
                }
                const proxyContractTx = await web3.eth.accounts.signTransaction(tx, process.env.TOKEN_ADMIN_PRIVATEKEY);
                web3.eth.sendSignedTransaction(proxyContractTx.rawTransaction)
                    .on('confirmation', async (number, receipt) => {
                        if (number == 1) {
                            proxyContract.options.address = receipt.contractAddress;
                            console.log('Proxy deployed')

                            let data = wlitiContract.deploy({
                                data: wlitiBYTECODE,
                                arguments: [proxyContract.options.address]
                            }).encodeABI();
                            let tx = {
                                gasLimit: 8000000,
                                data: data,
                            }
                            const wlitiContractTx = await web3.eth.accounts.signTransaction(tx, process.env.TOKEN_ADMIN_PRIVATEKEY);
                            web3.eth.sendSignedTransaction(wlitiContractTx.rawTransaction)
                                .on('confirmation', (number, receipt) => {
                                    if (number == 1) {
                                        wlitiContract.options.address = receipt.contractAddress;

                                        const deployed = {
                                            proxyAddress: proxyContract.options.address,
                                            sharesAddress: sharesContract.options.address,
                                            wrappedAddress: wlitiContract.options.address
                                        }
                                        fs.writeFileSync('deployedContracts.json', JSON.stringify(deployed));
                                        console.log('Done')
                                    }
                                })
                                .on('error', async (error) => {
                                    console.log('error submitting transaction. Error: ', error)
                                })
                        }
                    })
                    .on('error', async (error) => {
                        console.log('error submitting transaction. Error: ', error)
                    })

            }
        })
        .on('error', async (error) => {
            console.log('Error deploying shares contract: ', error)
        })

}

main();
