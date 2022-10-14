package chaincode

import (
	"encoding/json"
	"fmt"
	"crypto/sha256"
	"encoding/hex"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"strconv"

)

// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}

// Asset describes basic details of what makes up a simple asset
//Insert struct field in alphabetic order => to achieve determinism across languages
// golang keeps the order when marshal to json but doesn't order automatically
type Asset struct {
	ID 				string  `json:"id"`
	Owner          	string 	`json:"owner"`
	Location       	string 	`json:"location"`
	Category 		string	`json:"category"`
	Kind 			string	`json:"kind"`
	TotalPrice 		int 	`json:"totalprice"`
	Area 			int		`json:"area"`
	Price          	int		`json:"price"`
	Description		bool	`json:"description"`	
}
// CreateAsset issues a new asset to the world state with given details.
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, owner string, location string, category string, kind string, totalprice int, area int, price int,) (string,error) {
	hash := sha256.New()
	hash.Write([]byte(owner+location+category+kind+strconv.Itoa(totalprice)+strconv.Itoa(area)+strconv.Itoa(price)))
	md := hash.Sum(nil)
	id := hex.EncodeToString(md)
	
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return "", err
	}
	if exists {
		return "", fmt.Errorf("the asset %s already exists", id)
	}
	description := true 
	asset := Asset{
		ID:             id,
		Owner:          owner,
		Location: 		location,
		Category:		category,
		Kind:			kind,
		TotalPrice:		totalprice,
		Area:			area,
		Price:          price,
		Description:	description,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return "", err
	}
	err = ctx.GetStub().PutState(id, assetJSON)
	if err != nil {
		return  "",err
	}
	return id, nil
}

// ReadAsset returns the asset stored in the world state with given id.
func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if assetJSON == nil {
		return nil, fmt.Errorf("the asset %s does not exist", id)
	}

	var asset Asset
	err = json.Unmarshal(assetJSON, &asset)
	if err != nil {
		return nil, err
	}

	return &asset, nil
}

// UpdateAsset updates an existing asset in the world state with provided parameters.
func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, id string, owner string,  location string, category string, kind string, totalprice int, area int, price int,) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}
	description := true
	// overwriting original asset with new asset
	asset := Asset{
		ID:             id,
		Owner:          owner,
		Location: 		location,
		Category:		category,
		Kind:			kind,
		TotalPrice:		totalprice,
		Area:			area,
		Price:          price,
		Description:	description,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, assetJSON)
}

// DeleteAsset deletes an given asset from the world state.
func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, id string) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}

	return ctx.GetStub().DelState(id)
}

// AssetExists returns true when asset with given ID exists in world state
func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	return assetJSON != nil, nil
}

// TransferAsset updates the owner field of asset with given id in world state, and returns the old owner.
func (s *SmartContract) TransferAsset(ctx contractapi.TransactionContextInterface, id string, newOwner string)  error {
	asset, err := s.ReadAsset(ctx, id)
	if err != nil {
		return  err
	}
	if (asset.Description == false) {
		fmt.Errorf("This item has already been traded.")
	}
	asset.Description = false
	asset.Owner = newOwner
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return  err
	}

	err = ctx.GetStub().PutState(id, assetJSON)
	if err != nil {
		return  err
	}

	return nil
}

// GetAllAssets returns all assets found in world state
func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]*Asset, error) {
	// range query with empty string for startKey and endKey does an
	// open-ended query of all assets in the chaincode namespace.
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var assets []*Asset
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var asset Asset
		err = json.Unmarshal(queryResponse.Value, &asset)
		if err != nil {
			return nil, err
		}
		assets = append(assets, &asset)
	}
	return assets, nil
}

func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) ([]*Asset, error) {
	var assets []*Asset
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var asset Asset
		err = json.Unmarshal(queryResult.Value, &asset)
		if err != nil {
			return nil, err
		}
		assets = append(assets, &asset)
	}

	return assets, nil
}



func (s *SmartContract) QueryAssets(ctx contractapi.TransactionContextInterface, queryString string) ([]*Asset, error) {
	return getQueryResultForQueryString(ctx, queryString)
}

func getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]*Asset, error) {
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	return constructQueryResponseFromIterator(resultsIterator)
}