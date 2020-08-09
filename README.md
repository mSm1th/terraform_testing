# terraform_testing
A repo to demonstrate testing within Terraform. Within this page we will look at several classifications of testing.
While some of these definitions may be disputed, it is important to take the value from each of the sections. 
By doing so, you can be more confidfdent in your code/infrastructure.



## Static Testing/Analysis

**What is Static testing?**

Static testing is a software testing technique by which we can check the defects in software 
without actually executing it. 


What are the benifits of static testing/analysis
- Fast.
- Stable.
- No need to deploy resources.
- Very easy to use.


**Tools:**

- Terraform.
In our case, for our static analysis we will make use of a native Terraform command - `terraform validate`.
This will allow for a quick check to make sure you have not made a silly mistake with spelling, missing a braket, or what I
believe to be more useful; checking for unused variables.

All you will need to do here is run your terraform validate command in your code DIR.
`terraform validate -json`

A common exaple for errors that can be easily found is duplication. Within the static_analysis section I have copied some code from the TF website.

I have followed a standard of creating a `proivider.tf` file to store any provider information:


```yaml
provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = var.region
  version    = "~> 2.56"
}
```

However I have also copied code that already has a provider block nested within it, and I have added that to my `main.tf` file. If I run a validate command, this is clear.

```
$ terraform validate

Error: Duplicate provider configuration

  on provider.tf line 1:
   1: provider "aws" {

A default (non-aliased) provider configuration for "aws" was already given at
main.tf:3,1-15. If multiple configurations are required, set the "alias"
argument for alternative configurations.
```


**Pre-requirments:** 
- Just have TF installed.

**Links:**
[Terraform Validate](https://www.terraform.io/docs/commands/validate.html)



## Linters 

**What is a Linter?**

**Tools:**
**Pre-requirments:** 
**Links:**


## Security Testing

**What security aspects are we looking for?** 

**Tools:**
**Pre-requirments:** 
**Links:**

## Unit Testing

**What is a Terraform Unit Test?**

**Tools:**
**Pre-requirments:** 
**Links:**


## Integration Testing

**What is a Terraform Integration Test?**

**Tools:**
**Pre-requirments:** 
**Links:**

## Property Testing

**What is a Property/properties Test?**

**Tools:**
**Pre-requirments:** 
**Links:**

## E2E Testing

E2E testing in Terraform is ......

**Tools:**
**Pre-requirments:** 
**Links:**

--- 
