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

using MilestonePSTools.Connection;
using MilestonePSTools.Extensions;
using MilestonePSTools.Helpers;
using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Security.Principal;
using System.Text.RegularExpressions;
using VideoOS.ConfigurationApi.ClientService;
using VideoOS.Platform;
using VideoOS.Platform.ConfigurationItems;
using VideoOS.Platform.Proxy.ConfigApi;

namespace MilestonePSTools
{

    public class VmsFeatureNotAvailableException : Exception
    {
        public string FeatureFlag { get; set; }

        public VmsFeatureNotAvailableException() { }

        public VmsFeatureNotAvailableException(string message) : base(message) { }
        public VmsFeatureNotAvailableException(string message, Exception inner) : base(message, inner) { }

        public VmsFeatureNotAvailableException(string message, string featureFlag) : base(message)
        {
            FeatureFlag = featureFlag;
        }

        public VmsFeatureNotAvailableException(string message, string featureFlag, Exception inner) : base(message, inner)
        {
            FeatureFlag = featureFlag;
        }
    }

    public class VmsVersionValidationException : Exception
    {
        public VersionInterval RequiredVersion { get; set; }

        public VmsVersionValidationException() { }

        public VmsVersionValidationException(string message) : base(message) { }
        public VmsVersionValidationException(string message, Exception inner) : base(message, inner) { }

        public VmsVersionValidationException(string message, VersionInterval requiredVersion) : base(message)
        {
            RequiredVersion = requiredVersion;
        }

        public VmsVersionValidationException(string message, VersionInterval requiredVersion, Exception inner) : base(message, inner)
        {
            RequiredVersion = requiredVersion;
        }
    }

    public class VmsItemTypeValidationException : Exception
    {
        public IEnumerable<string> ValidItemTypes { get; private set; }
        public string ItemType { get; private set; }
        public VmsItemTypeValidationException() { }

        public VmsItemTypeValidationException(string message) : base(message) { }
        public VmsItemTypeValidationException(string message, Exception inner) : base(message, inner) { }

        public VmsItemTypeValidationException(string message, IEnumerable<string> validItemTypes, string itemType) : base(message)
        {
            ValidItemTypes = validItemTypes;
            ItemType = itemType;
        }
    }

    public class VmsNotConnectedException : Exception
    {
        public string FeatureFlag { get; set; }

        public VmsNotConnectedException() { }

        public VmsNotConnectedException(string message) : base(message) { }
        public VmsNotConnectedException(string message, Exception inner) : base(message, inner) { }
    }

    public class AdminElevationRequiredException : Exception
    {

        public AdminElevationRequiredException() { }

        public AdminElevationRequiredException(string message) : base(message) { }
        public AdminElevationRequiredException(string message, Exception inner) : base(message, inner) { }
    }

    public class InteractiveSessionRequiredException : Exception
    {

        public InteractiveSessionRequiredException() { }

        public InteractiveSessionRequiredException(string message) : base(message) { }
        public InteractiveSessionRequiredException(string message, Exception inner) : base(message, inner) { }
    }


    public interface IVmsRequirementValidator
    {
        string Source { get; set; }
        void Validate();
    }

    public interface IDescriptive
    {
        string Description { get; }
    }

    public class VersionInterval
    {
        public bool MinVersionExclusive { get; }
        public bool MaxVersionExclusive { get; }

        public Version MinVersion { get; } = new Version(0, 0, 0, 0);
        public Version MaxVersion { get; } = new Version(int.MaxValue, int.MaxValue, int.MaxValue, int.MaxValue);

        private readonly string _originalString;

        private static readonly string BasicPattern = @"^(?<minVer>\d+\.\d+(\.\d+){0,2}?)$";
        private static readonly string ExactMatch = @"^\[(?<exactVer>\d+\.\d+(\.\d+){0,2}?)\]$";
        private static readonly string AdvancedPattern = @"^(?<minScope>[\[\(])(?<minVer>\d+\.\d+(\.\d+){0,2}?)?,(?<maxVer>\d+\.\d+(\.\d+){0,2}?)?(?<maxScope>[\]\)])$";

