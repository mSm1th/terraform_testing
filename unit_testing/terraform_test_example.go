package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsHelloWorldExample(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located. Note my code lives in on the GO path. SO you will need to update.
		TerraformDir: "../examples/simpleExample",
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the IP of the instance
	publicIp := terraform.Output(t, terraformOptions, "public_ip")

	//If you wanted to test for specific values you can make use of the assert method:
	// assert.Equal(t, <variable>, <output_variable>)
	//Check that a subnet is private:
	// assert.False(t, aws.IsPublicSubnet(t, <output_subnet_var>, <region_variable>))

	// Make an HTTP request to the instance and make sure we get back a 200 OK with the body "Hello, World!"
	url := fmt.Sprintf("http://%s:8080", publicIp)
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 5*time.Second)
}
