var walletSdk = require('./walletSdk');
var assetSdk = require('./assetSdk');
var receiptSdk = require('./receiptSdk');
var gapSdk = require('./gapSdk');
function MakeQuery(key,value) {
 	var msg= '{"selector":{"'+key+'":"'+value+'"}}'    
    return msg
}

function AssetOrgController(org,type,func,args,res){
    if (org==1){
        assetSdk.send1(type,func,args,res);
    }
    else if (org==2){
        assetSdk.send2(type,func,args,res);
    }
    else if (org==3){
        assetSdk.send3(type,func,args,res);
    }
    else if (org==4){
        assetSdk.send4(type,func,args,res);
    }
}
function WalletOrgController(org,type,func,args,res){
    if (org==1){
        walletSdk.send1(type,func,args,res);
    }
    else if (org==2){
        walletSdk.send2(type,func,args,res);
    }
    else if (org==3){
        walletSdk.send3(type,func,args,res);
    }
    else if (org==4){
        walletSdk.send4(type,func,args,res);
    }
}
function ReceiptOrgController(org,type,func,args,res){
    if (org==1){
        receiptSdk.send1(type,func,args,res);
    }
    else if (org==2){
        receiptSdk.send2(type,func,args,res);
    }
    else if (org==3){
        receiptSdk.send3(type,func,args,res);
    }
    else if (org==4){
        receiptSdk.send4(type,func,args,res);
    }
}

function GapOrgController(org,type,func,args,res){
    if (org==1){
        gapSdk.send1(type,func,args,res);
    }
    else if (org==2){
        gapSdk.send2(type,func,args,res);
    }
    else if (org==3){
        gapSdk.send3(type,func,args,res);
    }
    else if (org==4){
        gapSdk.send4(type,func,args,res);
    }
}
module.exports = function(app) {

    app.get('/GetAllAssets', function (req, res) {
        var org = req.query.org;
        let args = [];
        AssetOrgController(org, false, 'GetAllAssets', args, res);
    });

    app.get('/AssetExists', function (req, res) {
        var org = req.query.org;
        var id = req.query.id;
        let args = [id];
        AssetOrgController(org, false, 'AssetExists', args, res);
    });

    app.get('/DeleteAsset', function (req, res) {
        var org = req.query.org;
        var id = req.query.id;
        let args = [id];
        AssetOrgController(org, true, 'DeleteAsset', args, res);
    });

    app.get('/ReadAsset', function (req, res) {
        var org = req.query.org;
        var id = req.query.id;
        let args = [id];
        AssetOrgController(org, false, 'ReadAsset', args, res);
    });

    app.get('/TransferAsset', function (req, res) {
        var org = req.query.org;
        var id = req.query.id;
        var newOwner = req.query.newOwner;
        let args = [id, newOwner];
        AssetOrgController(org, true, 'TransferAsset', args, res);
    });

    app.get('/CreateAsset', function (req, res) {
        // var id = req.query.id;
        var org = req.query.org;
        var owner = req.query.owner;
        var location = req.query.location;  
        var category = req.query.category;
        var kind = req.query.kind;
        var totalprice = req.query.totalprice;
        var area = req.query.area;
        var price = req.query.price;
        let args = [owner,  location, category, kind, totalprice, area, price];
        AssetOrgController(org, true, 'CreateAsset', args, res);
    });

    app.get('/UpdateAsset', function (req, res) {
        var org = req.query.org;
        var id = req.query.id;
        var owner = req.query.owner;
        var location = req.query.location;  
        var category = req.query.category;
        var kind = req.query.kind;
        var totalprice = req.query.totalprice;
        var area = req.query.area;
        var price = req.query.price;
        let args = [id, owner, location, category, kind, totalprice, area, price];
        AssetOrgController(org, 'UpdateAsset', args, res);
    });

    app.get('/QueryAssets', function (req, res) {
        var org = req.query.org;
        var key = req.query.key;
        var value = req.query.value;
        var msg = MakeQuery(key,value);
        let args = [msg];
        AssetOrgController(org, false, 'QueryAssets', args, res);
    });   
    
    app.get('/CreateWallet', function (req, res) {
        var org = req.query.org;
        var owner = req.query.owner;
         
        let args = [owner];
        WalletOrgController(org, true, 'CreateWallet', args, res);
    });

    app.get('/ReadWallet', function (req, res) {
        var org = req.query.org;
        var id = req.query.id;         
        let args = [id];
        WalletOrgController(org, false, 'ReadWallet', args, res);
    });
    app.get('/Mint', function (req, res) {
        var org = req.query.org;
        var id = req.query.id;
        var amount = req.query.amount;
        let args = [id, amount];
        WalletOrgController(org, true, 'Mint', args, res);
    });

    app.get('/Burn', function (req, res) {
        var org = req.query.org;
        var id  = req.query.id;
        var amount = req.query.amount;
        let args = [id, amount];
        WalletOrgController(org, true, 'Burn', args, res);
    });

    app.get('/BalanceOf', function (req, res) {
        var org = req.query.org;
        var id  = req.query.id;
        let args = [id];
        WalletOrgController(org, false, 'BalanceOf', args, res);
    });    
    app.get('/TransferToken', function (req, res) {
        var org = req.query.org;
        var client = req.query.client;
        var recipient = req.query.recipient;
        var value = req.query.value;
        let args = [client, recipient, value];
        WalletOrgController(org, true, 'TransferToken', args, res);
    });

    app.get('/TokenInitialize', function (req, res) {
        var org = req.query.org;
        var name = req.query.name;
        var symbol = req.query.symbol;
        var decimals = req.query.decimals;
        let args = [name,symbol,decimals];
        WalletOrgController(org, true, 'TokenInitialize', args, res);
    });

    
    app.get('/QueryReceipts', function (req, res) {
        var org = req.query.org;
        var key = req.query.key;
        var value = req.query.value;
        var msg = MakeQuery(key,value);
        let args = [msg];
        ReceiptOrgController(org, false, 'QueryReceipts', args, res);
    });


    app.get('/CreateReceipt', function (req, res) {
        var org = req.query.org;
        var assetid = req.query.assetid;
        var from = req.query.from;
        var to = req.query.to;
        var totalprice = req.query.totalprice;
        var downpayment = req.query.downpayment;
        var releasedate = req.query.releasedate;
        var timestamp = req.query.timestamp;
        let args = [assetid, from, to, totalprice, downpayment, releasedate, timestamp];
        ReceiptOrgController(org, true, 'CreateReceipt', args, res);
    });
    app.get('/GapExists', function (req, res) {
        var org = req.query.org;
        var gapnum = req.query.gapnum;
        var name = req.query.name;
        var kind = req.query.kind;
        var location = req.query.location;
        var area = req.query.area;
        let args = [gapnum, name, kind, location, area];
        GapOrgController(org, false, 'GapExists', args, res);
    });
    app.get('/InitGapLedger', function (req, res) {
        var org = req.query.org;        
        let args = [];
        GapOrgController(org, true, 'InitGapLedger', args, res);
    });
                
}