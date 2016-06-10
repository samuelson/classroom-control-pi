class dsciis {
# Corrected name to this resource so DSC can trigger reboots
reboot { 'dsc_reboot':
when => pending,
timeout => 15,
}
package { 'dotnet4.5.2':
ensure => latest,
provider => 'chocolatey',
notify => Reboot['dsc_reboot'],
}
vcsrepo { 'C:/inetpub/puppetize':
ensure => present,
provider => git,
source => 'https://github.com/puppetlabs-education/asp-starter-site.git',
revision => 'production',
}
# Translated the provided DSC Powershell script into Puppet code below
dsc_windowsfeature{'iis':
dsc_ensure => 'Present',
dsc_name => 'Web-Server',
}
-> dsc_windowsfeature{'iisscriptingtools':
dsc_ensure => 'Present',
dsc_name => 'Web-Scripting-Tools',
}
-> dsc_windowsfeature{'aspnet45':
dsc_ensure => 'Present',
dsc_name => 'Web-Asp-Net45',
}
-> dsc_xwebsite{'defaultsite':
dsc_ensure => 'Present',
dsc_name => 'Default Web Site',
dsc_state => 'Stopped',
dsc_physicalpath => 'C:\inetpub\wwwroot',
}
-> dsc_xwebapppooldefaults{'newwebapppool':
dsc_managedruntimeversion => 'v4.0',
dsc_identitytype => 'ApplicationPoolIdentity',
dsc_applyto => 'Machine',
}
-> dsc_xwebapppool{'newwebapppool':
dsc_name => 'PuppetCodezAppPool',
dsc_ensure => 'Present',
dsc_state => 'Started',
}
-> dsc_xwebsite{'newwebsite':
dsc_ensure => 'Present',
dsc_name => 'PuppetCodez',
dsc_state => 'Started',
dsc_physicalpath => 'C:\inetpub\puppetize',
dsc_applicationpool => 'PuppetCodezAppPool',
dsc_bindinginfo => [{
protocol => 'HTTP',
port => 80,
}],
require => [
Vcsrepo['C:/inetpub/puppetize'], # added dependencies
Package['dotnet4.5.2'],
],
}
}
