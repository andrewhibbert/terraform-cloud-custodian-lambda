package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const modeChangePrefix = "custodian-dev-"

func modeChangeOptions(t *testing.T, policyName, modeType string) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../fixtures/mode-change",
		Vars: map[string]interface{}{
			"policy_name": policyName,
			"mode_type":   modeType,
		},
		NoColor: true,
	})
}

// TestModeChange deploys a policy as a Lambda and then changes only its mode.
// The policy itself is never executed; the point is that the mode change
// applies in a single pass with no manual state manipulation, keeping the same
// Lambda function and the same EventBridge rule.
func TestModeChange(t *testing.T) {
	policyName := fmt.Sprintf("mode-change-%s", random.UniqueId())
	expectedName := modeChangePrefix + policyName

	periodicOptions := modeChangeOptions(t, policyName, "periodic")
	cloudtrailOptions := modeChangeOptions(t, policyName, "cloudtrail")

	defer terraform.Destroy(t, periodicOptions)

	// First apply in periodic mode
	terraform.InitAndApply(t, periodicOptions)

	assert.Equal(t, "periodic", terraform.Output(t, periodicOptions, "mode_type"),
		"mode_type is not correct")

	lambdaName := terraform.Output(t, periodicOptions, "lambda_function_name")
	lambdaArn := terraform.Output(t, periodicOptions, "lambda_function_arn")
	ruleName := terraform.Output(t, periodicOptions, "periodic_event_rule_name")
	ruleArn := terraform.Output(t, periodicOptions, "periodic_event_rule_arn")

	assert.Equal(t, expectedName, lambdaName, "lambda_function_name is not correct")
	assert.Equal(t, expectedName, ruleName, "periodic_event_rule_name is not correct")
	assert.Equal(t, "rate(5 minutes)",
		terraform.Output(t, periodicOptions, "periodic_schedule_expression"),
		"periodic_schedule_expression is not correct")

	// Change mode to cloudtrail in a single apply, with no manual state manipulation
	terraform.Apply(t, cloudtrailOptions)

	assert.Equal(t, "cloudtrail", terraform.Output(t, cloudtrailOptions, "mode_type"),
		"mode_type is not correct")

	assert.Equal(t, lambdaName,
		terraform.Output(t, cloudtrailOptions, "lambda_function_name"),
		"lambda function name should not change when the policy mode changes")
	assert.Equal(t, lambdaArn,
		terraform.Output(t, cloudtrailOptions, "lambda_function_arn"),
		"lambda function should not be replaced when the policy mode changes")

	assert.Equal(t, ruleName,
		terraform.Output(t, cloudtrailOptions, "cloudwatch_event_rule_name"),
		"the EventBridge rule should keep the same name across a mode change")
	assert.Equal(t, ruleArn,
		terraform.Output(t, cloudtrailOptions, "cloudwatch_event_rule_arn"),
		"the EventBridge rule should be updated in place, not replaced, across a mode change")

	assert.NotEmpty(t, terraform.Output(t, cloudtrailOptions, "cloudwatch_event_pattern"),
		"cloudwatch_event_pattern should be set in cloudtrail mode")
	assert.Empty(t, terraform.Output(t, cloudtrailOptions, "periodic_schedule_expression"),
		"periodic_schedule_expression should be unset in cloudtrail mode")

	// Change back to periodic to prove the transition is reversible.
	terraform.Apply(t, periodicOptions)

	assert.Equal(t, "periodic", terraform.Output(t, periodicOptions, "mode_type"),
		"mode_type is not correct")

	assert.Equal(t, lambdaArn,
		terraform.Output(t, periodicOptions, "lambda_function_arn"),
		"lambda function should not be replaced when the policy mode changes back")
	assert.Equal(t, ruleArn,
		terraform.Output(t, periodicOptions, "periodic_event_rule_arn"),
		"the EventBridge rule should be updated in place, not replaced, when the mode changes back")

	assert.Equal(t, "rate(5 minutes)",
		terraform.Output(t, periodicOptions, "periodic_schedule_expression"),
		"periodic_schedule_expression should be restored in periodic mode")
	assert.Empty(t, terraform.Output(t, periodicOptions, "cloudwatch_event_pattern"),
		"cloudwatch_event_pattern should be unset in periodic mode")
}
