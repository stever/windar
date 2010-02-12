/*************************************************************************
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * Copyright (C) 2009, 2010 Steven Robertson <steve@playnode.org>
 *
 * Windar: Playdar for Windows
 *
 * Windar is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Windar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ************************************************************************/

using System.Windows.Forms;
using Windar.Common;

namespace Windar.PluginAPI
{
    public interface IPluginHost
    {
        WindarPaths Paths { get; }
        Credentials ScrobblerCredentials { get; set; }
        void AddTabPage(UserControl control, string title);
        void AddConfigurationPage(ConfigTabContent control, string title);
        void ApplyChangesRequiresDaemonRestart();
    }
}
