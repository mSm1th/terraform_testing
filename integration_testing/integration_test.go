package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Define module locations
// Replace these with the proper paths to your modules
const vpcDirDev = "../tfcode/modules/VPC"
const instanceDirDev = "../tfcode/modules/EC2"

// This is the main function that will be used to deploy the need modules and test them.
func TestStagingInstances(t *testing.T) {
	t.Parallel()

	// Deploy the VPC
	vpcOpts := createVpcOpts(vpcDirDev)
	defer terraform.Destroy(t, vpcOpts)
	terraform.InitAndApply(t, vpcOpts)

	// Deploy the instances
	instanceOpts := createInstanceOpts(t, vpcOpts, instanceDirDev)
	defer terraform.Destroy(t, instanceOpts)
	terraform.InitAndApply(t, instanceOpts)

	// Validate the hello-world-app works
	validateInstance(t, instanceOpts)
}

func createVpcOpts(terraformDir string) *terraform.Options {

	return &terraform.Options{

		// Set the TF directory
		TerraformDir: terraformDir,

		// If you had backend that you wanted to define you could also do that here.

		// Pick a random AWS region to test in. This helps ensure your code works in all regions.
		//awsRegion := aws.GetRandomStableRegion(t, []string{"us-east-1", "eu-west-1"}, nil)

		// Set the variables here:
		Vars: map[string]interface{}{
			"region":            "eu-west-1",
			"main_cidr":         "10.0.0.0/16",
			"availability_zone": "eu-west-1c",
		},
	}
}

// Notice how the next function makes use of the vpcOpts
func createInstanceOpts(t *testing.T,
	vpcOpts *terraform.Options,
	terraformDir string) *terraform.Options {

	// Get the outputs of VPC to use for instace.
	vpcSubet := terraform.OutputRequired(t, vpcOpts, "subnet")
	vpcISG := terraform.OutputRequired(t, vpcOpts, "instance_security_group")
	vpcAppLb := terraform.OutputRequired(t, vpcOpts, "web_app_LB")

	return &terraform.Options{
		TerraformDir: terraformDir,

		Vars: map[string]interface{}{
			"region":                  "eu-west-1",
			"public_key":              "/home/ms/.ssh/aws_key.pub",
			"private_key":             "/home/ms/.ssh/aws_key",
			"instance_type":           "t2.micro",
			"instance_count":          "2",
			"subnet":                  vpcSubet,
			"instance_security_group": vpcISG,
			"web_app_LB":              vpcAppLb,
		},

		// Retry up to 3 times, with 5 seconds between retries,
		// on known errors
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed": "Throttling issue?",
		},
	}
}

func validateInstance(t *testing.T, instanceOpts *terraform.Options) {

	//Get the instaces output expected from the TF modules.
	instances := terraform.OutputRequired(t, instanceOpts, "instances")

	r := strings.NewReplacer("\"", "", "[", "", "]", "")
	cleanedStrings := r.Replace(instances)
	formattedStrings := strings.TrimSpace(cleanedStrings)
	instancesListStrings := strings.Split(formattedStrings, ",")

	instanceList := map[int]string{}

	// Added the string to a map that will be used for testing
	for index, element := range instancesListStrings {
		instanceList[index] = element
	}

	// Iterate tests for each of the instances found
	for key, element := range instanceList {
		if len(strings.TrimSpace(element)) != 0 {
			fmt.Println("Key:", key, "=>", "Instance:", strings.TrimSpace(element))
			url := fmt.Sprintf("http://%s:80", strings.TrimSpace(element))
			http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 10, 10*time.Second)
		}
	}
}
