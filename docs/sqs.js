const SQS = require("aws-sdk");
const json = require("./message");

const AWS_SQS_EXAMPLE_URL = "https://sqs.eu-west-1.amazonaws.com/852196116519/example";


function sendMessage(json) {
  const sqs = new SQS({apiVersion: "2012-11-05"});
  return util.promisify(sqs.sendMessage.bind(sqs))({
    MessageBody: JSON.stringify(json),
    QueueUrl: AWS_SQS_EXAMPLE_URL,
  });
}

sendMessage(json);
