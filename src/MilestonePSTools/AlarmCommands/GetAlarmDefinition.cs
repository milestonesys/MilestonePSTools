// Copyright 2025 Milestone Systems A/S
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using System.Linq;
using System.Management.Automation;
using VideoOS.Platform.ConfigurationItems;

namespace MilestonePSTools.AlarmCommands
{
    /// <summary>
    /// <para type="synopsis">Gets Alarm Definitions from the Event Server.</para>
    /// <para type="description">Gets a list of Alarm Definitions from the Management Server / Event Server. Effectively this is a simplified way to access (Get-VmsManagementServer).AlarmDefinitionFolder.AlarmDefinitions.</para>
    /// <para type="description">Note: Manipulation of Alarm Definitions is not fully supported in this module. You can, however, manipulate alarm definitions retrieved from this cmdlet by making supported changes to the object, then calling the Save() method.</para>
    /// <example>
    ///     <code>C:\PS>Get-AlarmDefinition</code>
    ///     <para>Gets all Alarm Definitions defined on the Event Server. This should be the same list you would see in the Management Client.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Get-AlarmDefinition -Name *Overflow*</code>
    ///     <para>Gets all Alarm Definitions defined on the Event Server where the Name of the alarm contains "Overflow".</para>
    ///     <para>Alarms named "Feed Overflow Started" or "Overflows Detected" would be returned with this command.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>$alarm = Get-AlarmDefinition -Name "Motion Detected"; $alarm.TriggerEventlist = 'UserDefinedEvent[a90f978f-9c28-4202-b7cc-4c232e8b17b4]'; $alarm.Save()</code>
    ///     <para>Gets an alarm named "Motion Detected", and changes the alarm settings such that a previously defined User-defined Event will be triggered when the alarm is triggered, then saves the changes using the Save() method.</para>
    ///     <para>You might trigger a user-defined event with an alarm in order to connect the alarm into the rules system to perform some other desired action. Occasionally the source of an alarm is not available as a trigger in the rule system, so you can map an alarm into a rule in this way.</para>
    ///     <para>Note: If an Alarm Definition named 'Motion Detected' does not exist, an error will be thrown with exception ItemNotFoundException.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, nameof(AlarmDefinition))]
    [OutputType(typeof(AlarmDefinition))]
    [RequiresVmsConnection()]
    public class GetAlarmDefinition : ConfigApiCmdlet
    {
        /// <summary>
        /// <para type="description">Specifies the Alarm Definition Name using a case-insensitive string with support for wildcards characters.</para>
        /// <para type="description">If Name is provided, does not contain wildcard characters, and no matching Alarm Definition is found, an error will be raised.</para>
        /// </summary>
        [Parameter(Position = 1)]
        public string Name { get; set; } = "*";

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            var ms = Connection.ManagementServer;
            var pattern = new WildcardPattern(Name, WildcardOptions.IgnoreCase);
            var matches = ms.AlarmDefinitionFolder.AlarmDefinitions.Where(o => pattern.IsMatch(o.Name)).ToList();
            if (!matches.Any() && !WildcardPattern.ContainsWildcardCharacters(Name))
            {
                WriteError(
                    new ErrorRecord(
                        new ItemNotFoundException($"Alarm Definition not found with Name matching '{Name}'"),
                        "Alarm Definition not found",
                        ErrorCategory.ObjectNotFound,
                        null));
            }
            foreach (var match in matches)
            {
                WriteObject(match);
            }
        }
    }
}

