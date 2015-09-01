# Worker between Champaign and Actionkit

This is a Dockerized Rails application that functions as a worker between [Champaign, our digital campaigning platform](https://github.com/SumOfUs/Champaign), and [ActionKit](https://github.com/SumOfUs/Champaign) - a proprietary campaigning platform we currently use for e.g. their mailing functionalities and to store user and action data. This worker serves a very specific organizational need, and unless you will want to pass messages between Champaign and ActionKit, you will not need it. For instructions on how to run the application locally, go [here](https://github.com/SumOfUs/Champaign) - the steps are very similar.

This application is deployed under the [worker tier on AWS Elastic Beanstalk](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features-managing-env-tiers.html). Workers on EB listen for messages from Amazon SQS, process the messages, and send them to an endpoint you have specified in the worker configuration on AWS. You can pull a Docker image for the application over at [soutech/champaign-ak-processor](https://hub.docker.com/r/soutech/champaign-ak-processor/) on Docker Hub.

