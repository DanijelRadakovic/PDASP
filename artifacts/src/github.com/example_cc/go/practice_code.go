package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

var logger = shim.NewLogger("Banking")

const (
	USER  = "USER"
	BANK  = "BANK"
	TRANS = "TRANS"
	LOAN  = "LOAN"
)

type tutor struct {
	Id      string
	Name    string
	Surname string
}

type tutorial struct {
	Id     string
	Name   string
	Tutors []string
}

type User struct {
	Id           string
	Account      string
	FirstName    string
	LastName     string
	Email        string
	Bank 		 string
	Loan		 string
	Balance      float64
	Transactions []string
}

type Bank struct {
	Id        	 string
	Name      	 string
	Year      	 string
	Countries 	 []string
	Users     	 []string
	Loans	  	 []string
	PayedLoans   []string
	Transactions []string
	Balance   	 float64
}

type Transaction struct {
	Id         string
	Date       string
	Receiver   string
	Payer      string
	Amount     float64
}

type Loan struct {
	Id                string
	UserId            string
	ApprovalDate      string
	RepaymentEndDate  string
	InstallmentAmount float64
	InterestRate      float64
	AllInstallments   int
	PaidInstallments  int
	Base              float64
}

type Sequencer struct {
	UserId  int
	BankId  int
	TransId int
	LoanId  int
}

func (s *Sequencer) GetId(t string) (string, error) {
	if t == BANK {
		s.BankId++
		return "bk" + strconv.Itoa(s.BankId), nil
	} else if t == USER {
		s.UserId++
		return "ur" + strconv.Itoa(s.UserId), nil
	} else if t == TRANS {
		s.TransId++
		return "tr" + strconv.Itoa(s.TransId), nil
	} else if t == LOAN {
		s.LoanId++
		return "ln" + strconv.Itoa(s.LoanId), nil
	} else {
		return "", errors.New("sequencer received wrong type")
	}
}

var seq = Sequencer{}

// Global variables for ID
var tutorId int
var tutorialId int

type BankingChaincode struct {
}

