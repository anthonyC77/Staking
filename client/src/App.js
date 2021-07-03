import React, { Component } from "react";
import '../node_modules/bootstrap/dist/css/bootstrap.min.css';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Card from 'react-bootstrap/Card';
import ListGroup from 'react-bootstrap/ListGroup';
import Table from 'react-bootstrap/Table';
import getWeb3 from "./getWeb3";
import "./App.css";
import Staking from "./contracts/Staking.json";
import CrowdsaleERC20Chainlink from "./contracts/CrowdsaleERC20Chainlink.json";

class App extends Component {
	
	
  constructor(props) {
    super(props);
    this.state = {
      values: [
        { name: 'Choose a pair',   id: "0x0000000000000000000000000000000000000000" },
		{ name: 'BAT / USD',id: "0x031dB56e01f82f20803059331DC6bEe9b17F7fC9" },
		{ name: 'BNB / USD',id: "0xcf0f51ca2cDAecb464eeE4227f5295F2384F84ED" },
		{ name: 'LINK / USD',id: "0xd8bD0a1cB028a31AA859A21A3758685a95dE4623" },
		{ name: 'LTC / USD',id: "0x4d38a35C2D87976F334c2d2379b535F1D461D9B4" },
		{ name: 'SNX / USD',id: "0xE96C4407597CD507002dF88ff6E0008AB41266Ee" },
		{ name: 'TRX / USD',id: "0xb29f616a0d54FF292e997922fFf46012a63E2FAe" },
		{ name: 'XRP / USD',id: "0xc3E76f41CAbA4aB38F00c7255d4df663DA02A024" },
		{ name: 'ZRX / USD',id: "0xF7Bbe4D7d13d600127B6Aa132f1dCea301e9c8Fc" }
      ]
    };
  }	  
	
  state = {  web3: null, accounts: null, contractStaking: null,
  contractBank:null, deployedAdress : null, stakedAdress:null};

