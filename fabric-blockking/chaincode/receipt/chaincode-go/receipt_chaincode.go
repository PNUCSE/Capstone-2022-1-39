/*
 SPDX-License-Identifier: Apache-2.0
*/



package main

import (
	"encoding/json"
	"log"
	"crypto/sha256"
	"encoding/hex"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

const index = "from~to~assetid"

// SimpleChaincode implements the fabric-contract-api-go programming model
type SimpleChaincode struct {
	contractapi.Contract
}

type Receipt struct {
	ID 				string `json:"id"`
	AssetID			string `json:"assetid"`
	From       		string `json:"from"`          //구매자
	To          	string `json:"to"`        	  //판매자
	TotalPrice      int    `json:"totalprice"`       //잔금
	DownPayment    	int    `json:"downpayment"`   //계약금
	ReleaseDate     string `json:"releasedate"`   //반출일
	timestamp      	string `json:"timestamp"`     //계약일 
}

// PaginatedQueryResult structure used for returning paginated query results and metadata
type PaginatedQueryResult struct {
	Records             []*Receipt `json:"records"`
	FetchedRecordsCount int32    `json:"fetchedRecordsCount"`
	Bookmark            string   `json:"bookmark"`
}


func (t *SimpleChaincode) CreateReceipt(ctx contractapi.TransactionContextInterface, assetid string , from string, to string,totalprice int , downpayment int,  releasedate string,timestamp string) error {
	hash := sha256.New()
	hash.Write([]byte(from+to+assetid+timestamp))
	md := hash.Sum(nil)
	id := hex.EncodeToString(md)
	receipt := &Receipt{
		ID:				id,
		AssetID:		assetid,
		From:			from,          	//구매자
		To:          	to,        	  	//판매자
		TotalPrice:		totalprice,       	//잔금		
		DownPayment: 	downpayment, 	//계약금	 
		ReleaseDate:    releasedate,   	//반출일
		timestamp:  	timestamp,      //계약일  
	}
	receiptBytes, err := json.Marshal(receipt)
	if err != nil {
		return err
	}

	err = ctx.GetStub().PutState(id, receiptBytes)
	if err != nil {
		return err
	}

	IndexKey, err := ctx.GetStub().CreateCompositeKey(index, []string{receipt.From, receipt.To, receipt.AssetID})
	if err != nil {
		return err
	}

	IndexValue := []byte{0x00}
	return ctx.GetStub().PutState(IndexKey, IndexValue)
}


func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) ([]*Receipt, error) {
	var receipts []*Receipt
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var receipt Receipt
		err = json.Unmarshal(queryResult.Value, &receipt)
		if err != nil {
			return nil, err
		}
		receipts = append(receipts, &receipt)
	}

	return receipts, nil
}



func (t *SimpleChaincode) QueryReceipts(ctx contractapi.TransactionContextInterface, queryString string) ([]*Receipt, error) {
	return getQueryResultForQueryString(ctx, queryString)
}

// getQueryResultForQueryString executes the passed in query string.
// The result set is built and returned as a byte array containing the JSON results.
func getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]*Receipt, error) {
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	return constructQueryResponseFromIterator(resultsIterator)
}

func (t *SimpleChaincode) QueryReceiptsWithPagination(ctx contractapi.TransactionContextInterface, queryString string, pageSize int, bookmark string) (*PaginatedQueryResult, error) {

	return getQueryResultForQueryStringWithPagination(ctx, queryString, int32(pageSize), bookmark)
}

// getQueryResultForQueryStringWithPagination executes the passed in query string with
// pagination info. The result set is built and returned as a byte array containing the JSON results.
func getQueryResultForQueryStringWithPagination(ctx contractapi.TransactionContextInterface, queryString string, pageSize int32, bookmark string) (*PaginatedQueryResult, error) {

	resultsIterator, responseMetadata, err := ctx.GetStub().GetQueryResultWithPagination(queryString, pageSize, bookmark)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	receipts, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	return &PaginatedQueryResult{
		Records:             receipts,
		FetchedRecordsCount: responseMetadata.FetchedRecordsCount,
		Bookmark:            responseMetadata.Bookmark,
	}, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&SimpleChaincode{})
	if err != nil {
		log.Panicf("Error creating receipt chaincode: %v", err)
	}

	if err := chaincode.Start(); err != nil {
		log.Panicf("Error starting receipt chaincode: %v", err)
	}
}