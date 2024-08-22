const express = require('express');
const app = express();
const axios = require('axios');

app.use(express.json());

const { MongoClient, ServerApiVersion } = require('mongodb');
const uri = "mongodb+srv://aryapatki:pass123@cluster0.3vovzgd.mongodb.net/?retryWrites=true&w=majority";
// var DATABASENAME="wishlist";
// var database;

const PORT= 8080 || process.env.PORT
const OAuthToken=require('./ebay_oauth_token')

let dataList;
const client_id = 'AryaPatk-Assignme-PRD-072b2ae15-5fce431c';
const client_secret = 'PRD-72b2ae159af4-8490-4e32-a292-13e2';

const oauthToken = new OAuthToken(client_id, client_secret);

const cors = require('cors');
const { default: mongoose } = require('mongoose');
app.use(cors());
app.get('/getItemsList', (req, res) => {
    let keywords = req.query.keyword;
    let MaxDistance= req.query.distance;
    let buyerPostalCode=req.query.location;
    let newCondition=req.query.new;
    let usedCondition=req.query.used;
    let unspecifiedCondition=req.query.unspecified;
    let LocalPickupOnly=req.query.localPickup;
    let FreeShippingOnly=req.query.freeShipping;
    let category=req.query.category;
    let categoryId;
    if(category){
        if(category=="allCategories"){categoryId="-1"}
        else if(category=="art"){
            categoryId="550"
        }
        else if(category=="baby") categoryId="2984"
        else if(category=="books") categoryId="267"
        else if(category=="CSA" ) categoryId="11450"
        else if(category=="CTN" ) categoryId="58058"
        else if(category=="HB" ) categoryId="26395"
        else if(category=="music" ) categoryId="11233"
        else if(category=="VGC" ) categoryId="1249"
    }

    let ebay_link= 'https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=AryaPatk-Assignme-PRD-072b2ae15-5fce431c&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&paginationInput.entriesPerPage=50'

    let params=""

    params+="&keywords="+keywords;
    if(categoryId!="-1"){ 
        // console.log(categoryId);
        params+="&categoryId="+categoryId;}
    params+="&buyerPostalCode="+buyerPostalCode;
    params+="&itemFilter(0).name=MaxDistance&itemFilter(0).value="+MaxDistance;
    let count=1;
    if(FreeShippingOnly){
        params+= "&itemFilter(" +count+").name=FreeShippingOnly&itemFilter("+count+" ).value=true";
        count++;
    }
    if(LocalPickupOnly){
        params += "&itemFilter(" +count+").name=LocalPickupOnly&itemFilter("+count+").value=true";
        count++ ;
    }
    params+= "&itemFilter("+count+").name=HideDuplicateItems&itemFilter("+count+").value=true";
    count++;
    if(newCondition || usedCondition){
        params+="&itemFilter("+count+").name=Condition";
        let conditionCount=0;
        if(newCondition){
            params+="&itemFilter("+count+").value("+conditionCount+")=New"
            conditionCount++;
        }
        if(usedCondition){
            params+="&itemFilter("+count+").value("+conditionCount+")=Used"
            conditionCount++;
        }

    }


    params+="&outputSelector(0)=SellerInfo&outputSelector(1)=StoreInfo"

    ebay_link+=params

    // console.log(ebay_link);r

    axios.get(ebay_link)
 .then(response => {
    // console.log(response.data);
    dataList= response.data.findItemsAdvancedResponse[0].searchResult[0].item;
    console.log("dataList: ",dataList);
    res.json({data:response.data.findItemsAdvancedResponse[0]});
 })
 .catch(error => {
    console.log(error);
 });
    // Sample response, you can modify this as per your needs.
  
});

app.get('/getZipCodeList',(req,res)=>{
    url= "http://api.geonames.org/postalCodeSearchJSON?postalcode_startsWith="+req.query.zip+"&maxRows=5&username=apatki&country=US"

    axios.get(url)
    .then((response) => {
        console.log('geoloc: ', response.data);
        res.json({data:response.data});
    })
    .catch((err) => {
        console.log('Error in getting item details : ', err);
    });

})

app.get('/getItemDetails',async (req,res)=>{
    const accessToken= await getAccessToken()
    let headers = {
        "X-EBAY-API-IAF-TOKEN": accessToken
    };
    let filters = {
        "itemId": req.query.itemId,
        "IncludeSelector": 'Description,Details,ItemSpecifics'
    };

    getSingleItemUrl="https://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid="+client_id+"&siteid=0&version=967"
// console.log("access token: ",headers['X-EBAY-API-IAF-TOKEN']);
    axios.get(getSingleItemUrl,{params:filters, headers:headers})
    .then((response) => {
        // console.log('Get Item Details Response : ', response.data);
        res.json({data:response.data});
    })
    .catch((err) => {
        console.log('Error in getting item details : ', err);
    });


    
});