        public VersionInterval(string version)
        {
            version = version.Replace(" ", "");
            Match match;
            if ((match = Regex.Match(version, BasicPattern)).Success)
            {
                MinVersion = Version.Parse(match.Groups["minVer"].Value);
            }
            else if ((match = Regex.Match(version, ExactMatch)).Success)
            {
                MinVersion = Version.Parse(match.Groups["exactVer"].Value);
                MaxVersion = Version.Parse(match.Groups["exactVer"].Value);
            }
            else if ((match = Regex.Match(version, AdvancedPattern)).Success)
            {
                MinVersion = string.IsNullOrWhiteSpace(match.Groups["minVer"].Value) ? MinVersion : Version.Parse(match.Groups["minVer"].Value);
                MaxVersion = string.IsNullOrWhiteSpace(match.Groups["maxVer"].Value) ? MaxVersion : Version.Parse(match.Groups["maxVer"].Value);
                MinVersionExclusive = match.Groups["minScope"].Value.Equals("(");
                MaxVersionExclusive = match.Groups["maxScope"].Value.Equals(")");
            }
            else
            {
                throw new ArgumentException("Failed to parse version using interval notation.", nameof(version));
            }

            _originalString = version;
        }

        public bool IncludesVersion(Version version)
        {
            if (version < MinVersion)
            {
                return false;
            }

            if (MinVersionExclusive && version == MinVersion)
            {
                return false;
            }

            if (version > MaxVersion)
            {
                return false;
            }

            if (MaxVersionExclusive && version == MaxVersion)
            {
                return false;
            }

            return true;
        }

        public void Validate(Version version)
        {
            if (MinVersion == MaxVersion && version != MinVersion)
            {
                throw new VmsVersionValidationException($"Server version must be exactly {MinVersion}. Actual version: {version}", this);
            }

            if (version < MinVersion)
            {
                throw new VmsVersionValidationException($"Server version must be greater than or equal to {MinVersion}. Actual version: {version}", this);
            }

            if (MinVersionExclusive && version == MinVersion)
            {
                throw new VmsVersionValidationException($"Server version must be greater than {MinVersion}. Actual version: {version}", this);
            }

            if (version > MaxVersion)
            {
                throw new VmsVersionValidationException($"Server version must be less than or equal to {MaxVersion}. Actual version: {version}", this);
            }

            if (MaxVersionExclusive && version == MaxVersion)
            {
                throw new VmsVersionValidationException($"Server version must be less than {MaxVersion}. Actual version: {version}", this);
            }
        }

        public override string ToString()
        {
            return _originalString;
        }
    }

    public class RequiresVmsVersionAttribute : Attribute, IVmsRequirementValidator, IDescriptive
    {
        public VersionInterval RequiredVersion { get; }
        public string Source { get; set; }

        public string Description
        {
            get
            {
                return $"Requires VMS version {RequiredVersion}";
            }
        }

        public RequiresVmsVersionAttribute(VersionInterval requiredVersion)
        {
            RequiredVersion = requiredVersion;
        }

        public void Validate()
        {
            if (MilestoneConnection.Instance == null)
            {
                throw new VmsNotConnectedException($"You are not connected to a Milestone VMS. Use Connect-Vms to login.{(string.IsNullOrWhiteSpace(Source) ? string.Empty : $" Source: {Source}.")}");
            }

            try
            {
                var serverVersion = MilestoneConnection.Instance.CurrentSite.Properties["ServerVersion"];
                RequiredVersion.Validate(Version.Parse(serverVersion));
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
                throw new VmsVersionValidationException($"{ex.Message}{(string.IsNullOrWhiteSpace(Source) ? string.Empty : $" Source: {Source}.")}", ex);
            }

        }

