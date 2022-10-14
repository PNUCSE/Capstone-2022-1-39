/*
 SPDX-License-Identifier: Apache-2.0
*/



package main

import (
	"encoding/json"
	"log"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"fmt"
)


// SmartContract implements the fabric-contract-api-go programming model
type SmartContract struct {
	contractapi.Contract
}

type Gap struct {
	GapNum        	string `json:"gapnum"`
	Name           string `json:"name"`
	Kind			string `json:"kind"`
	Location		string `json:"location"`
	Area			int `json:"area"`
}


func (s *SmartContract) InitGapLedger(ctx contractapi.TransactionContextInterface) error {
	gaps := []Gap{
		{GapNum: "GAP1", Name: "김재현", Kind: "파", Location:"부산", Area: 500},
		{GapNum: "GAP2", Name: "장희승", Kind: "배추", Location:"대전", Area: 600},
		{GapNum: "GAP3", Name: "이세진", Kind: "양파", Location:"대구", Area: 700},
		{GapNum: "GAP4", Name: "신예주", Kind: "당근", Location:"서울", Area: 800},
	}

	for _, gap := range gaps {
		gapJSON, err := json.Marshal(gap)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(gap.GapNum, gapJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}

	return nil
}
func (s *SmartContract) GapExists(ctx contractapi.TransactionContextInterface, gapnum string, name string, kind string, location string, area int) (bool, error) {
	gapJSON, err := ctx.GetStub().GetState(gapnum)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	if gapJSON == nil {
		return false, fmt.Errorf("the Gap %s does not exist", gapnum)
	}

	var gap Gap
	err = json.Unmarshal(gapJSON, &gap)
	if err != nil {
		return false, err
	}
	if (gap.Name != name ){
		return false, fmt.Errorf("the Gap %s information error", gapnum)
	}
	if (gap.Kind != kind ){
		return false, fmt.Errorf("the Gap %s information error", gapnum)
	}
	if (gap.Location != location ){
		return false, fmt.Errorf("the Gap %s information error", gapnum)
	}
	if (gap.Area - area != 0 ){
		return false, fmt.Errorf("the Gap %s information error", gapnum)
	}
	return true, nil
}


func main() {
	validationChaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		log.Panicf("Error creating validation chaincode: %v", err)
	}

	if err := validationChaincode.Start(); err != nil {
		log.Panicf("Error starting validation chaincode: %v", err)
	}
}