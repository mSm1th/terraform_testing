package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)



// Define module locations
// Replace these with the proper paths to your modules
const vpcDirDev = "../"
const instanceDirDev = "../"


// This is the main function that will be used to deploy the need modules and test them.
func TestStagingInstances(t *testing.T) {
	t.Parallel()

	// Deploy the VPC 
	vpcOpts := createVpcOpts(t, vpcDirDev)
	defer terraform.Destroy(t, vpcOpts)
	terraform.InitAndApply(t, vpcOpts)

	// Deploy the instances
	instanceOpts := createInstanceOpts(vpcOpts, instanceDirDev)
	defer terraform.Destroy(t, instanceOpts)
	terraform.InitAndApply(t, instanceOpts)

	// Validate the hello-world-app works
	validateInstances(t, instanceOpts)
}

func createVpcOpts(t *testing.T, terraformDir string) *terraform.Options {
	return &terraform.Options{
		
		// Set the TF directory
		TerraformDir: terraformDir,

		// If you had backend that you wanted to define you could also do that here.

		// Set the variables here:
		Vars: map[string]interface{}{
			"region": "eu-west-1",
			"main_cidr": "10.0.0.0/16",
			"availability_zone": "eu-west-1c",
		}

	}
}

// Notice how the next function makes use of the vpcOpts
func createInstanceOpts(
	vpcOpts *terraform.Options,
	terraformDir string) *terraform.Options {
	
	// Get the outputs of VPC to use for instace.
	vpcSubet := terraform.OutputRequired(t, vpcOpts, "subnet")
	vpcISG := terraform.OutputRequired(t, vpcOpts, "instance_security_group")
	vpcAppLb := terraform.OutputRequired(t, vpcOpts, "web_app_LB")


		return &terraform.Options{
			TerraformDir: terraformDir,
	
			Vars: map[string]interface{}{
				//"public_key"
				//"private_key" 
				"instance_type": "t2.micro",
				"instance_count": "1", 
				"subnet": vpcSubet,
				"instance_security_group": vpcISG, 
				"web_app_LB":vpcAppLb, 
			},
	
			// Retry up to 3 times, with 5 seconds between retries,
			// on known errors
			MaxRetries: 3,
			TimeBetweenRetries: 5 * time.Second,
			RetryableTerraformErrors: map[string]string{
				"RequestError: send request failed": "Throttling issue?",
			},
		}
}

func validateInstance(t *testing.T, instanceOpts *terraform.Options){

	//Get the instaces output expected from the TF modules.
	instances := terraform.OutputRequired(t, instanceOpts, "instances")

	// Create an instance list slice
	instaceList := []string{}
	// The below will create a slice with the values of the instances
	instaceListStrings := strings.Split(instances, ",")

	// For each of the instances found, add them to the slice
	for index, element := range instaceListStrings {
		instanceList = append(instanceList, element)	
	}
	
	// Iterate tests for each of the instances found
	for index, element := range instance_list {
		url := fmt.Sprintf("http://%s", element)
		maxRetries := 10
		timeBetweenRetries := 10 * time.Second

		http_helper.HttpGetWithRetryWithCustomValidation(
			t,
			url,
			maxRetries,
			timeBetweenRetries,
			func(status int, body string) bool {
				return status == 200 &&
					strings.Contains(body, "Hello, World")
			},
		)
	}	
}