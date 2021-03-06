﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using log4net;
using Windar.Common;
using Windar.PluginAPI;

namespace Windar.TrayApp
{
    class PluginHost : IPluginHost
    {
        static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().ReflectedType);

        List<IPlugin> _plugins;
        WindarPaths _paths;

        public List<IPlugin> Plugins
        {
            get { return _plugins; }
            set { _plugins = value; }
        }

        public WindarPaths Paths
        {
            get { return _paths; }
            set { _paths = value; }
        }

        public Credentials ScrobblerCredentials
        {
            get
            {
                return Program.Instance.Config.MainConfig.ScrobblerCredentials;
            }
            set
            {
                Program.Instance.Config.MainConfig.ScrobblerCredentials = value;
                Program.Instance.Config.MainConfig.Save();
            }
        }

        public PluginHost(WindarPaths paths)
        {
            Paths = paths;
        }

        public void Load()
        {
            if (Log.IsDebugEnabled) Log.Debug("Loading plugins.");
            Plugins = GetPlugins<IPlugin>();
            foreach (IPlugin plugin in Plugins)
            {
                // Check for player plugin and ignore it if mplayer is not found.
                string pluginName = plugin.GetType().Name;
                if (Log.IsDebugEnabled) Log.Debug("Found plugin: " + pluginName);
                if (pluginName.Equals("PlayerPlugin") && !Program.Instance.FindMPlayer()) continue;

                plugin.Host = this;
                plugin.Load();

                if (Log.IsDebugEnabled) Log.Debug("Loaded plugin: " + pluginName);
            }
        }

        public List<T> GetPlugins<T>()
        {
            string path = Application.ExecutablePath.Substring(0, Application.ExecutablePath.LastIndexOf('\\'));
            return GetPlugins<T>(path);
        }

        public List<T> GetPlugins<T>(string path)
        {
            if (Log.IsInfoEnabled) Log.Info("Loading plugins.");
            if (Log.IsDebugEnabled) Log.Debug("Plugins path = " + path);
            string[] files = Directory.GetFiles(path, "*Plugin.dll");
            if (Log.IsDebugEnabled) Log.Debug("Plugin count = " + files.Length);
            List<T> list = new List<T>();
            foreach (string file in files)
            {
                Assembly assembly = Assembly.LoadFile(file);
                if (Log.IsDebugEnabled) Log.Debug("Loaded assembly = " + file);
                foreach (Type type in assembly.GetTypes())
                {
                    if (!type.IsClass || type.IsNotPublic) continue;
                    if (!((IList)type.GetInterfaces()).Contains(typeof(T))) continue;
                    try
                    {
                        list.Add((T) Activator.CreateInstance(type));
                        if (Log.IsInfoEnabled) Log.Info("Loaded " + type.Name);
                    }
                    catch (ReflectionTypeLoadException ex)
                    {
                        if (Log.IsErrorEnabled)
                        {
                            StringBuilder sb = new StringBuilder();
                            sb.Append("Loader Exception");
                            foreach (Exception e in ex.LoaderExceptions)
                                sb.Append('\n').Append(e.Message);
                            Log.Error(sb.ToString());
                        }
                    }
                    catch (Exception ex)
                    {
                        if (Log.IsErrorEnabled)
                            Log.Error("Exception when reading plugins.", ex);
                    }
                }
            }
            return list;
        }

        public void Shutdown()
        {
            if (Plugins == null) return;
            foreach (IPlugin plugin in Plugins)
            {
                plugin.Shutdown();
            }
        }

        public void AddTabPage(UserControl control, string title)
        {
            TabPage tab = new TabPage();
            tab.Text = title;
            tab.Controls.Add(control);
            control.Dock = DockStyle.Fill;
            Program.Instance.MainForm.mainTabControl.Controls.Add(tab);

            // Keep the log tab at the end.
            TabControl.TabPageCollection tabs = Program.Instance.MainForm.mainTabControl.TabPages;
            foreach (object page in tabs)
            {
                TabPage tabPage = (TabPage) page;
                if (tabPage.Name != "logTabPage") continue;
                tabs.Remove(tabPage);
                tabs.Add(tabPage);
            }
        }

        public void AddConfigurationPage(ConfigTabContent control, string title)
        {
            TabPage tab = new TabPage();
            tab.Text = title;
            tab.Controls.Add(control);
            tab.BackColor = Color.FromKnownColor(KnownColor.Transparent);
            tab.Padding = new Padding(3);
            control.Dock = DockStyle.Fill;
            Program.Instance.MainForm.optionsTabControl.Controls.Add(tab);
        }

        public void ApplyChangesRequiresDaemonRestart()
        {
            Program.ShowApplyChangesDialog();
        }
    }
}
