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
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Windows.Forms;
using VideoOS.Platform;

namespace MilestonePSTools.ConnectionCommands
{
    /// <summary>
    /// <para type="synopsis">Connects to a Milestone XProtect VMS Management Server</para>
    /// <para type="description">The Connect-ManagementServer cmdlet is the first cmdlet used when working
    /// with MilestonePSTools to explore or modify a Milestone XProtect VMS.</para>
    /// <para type="description">Authentication methods include Windows, Active Directory, or Basic users,
    /// and Milestone Federated Architecture is supported when using anything besides Basic authentication.
    /// The state of the session with the Management Server will be maintained in the background for the
    /// duration of the PowerShell session, or until Disconnect-ManagementServer is used.</para>
    /// <para type="description">By default, this cmdlet will only authenticate with the Management Server
    /// provided in the -Server parameter. If child sites need to be accessed during the same session, you
    /// should supply the -IncludeChildSites switch, and use the Select-VmsSite cmdlet to switch between sites</para>
    /// <para type="description">Note: If you do not supply a Credential object, the current Windows user
    /// will be used for authentication automatically.</para>
    /// <example>
    ///     <code>C:\PS>Connect-ManagementServer -ShowDialog</code>
    ///     <para>Prompts the user with a familiar Milestone login dialog to login to the Management Server</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Connect-ManagementServer -ShowDialog -DisableAutoLogin</code>
    ///     <para>Prompts the user with a familiar Milestone login dialog to login to the Management Server and prevents automatic login in case that was used previously isn't wanted now.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Connect-ManagementServer -Server mgtsrv1</code>
    ///     <para>This command authenticates with a server named mgtsrv1 where the server is listening on HTTP port 80, and it uses the current PowerShell user context.</para>
    ///     <para>If you have opened PowerShell normally, as your current Windows user, then the credentials used will be that of your current Windows user.</para>
    ///     <para>If you have opened PowerShell as a different user (shift-right-click, run as a different user), OR you are executing your script as a scheduled task, the user context will be that of whichever user account was used to start the PowerShell session.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Connect-ManagementServer -Server mgtsrv1 -Credential (Get-Credential)</code>
    ///     <para>This command will prompt the user for a username and password, then authenticates with a server named mgtsrv1 where the server is listening on HTTP port 80 using Windows authentication.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// <example>
    ///     <code>C:\PS>Connect-ManagementServer -Server mgtsrv1 -Credential (Get-Credential) -BasicUser</code>
    ///     <para>This command authenticates with a server named mgtsrv1 where the server is listening on HTTPS port 443, and it authenticates a basic user using the credentials supplied in the Get-Credential pop-up</para>
    ///     <para>Note: As a "Basic User", the user will not have access to child sites in a Milestone Federated Architecture and thus the -IncludeChildSites switch will not have any effect.</para>
    ///     <para/><para/><para/>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommunications.Connect, "ManagementServer")]
    [RequiresVmsConnection(false)]
    public class ConnectManagementServer : PSCmdlet
    {
        private bool _connected;

        /// <summary>
        /// <para type="description">Specifies the HTTP/HTTPS server address of the Milestone XProtect Management Server to connect to. Default is [system.net.dns]::GetHostEntry("localhost").HostName</para>
        /// </summary>
        [Parameter(Position = 99, ParameterSetName = "NoLoginDialog")]
        public Uri ServerAddress { get; set; } = new Uri("http://localhost");

        /// <summary>
        /// <para type="description">Deprecated - please use ServerAddress. Specifies, as an IP, hostname, or FQDN, the address of the Milestone XProtect Management Server.</para>
        /// </summary>
        [Parameter(Position = 1, ParameterSetName = "NoLoginDialog")]
        public string Server { get; set; } = "localhost";

        /// <summary>
        /// <para type="description">Deprecated - please use ServerAddress. Specifies, as an integer between 1-65535, the HTTP port of the Management Server. Default is 80.</para>
        /// <para type="description">Note: When using basic authentication and a custom HTTP port on the Management Server, leave this value alone. MIP SDK will automatically use HTTPS on port 443.</para>
        /// </summary>
        [Parameter(ParameterSetName = "NoLoginDialog")]
        [ValidateRange(1, 65535)]
        public int Port { get; set; } = 80;

        /// <summary>
        /// <para type="description">Specifies the username and password of either a Windows/AD or Milestone-specific Basic user. If
        /// the credentials are for a basic user, you must also supply the -BasicUser switch parameter. If this Credential parameter
        /// is omitted, the current Windows user credentials running the PowerShell session will be used by default.</para>
        /// </summary>
        [Parameter(Position = 2, ParameterSetName = "NoLoginDialog")]
        public PSCredential Credential { get; set; }

