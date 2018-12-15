import web3 from "./web3.js";
import secret from './secret.js';

import CampaignFactory from './build/CampaignFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(CampaignFactory.interface),
  secret.factoryAddress
);

export default instance;