app.get('/getItemPhotos',(req,res)=>{
    apiKey="AIzaSyAzCW-v1O_mta1Yr7P47wuWtQRQ5ykg1aM";
    searchEngineId="709064201e17b401c";

    let url= "https://www.googleapis.com/customsearch/v1?q=";
    url+=req.query.title;
    url+="&cx="+searchEngineId+"&imgSize=huge&num=8&searchType=image&key="+apiKey;

    // console.log(url);

    axios.get(url)
    .then((response) => {
        // console.log('Get Item Details Response : ', response.data);
        res.json({data:response.data});
    })
    .catch((err) => {
        console.log('Error in getting item details : ', err);
    });
});

app.get('/getSimilarItems',(req,res)=>{

    url="https://svcs.ebay.com/MerchandisingService?OPERATION-NAME=getSimilarItems&SERVICE-NAME=MerchandisingService&SERVICE-VERSION=1.1.0&CONSUMER-ID=AryaPatk-Assignme-PRD-072b2ae15-5fce431c&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&itemId="+req.query.itemId+"&maxResults=20"

    axios.get(url)
    .then((response) => {

        res.json({data:response.data});
    })
    .catch((err) => {
        console.log('Error in getting item details : ', err);
    });
})


async function getAccessToken() {
    try {
        const accessToken = await oauthToken.getApplicationToken();
        // console.log('Access Token:', accessToken);
        return accessToken;
    } catch (error) {
        console.error('Error:', error);
    }
}


// async function connectMongo(){
//     try{
//         await mongoose.connect(CONNECTION_STRING);
//         console.log("connected to mongoDB");
//     }catch{
//         console.error();
//     }
// }
// connectMongo()

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri, {
    serverApi: {
      version: ServerApiVersion.v1,
      strict: true,
      deprecationErrors: true,
    }
  });


async function run() {
    try {
      // Connect the client to the server	(optional starting in v4.7)
      await client.connect();
      // Send a ping to confirm a successful connection
      await client.db("admin").command({ ping: 1 });
      console.log("Pinged your deployment. You successfully connected to MongoDB!");
    } finally {
      // Ensures that the client will close when you finish/error
    //   await client.close();
    }
  }
  run().catch(console.dir);

  
// async 
  app.get('/wishListRemove', async  (req,res)=>{
    console.log("inside wishlist remove");
    
    // console.log(req.query.itemId);
    try{
        // await 
    const result= await client.db("wishlist").collection("wishlistcollection").deleteOne({itemId: req.query.itemId})
     
    if(result.acknowledged) {
        res.status(200).send({ message: 'Item removed succesfully', _id: result.insertedId });
      } else {
        res.status(500).send({ message: 'Item could not be removed' });
      }

    } catch (error) {
        console.error('Error removing item:', error);
        res.status(500).send({ message: 'Error removing item', error });
      }
})


app.get('/wishListAdd',async(req,res)=>{
    console.log("inside wishlist add");
    console.log(req.query.itemId);

    let itemToBeStored=dataList.find(obj => obj.itemId[0] === req.query.itemId);

    console.log(itemToBeStored);

    try{
        const result=await client.db("wishlist").collection("wishlistcollection").insertOne(itemToBeStored);
        if(result.acknowledged) {
            res.status(200).send({ message: 'Item added successfully', _id: result.insertedId });
          } else {
            res.status(500).send({ message: 'Item could not be added' });
          }
        
    }catch (error) {
        console.error('Error adding item:', error);
        res.status(500).send({ message: 'Error adding item', error });
    }
 
});

// app.post('/wishListAdd',async(req,res)=>{
//     console.log("inside wishlist add");
//     // console.log(req.body);

//     try{
//         const result=await client.db("wishlist").collection("wishlistcollection").insertOne(req.body);
//         if(result.acknowledged) {
//             res.status(200).send({ message: 'Item added successfully', _id: result.insertedId });
//           } else {
//             res.status(500).send({ message: 'Item could not be added' });
//           }
        
//     }catch (error) {
//         console.error('Error adding item:', error);
//         res.status(500).send({ message: 'Error adding item', error });
//     }
 
// });

app.listen(PORT, () => {

    console.log('Server is running on port 3000.');
});