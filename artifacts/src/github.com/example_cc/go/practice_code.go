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

type User struct {
	Id           string
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


type BankingChaincode struct {
}

func (t *BankingChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	logger.Info("########### Init ###########")

	id, _ := seq.GetId(USER)
	user1 := User{
		Id: id,
		FirstName: "Peter",
		LastName: "Anderson",
		Email: "peter@gmail.com",
		Balance: 2000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user2 := User{
		Id: id,
		FirstName: "Nicole",
		LastName: "Taylor",
		Email: "nicole@gmail.com",
		Balance: 1000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user3 := User{
		Id: id,
		FirstName: "John",
		LastName: "Jordan",
		Email: "john@gmail.com",
		Balance: 3000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user4 := User{
		Id: id,
		FirstName: "Mike",
		LastName: "Grey",
		Email: "mike@gmail.com",
		Balance: 4000,
		Transactions: make([]string, 0, 50),
	}

	id, _ = seq.GetId(USER)
	user5 := User{
		Id: id,
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
		InstallmentAmount: 220,
		InterestRate: 0.10,
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
		InstallmentAmount: 150,
		InterestRate: 0.50,
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
		InstallmentAmount: 330,
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
		InstallmentAmount: 260,
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

	if function == "query" {
		return t.query(stub, args)
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
		logger.Errorf("Unknown action, check the first argument, must be one of 'query', 'transfer', " +
			"'payInstallment', 'createLoan', 'createBank', 'createUser'. But got: %v", args[0])
		return shim.Error(fmt.Sprintf("Unknown action, check the first argument, must be one of " +
			"'query', 'transfer', 'payInstallment', 'createLoan', 'createBank', 'createUser'. But got: %v", args[0]))
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
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2 arguments: User ID, Installment Amount")
	} else if user, err := findUser(stub, args[0]); err != nil {
		return shim.Error(err.Error())
	} else if bank, err := findBank(stub, user.Bank); err != nil {
		return shim.Error(err.Error())
	} else if user.Loan == "" {
		return shim.Error(fmt.Sprintf("User %v does not have loan", user.Id))
	} else if loan, err := findLoan(stub, user.Loan); err != nil {
		return shim.Error(err.Error())
	} else if installmentAmount, err := strconv.ParseFloat(args[1], 64); err != nil {
		return shim.Error(fmt.Sprintf("Invalid installment amount received, could not parse %v", args[5]))
	} else if installmentAmount != loan.InstallmentAmount {
		return shim.Error("Invalid installment amount received, installment amount does not match with loan's amount")
	} else {
		loan.PaidInstallments += 1
		if loan.PaidInstallments == loan.AllInstallments {
			user.Loan = ""

			var index int
			var loanId string
			for i, l := range bank.Loans {
				if l == loan.Id {
					index = i
					loanId = l
				}
			}
			copy(bank.Loans[index:], bank.Loans[index+1:])
			bank.Loans[len(bank.Loans)-1] = ""
			bank.Loans = bank.Loans[:len(bank.Loans)-1]
			bank.PayedLoans = append(bank.PayedLoans, loanId)
		}
		return createInstallmentTransaction(stub, bank, user, installmentAmount)
	}
}

func (t *BankingChaincode) createLoan(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 6 {
		return shim.Error("Incorrect number of arguments. Expecting 6 arguments: " +
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
		bank.Loans = append(bank.Loans, loan.Id)
		user.Loan = loan.Id
		return createLoanTransaction(stub, user, bank, base)
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
	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting at least 5 arguments: " +
			"First Name, Last Name, Email, BankId, Balance")
	} else if bank, err := findBank(stub, args[3]); err != nil {
		return shim.Error(err.Error())
	} else if balance, err := strconv.ParseFloat(args[4], 64); err != nil {
		return shim.Error(fmt.Sprintf("Invalid balance received, could not parse %v", args[5]))
	} else if balance <= 0 {
		return shim.Error("Invalid balance received, balance can not be zero or negative")
	} else {
		id, _ := seq.GetId(USER)
		user := User{
			Id:           id,
			FirstName:    args[0],
			LastName:     args[1],
			Email:        args[2],
			Bank:         bank.Id,
			Loan:         "",
			Balance:      balance,
			Transactions: []string{},
		}
		bank.Users = append(bank.Users, user.Id)

		userJson, _ := json.Marshal(user)
		err := stub.PutState(user.Id, userJson)
		if err != nil {
			return shim.Error(err.Error())
		}

		bankJson, _ := json.Marshal(bank)
		err = stub.PutState(bank.Id, bankJson)
		if err != nil {
			return shim.Error(err.Error())
		}
	}
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

func createLoanTransaction(stub shim.ChaincodeStubInterface, receiver *User, payer *Bank,
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

func createInstallmentTransaction(stub shim.ChaincodeStubInterface, receiver *Bank, payer *User,
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
		return nil, errors.New("failed to crate user from json")
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
		return nil, errors.New("failed to crate bank from json")
	}
	return &bank, nil
}

func findLoan (stub shim.ChaincodeStubInterface, loanId string) (*Loan, error) {
	var loan Loan
	loanJson, err := stub.GetState(loanId)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + loanId + "\"}"
		return nil, errors.New(jsonResp)
	}

	if loanJson == nil || len(loanJson) == 0 {
		jsonResp := "{\"Error\":\" " + loanId + " does not exit " + "\"}"
		return nil, errors.New(jsonResp)
	}
	err = json.Unmarshal(loanJson, &loan)
	if err != nil {
		return nil, errors.New("failed to crate loan from json")
	}
	return &loan, nil
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
