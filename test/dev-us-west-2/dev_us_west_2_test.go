package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/dev-us-west-2
func TestDevUsWest2(t *testing.T) {
	t.Parallel()

	// Create state for passing data between test stages
	// https://github.com/gruntwork-io/terratest#iterating-locally-using-test-stages
	exampleFolder := test_structure.CopyTerraformFolderToTemp(
		t,
		"../../",
		"examples/dev-us-west-2",
	)

	// At the end of the test, `terraform destroy` the created resources
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy the tested infrastructure
	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions := configureTerraformOptions(t, exampleFolder)

		// Save the options and key pair so later test stages can use them
		test_structure.SaveTerraformOptions(t, exampleFolder, terraformOptions)

		// Run `terraform init` and `terraform apply` and fail if there are errors
		terraform.InitAndApply(t, terraformOptions)

		// Run `terraform output` to get the value of an output variables
		albDNSName := terraform.Output(t, terraformOptions, "aws_alb_dns_name")
		bucketName := terraform.Output(t, terraformOptions, "license_s3_bucket_id")

		publicHostnames := terraform.Output(t, terraformOptions, "public_hostnames")
		privateHostnames := terraform.Output(t, terraformOptions, "private_hostnames")
		privateKeyFilename := terraform.Output(t, terraformOptions, "private_key_filename")

		// Save outputs for the validation stage
		test_structure.SaveString(t, exampleFolder, "albDNSName", albDNSName)
		test_structure.SaveString(t, exampleFolder, "bucketName", bucketName)
		test_structure.SaveString(t, exampleFolder, "bucketRegion", "us-west-2")
		test_structure.SaveString(t, exampleFolder, "publicHostnames", publicHostnames)
		test_structure.SaveString(t, exampleFolder, "privateHostnames", privateHostnames)
		test_structure.SaveString(t, exampleFolder, "privateKeyFilename", privateKeyFilename)

	})

	// Validate the test infrastructure
	test_structure.RunTestStage(t, "validate", func() {
		testAlbValid(t, exampleFolder)
		testS3BucketContents(t, exampleFolder)
		testCompute(t, exampleFolder)
		testObservability(t, exampleFolder)
	})
}

func configureTerraformOptions(t *testing.T, exampleFolder string) *terraform.Options {

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: exampleFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"environment": "development",
			"region":      "us-west-2",
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-west-2",
		},
	}

	return terraformOptions
}

func testAlbValid(t *testing.T, exampleFolder string) {

	// Load module outputs for validation
	albDNSName := test_structure.LoadString(t, exampleFolder, "albDNSName")

	// The ALB has valid characteristics
	assert.NotEmpty(t, albDNSName)
	assert.Contains(t, albDNSName, ".elb.amazonaws.com")

}

func testS3BucketContents(t *testing.T, exampleFolder string) {

	// Load bucket info for content validation
	bucketRegion := test_structure.LoadString(t, exampleFolder, "bucketRegion")
	bucketName := test_structure.LoadString(t, exampleFolder, "bucketName")
	licensePath := "license.rli"

	content := aws.GetS3ObjectContents(t, bucketRegion, bucketName, licensePath)
	assert.NotEmpty(t, content)

}

func testCompute(t *testing.T, exampleFolder string) {

	// Load module outputs for validation
	privateHostnames := test_structure.LoadString(t, exampleFolder, "privateHostnames")
	publicHostnames := test_structure.LoadString(t, exampleFolder, "publicHostnames")
	privateKeyFilename := test_structure.LoadString(t, exampleFolder, "privateKeyFilename")

	assert.NotEmpty(t, privateHostnames)
	assert.NotEmpty(t, publicHostnames)
	assert.NotEmpty(t, privateKeyFilename)

}

func testObservability(t *testing.T, exampleFolder string) {

	cmd := shell.Command{
		Env:     map[string]string{"AWS_DEFAULT_REGION": "us-west-2"},
		Command: "aws",
		Args:    []string{"cloudwatch", "describe-alarms"},
	}
	out := shell.RunCommandAndGetOutput(t, cmd)

	assert.Contains(t, out, "compute_saturated")

}
