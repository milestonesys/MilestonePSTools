<#

# TODO: Find all functions missing an [OutputType(...)] attribute. If a function returns nothing, you can explicitly use [OutputType('None')] and the Outputs section of the docs will say "None" which is better than a blank string or randomly "Object" or whatever.
get-command -Module MilestonePSTools -CommandType Function | ? { $null -eq ($_.ScriptBlock.Attributes | ? TypeId -eq ([System.Management.Automation.OutputTypeAttribute])) } 

#>