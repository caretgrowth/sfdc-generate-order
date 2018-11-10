# sfdc-generate-order

Give your users an easy way to create Orders (and related Order Products) from Opportunities without using CPQ.

This simple lightning component and action that you can add to your Opportunity Page Layout that will save users time and ensure they are adding the correct quantity and products to the corresponding orders.

Action

![image](https://user-images.githubusercontent.com/3085186/48305679-43ca7280-e4fd-11e8-9c8b-a163fc2b7e7e.png)

Modal

![image](https://user-images.githubusercontent.com/3085186/48305692-60ff4100-e4fd-11e8-9f4e-45f183ae9844.png)

It is also includes an InvocableMethod that allows you to create orders on Opportunity close using process builder or visual flows.

![image](https://user-images.githubusercontent.com/3085186/48305705-9a37b100-e4fd-11e8-9ea4-6eaefbfaf81b.png)

## Dev Setup Instructions (SFDX)

### Manual

```shell
git clone git@github.com:mikesimps/sfdc-generate-order.git
```

```shell
cd sfdc-generage-order
```

```shell
sfdx force:org:create -a orders -v YOUR_DEVHUB -s -d 30 -f config/project-scratch-def.json -w 5
```

```shell
sfdx force:source:push
```

### Easier method

[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com/)

## Deploy/Install

### Deploy Source Directly (Test in Sandbox First!)

(assumes cloned and in current directory)

```shell
sfdx force:source:convert -d deploy -r generate-order
```

```shell
sfdx force:mdapi:deploy -d deploy -u YOUR_ORG  -l RunSpecifiedTests -r CreateOrderFromOpportunityControllerTEST -w 5
```

### Deploy as unlocked package [Trailhead](https://trailhead.salesforce.com/content/learn/modules/unlocked-packages-for-customers/build-your-first-unlocked-package)

**Create the package (you only need to do this when you install the initial version)**

Be sure to give your package name a unique suffix (must be unique across all orgs)

```shell
sfdx force:package:create --name generate-order-YOURORG --description "Forked version of sfdc-generate-order" --packagetype Unlocked --path generate-order --nonamespace -v YOUR_DEVHUB
```

Be sure to save/note the package id beginning with 0Ho for later

Update the version your sfdx-project.json to the next version

```json
    "packageDirectories": [
        {
            "path": "generate-order",
            "default": true,
            "package": "generate-order-YOURORG",
            "versionName": "ver 0.1.1",
            "versionNumber": "0.1.1.NEXT"
        }
    ],
```

Take the package id it gives you and use it in this command to create the version. If you run this command multiple times it will just add a build number on the end (i.e. `ver 0.1.0-2`)

```shell
sfdx force:package:version:create -w 10 -x -v YOUR_DEVHUB -p 0Ho###############
```

Once that completes (could take a while), you will want to test your package installation in a sandbox or scratch org. You can install the version of the package using the command below and the package version id it gives you from the previous command (starts with `04t`)

```shell
sfdx force:package:install -u YOUR_TEST_ORG -p 04t############### -w 5 -r
```

Once you are confident it is ready to deploy, you need to promote it with this command. Once it is promoted, you will be able to install in Production.

```shell
sfdx force:package:version:promote -v YOUR_DEVHUB -p 04t###############
```

Almost there! Now you just need to install it into production with the same install command above, just targeting your production org.

Once the package is installed, all you need to do is add the Action to the page layout and you should be good to go.

## Issues and Contributions

All contributions are welcome including bugs and feature requests. Just submit an issue and be as descriptive as possible.
