# salesforce-demo is no longer actively maintained by VMware, Inc.

## Functionality
This is a Web App which can be used to populate demo data in a Salesforce instance by seeding it with public company data from LinkedIn.
The data that can be generated includes: Leads, Opportunities and Accounts.
To seed data simply:

- Go into the Linkedin Section and perform a query
- Add the desired objects to your shopping cart
- Once you have enough data:
   - Navigate to the Salesforce object type of choice(Lead, Opportunity or Account)
   - Click Generate

You can try it live at https://salesforce-demo.cloudfoundry.com/

## Using Cloud Foundry
I used CloudFoundry to invoke Salesforce REST API since CloudFoundry supports SSL out of the box and Redis which is what I used for the shopping cart.
If you have not heard of Cloud Foundry here are some steps to get you started

## Getting Started
 - Register at [http://cloudfoundry.com/](https://my.cloudfoundry.com/signup/hack) for an account if you don't have one

Open a terminal window and run

``` bash
gem install vmc
vmc target api.cloudfoundry.com
vmc login <email>
```

Clone this repository if you have not done so already and make your modifications.

In particular you need to make a copy of `add_keys_sample.sh` as `add_keys.sh` and put in it your credentials:

- LinkedIn App Key and Secret and
- Salesforce App Key and Secret
- Also for `salesforce_instance_url` use your instance like `na3`

Then deploy to Cloud Foundry. Example

``` bash
vmc push --nostart
```

This push will use the `manifest.yml` to create a redis service and bind it to your app which has been created with a semi random name

You can then add all the keys

``` bash
export APP_NAME=<new_app_name>
./add_keys.sh
vmc start
```

Then go to your Cloud Foundry app to test. Remember to use SSL


## Application details
* Simple Sinatra Web App built using Ruby 1.9.2
    * The main file is demo.rb
    * Uses OAuth 2.0 and LinkedIn gems
    * Styling done with 960.gs. See style.css
* The project will be open sourced under MIT License

## About the Salesforce code
I updated the source code from a recipe submitted here to use the latest version of the OAuth2 gem
http://developer.force.com/cookbook/recipe/interact-with-the-forcecom-rest-api-from-ruby
I still had to monkey patch one item on the OAuth 2.0 client since Salesforce is using an old draft of OAuth 2 (draft 10)

More info on Salesforce REST API here:
http://www.salesforce.com/us/developer/docs/api_rest/Content/quickstart_code.htm

## About the LinkedIn code
I used the main LinkedIn gem located here: https://github.com/pengwynn/linkedin and patches from this pull request
https://github.com/pengwynn/linkedin/pull/55#issuecomment-1989910 added to linkedin_client.rb

