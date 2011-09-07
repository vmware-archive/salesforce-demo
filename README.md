# Salesforce Demo

## Functionality
This is a Web App which can be used to populate demo data in a Salesforce instance by seeding it with public company data from LinkedIn.
The data that can be generated includes: Leads, Opportunities and Accounts.
To seed data simply:

* Go into the Linkedin Section and perform a query
* Add the desired objects to your shopping cart
* Once you have enough data:
    * Navigate to the Salesforce object type of choice(Lead, Opportunity or Account)
    * Click Generate

You can try it live at https://salesforce-demo.cloudfoundry.com/

# Code
* Simple Sinatra Web App built using Ruby 1.9.2-p180
    * The main file is demo.rb
    * Uses OAuth 2.0 and LinkedIn gems
    * Styling done with 960.gs. See style.css
* The project will be open sourced under MIT License

## About the Salesforce code
I updated the source code from a recipe submitted here to use the latest version of the OAuth2 gem
http://developer.force.com/cookbook/recipe/interact-with-the-forcecom-rest-api-from-ruby
I still had to monkey patch one item on the OAUth 2.0 client since Salesforce is using an old draft of OAuth 2

More info on Salesforce REST API here:
http://www.salesforce.com/us/developer/docs/api_rest/Content/quickstart_code.htm

## About the LinkedIn code
I used the main LinkedIn gem located here: https://github.com/pengwynn/linkedin and patches from this pull request
https://github.com/pengwynn/linkedin/pull/55#issuecomment-1989910 added to linkedin_client.rb

## Using Cloud Foundry
I used CloudFoundry to invoke Salesforce REST API since CloudFoundry supports SSL out of the box and Redis which is what I used for the shopping cart.
If you have not heard of Cloud Foundry here are some steps to get you started

Register at http://cloudfoundry.com/

* vmc target api.cloudfoundry.com
* vmc login
* Enter Credentials
* Clone this repository if you have not done so already

* vmc push salesforce-demo

* vmc env-add salesforce-demo salesforce_key=3MVB9y6x0357Hled43uoiWgfZ.8DAvMK3vZmbf6HCm_gBYFaHD6ZfPQA5SPUSNFsXfWNXcWqWet8iAxBT.UKP
* vmc env-add salesforce-demo salesforce_secret=3746747173514820663
* vmc env-add salesforce-demo salesforce_instance_url=https://c.na9.visual.force.com

* vmc bind-service redis salesforce-demo

Then go to your cloud foundry app to test. Remember to use SSL

