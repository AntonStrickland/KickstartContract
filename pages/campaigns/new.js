import React from 'react';
import { Form, Button, Input, Message } from 'semantic-ui-react';
import Layout from '../../components/Layout.js';
import factory from '../../ethereum/factory.js';
import web3 from '../../ethereum/web3.js';
import {Router} from '../../routes';

class CampaignNew extends React.Component {

  state = {
    minimumContribution: '',
    errorMessage: '',
    loading: false
  };

  onSubmit = async (event) => {
    event.preventDefault();

    this.setState({loading: true, errorMessage: ''});

    try {

      const accounts = await web3.eth.getAccounts();
      await factory.methods.createCampaign(this.state.minimumContribution)
      .send({
        from: accounts[0]
      });

      Router.pushRoute('/');

    } catch (err) {
      this.setState({errorMessage: err.message});
    }

    this.setState({loading: false});


  }

  render() {
    return (
      <Layout>
      <h1>Create a new campaign</h1>

      <Form error={!!this.state.errorMessage} onSubmit={this.onSubmit}>
        <Form.Field>
        <label>Minimum Contribution</label>
        <Input label="Wei" labelPosition="right"
        value={this.state.minimumContribution}
        onChange={event=>this.setState({minimumContribution: event.target.value})}/>
        </Form.Field>

      <Button loading={this.state.loading} primary>Create!</Button>
      <Message error header="Oops!" content={this.state.errorMessage} />

      </Form>


      </Layout>
    );
  }
}

export default CampaignNew;