        /// <summary>
        /// <para type="description">Uses Basic User authentication. Use only to authenticate Basic Users which are users specific to Milestone and do not correspond to a Windows or Active Directory user account.</para>
        /// </summary>
        [Parameter(Position = 5, ParameterSetName = "NoLoginDialog")]
        public SwitchParameter BasicUser { get; set; }

        /// <summary>
        /// <para type="description">Specifies that a secure HTTPS connection is required. Supported on XProtect VMS versions 2021 R1 and newer.</para>
        /// </summary>
        [Parameter(Position = 6, ParameterSetName = "NoLoginDialog")]
        public SwitchParameter SecureOnly { get; set; }

        /// <summary>
        /// <para type="description">Acknowledge you have read and accept the end-user license agreement for the redistributable MIP SDK package</para>
        /// </summary>
        [Parameter(Position = 7)]
        public SwitchParameter AcceptEula { get; set; }

        /// <summary>
        /// <para type="description">Authenticates with the supplied Management Server, and all child Management Servers in a given Milestone Federated Architecture tree.</para>
        /// </summary>
        [Parameter(Position = 8)]
        public SwitchParameter IncludeChildSites { get; set; }

        /// <summary>
        /// <para type="description">Specifies that any existing Management Server connections should be closed before connecting to the specified Management Server</para>
        /// </summary>
        [Parameter(Position = 9)]
        public SwitchParameter Force { get; set; }