        public override string ToString()
        {
            return $"[RequiresVmsVersion('{RequiredVersion}')]";
        }
    }

    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = true)]
    public class ValidateVmsVersionAttribute : ValidateArgumentsAttribute, IDescriptive
    {
        public VersionInterval RequiredVersion { get; }

        public string Description
        {
            get
            {
                return $"Requires VMS version {RequiredVersion}";
            }
        }

        public ValidateVmsVersionAttribute(VersionInterval requiredVersion)
        {
            RequiredVersion = requiredVersion;
        }
        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            var serverVersion = MilestoneConnection.Instance.CurrentSite.Properties["ServerVersion"];
            RequiredVersion.Validate(Version.Parse(serverVersion));
        }

        public override string ToString()
        {
            return $"[ValidateVmsVersion('{RequiredVersion}')]";
        }
    }


    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class RequiresVmsFeatureAttribute : Attribute, IVmsRequirementValidator, IDescriptive
    {
        public string Feature { get; }

        public string Description
        {
            get
            {
                return $"Requires VMS feature \"{Feature}\"";
            }
        }

        public string Source { get; set; }

        public RequiresVmsFeatureAttribute(string feature)
        {
            Feature = feature;
        }

        public void Validate()
        {
            if (MilestoneConnection.Instance == null)
            {
                throw new VmsNotConnectedException($"You are not connected to a Milestone VMS. Use Connect-Vms to login.{(string.IsNullOrWhiteSpace(Source) ? string.Empty : $" Source: {Source}.")}");
            }

            if (!MilestoneConnection.Instance.SystemLicense.IsFeatureEnabled(Feature))
            {
                throw new VmsFeatureNotAvailableException($"The required feature is not available on your VMS: {Feature}.{(string.IsNullOrWhiteSpace(Source) ? string.Empty : $" Source: {Source}.")}", Feature);
            }
        }

        public override string ToString()
        {
            return $"[RequiresVmsFeature('{Feature}')]";
        }
    }

    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = true)]
    public class ValidateVmsFeatureAttribute : ValidateArgumentsAttribute, IDescriptive
    {
        public string Feature { get; }

        public string Description
        {
            get
            {
                return $"Requires VMS feature \"{Feature}\"";
            }
        }

        public ValidateVmsFeatureAttribute(string feature)
        {
            Feature = feature;
        }
        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            if (!MilestoneConnection.Instance.SystemLicense.IsFeatureEnabled(Feature))
            {
                throw new VmsFeatureNotAvailableException($"The required feature is not available on your VMS: {Feature}.", Feature);
            }
        }

        public override string ToString()
        {
            return $"[ValidateVmsFeature('{Feature}')]";
        }
    }

    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class RequiresVmsConnectionAttribute : Attribute, IVmsRequirementValidator, IDescriptive
    {
        public bool AutoConnect { get; set; }
        public bool ConnectionRequired { get; set; }
        public string Source { get; set; }

        public string Description
        {
            get
            {
                if (ConnectionRequired)
                {
                    return $"Requires VMS connection{(AutoConnect ? " and will attempt to connect automatically" : string.Empty)}";
                }
                return $"Does not require a VMS connection";
            }
        }

        public RequiresVmsConnectionAttribute()
        {
            ConnectionRequired = true;
            AutoConnect = true;
        }
        public RequiresVmsConnectionAttribute(bool connectionRequired)
        {
            ConnectionRequired = connectionRequired;
            AutoConnect = true;
        }

        public RequiresVmsConnectionAttribute(bool connectionRequired, bool autoConnect)
        {
            ConnectionRequired = connectionRequired;
            AutoConnect = autoConnect;
        }

        public void Validate()
        {
            if (ConnectionRequired && MilestoneConnection.Instance == null)
            {
                Exception innerException = null;
                if (AutoConnect)
                {

                    using (var shell = PowerShell.Create(RunspaceMode.CurrentRunspace))
                    {
                        try
                        {
                            var result = shell.AddCommand("Connect-Vms").AddParameter("NoProfile", true).AddParameter("ErrorAction", ActionPreference.Stop).Invoke<VideoOS.Platform.ConfigurationItems.ManagementServer>();
                            foreach (var errorRecord in shell.Streams.Error)
                            {
                                throw errorRecord.Exception;
                            }
                        }
                        catch (Exception ex)
                        {
                            EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
                            innerException = ex;
                        }
                    }
                }

                if (MilestoneConnection.Instance == null)
                {
                    throw new VmsNotConnectedException($"You are not connected to a Milestone VMS. Use Connect-Vms to login.{(string.IsNullOrWhiteSpace(Source) ? string.Empty : $" Source: {Source}.")}", innerException);
                }
            }
        }

        public override string ToString()
        {
            return $"[RequiresVmsConnection(ConnectionRequired = ${ConnectionRequired.ToString().ToLower()}, AutoConnect = ${AutoConnect.ToString().ToLower()})]";
        }
    }

    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class RequiresVmsWindowsUserAttribute : Attribute, IVmsRequirementValidator, IDescriptive
    {
        public string Source { get; set; }

        public string Description => "Requires a VMS connection using a Windows, or Active Directory user account.";

        public RequiresVmsWindowsUserAttribute() {}

        public void Validate()
        {
            if (MilestoneConnection.Instance == null)
            {
                // No error if not connected at all. You must use RequiresVmsConnection for that.
                return;
            }

            var site = MilestoneConnection.Instance.CurrentSite;
            var loginSettings = VideoOS.Platform.Login.LoginSettingsCache.GetLoginSettings(site.FQID.ObjectId);
            
            if (loginSettings.IsBasicUser)
            {
                throw new VmsNotConnectedException($"You logged in as {loginSettings.UserName} using a basic user, but a Windows user is required.");
            }
            if (loginSettings.IsOAuthIdentity)
            {
                throw new VmsNotConnectedException($"You logged in as {loginSettings.UserName} using an external identity provider, but a Windows user is required.");
            }
        }

        public override string ToString() => $"[RequiresVmsWindowsUser()]";
    }

    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class RequiresElevationAttribute : Attribute, IVmsRequirementValidator, IDescriptive
    {
        public RequiresElevationAttribute() { }
        public string Description { get; } = "Requires elevated privileges (run as Administrator)";
        public string Source { get; set; }
        public void Validate()
        {
            var principal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
            if (!principal.IsInRole(WindowsBuiltInRole.Administrator))
            {
                throw new AdminElevationRequiredException($"Elevation is required. Re-run the command in a PowerShell session with elevated privileges.{(string.IsNullOrWhiteSpace(Source) ? string.Empty : $" Source: {Source}.")}");
            }
        }

        public override string ToString()
        {
            return "[RequiresElevation()]";
        }
    }

    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = false)]
    public class ValidateVmsItemTypeAttribute : ValidateArgumentsAttribute, IDescriptive
    {
        private readonly Dictionary<string, string> _itemTypes = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        public string Description
        {
            get
            {
                return $"Allowed item types: {string.Join(", ", _itemTypes.Keys)}";
            }
        }

        public ValidateVmsItemTypeAttribute(params string[] itemTypes)
        {
            foreach (var itemType in itemTypes)
            {
                _itemTypes.Add(itemType, null);
            }
        }

        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            if (arguments is IEnumerable<object> argumentArray) {
                foreach (var element in argumentArray)
                {
                    Validate(element, engineIntrinsics);
                }
                return;
            }
            
            string itemType;
            if (arguments is IConfigurationItem strongTypedItem)
            {
                itemType = new ConfigurationItemPath(strongTypedItem.Path).ItemType;
            }
            else if (arguments is ConfigurationItem weakTypedItem)
            {
                itemType = new ConfigurationItemPath(weakTypedItem.Path).ItemType;
            }
            else if (arguments is string path)
            {
                itemType = new ConfigurationItemPath(path).ItemType;
            }
            else {
                throw new ArgumentException($"{nameof(ValidateVmsItemTypeAttribute)} may only be applied to arguments of type string, IConfigurationItem or ConfigurationItem.", arguments.GetType().FullName);
            }
            
            if (!_itemTypes.ContainsKey(itemType))
            {
                throw new VmsItemTypeValidationException($"Invalid item type '{itemType}'. Expected one of '{string.Join("', '", _itemTypes.Keys)}'.", _itemTypes.Keys, itemType);
            }
        }

        public override string ToString()
        {
            return $"[ValidateVmsItemType('{string.Join("', '", _itemTypes.Keys)}')]";
        }
    }

    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = false)]
    public class ValidateTimeSpanRangeAttribute : ValidateArgumentsAttribute, IDescriptive
    {
        public string Description
        {
            get
            {
                return $"Minimum: {MinRange:c}, Maximum: {MaxRange:c}";
            }
        }

        public TimeSpan MinRange { get; }
        public TimeSpan MaxRange { get; }

        public ValidateTimeSpanRangeAttribute(TimeSpan minRange, TimeSpan maxRange)
        {
            if (minRange == null)
            {
                throw new ArgumentNullException(nameof(minRange));
            }
            if (maxRange == null)
            {
                throw new ArgumentNullException(nameof(maxRange));
            }
            if (minRange > maxRange) {
                throw new ArgumentException("The value of maxRange is less than the value of minRange.", nameof(maxRange));
            }
            MinRange = minRange;
            MaxRange = maxRange;
        }

        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            if (!(arguments is TimeSpan)) {
                throw new ArgumentException($"{nameof(ValidateTimeSpanRangeAttribute)} may only be applied to arguments of type {typeof(TimeSpan).FullName}.", arguments.GetType().FullName);
            }
            var ts = (TimeSpan)arguments;
            if (ts < MinRange) {
                throw new ArgumentException($"The TimeSpan value {ts:c} is less than the {nameof(MinRange)} value {MinRange:c}.", nameof(MinRange));
            }
            if (ts > MaxRange) {
                throw new ArgumentException($"The TimeSpan value {ts:c} is greater than the {nameof(MaxRange)} value {MaxRange:c}.", nameof(MaxRange));
            }
        }

        public override string ToString()
        {
            return $"[ValidateTimeSpanRange('{MinRange:c}', '{MaxRange:c}')]";
        }
    }

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = false)]
    public class RequiresInteractiveSessionAttribute : ValidateArgumentsAttribute, IDescriptive, IVmsRequirementValidator
    {
        public string Description
        {
            get
            {
                return $"Requires an interactive PowerShell session.";
            }
        }

        public string Source { get; set; }

        public RequiresInteractiveSessionAttribute() {}

        public void Validate() {
            if (AppDomain.CurrentDomain.FriendlyName.Equals("PowerShell_ISE.exe", StringComparison.CurrentCultureIgnoreCase)) {
                return;
            }
            else if (!UserSession.IsInteractive()) {
                throw new InteractiveSessionRequiredException($"An interactive PowerShell session is required.{(string.IsNullOrWhiteSpace(Source) ? string.Empty : $" Source: {Source}.")}");
            }
        }

        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            Validate();
        }

        public override string ToString()
        {
            return $"[RequiresInteractiveSession()]";
        }
    }

    public class ValidateCoordinatesAttribute : ValidateArgumentsAttribute
    {
        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            if (arguments == null) return;
            if (!(arguments is string coordinate))
            {
                throw new ArgumentException("Coordinates must be provided as a comma-separated list of numbers representing the latitude, and longitude.");
            }

            coordinate.ToGisPoint();
        }
    }
}