	componentDidMount = async () => {
    try {      
	  
	  const web3 = await getWeb3();	  
	  const networkId = await web3.eth.net.getId();
      const accounts = await web3.eth.getAccounts();
	  
	  const deployedNetworkBank = CrowdsaleERC20Chainlink.networks[networkId]; // 1000 
	  const instanceBank = new web3.eth.Contract(
        CrowdsaleERC20Chainlink.abi,
        deployedNetworkBank && deployedNetworkBank.address,
      );
	  
	  const deployedNetworkStaking = Staking.networks[networkId]; // 1000 
	  const instanceStaking = new web3.eth.Contract(
        Staking.abi,
        deployedNetworkStaking && deployedNetworkStaking.address,
      );
	  
	  
	  this.setState({ 
		web3, 
		accounts, 
		contractStaking: instanceStaking,
		contractBank : instanceBank,
	    deployedAdress : deployedNetworkStaking.address
   	});
	  
	  
	  //console.log(user);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };
  
  GetValuePair(event) {
	 
	if(event.target.value == "0x0000000000000000000000000000000000000000"){
		this.amount.value = "";
	}
	else{
		const { web3, accounts, contractBank, deployedAdress } = this.state;
	  
	 this.state.valueSelected = event.target;
	 
	 var index = event.nativeEvent.target.selectedIndex;

	 var money = event.nativeEvent.target[index].text.slice(-3);
	 
	var roundDec = 100000000;
	if(money == "ETH"){
		roundDec = 1000000000000000000;
	}
	
	if(event.target.value == "0x0000000000000000000000000000000000000000"){
		this.amount.value = "";
	}
	else
		
	contractBank.methods.getThePrice(event.target.value).call({from: accounts[0]})
		.then((roundData) => {
		let brutPrice = roundData;
		let data = brutPrice / roundDec;
		console.log(roundData)
		console.log(brutPrice);
		console.log(data);
		
		this.amount.value = data;
	});
	
	this.state.stakedAdress = event.target.value;
	}
  }
  
  Calculation = async () => {
	const { accounts, contractBank, deployedAdress } = this.state;
	this.calcul.value = this.quantity.value * this.amount.value;
	  
	let eth = await contractBank.methods.getThePrice("0x8A753747A1Fa494EC906cE90E9f37563A8AF630e").call({from: accounts[0]});  
    //this.etherPrice.value = eth;
	let ethPrice = eth / 100000000;
	this.etherPrice.value = this.calcul.value / ethPrice;
	if(this.etherPrice.value < 0.1){
		alert("You must send at least 0.1 ETH");
	}
  }
  
  Approve = async () => {
	  const { accounts, web3, deployedAdress,contractBank, stakedAdress } = this.state;
	  const abi = [
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name_",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "symbol_",
				"type": "string"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "subtractedValue",
				"type": "uint256"
			}
		],
		"name": "decreaseAllowance",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "addedValue",
				"type": "uint256"
			}
		],
		"name": "increaseAllowance",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
];
	  	  
	  let adressERC20 = await contractBank.methods.getAddressERC20(stakedAdress).call({from: accounts[0]});
	  
	  let somme = web3.utils.toWei(this.quantity.value, 'ether'); 
	  let sSomme = somme.toString();
	  const moneyToStake = new web3.eth.Contract(abi, adressERC20);
	  await moneyToStake.methods.approve(deployedAdress,sSomme).send({from: accounts[0]});	  
  }
  
  Staking = async() => {
	const { accounts, contractStaking, stakedAdress, web3 } = this.state; 
    let somme = web3.utils.toWei(this.quantity.value, 'ether'); 
	let sSomme = somme.toString();
	await contractStaking.methods.Stake(stakedAdress, sSomme).send({from: accounts[0]});
	
  }
  
  UnStaking = async() => {
	const { accounts, contractStaking } = this.state; 
	await contractStaking.methods.UnStake().send({from: accounts[0]});
  }

  AddInMetamask = async() => {
	const { accounts, contractStaking, web3 } = this.state; 
	const tokenAddress = await contractStaking.methods.GetTokenANTCAddress().call({from: accounts[0]});
	const tokenSymbol = 'ANTC';
	const tokenDecimals = 18;
	const tokenImage = 'https://ipfs.io/ipfs/QmeYp7Et2owcGBinFiSsU2Tdjvpeq2BzaW1bEpzVyhE8WV?filename=hermes.png'; // get from IPFS

	try {
	  // wasAdded is a boolean. Like any RPC method, an error may be thrown.
	  const wasAdded = await window.ethereum.request({
		method: 'wallet_watchAsset',
		params: {
		  type: 'ERC20', // Initially only supports ERC20, but eventually more!
		  options: {
			address: tokenAddress, // The address that the token is at.
			symbol: tokenSymbol, // A ticker symbol or shorthand, up to 5 chars.
			decimals: tokenDecimals, // The number of decimals in the token
			image: tokenImage, // A string url of the token logo
		  },
		},
	  });

	  if (wasAdded) {
		console.log('Thanks for your interest!');
	  } else {
		console.log('Your loss!');
	  }
	} catch (error) {
	  console.log(error);
	}
  }
  
  BuyToken = async() => {
	  const { accounts, contractBank, web3 } = this.state; 
	  const abi = [
	{
		"inputs": [],
		"name": "decimals",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "description",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint80",
				"name": "_roundId",
				"type": "uint80"
			}
		],
		"name": "getRoundData",
		"outputs": [
			{
				"internalType": "uint80",
				"name": "roundId",
				"type": "uint80"
			},
			{
				"internalType": "int256",
				"name": "answer",
				"type": "int256"
			},
			{
				"internalType": "uint256",
				"name": "startedAt",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "updatedAt",
				"type": "uint256"
			},
			{
				"internalType": "uint80",
				"name": "answeredInRound",
				"type": "uint80"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "latestRoundData",
		"outputs": [
			{
				"internalType": "uint80",
				"name": "roundId",
				"type": "uint80"
			},
			{
				"internalType": "int256",
				"name": "answer",
				"type": "int256"
			},
			{
				"internalType": "uint256",
				"name": "startedAt",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "updatedAt",
				"type": "uint256"
			},
			{
				"internalType": "uint80",
				"name": "answeredInRound",
				"type": "uint80"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "version",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];
      let price = Number(web3.utils.toWei(this.etherPrice.value)); 
	  let somme = web3.utils.toWei(this.quantity.value, 'ether'); 
	  let sSomme = somme.toString();
	  let data = await contractBank.methods.receiveToken(this.state.stakedAdress
	  , sSomme).send({value: price ,from: accounts[0]});
	    
  }

  render() {
	  let optionTemplate = this.state.values.map(v => (
      <option value={v.id}>{v.name}</option>
    ));
    return (
<div style={{display: 'flex', justifyContent: 'center'}}>
   <Card style={{ width: '50rem' }}>
	 <Card.Header><strong>Staking Tokens</strong></Card.Header>
		<Card.Body>
			   <Form.Group controlId="formAddress">					 
				<label> 
					<select 
						value={this.state.value} 
						onChange={this.GetValuePair.bind(this)}>
								{optionTemplate}
					</select>
				</label>
				 
				 <Form.Control type="text" id="amount"
				 ref={(input) => { this.amount = input }}
				 />
			   </Form.Group>
			   Quantity 
				 <Form.Control type="text" id="quantity" 
				 ref={(input) => { this.quantity = input }}
				 />	
			 
			<Card.Body>
				 <Button onClick={this.Calculation}>Calculate price</Button>
			</Card.Body>
			
			USD
			<Form.Control type="text" id="calcul"
				 ref={(input) => { this.calcul = input }}
				 />
				 
			ETH to pay
			<Form.Control type="text" id="etherPrice"
				 ref={(input) => { this.etherPrice = input }}
				 />
			<Card.Body>	
				<Button onClick={this.BuyToken}>Buy token</Button>
			</Card.Body>
		    <Card.Body>
				<Button onClick={this.Approve}> Approve token</Button>
			</Card.Body>
			<Card.Body>
				<Button onClick={this.Staking}> Stake</Button>
			</Card.Body>
			<Card.Body>
				<Button onClick={this.UnStaking}> UnStake</Button>
			</Card.Body>
			<Card.Body>
				 <Button onClick={this.AddInMetamask}>Add reward token in Metamask </Button>
			</Card.Body>			
		</Card.Body>
	</Card>		
			
		 </div>
		 
		 
    );
  }
}

export default App;
