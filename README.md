# Tibber onboarding script

I have a dream...

> As a new employee, I want to be able to run one single script that takes care of setting up my entire dev environment. This process should take minutes and not hours/days.

Dreams & visions are good because the help guide us. However, **perfect is the enemy of good**. This will not happen overnight. If we can remove one single obstacle of the onboarding process, that's a win.

We want continuous improvements to the onboarding experience, so please take the time to improve on this dream and the implementation.

## Running the script

This script doesn't yet contain any sensitive information. IMHO, we can upload/deploy the script to a public location. To begin with I created an s3 bucket where we can host this script but not have it indexed by google.

The [bucket](https://eu-west-1.console.aws.amazon.com/s3/buckets/dev-tibber-onboarding?region=eu-west-1&bucketType=general&tab=objects) itself is private, but the folder `public-scripts` is public. For now, deployments is a manual process of simply uploading this script into this bucket + folder.

Run the script:

```
curl -sSL https://dev-tibber-onboarding.s3.eu-west-1.amazonaws.com/public-scripts/setup_mac_dev_env.sh | bash
```

## Caveats

This script is opinionated and probably should be. It should enforce the recommended way. If an employee wants a customized environment they should probably perform the installation manually.

Version 1.0 is written for Mac in the perspective of a node developer. Linux, Windows, Python, .NET probably have other requirements. Maybe we can share a script, maybe not. It will need to be a joint effort.
