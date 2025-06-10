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

using MilestonePSTools.Telemetry;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.InteropServices;

namespace MilestonePSTools
{
    /// <summary>
    /// Contains the minimum code necessary to import the MIP SDK assemblies and make it possible to call the VideoOS.Platform.SDK.Environment.Login()
    /// </summary>
    public class ModuleInitializer : IModuleAssemblyInitializer
    {
        public static Dictionary<string, Assembly> LoadedAssemblies;

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool SetDllDirectory(string lpPathName);

        /// <summary>
        /// Uses reflection to load all assemblies immediately, and adds an assembly resolver to help do what a binding redirect would normally do for the mismatched Newtonsoft.Json versions.
        /// </summary>
        public void OnImport()
        {
            AddMipSdkDllDirectory();
            AppDomain.CurrentDomain.AssemblyResolve += RedirectToLoadedAssemblies;

            VideoOS.Platform.SDK.Environment.Initialize();
            VideoOS.Platform.SDK.UI.Environment.Initialize();
            VideoOS.Platform.SDK.Log.Environment.Initialize();
            VideoOS.Platform.SDK.Media.Environment.Initialize();
            VideoOS.Platform.SDK.Export.Environment.Initialize();
            
            Module.Initialize();
            AppInsightsTelemetry.SendStartupTelemetry();
        }

        private void AddMipSdkDllDirectory()
        {
            var thisAssembly = this.GetType().Assembly.Location;
            var folder = new FileInfo(thisAssembly).DirectoryName ?? throw new DirectoryNotFoundException($"Could not find the parent directory of {thisAssembly}.");
            SetDllDirectory(folder);
            LoadedAssemblies = new Dictionary<string, Assembly>();
            foreach (var dll in Directory.GetFiles(folder, "*.dll", SearchOption.TopDirectoryOnly))
            {
                var dllFileInfo = new FileInfo(dll);
                if (!MipSdkAssemblies.Managed.Contains(dllFileInfo.Name)) continue;
                var current = Assembly.LoadFile(dll);
                LoadedAssemblies[current.FullName.Split(new[] { ',' })[0]] = current;
            }
        }

        private static Assembly RedirectToLoadedAssemblies(object sender, ResolveEventArgs args)
        {
            var baseName = args.Name.Split(',')[0];
            if (LoadedAssemblies.TryGetValue(baseName, out var assembly))
            {
                return assembly;
            }
            return null;
        }
    }
}

