@export()
var sizeAppVm = 'Standard_D64_v5'
@export()
var sizeMediaVm = 'Standard_L8as_v3'
@export()
var projectName = 'volumezdemo'
@export()
var snetName = 'snet-${projectName}-vms'
@export()
var vnetName = 'vnet-${projectName}-services'
@export()
var vmAppOffer = 'RHEL'
@export()
var vmMediaOffer = 'RHEL'
@export()
var vmAppPublisher = 'RedHat'
@export()
var vmMediaPublisher = 'RedHat'
@export()
var vmAppSku = '8_7'
@export()
var vmMediaSku = '8_7'
@export()
var vmAppVersion = 'latest'
@export()
var vmMediaVersion = 'latest'
@export()
var signup_domain = 'signup.volumez.com'
@export()
var zones = [ 2 ]
@export()
var zone = 2


func allSizes() array => [
  {
    name: 'small'
    nrAppVms: 1
    nrMediaVms: 2
    sizeAppVm: 'Standard_D16_v5'
    sizeMediaVm: 'Standard_L8s_v3'
  }
  {
    name: 'medium'
    nrAppVms: 1
    nrMediaVms: 6
    sizeAppVm: 'Standard_D32_v5'
    sizeMediaVm: 'Standard_L8s_v3'
  }
  {
    name: 'large'
    nrAppVms: 1
    nrMediaVms: 12
    sizeAppVm: 'Standard_D64_v5'
    sizeMediaVm: 'Standard_L8s_v3'
  }
  {
    name: 'xlarge'
    nrAppVms: 1
    nrMediaVms: 18 
    sizeAppVm: 'Standard_D96_v5'
    sizeMediaVm: 'Standard_L8s_v3'
  }
]


@export()
func getSize( sizeInput string ) object => last(filter( allSizes(), size => size.name == sizeInput ))
