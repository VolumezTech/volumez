/*
#######################################################################################
#
#  Config/ variables
#
#######################################################################################
*/

@secure()
param adminPassword string
param tenant_token string
param nrAppVms int
param nrMediaVms int
param deployBastion string
param location string = resourceGroup().location



var sizeAppVm = 'Standard_D64_v5'
var sizeMediaVm = 'Standard_L8as_v3'
var projectName = 'volumezdemo'
var snetName = 'snet-${projectName}-vms'
var vnetName = 'vnet-${projectName}-services'
var vmAppOffer = 'RHEL'
var vmMediaOffer = 'RHEL'
var vmAppPublisher = 'RedHat'
var vmMediaPublisher = 'RedHat'
var vmAppSku = '8_7'
var vmMediaSku = '8_7'
var vmAppVersion = 'latest'
var vmMediaVersion = 'latest'
var signup_domain = 'signup.volumez.com'
var script = loadTextContent('../scripts/deploy_connector.sh')
var deployBastionBool = bool(deployBastion) 
var cloudInitScript = replaceMultiple(script, {
  '{0}': tenant_token
  '{1}': signup_domain
})
