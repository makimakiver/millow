import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

// Components
import Navigation from './components/Navigation';
import Search from './components/Search';
import Home from './components/Home';

// ABIs
import RealEstate from './abis/RealEstate.json'
import Escrow from './abis/Escrow.json'

// Config
import config from './config.json';

function App() {

  // create a function which will set new array in which stores the account info  
  const [provider, setProvider] = useState(null);
  const [escrow, setEscrow] = useState(null);
  const [account, setAccount] = useState(null);
  // remember it is not a null when you set an array!
  const [homes, setHomes] = useState([])
  const [home, setHome] = useState({})
  const [toggle, setToggle] = useState(false)
  const loadBlockchainData = async () => {
    
    try{
      // making a connection to ethereum blockchain (window.ethereum method allows you to interact with the ethereum wallet)
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      setProvider(provider);
  
      const network = await provider.getNetwork();
    console.log(network.chainId)
    console.log(config[network.chainId])
    // Check if the network's chainId exists in the config
    // if (!config[network.chainId]) {
    //   throw new Error(`Network with chainId ${network.chainId} not supported`);
    // }
    
    // RealEstate Contract
    const realEstate = new ethers.Contract(
      config[network.chainId].realEstate.address,
      RealEstate,
      provider
    )
    try {
        const totalSupply = await realEstate.totalSupply();
        console.log("Total Supply:", totalSupply.toString()); // Log the total supply to check it
        
        const homes = [];
      
        // Iterate over each token to fetch its metadata
        for (let i = 1; i <= totalSupply; i++) {
          try {
            const uri = await realEstate.tokenURI(i);
            console.log("Token URI for token", i, ":", uri); // Log URI to verify
      
            // Fetch metadata from the URI
            const response = await fetch(uri);
            const metadata = await response.json();
            console.log("Metadata for token", i, ":", metadata); // Log metadata to verify
            homes.push(metadata); // Add metadata to homes array
          } catch (error) {
            console.error("Error fetching metadata for token", i, ":", error);
          }
        }
      
        setHomes(homes); // Set the homes state only once, after the loop is complete
        console.log("Homes array:", homes); // Log homes array to confirm data
      
        } catch (error) {
          console.error("Error loading totalSupply or metadata:", error);
        }
    
        console.log("Hello")
    const escrow = new ethers.Contract(config[network.chainId].escrow.address, Escrow, provider)
    setEscrow(escrow);
    console.log("Escrow: ",escrow)
    // config[network.chainId].realEstate.address
    // config[network.chainId].escrow.address
    }catch (error) {
      console.error("Error loading blockchain data:", error);
    }
    window.ethereum.on('accountsChanged', async () => {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      const account = ethers.utils.getAddress(accounts[0])
      setAccount(account);
    })
    // window.ethereum will make a connection between ethereum blockchain and you
  }
  // we want to call the function when the web page is rendered 
  //  we'll use the react hook called useEffect
  useEffect(() => {
    loadBlockchainData()
  }, [account])

  const togglePop = (home) => {
    console.log(account)
    setHome(home)
    toggle ? setToggle(false): setToggle(true)
  }
  return (
    <div>
      <Navigation account={account} setAccount={setAccount}/>
      <Search/>
      <div className='cards__section'>

        <h3>Homes for you</h3>

        <hr />
        <div className='cards'>
            {/* Uncaught TypeError: homes.map is not a function */}
            {homes.map((home, index) => (
              <div className='card' key={index} onClick={() => togglePop(home)}>
                <div className='card__image'>
                  {/* use the double quotation mark */}
                  <img src={home.image} alt="Home"/>
                </div>
                <div className='card__info'>
                  <h4>{home.attributes[0].value}ETH</h4>
                  <p>
                    <strong>{home.attributes[2].value}</strong> 
                    <strong>{home.attributes[3].value}</strong> 
                    <strong>{home.attributes[4].value}</strong>
                  </p>
                  <p>{home.address}</p>
                </div>
              </div>
            ))}
            
          </div>
        </div>

        {toggle && (
          <Home home={home} provider={provider} account={account} escrow={escrow} togglePop={togglePop}/>
        )}
    </div>

  );
}

export default App;