        /// <summary>
        /// <para type="description">Shows a familiar Milestone login dialog to enter server address, credentials, credential type, and other options.</para>
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "ShowLoginDialog")]
        [RequiresInteractiveSession()]
        public SwitchParameter ShowDialog { get; set; }

        /// <summary>
        /// <para type="description">Specifies that the login dialog should not login automatically if it had previously been set to do so.</para>
        /// </summary>
        [Parameter(ParameterSetName = "ShowLoginDialog")]
        public SwitchParameter DisableAutoLogin { get; set; }

        /// <summary>
        /// <para type="description">Specifies, as an integer value representing seconds, the maximum timeout value for any Milestone Configuration API operation.</para>
        /// <para type="description">The Configuration API utilizes Windows Communication Foundation to establish a secure communication channel, and provides extensive access to Milestone XProtect VMS configuration elements.</para>
        /// <para type="description">Most operations should complete very quickly, but in some environments it is possible for operations to take several minutes to complete.</para>
        /// <para type="description">Default value is 300 seconds, or 5 minutes.</para>
        /// </summary>
        [Parameter(Position = 10)]
        public int WcfProxyTimeoutSeconds { get; set; } = (int)ChannelSettings.Timeouts.OpenTimeout.TotalSeconds;

        private static void DisconnectManagementServer()
        {
            if (MilestoneConnection.Instance == null) return;
            var ps = PowerShell.Create(RunspaceMode.CurrentRunspace);
            ps.AddCommand("Disconnect-ManagementServer");
            ps.Invoke();
            ps.Dispose();
        }

        /// <summary>
        ///
        /// </summary>
        protected override void ProcessRecord()
        {
            if (MilestoneConnection.Instance != null)
            {
                if (Force)
                {
                    DisconnectManagementServer();
                }
                else
                {
                    ThrowTerminatingError(new ErrorRecord(
                        new InvalidOperationException("Already connected to a Management Server. Include the -Force switch parameter to automatically disconnect from previous sessions."),
                        "Already connected to a Management Server",
                        ErrorCategory.QuotaExceeded,
                        null));
                    return;
                }
            }
            if (!UserAcceptsEula()) return;

            try
            {
                if (ShowDialog)
                {
                    var loginDialog = new VideoOS.Platform.SDK.UI.LoginDialog.DialogLoginForm(HandleLoginResult,
                        MyInvocation.MyCommand.Module.Guid, MyInvocation.MyCommand.Module.Name,
                        MyInvocation.MyCommand.Module.Version.ToString(), MyInvocation.MyCommand.Module.CompanyName);
                    try
                    {
                        loginDialog.Icon = Resources.MilestoneIcon;
                        loginDialog.LoginLogoImage = Resources.LoginDialogHeaderMilestonePSTools;
                        loginDialog.DisableAutoLogin = DisableAutoLogin;
                        loginDialog.TopMost = true;
                        loginDialog.StartPosition = FormStartPosition.CenterScreen;
                        if (loginDialog.Controls.Find("chkSecureOnly", true)?.FirstOrDefault() is CheckBox secureOnlyCheckbox)
                        {
                            if (loginDialog.Controls.Find("cbServerName", true)?.FirstOrDefault() is ComboBox serverNameCombo)
                            {
                                secureOnlyCheckbox.Checked = serverNameCombo.SelectedItem.ToString().ToLower().StartsWith("https");
                                serverNameCombo.TextChanged += (sender, args) => secureOnlyCheckbox.Checked = (sender as ComboBox)?.Text.ToLower().StartsWith("https") ?? false;
                            }
                        }
                        loginDialog.Shown += (sender, args) =>
                        {
                            if (sender is Form form)
                            {
                                form.Activate();
                                DialogHelpers.SetForegroundWindow(form.Handle);
                            }
                        };
                        Application.Run(loginDialog);
                        Application.ThreadException += (sender, args) =>
                        {
                            throw args.Exception;
                        };


                        if (loginDialog.DialogResult != DialogResult.OK)
                        {
                            throw new Exception($"Login dialog cancelled by user");
                        }
                    }
                    finally
                    {
                        loginDialog?.Dispose();
                    }

                    var loginSettings = VideoOS.Platform.Login.LoginSettingsCache.LoginSettings.FirstOrDefault();
                    if (!_connected || loginSettings == null)
                    {
                        throw new VmsNotConnectedException("Failed to connect to Management Server.");
                    }

                    var connection = new MilestoneConnection(loginSettings)
                    {
                        IncludeChildSites = IncludeChildSites,
                        IntegrationId = MyInvocation.MyCommand.Module.Guid,
                        IntegrationName = MyInvocation.MyCommand.Module.Name,
                        IntegrationVersion = MyInvocation.MyCommand.Module.Version.ToString(),
                        ManufacturerName = MyInvocation.MyCommand.Module.CompanyName,
                        SecureOnly = SecureOnly
                    };
                    connection.Open();
                    ConfigApiCmdlet.ClearProxyClientCache();
                    ChannelSettings.Timeouts.AllTimeouts = TimeSpan.FromSeconds(WcfProxyTimeoutSeconds);
                }
                else
                {
                    var uriBuilder = new UriBuilder(ServerAddress)
                    {
                        Scheme = MyInvocation.BoundParameters.ContainsKey(nameof(ServerAddress)) ? ServerAddress.Scheme : "http",
                        Host = MyInvocation.BoundParameters.ContainsKey(nameof(Server)) ? Server : ServerAddress.Host,
                        Port = MyInvocation.BoundParameters.ContainsKey(nameof(ServerAddress)) ? ServerAddress.Port : 80
                    };
                    var uri = uriBuilder.Uri;

                    var loginType = BasicUser
                        ? LoginType.Basic
                        : string.IsNullOrEmpty(Credential?.UserName)
                            ? LoginType.WindowsCurrentUser
                            : LoginType.Windows;
                    var connection = new MilestoneConnection(uri, loginType, Credential?.GetNetworkCredential())
                    {
                        IncludeChildSites = IncludeChildSites,
                        IntegrationId = new Guid(Module.ModuleId),
                        IntegrationName = Module.ModuleName,
                        IntegrationVersion = Module.AssemblyVersion,
                        ManufacturerName = Module.CompanyName,
                        SecureOnly = SecureOnly
                    };
                    connection.Open();
                    ConfigApiCmdlet.ClearProxyClientCache();
                    ChannelSettings.Timeouts.AllTimeouts = TimeSpan.FromSeconds(WcfProxyTimeoutSeconds);
                }
            }
            catch (Exception ex)
            {
                EnvironmentManager.Instance.Log(true, System.Reflection.MethodBase.GetCurrentMethod().Name, ex.ToString());
                DisconnectManagementServer();
                WriteError(
                    new ErrorRecord(
                        ex, ex.Message, ErrorCategory.AuthenticationError, null));
            }
        }

        private void HandleLoginResult(bool connected)
        {
            _connected = connected;
        }

        private bool UserAcceptsEula()
        {
            var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            var file = new FileInfo(Path.Combine(appData, @"MilestonePSTools\user-accepted-eula.txt"));
            if (file.Directory == null || file.DirectoryName == null) throw new DirectoryNotFoundException($"Failed to locate appdata directory for {file.FullName}");
            if (!file.Directory.Exists)
            {
                Directory.CreateDirectory(file.DirectoryName);
            }

            if (file.Exists)
            {
                return true;
            }

            if (AcceptEula)
            {
                File.WriteAllText(file.FullName, string.Empty);
                return true;
            }

            var modulePath = Path.Combine(Path.GetDirectoryName(GetType().Assembly.Location), @"..");
            var eulaPath = Path.Combine(modulePath, "assets\\MIPSDK_EULA.txt");
            WriteError(
                new ErrorRecord(
                    new InvalidOperationException(
                        "Please read and accept the end-user license agreement before using " +
                        "MilestonePSTools. Use -AcceptEula to indicate agreement. This is only " +
                        "required once for the current Windows user."),
                    "AcceptEula",
                    ErrorCategory.InvalidOperation,
                    null));
            Process.Start(eulaPath);
            return false;
        }
    }
}