func (t *BankingChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	logger.Info("########### Init ###########")

	id, _ := seq.GetId(USER)
	user1 := User{
		Id: id,
		Account: "170-359-12",
		FirstName: "Peter",
		LastName: "Anderson",
		Email: "peter@gmail.com",
		Balance: 2000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user2 := User{
		Id: id,
		Account: "170-753-26",
		FirstName: "Nicole",
		LastName: "Taylor",
		Email: "nicole@gmail.com",
		Balance: 1000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user3 := User{
		Id: id,
		Account: "257-965-42",
		FirstName: "John",
		LastName: "Jordan",
		Email: "john@gmail.com",
		Balance: 3000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user4 := User{
		Id: id,
		Account: "257-112-42",
		FirstName: "Mike",
		LastName: "Grey",
		Email: "mike@gmail.com",
		Balance: 4000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user5 := User{
		Id: id,
		Account: "257-449-42",
		FirstName: "Tom",
		LastName: "Murray",
		Email: "tom@gmail.com",
		Balance: 5000,
		Transactions: make([]string, 0, 50),
	}


	id, _ = seq.GetId(BANK)
	bank1 := Bank{
		Id: id,
		Name: "UniCredit",
		Year: "2003",
		Countries: []string{"USA", "UK", "Germany", "France", "Italy"},
		Users:     []string{user1.Id, user2.Id},
		Loans: make([]string, 0, 50),
		PayedLoans: make([]string, 0, 50),
		Transactions: make([]string, 0, 50),
		Balance:   10000,
	}
	user1.Bank = bank1.Id
	user2.Bank = bank1.Id

	id, _ = seq.GetId(BANK)
	bank2 := Bank{
		Id: id,
		Name: "Raiffeisen",
		Year: "2000",
		Countries: []string{"USA", "UK", "Germany", "France", "Italy"},
		Users:     []string{user3.Id,user4.Id,user5.Id},
		Loans: make([]string, 0, 50),
		PayedLoans: make([]string, 0, 50),
		Transactions: make([]string, 0, 50),
		Balance:   20000,
	}
	user3.Bank = bank2.Id
	user4.Bank = bank2.Id
	user5.Bank = bank2.Id


	id, _ = seq.GetId(TRANS)
	trans1 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:00:00",
		Receiver: "ur1",
		Payer: "ur2",
		Amount: 100,
	}
	user1.Transactions = append(user1.Transactions, id)
	user2.Transactions = append(user2.Transactions, id)

	id, _ = seq.GetId(TRANS)
	trans2 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:05:00",
		Receiver: "ur2",
		Payer: "ur3",
		Amount: 200,
	}
	user2.Transactions = append(user2.Transactions, id)
	user3.Transactions = append(user3.Transactions, id)

	id, _ = seq.GetId(TRANS)
	trans3 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:10:00",
		Receiver: "ur3",
		Payer: "ur2",
		Amount: 300,
	}
	user2.Transactions = append(user2.Transactions, id)
	user3.Transactions = append(user3.Transactions, id)

	id, _ = seq.GetId(TRANS)
	trans4 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:15:00",
		Receiver: "ur3",
		Payer: "ur1",
		Amount: 400,
	}
	user1.Transactions = append(user1.Transactions, id)
	user3.Transactions = append(user3.Transactions, id)

	id, _ = seq.GetId(TRANS)
	trans5 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:20:00",
		Receiver: "ur5",
		Payer: "ur3",
		Amount: 500,
	}
	user5.Transactions = append(user5.Transactions, id)
	user3.Transactions = append(user3.Transactions, id)

	id, _ = seq.GetId(LOAN)
	loan1 := Loan{
		Id: id,
		UserId: user1.Id,
		ApprovalDate: "24.02.2020.",
		RepaymentEndDate: "24.02.2021.",
		InstallmentAmount: 200,
		InterestRate: 0.02,
		AllInstallments: 12,
		PaidInstallments: 0,
		Base: 2400,
	}
	bank1.Loans = append(bank1.Loans, id)
	user1.Loan = loan1.Id

	id, _ = seq.GetId(TRANS)
	trans6 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:25:00",
		Receiver: user1.Id,
		Payer: user1.Bank,
		Amount: loan1.Base,
	}
	user1.Transactions = append(user1.Transactions, id)
	bank1.Transactions = append(bank1.Transactions, id)

	id, _ = seq.GetId(LOAN)
	loan2 := Loan{
		Id: id,
		UserId: user3.Id,
		ApprovalDate: "25.02.2020.",
		RepaymentEndDate: "25.02.2021.",
		InstallmentAmount: 100,
		InterestRate: 0.03,
		AllInstallments: 12,
		PaidInstallments: 0,
		Base: 1200,
	}
	bank2.Loans = append(bank2.Loans, id)
	user3.Loan = loan2.Id

	id, _ = seq.GetId(TRANS)
	trans7 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:30:00",
		Receiver: user3.Id,
		Payer: user3.Bank,
		Amount: loan2.Base,
	}
	user3.Transactions = append(user3.Transactions, id)
	bank2.Transactions = append(bank2.Transactions, id)

	id, _ = seq.GetId(LOAN)
	loan3 := Loan{
		Id: id,
		UserId: user2.Id,
		ApprovalDate: "25.02.2020.",
		RepaymentEndDate: "25.02.2021.",
		InstallmentAmount: 300,
		InterestRate: 0.1,
		AllInstallments: 6,
		PaidInstallments: 0,
		Base: 1800,
	}
	bank1.Loans = append(bank1.Loans, id)
	user2.Loan = loan3.Id

	id, _ = seq.GetId(TRANS)
	trans8 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:35:00",
		Receiver: user2.Id,
		Payer: user2.Bank,
		Amount: loan3.Base,
	}
	user2.Transactions = append(user2.Transactions, id)
	bank1.Transactions = append(bank1.Transactions, id)

	id, _ = seq.GetId(LOAN)
	loan4 := Loan{
		Id: id,
		UserId: user4.Id,
		ApprovalDate: "26.02.2020.",
		RepaymentEndDate: "26.02.2021.",
		InstallmentAmount: 200,
		InterestRate: 0.3,
		AllInstallments: 24,
		PaidInstallments: 0,
		Base: 4800,
	}
	bank2.Loans = append(bank2.Loans, id)
	user4.Loan = loan4.Id

	id, _ = seq.GetId(TRANS)
	trans9 := Transaction{
		Id: id,
		Date: "24.02.2020. 19:40:00",
		Receiver: user4.Id,
		Payer: user4.Bank,
		Amount: loan4.Base,
	}
	user4.Transactions = append(user4.Transactions, id)
	bank2.Transactions = append(bank2.Transactions, id)

	// Write the state to the ledger
	assetJson, _ := json.Marshal(user1)
	err := stub.PutState(user1.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(user2)
	err = stub.PutState(user2.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(user3)
	err = stub.PutState(user3.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(user4)
	err = stub.PutState(user4.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(user5)
	err = stub.PutState(user5.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(bank1)
	err = stub.PutState(bank1.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(bank2)
	err = stub.PutState(bank2.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans1)
	err = stub.PutState(trans1.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans2)
	err = stub.PutState(trans2.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans3)
	err = stub.PutState(trans3.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans4)
	err = stub.PutState(trans4.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans5)
	err = stub.PutState(trans5.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans6)
	err = stub.PutState(trans6.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans7)
	err = stub.PutState(trans7.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans8)
	err = stub.PutState(trans8.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(trans9)
	err = stub.PutState(trans9.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(loan1)
	err = stub.PutState(loan1.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(loan2)
	err = stub.PutState(loan2.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(loan3)
	err = stub.PutState(loan3.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	assetJson, _ = json.Marshal(loan4)
	err = stub.PutState(loan4.Id, assetJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (t *BankingChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	logger.Info("########### Invoke ###########")

	function, args := stub.GetFunctionAndParameters()

	if function == "delete" {
		return t.delete(stub, args)
	} else if function == "query" {
		return t.query(stub, args)
	} else if function == "addTutorial" {
		return t.addTutorial(stub, args)
	} else if function == "addTutor" {
		return t.addTutor(stub, args)
	} else if function == "addTutorToTutorial" {
		return t.addTutorToTutorial(stub, args)
	} else if function == "removeTutorFromTutorial" {
		return t.removeTutorFromTutorial(stub, args)
	} else if function == "transfer" {
		return t.transfer(stub, args)
	} else if function == "payInstallment" {
		return t.payInstallment(stub, args)
	} else if function == "createBank" {
		return t.createBank(stub, args)
	}  else if function == "createUser" {
		return t.createUser(stub, args)
	} else if function == "createLoan" {
		return t.createLoan(stub, args)
	} else {
		logger.Errorf("Unknown action, check the first argument, must be one of 'delete', 'query', 'transfer', " +
			"'payInstallment', 'createLoan', 'createBank', 'createUser'. But got: %v", args[0])
		return shim.Error(fmt.Sprintf("Unknown action, check the first argument, must be one of 'delete', 'query', 'transfer', " +
			"'payInstallment', 'createLoan', 'createBank', 'createUser'. But got: %v", args[0]))
	}
}

func (t *BankingChaincode) transfer(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var receiver, payer *User
	var useDebt string
	var err error

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4 arguments: " +
			"Receiver ID, Payer ID, Amount, Use debt (y/n)")
	}

	if args[3] != "y" && args[3] != "n" {
		return shim.Error("Incorrect value for use debt receive. Allowed values are y or n")
	}

	useDebt = args[3]

	receiver, err = findUser(stub, args[0])
	if err != nil {
		return shim.Error(err.Error())
	}

	payer, err = findUser(stub, args[1])
	if err != nil {
		return shim.Error(err.Error())
	}

	if amount, e := strconv.ParseFloat(args[2], 64); e != nil {
		return shim.Error(fmt.Sprintf("Invalid year received, could not parse %v", args[1]))
	} else {
		if amount <= 0 {
			return shim.Error("Invalid amount received, amount can not be zero or negative")
		}
		if useDebt == "n" {
			if amount > payer.Balance {
				return shim.Error("Not enough money on account")
			} else {
				return createTransaction(stub, receiver, payer, amount)
			}
		} else {
			var avgIncome float64
			avgIncome, err = averageIncome(stub, payer)
			if err != nil {
				return shim.Error(err.Error())
			} else if avgIncome+payer.Balance < amount {
				return shim.Error("Not enough money on account and can not use debt")
			} else {
				return createTransaction(stub, receiver, payer, amount)
			}
		}

	}

}

func (t *BankingChaincode) payInstallment(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// TODO vrednost uplate mora da se poklopi sa ratom + kamata
	return shim.Success(nil)
}

func (t *BankingChaincode) createLoan(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 6 {
		return shim.Error("Incorrect number of arguments. Expecting  arguments: " +
			"User ID, Approval Date, Repayment End Date, Interest, Number of Installments, Base")
	} else if user, err := findUser(stub, args[0]); err != nil {
		return shim.Error(err.Error())
	} else if approvalDate, err := time.Parse("02.01.2006.", args[1]); err != nil {
		return shim.Error(fmt.Sprintf("Invalid approval date received, could not parse %v, " +
			"valid format is: 02.01.2006", args[1]))
	} else if repaymentEndDate, err := time.Parse("02.01.2006.", args[2]); err != nil {
		return shim.Error(fmt.Sprintf("Invalid repayment end date received, could not parse %v, " +
			"valid format is: 02.01.2006", args[2]))
	} else if approvalDate.After(repaymentEndDate) {
		return shim.Error("Approval date is after repayment end date")
	} else if interestRate, err := strconv.ParseFloat(args[3], 64); err != nil {
		return shim.Error(fmt.Sprintf("Invalid interest rate received, could not parse %v", args[3]))
	} else if interestRate <= 0 {
		return shim.Error("Invalid interest rate received, interest rate can not be zero or negative")
	} else if base, err := strconv.ParseFloat(args[5], 64); err != nil {
		return shim.Error(fmt.Sprintf("Invalid base received, could not parse %v", args[5]))
	} else if base <= 0 {
		return shim.Error("Invalid base received, base can not be zero or negative")
	} else if installments, err :=strconv.Atoi(args[4]); err != nil {
		return shim.Error(fmt.Sprintf("Invalid number of installments received, " +
			"could not parse %v", args[4]))
	} else if installments <= 0 {
		return shim.Error("Invalid number of installments received, number can not be zero or negative")
	} else if user.Loan != "" {
		return shim.Error("User already have a loan")
	} else if average, err  := averageIncome(stub, user); err != nil {
		return shim.Error(err.Error())
	} else if base > average * 5 && average != 0 {
		return shim.Error(fmt.Sprintf("Base is too big to be allowed, maximul value is %v", average * 5))
	} else {
		if average == 0 || user.Balance == 0 {
			base = 1000
		}

		id, _ := seq.GetId(LOAN)
		loan := Loan{
			Id:                id,
			UserId:            user.Id,
			ApprovalDate:      approvalDate.Format("02.01.2006."),
			RepaymentEndDate:  repaymentEndDate.Format("02.01.2006."),
			InstallmentAmount: (base + interestRate*base)/float64(installments),
			InterestRate:      interestRate,
			AllInstallments:   installments,
			PaidInstallments:  0,
			Base:              base,
		}

		loanJson, _ := json.Marshal(loan)
		err = stub.PutState(loan.Id, loanJson)
		if err != nil {
			return shim.Error(err.Error())
		}
		bank, err := findBank(stub, user.Bank)
		if err != nil {
			return shim.Error(err.Error())
		}
		return createTransactionWithBank(stub, user, bank, base)
	}
}

func (t *BankingChaincode) createBank(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var bank Bank

	if len(args) < 3  {
		return shim.Error("Incorrect number of arguments. Expecting at least 3 arguments: " +
			"Name, Year, Balance, [Countries]")
	}

	if _, err := time.Parse("2006", args[1]); err != nil {
		return shim.Error(fmt.Sprintf("Invalid year received, could not parse %v", args[1]))
	}

	if amount, e := strconv.ParseFloat(args[2], 64); e != nil {
		return shim.Error(fmt.Sprintf("Invalid balance received, could not parse %v", args[2]))
	} else {
		if amount < 0 {
			return shim.Error("Invalid balance received, balance can not be negative")
		}
		id, _ := seq.GetId(BANK)
		if len(args) > 3 {
			bank = Bank{
				Id: id,
				Name: args[0],
				Year: args[1],
				Balance: amount,
				Countries: args[3:],
				Users: []string{},
				Loans: []string{},
				PayedLoans: []string{},
				Transactions: []string{},
			}
		} else {
			bank = Bank{
				Id: id,
				Name: args[0],
				Year: args[1],
				Balance: amount,
				Countries: []string{},
				Users: []string{},
				Loans: []string{},
				PayedLoans: []string{},
				Transactions: []string{},
			}
		}

		bankJson, _ := json.Marshal(bank)
		err := stub.PutState(bank.Id, bankJson)
		if err != nil {
			return shim.Error(err.Error())
		}
	}
	return shim.Success(nil)
}

func (t *BankingChaincode) createUser(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	return shim.Success(nil)
}

func createTransaction(stub shim.ChaincodeStubInterface, receiver, payer *User, amount float64) pb.Response {
	id, _ := seq.GetId(TRANS)
	trans := Transaction{Id: id, Date: time.Now().Format("02.01.2006. 15:04:05"), Receiver: receiver.Id,
		Payer: payer.Id, Amount: amount}

	receiver.Balance += amount
	payer.Balance -= amount
	receiver.Transactions = append(receiver.Transactions, id)
	payer.Transactions = append(payer.Transactions, id)

	receiverJson, _ := json.Marshal(receiver)
	payerJson, _ := json.Marshal(payer)
	transJson, _ := json.Marshal(trans)

	err := stub.PutState(receiver.Id, receiverJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(payer.Id, payerJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(trans.Id, transJson)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

func createTransactionWithBank(stub shim.ChaincodeStubInterface, receiver *User, payer *Bank,
	amount float64) pb.Response {
	id, _ := seq.GetId(TRANS)
	trans := Transaction{Id: id, Date: time.Now().Format("02.01.2006. 15:04:05"), Receiver: receiver.Id,
		Payer: payer.Id, Amount: amount}

	receiver.Balance += amount
	payer.Balance -= amount
	receiver.Transactions = append(receiver.Transactions, id)
	payer.Transactions = append(payer.Transactions, id)

	receiverJson, _ := json.Marshal(receiver)
	payerJson, _ := json.Marshal(payer)
	transJson, _ := json.Marshal(trans)

	err := stub.PutState(receiver.Id, receiverJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(payer.Id, payerJson)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(trans.Id, transJson)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

func findUser(stub shim.ChaincodeStubInterface, userId string) (*User, error) {
	var user User
	userJson, err := stub.GetState(userId)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + userId + "\"}"
		return nil, errors.New(jsonResp)
	}

	if userJson == nil || len(userJson) == 0 {
		jsonResp := "{\"Error\":\" " + userId + " does not exit " + "\"}"
		return nil, errors.New(jsonResp)
	}
	err = json.Unmarshal(userJson, &user)
	if err != nil {
		return nil, errors.New("Failed to crate user from json")
	}
	return &user, nil
}

func findBank(stub shim.ChaincodeStubInterface, bankId string) (*Bank, error) {
	var bank Bank
	bankJson, err := stub.GetState(bankId)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + bankId + "\"}"
		return nil, errors.New(jsonResp)
	}

	if bankJson == nil || len(bankJson) == 0 {
		jsonResp := "{\"Error\":\" " + bankId + " does not exit " + "\"}"
		return nil, errors.New(jsonResp)
	}
	err = json.Unmarshal(bankJson, &bank)
	if err != nil {
		return nil, errors.New("Failed to crate user from json")
	}
	return &bank, nil
}


func averageIncome(stub shim.ChaincodeStubInterface, user *User) (float64, error) {
	var trans Transaction
	amount := 0.0
	cnt := 0

	if len(user.Transactions) == 0 {
		return 0, nil
	}

	for _, transId := range user.Transactions {
		transJson, err := stub.GetState(transId)
		if err != nil {
			jsonResp := "{\"Error\":\"Failed to get state for " + transId + "\"}"
			return -1, errors.New(jsonResp)
		}

		if transJson == nil || len(transJson) == 0 {
			jsonResp := "{\"Error\":\" " + transId + " does not exit " + "\"}"
			return -1, errors.New(jsonResp)
		}

		err = json.Unmarshal(transJson, &trans)
		if err != nil {
			return -1, errors.New("Failed to crate transaction from json")
		}

		if trans.Receiver == user.Id {
			amount += trans.Amount
			cnt++
		}
	}
	return amount / float64(cnt), nil
}

func (t *BankingChaincode) addTutor(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var name, surname string // Entities

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 4, function followed by 2 names and 1 value")
	}

	name = args[0]
	surname = args[1]

	tutorKey := "tu" + strconv.Itoa(tutorId)
	tutorId = tutorId + 1
	var newTutor = tutor{tutorKey, name, surname}

	ajson, _ := json.Marshal(newTutor)
	err := stub.PutState(newTutor.Id, ajson)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (t *BankingChaincode) addTutorial(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// TODO implement function
	// arg 0 - name, arg1,arg2,arg3,arg4... - tutorID (which is the same as tutorKey)
	// Check number of arguments
	// Check if tutors exist in ledger before adding them to tutorial
	var name, tutorKey string // Entities

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 4, function followed by 2 names and 1 value")
	}

	name = args[0]
	var tutors = make([]string, 0, 20)
	for i := 1; i < len(args); i++ {
		tutorKey = args[i]
		tutorI, err := stub.GetState(tutorKey)
		logger.Info("Tutor " + tutorKey + "postoji")
		logger.Info(tutorI)

		if err != nil {
			jsonResp := "{\"Error\":\"Failed to get state for " + tutorKey + "\"}"
			return shim.Error(jsonResp)
		}
		if tutorI == nil || len(tutorI) == 0 {
			jsonResp := "{\"Error\":\" " + tutorKey + " does not exit " + "\"}"
			return shim.Error(jsonResp)
		}

		tutors = append(tutors, tutorKey)
	}

	tutorialKey := "t" + strconv.Itoa(tutorialId)
	tutorialId = tutorialId + 1
	var newTutorial = tutorial{tutorialKey, name, tutors}

	ajson, _ := json.Marshal(newTutorial)
	err := stub.PutState(newTutorial.Id, ajson)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (t *BankingChaincode) addTutorToTutorial(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// TODO implement function
	// arg0 - tutrorialId (which is the same as tutorialKey), arg1 - tutorId
	// Check number of arguments
	// Check if tutor and tutorial exist in ledger
	// Make sure that tutor is not already listed in tutorial. If that is the case, return error
	var tutorialKey, tutorKey string // Entities

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 4, function followed by 2 names and 1 value")
	}

	tutorialKey = args[0]
	tutorKey = args[1]

	// load tutorial
	tutorialB, err := stub.GetState(tutorialKey)

	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + tutorialKey + "\"}"
		return shim.Error(jsonResp)
	}
	if tutorialB == nil || len(tutorialB) == 0 {
		jsonResp := "{\"Error\":\" " + tutorialKey + " does not exit " + "\"}"
		return shim.Error(jsonResp)
	}
	tutorial := tutorial{}
	err = json.Unmarshal(tutorialB, &tutorial)
	if err != nil {
		return shim.Error("Failed to get state")
	}

	// load tutor which will be added to tutorial
	tutor, err := stub.GetState(tutorKey)
	logger.Info("Tutor " + tutorKey + "postoji")
	logger.Info(tutor)

	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + tutorKey + "\"}"
		return shim.Error(jsonResp)
	}
	if tutor == nil || len(tutor) == 0 {
		jsonResp := "{\"Error\":\" " + tutorKey + " does not exit " + "\"}"
		return shim.Error(jsonResp)
	}

	for i := 0; i < len(tutorial.Tutors); i++ {
		if tutorial.Tutors[i] == tutorKey {
			jsonResp := "{\"Error\":\" Tutor with id: " + tutorKey + " is already on list to tutors" + "\"}"
			return shim.Error(jsonResp)
		}
	}

	tutorial.Tutors = append(tutorial.Tutors, tutorKey)

	ajson, _ := json.Marshal(tutorial)
	err = stub.PutState(tutorial.Id, ajson)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (t *BankingChaincode) removeTutorFromTutorial(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// TODO implement function
	// arg0 - tutrorialId, arg1 - tutorId
	// Check number of arguments
	// Check if tutor and tutorial exist in ledger
	// If tutor (which we want to remove) is not listed in tutorial, return error
	var tutorialKey, tutorKey string // Entities

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 4, function followed by 2 names and 1 value")
	}

	tutorialKey = args[0]
	tutorKey = args[1]

	// load tutorial
	tutorialB, err := stub.GetState(tutorialKey)

	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + tutorialKey + "\"}"
		return shim.Error(jsonResp)
	}
	if tutorialB == nil || len(tutorialB) == 0 {
		jsonResp := "{\"Error\":\" " + tutorialKey + " does not exit " + "\"}"
		return shim.Error(jsonResp)
	}
	tutorial := tutorial{}
	err = json.Unmarshal(tutorialB, &tutorial)
	if err != nil {
		return shim.Error("Failed to get state")
	}

	// load tutor which will be removed from tutorial
	tutor, err := stub.GetState(tutorKey)
	logger.Info("Tutor " + tutorKey + "postoji")
	logger.Info(tutor)

	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + tutorKey + "\"}"
		return shim.Error(jsonResp)
	}
	if tutor == nil || len(tutor) == 0 {
		jsonResp := "{\"Error\":\" " + tutorKey + " does not exit " + "\"}"
		return shim.Error(jsonResp)
	}

	for i := 0; i < len(tutorial.Tutors); i++ {
		if tutorial.Tutors[i] == tutorKey {

			tutorial.Tutors = append(tutorial.Tutors[:i], tutorial.Tutors[i+1:]...)
			ajson, _ := json.Marshal(tutorial)
			err = stub.PutState(tutorial.Id, ajson)
			if err != nil {
				return shim.Error(err.Error())
			}

			return shim.Success(nil)
		}
	}

	// If tutor is not removed then it does not exits in list of tutors for given tutorial
	jsonResp := "{\"Error\":\" Tutor with id: " + tutorKey + " is not on list of tutors" + "\"}"
	return shim.Error(jsonResp)
}

// Deletes an entity from state
func (t *BankingChaincode) delete(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	A := args[0]

	// Delete the key from the state in ledger
	err := stub.DelState(A)
	if err != nil {
		return shim.Error("Failed to delete state")
	}

	return shim.Success(nil)
}

// Query callback representing the query of a chaincode
func (t *BankingChaincode) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var A string // Entities
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting id of asset to query")
	}

	A = args[0]

	// Get the state from the ledger
	availableBytes, err := stub.GetState(A)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	if availableBytes == nil {
		jsonResp := "{\"Error\":\"Nil for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	jsonResp := "{\"Name\":\"" + A + "\",\"Amount\":\"" + string(availableBytes) + "\"}"
	logger.Infof("Query Response:%s\n", jsonResp)
	return shim.Success(availableBytes)
}

func main() {
	err := shim.Start(new(BankingChaincode))
	if err != nil {
		logger.Errorf("Error starting Banking chaincode: %s", err)
	}
}
